ad_page_contract {
    Reactivates deprecated categories.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:naturalnum,notnull
    category_id:naturalnum,multiple
    {locale ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

permission::require_permission -object_id $tree_id -privilege category_tree_write

db_transaction {
    foreach id $category_id {
	category::phase_in $id
    }
}
category_tree::flush_cache $tree_id

ad_returnredirect [export_vars -no_empty -base tree-view { tree_id locale object_id ctx_id}]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
