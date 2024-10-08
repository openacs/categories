ad_page_contract {

    This page shows all the package instances mapped to a particular category tree.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree_name:onevalue
    tree_description:onevalue
    modules:multirow
    instances_without_permission:onevalue
}

set user_id [auth::require_login]

array set tree [category_tree::get_data $tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

set tree_name $tree(tree_name)
set tree_description $tree(description)
set page_title [_ categories.Usage_title]

set context_bar [category::context_bar $tree_id $locale \
                     [expr {[info exists object_id] ? $object_id : ""}] \
                     [expr {[info exists ctx_id] ? $ctx_id : ""}]]
lappend context_bar [_ categories.Usage]


template::multirow create modules package object_id object_name package_id instance_name read_p unmap_url

set instance_list [category_tree::usage $tree_id]

set instances_without_permission 0
foreach instance $instance_list {
    lassign $instance package object_id object_name package_id instance_name read_p
    set unmap_url [export_vars -no_empty -base tree-unmap {tree_id object_id ctx_id}]

    if {$read_p == "t"} {
        template::multirow append modules $package $object_id $object_name $package_id $instance_name $read_p $unmap_url
    } else {
        incr instances_without_permission
    }
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
