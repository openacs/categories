ad_page_contract {

    Multi-dimensional browsing of selected category trees.
    Shows a list of all objects mapped to selected categories
    using ad_table, ad_dimensional and paginator.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_ids:integer,multiple
    {category_ids:integer,multiple,optional ""}
    {page:integer,optional 1}
    {orderby:optional object_name}
    {subtree_p:optional f}
    {letter:optional all}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    trees:multirow
    url_vars:onevalue
    form_vars:onevalue
    object_count:onevalue
    page_count:onevalue
    page:onevalue
    orderby:onevalue
    items:onevalue
    dimension_bar:onevalue
    info:onerow
    pages:onerow
}

set user_id [ad_maybe_redirect_for_registration]

set page_title "Browse categories"

set context_bar [list "Browse categories"]
set url_vars [export_url_vars tree_ids:multiple category_ids:multiple subtree_p letter]
set form_vars [export_form_vars tree_ids:multiple orderby subtree_p letter]

set tree_ids [db_list check_permissions_on_trees [subst {
    select tree_id
    from category_trees
    where (site_wide_p = 't'
    or acs_permission.permission_p(tree_id, :user_id, 'category_tree_read') = 't')
    and tree_id in ([join $tree_ids ,])
}]]

template::multirow create trees tree_id tree_name category_id category_name indent selected_p
template::util::list_to_lookup $category_ids category_selected

# get tree structures and names from the cache
foreach tree_id $tree_ids {
    set tree_name [category_tree::get_name $tree_id]
    foreach category [category_tree::get_tree $tree_id] {
	util_unlist $category category_id category_name deprecated_p level
	set indent ""
	if {$level>1} {
	    set indent "[category::repeat_string "&nbsp;" [expr 2*$level -4]].."
	}
	template::multirow append trees $tree_id $tree_name $category_id $category_name $indent [info exists category_selected($category_id)]
    }
}

set table_def {
    {object_name "Object Name" {upper(n.object_name) $order} {<td><a href="/o/$object_id">$object_name</a></td>}}
    {instance_name "Package" {} {<td align=right><a href="/o/$package_id">$instance_name</a></td>}}
    {package_type "Package Type" {} r}
    {creation_date "Creation Date" {} r}
}

set order_by_clause [ad_order_by_from_sort_spec $orderby $table_def]

set dimensional_def {
    {subtree_p "Categorization" f {
	{f "Exact"}
	{t "Include Subcategories"}
    }}
    {letter "Name" all {{A "A"} {B "B"} {C "C"} {D "D"} {E "E"} {F "F"} {G "G"} {H "H"} {I "I"} {J "J"} {K "K"} {L "L"} {M "M"} {N "N"} {O "O"} {P "P"} {Q "Q"} {R "R"} {S "S"} {T "T"} {U "U"} {V "V"} {W "W"} {X "X"} {Y "Y"} {Z "Z"} {other "Other"} {all "All"}
    }}
}

set form [ns_getform]
ns_set delkey $form page
ns_set delkey $form button
set dimension_bar [ad_dimensional $dimensional_def categories-browse $form]

# generate sql for selecting object names beginning with selected letter
switch -exact $letter {
    other {
	set letter_sql "and (upper(n.object_name) < 'A' or upper(n.object_name) > 'Z')"
    }
    all {
	set letter_sql ""
    }
    default {
	set bind_letter "$letter%"
	set letter_sql "and upper(n.object_name) like :bind_letter"
    }
}

set category_ids_length [llength $category_ids]
if {$subtree_p == "t"} {
    # generate sql for exact categorizations plus subcategories
    set subtree_sql {
	select v.object_id
	from (select distinct m.object_id, c.category_id
	      from category_object_map m, categories c, category_temp t
	      where c.category_id = t.category_id
	      and m.category_id in (select c_sub.category_id
				    from categories c_sub
				    where c_sub.tree_id = c.tree_id
				    and c_sub.left_ind >= c.left_ind
				    and c_sub.left_ind < c.right_ind)) v
	group by v.object_id having count(*) = :category_ids_length
    }
} else {
    # generate sql for exact categorization
    set subtree_sql {
	select m.object_id
	from category_object_map m, category_temp t
	where acs_permission.permission_p(m.object_id, :user_id, 'read') = 't'
	and m.category_id = t.category_id
	group by m.object_id having count(*) = :category_ids_length
    }
}

# query to get the number of pages, number of objects etc used by the paginator
set count_query [subst {
    select n.object_id
    from acs_named_objects n, ($subtree_sql) s
    where n.object_id = s.object_id
    $letter_sql
}]

# paginated query to get the actual objects
set paginated_query [subst {
    select r.*
    from (select n.object_id, n.object_name as object_name, o.creation_date,
	         t.pretty_name as package_type, n.package_id, p.instance_name,
                 row_number() over ($order_by_clause) as row_number
	  from acs_objects o, acs_named_objects n, apm_packages p, apm_package_types t,
               ($subtree_sql) s
	  where n.object_id = s.object_id
	  and o.object_id = n.object_id
	  and p.package_id = n.package_id
	  and t.package_key = p.package_key
	  $letter_sql
	  $order_by_clause) r
    where r.row_number between :first_row and :last_row
}]

set p_name "browse_categories"
request create
request set_param page -datatype integer -value 1

db_transaction {
    # use temporary table to use only bind vars in queries
    foreach category_id $category_ids {
	db_dml insert_tmp_categories {
	    insert into category_temp
	    values (:category_id)
	}
    }

    # execute query to count objects and pages
    paginator create get_categorized_object_count $p_name $count_query -pagesize 20 -groupsize 10 -contextual -timeout 0
    set first_row [paginator get_row $p_name $page]
    set last_row [paginator get_row_last $p_name $page]

    # execute query to get the objects on current page
    set items [ad_table -Torderby $orderby get_categorized_objects $paginated_query $table_def]
}

paginator get_display_info $p_name info $page
set group [paginator get_group $p_name $page]
paginator get_context $p_name pages [paginator get_pages $p_name $group]
paginator get_context $p_name groups [paginator get_groups $p_name $group 10]

set object_count [paginator get_row_count $p_name]
set page_count [paginator get_page_count $p_name]

ad_return_template
