ad_page_contract {

    Map a subtree to a package (or object)

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    source_tree_id:integer,notnull
    category_id:integer,notnull
    {locale ""}
    object_id:integer,notnull
    {assign_single_p:optional f}
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $object_id -privilege admin

array set tree [category_tree::get_data $source_tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $source_tree_id -privilege category_tree_read
}

category_tree::map -tree_id $source_tree_id -subtree_category_id $category_id -object_id $object_id -assign_single_p $assign_single_p

ad_returnredirect [export_vars -base one-object {locale object_id}]
