ad_page_contract {
    Phases a category in/out.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer,multiple
    {phase_out_p:integer 1}
    {locale ""}
    object_id:integer,optional
} 

permission::require_permission -object_id $tree_id -privilege category_tree_write

if { $phase_out_p } {
    db_transaction {
	foreach id $category_id {
	    category::phase_out $id
	}
    }
    category_tree::flush_cache $tree_id
} else {
    db_transaction {
	foreach id $category_id {
	    category::phase_in $id
	}
    }
    category_tree::flush_cache $tree_id
}

ad_returnredirect [export_vars -base tree-view { tree_id locale object_id }]
