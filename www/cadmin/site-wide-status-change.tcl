ad_page_contract {
    Toggle the site-wide status of a category tree.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer
    action:integer
    {locale ""}
    object_id:integer,optional
}

set user_id [ad_maybe_redirect_for_registration]
set package_id [ad_conn package_id]
permission::require_permission -object_id $package_id -privilege category_admin

db_dml site_wide_status {
    update category_trees
    set site_wide_p = decode(:action,'1','t','f')
    where tree_id  = :tree_id
}

ad_returnredirect "permission-manage?[export_url_vars tree_id locale object_id]"
