ad_page_contract {
    Let the user toggle the site-wide status of a category tree.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    object_id:integer,optional
    {locale ""}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    sw_tree_p:onevalue
    admin_p:onevalue
    url_vars:onevalue
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_grant_permissions

array set tree [category_tree::get_data $tree_id $locale]
set tree_name $tree(tree_name)
set page_title "Permission Management for $tree_name"

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $tree_name] "Manage Permissions"

set url_vars [export_vars {tree_id object_id locale}]
set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -privilege category_admin]
set sw_tree_p [ad_decode $tree(site_wide_p) f 0 1]

ad_return_template
