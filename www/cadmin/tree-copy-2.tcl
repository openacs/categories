ad_page_contract {

    This page copies a category tree into another category tree

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer
    source_tree_id:integer
    {locale ""}
    object_id:integer,optional
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

category_tree::copy -source_tree $source_tree_id -dest_tree $tree_id

ad_returnredirect "tree-view?[export_url_vars tree_id locale object_id]"
