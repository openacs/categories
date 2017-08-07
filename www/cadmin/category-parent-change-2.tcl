ad_page_contract {

    Changes the parent category of a category.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:naturalnum,notnull
    category_id:naturalnum,notnull
    {parent_id:naturalnum,optional [db_null]}
    {locale ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

permission::require_permission -object_id $tree_id -privilege category_tree_write

category::change_parent -tree_id $tree_id -category_id $category_id -parent_id $parent_id

ad_returnredirect [export_vars -no_empty -base tree-view {tree_id locale object_id ctx_id}]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
