ad_page_contract {

    Show all objects mapped to a category.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    category_id:integer
    tree_id:integer
    {locale ""}
    object_id:integer,optional
    {page:integer,optional 1}
    {orderby:optional object_name}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    url_vars:onevalue
    object_count:onevalue
    page_count:onevalue
    page:onevalue
    orderby:onevalue
    items:onevalue
    info:onerow
    pages:onerow
}

set user_id [ad_maybe_redirect_for_registration]
array set tree [category_tree::get_data $tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

set tree_name $tree(tree_name)
set category_name [category::get_name $category_id $locale]
set page_title "Objects using category \"$category_name\" of tree \"$tree_name\""
set url_vars [export_url_vars category_id tree_id locale object_id]

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list "one-object?[export_url_vars locale object_id]" "Category Management"]]
} else {
    set context_bar [list [list ".?[export_url_vars locale]" "Category Management"]]
}
lappend context_bar [list "tree-view?[export_url_vars tree_id locale object_id]" $tree_name] "\"$category_name\" Usage"

set table_def {
    {object_name "Object Name" {upper(n.object_name) $order} {<td><a href="/o/$object_id">$object_name</a></td>}}
    {instance_name "Package" {} {<td align=right><a href="/o/$package_id">$instance_name</a></td>}}
    {package_type "Package Type" {} r}
    {creation_date "Creation Date" {} r}
}

set order_by_clause [ad_order_by_from_sort_spec $orderby $table_def]

# query to get the number of pages, number of objects etc used by the paginator
set count_query {
    select n.object_id
    from category_object_map m, acs_named_objects n
    where acs_permission.permission_p(m.object_id, :user_id, 'read') = 't'
    and m.category_id = :category_id
    and n.object_id = m.object_id
}

# paginated query to get the actual objects
set paginated_query [subst {
    select r.*
    from (select n.object_id, n.object_name as object_name, o.creation_date,
	         t.pretty_name as package_type, n.package_id, p.instance_name,
                 row_number() over ($order_by_clause) as row_number
	  from acs_objects o, acs_named_objects n, apm_packages p, apm_package_types t,
               category_object_map m
	  where n.object_id = m.object_id
	  and o.object_id = n.object_id
	  and p.package_id = n.package_id
	  and t.package_key = p.package_key
	  and m.category_id = :category_id
	  and acs_permission.permission_p(m.object_id, :user_id, 'read') = 't'
	  $order_by_clause) r
    where r.row_number between :first_row and :last_row
}]

set p_name "category-usage"
request create
request set_param page -datatype integer -value 1

# execute query to count objects and pages
paginator create get_category_usages $p_name $count_query -pagesize 20 -groupsize 10 -contextual -timeout 0
set first_row [paginator get_row $p_name $page]
set last_row [paginator get_row_last $p_name $page]

# execute query to get the objects on current page
set items [ad_table -Torderby $orderby get_objects_using_category $paginated_query $table_def]

paginator get_display_info $p_name info $page
set group [paginator get_group $p_name $page]
paginator get_context $p_name pages [paginator get_pages $p_name $group]
paginator get_context $p_name groups [paginator get_groups $p_name $group 10]

set object_count [paginator get_row_count $p_name]
set page_count [paginator get_page_count $p_name]

ad_return_template
