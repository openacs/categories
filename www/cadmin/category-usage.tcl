ad_page_contract {

    Show all objects mapped to a category.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    {page:integer,optional 1}
    {orderby:token,optional object_name}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    object_count:onevalue
    page_count:onevalue
    page:onevalue
    orderby:onevalue
    items:onevalue
    info:onerow
    pages:onerow
}

set user_id [auth::require_login]
array set tree [category_tree::get_data $tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

set tree_name [category_tree::get_name $tree_id $locale]
set category_name [category::get_name $category_id $locale]
set page_title "Objects using category \"$category_name\" of tree \"$tree_name\""

set context_bar [category::context_bar $tree_id $locale \
                     [expr {[info exists object_id] ? $object_id : ""}]]
lappend context_bar "\"$category_name\" Usage"

set rows_per_page 20

template::list::create \
    -name items_list \
    -multirow items \
    -key object_id \
    -page_size $rows_per_page \
    -page_groupsize 10 \
    -page_flush_p true \
    -page_query {
        select m.object_id
          from category_object_map m, acs_objects o
         where acs_permission.permission_p(m.object_id, :user_id, 'read') = 't'
           and m.category_id = :category_id
           and o.object_id = m.object_id
        [template::list::orderby_clause -orderby -name items_list]
    } \
    -elements {
	object_name {
	    label "Object Name"
            link_url_col object_url
	    orderby {o.title}
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
    -filters {tree_id {} category_id {}}

# execute query to get the objects on current page
db_multirow -extend {
    object_url
    package_url
} items get_objects_using_category [subst {
      select o.object_id,
             o.title as object_name,
             o.creation_date,
	     (select pretty_name
               from apm_package_types
              where package_key = p.package_key) as package_type,
             o.package_id,
             p.instance_name
        from acs_objects o,
             apm_packages p
       where p.package_id = o.package_id
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
