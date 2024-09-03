ad_page_contract {

    Multi-dimensional browsing of selected category trees.
    Shows a list of all objects mapped to selected categories
    using list template, ad_dimensional and paginator.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    tree_ids:integer,multiple
    {category_ids:integer,multiple,optional ""}
    {page:integer,optional,notnull 1}
    {orderby:token,optional object_name}
    {subtree_p:boolean,optional,notnull f}
    {letter:optional all}
    {join:optional or}
    {package_id:naturalnum,optional ""}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    trees:multirow
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

set user_id [auth::require_login]

set page_title "Browse categories"

set context_bar [list "Browse categories"]
set form_vars [export_vars -form {tree_ids:multiple orderby subtree_p letter package_id}]

set tree_ids [db_list check_permissions_on_trees [subst {
  select t.tree_id
  from category_trees t
  where (
     t.site_wide_p = 't'
     or acs_permission.permission_p(t.tree_id, :user_id, 'category_tree_read')
  )
  and t.tree_id in ([ns_dbquotelist $tree_ids])
}]]

template::multirow create trees tree_id tree_name category_id category_name indent selected_p
template::util::list_to_lookup $category_ids category_selected

# get tree structures and names from the cache
foreach tree_id $tree_ids {
    set tree_name [category_tree::get_name $tree_id]
    foreach category [category_tree::get_tree $tree_id] {
	lassign $category category_id category_name deprecated_p level
	set indent ""
	if {$level>1} {
	    set indent "[string repeat "&nbsp;" [expr {2*$level -4}]].."
	}
	template::multirow append trees \
            $tree_id \
            $tree_name \
            $category_id \
            $category_name \
            $indent \
            [info exists category_selected($category_id)]
    }
}


set dimensional_def {
    {subtree_p "Categorization" f {
	{f "Exact"}
	{t "Include Subcategories"}
    }}
    {letter "Name" all {
        {A "A"}
        {B "B"}
        {C "C"}
        {D "D"}
        {E "E"}
        {F "F"}
        {G "G"}
        {H "H"}
        {I "I"}
        {J "J"}
        {K "K"}
        {L "L"}
        {M "M"}
        {N "N"}
        {O "O"}
        {P "P"}
        {Q "Q"}
        {R "R"}
        {S "S"}
        {T "T"}
        {U "U"}
        {V "V"}
        {W "W"}
        {X "X"}
        {Y "Y"}
        {Z "Z"}
        {other "Other"}
        {all "All"}
    }}
}

set form [ns_getform]
ns_set delkey $form page
ns_set delkey $form button
set dimension_bar [ad_dimensional $dimensional_def categories-browse $form]

set category_ids_length [llength $category_ids]
if {$category_ids_length == 0} {
    set category_clause "(select category_id from categories
                           where tree_id in ([ns_dbquotelist $tree_ids]))"
} else {
    set category_clause ([ns_dbquotelist $category_ids])
}

if {$join eq "and"} {
    # combining categories with and
    if {$subtree_p == "t"} {
	# generate sql for exact categorizations plus subcategories
	set subtree_sql [db_map include_subtree_and]
    } else {
	# generate sql for exact categorization
	set subtree_sql [db_map exact_categorization_and]
    }
} else {
    # combining categories with or
    if {$subtree_p == "t"} {
	# generate sql for exact categorizations plus subcategories
	set subtree_sql [db_map include_subtree_or]
    } else {
	# generate sql for exact categorization
	set subtree_sql [db_map exact_categorization_or]
    }
}

set rows_per_page 20

template::list::create \
    -name items_list \
    -multirow items \
    -key object_id \
    -page_size $rows_per_page \
    -page_groupsize 10 \
    -page_flush_p true \
    -page_query {
        select n.object_id
          from acs_objects n, ($subtree_sql) s
         where n.object_id = s.object_id
           and acs_permission.permission_p(n.object_id, :user_id, 'read')
           and (:package_id is null or n.package_id = :package_id)
           and (:letter = 'all' or
                (:letter = 'other' and (upper(n.title) < 'A' or upper(n.title) > 'Z')) or
                upper(n.title) like :letter || '%'
               )
        [template::list::orderby_clause -orderby -name items_list]
    } \
    -elements {
	object_name {
	    label "Object Name"
            link_url_col object_url
	    orderby {n.title}
	}
	instance_name {
	    label "Package"
            link_url_col package_url
	    html {align right}
	}
	package_type {
	    label "Package Type"
	    html {align right}
	}
	creation_date {
	    label "Creation Date"
	    html {align right}
	}
    } \
    -filters {subtree_p {} letter {} tree_ids {}}


# execute query to get the objects on current page
db_multirow -extend {
    object_url
    package_url
} items get_categorized_objects [subst {
    select n.object_id,
           n.title as object_name,
           n.creation_date,
           t.pretty_name as package_type,
           n.package_id,
           p.instance_name
      from acs_objects n,
           apm_packages p,
           apm_package_types t
     where p.package_id = n.package_id
       and t.package_key = p.package_key
       [template::list::page_where_clause -name items_list -and]
       [template::list::orderby_clause -orderby -name items_list]
}] {
    set object_url /o/${object_id}
    set package_url /o/${package_id}
}

set object_count [template::list::get_rowcount -name items_list]
set page_count [expr {int($object_count / $rows_per_page) + 1}]


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
