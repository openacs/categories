ad_page_contract {

    Changes the parent category of a category.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    {parent_id:integer,optional [db_null]}
    {locale ""}
    object_id:integer,optional
}

permission::require_permission -object_id $tree_id -privilege category_tree_write

category::change_parent -tree_id $tree_id -category_id $category_id -parent_id $parent_id

ad_returnredirect "tree-view?[export_url_vars tree_id locale object_id]"
