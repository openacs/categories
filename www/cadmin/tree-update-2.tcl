ad_page_contract {
    Bulk delete of categories.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    category_ids:integer,multiple
    tree_id:integer
    {locale ""}
    object_id:integer,optional
}

permission::require_permission -object_id $tree_id -privilege category_tree_write

set list_of_errors ""

db_transaction {
    # use temporary table to use only bind vars in queries
    foreach category_id $category_ids {
	db_dml insert_tmp_categories ""
    }

    # delete first leaf categories, then parent categories
    set category_list [db_list sort_categories_to_delete ""]

    foreach category_id $category_list {
	category::delete -batch_mode $category_id
    }
    category::reset_translation_cache
    category_tree::flush_cache $tree_id
} on_error {
    append list_of_errors "<li> Node [category::get_name $category_id $locale] contains leaf (child) categories. If you really want to delete those leaf categories, plesae delete them first"	
}
db_dml delete_tmp_category_trees ""
    
if { [llength $list_of_errors] > 0 } {
    ad_return_complaint [llength $list_of_errors] "Error Deleting Nodes: $list_of_errors"
    return
}

ad_returnredirect [export_vars -base tree-view {tree_id locale object_id}]
