ad_page_contract {
    Phases a category in/out.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    phase_out_p:integer
    {locale ""}
    object_id:integer,optional
} 

permission::require_permission -object_id $tree_id -privilege category_tree_write

if {$phase_out_p} {
    category::phase_out $category_id
    category_tree::flush_cache $tree_id
} else {
    category::phase_in $category_id
    category_tree::flush_cache $tree_id
}

ad_returnredirect "tree-view?[export_url_vars tree_id locale object_id]"
