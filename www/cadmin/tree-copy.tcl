ad_page_contract {

    Let the user select a category tree which will be copied into the current category tree

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    trees:multirow
    tree_id:onevalue
    url_vars:onevalue
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set url_vars [export_vars {locale object_id}]
set page_title "Choose a tree to copy"
array set tree [category_tree::get_data $tree_id $locale]
set tree_name $tree(tree_name)

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $tree_name] "Copy a tree"

template::multirow create trees tree_id tree_name site_wide_p

db_foreach trees_select "" {
    if {$site_wide_p == "t" || $has_read_p == "t"} {
	set source_tree_name [category_tree::get_name $source_tree_id $locale]
	template::multirow append trees $source_tree_id $source_tree_name $site_wide_p
    }
}

ad_return_template
