ad_page_contract {

    Adds bidirectional category links

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    link_category_id:naturalnum,multiple
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

db_transaction {
    foreach forward_category_id [db_list check_link_forward_permissions ""] {
	category_link::add -from_category_id $category_id -to_category_id $forward_category_id
    }

    foreach backward_category_id [db_list check_link_backward_permissions ""] {
	category_link::add -from_category_id $backward_category_id -to_category_id $category_id
    }
} on_error {
    ad_return_complaint 1 "Error creating category link."
    return
}

ad_returnredirect [export_vars -no_empty -base category-links-view {category_id tree_id locale object_id ctx_id}]
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
