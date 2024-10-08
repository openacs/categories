ad_page_contract {
    Let the user toggle the site-wide status of a category tree.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    tree_id:naturalnum,notnull
    object_id:naturalnum,optional
    {locale:word ""}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    sw_tree_p:onevalue
    admin_p:onevalue
    url_vars:onevalue
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_grant_permissions

array set tree [category_tree::get_data $tree_id $locale]
set tree_name $tree(tree_name)
set page_title [_ categories.Permissions_manage_title]

set context_bar [category::context_bar $tree_id $locale [expr {[info exists object_id] ? $object_id : ""}]]
lappend context_bar [_ categories.Permissions_manage]

set url_vars [export_vars {tree_id object_id locale}]
set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -privilege category_admin]
set sw_tree_p [expr {$tree(site_wide_p) ne "f"}]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
