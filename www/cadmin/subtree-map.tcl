ad_page_contract {

    Map a subtree to a package (or object)

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    source_tree_id:integer,notnull
    category_id:integer,notnull
    {locale ""}
    object_id:integer,notnull
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $object_id -privilege admin

array set tree [category_tree::get_data $source_tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $source_tree_id -privilege category_tree_read
}

category_tree::map -tree_id $source_tree_id -subtree_category_id $category_id -object_id $object_id

ad_returnredirect "one-object?[export_url_vars locale object_id]"
