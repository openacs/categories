ad_page_contract {

    Deletes a category from a category tree

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    {locale ""}
    object_id:integer,optional
}

permission::require_permission -object_id $tree_id -privilege category_tree_write

db_transaction {
    category::delete $category_id
    category_tree::flush_cache $tree_id
} on_error {
    ad_return_complaint "Error Deleting Node" "<p> This node contains leaf (child) nodes. If you really want to delete those leaf nodes, plesae delete them first. Thank you."
    return
}

ad_returnredirect "tree-view?[export_url_vars tree_id locale object_id]"
