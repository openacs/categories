ad_page_contract {

    This page shows all the package instanes mapped to a particular category tree.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer,notnull
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree_name:onevalue
    tree_description:onevalue
    modules:multirow
    instances_without_permission:onevalue
}

set user_id [ad_maybe_redirect_for_registration]

array set tree [category_tree::get_data $tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

set tree_name $tree(tree_name)
set tree_description $tree(description)
set page_title "Modules using Category Tree \"$tree_name\""

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}] "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $tree_name] Usage


template::multirow create modules package object_id object_name package_id instance_name read_p

set instance_list [category_tree::usage $tree_id]

set instances_without_permission 0
foreach instance $instance_list {
    util_unlist $instance package object_id object_name package_id instance_name read_p
    if {$read_p == "t"} {
	template::multirow append modules $package $object_id $object_name $package_id $instance_name $read_p
    } else {
	incr instances_without_permission
    }
}

ad_return_template
