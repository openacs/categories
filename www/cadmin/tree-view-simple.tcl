ad_page_contract {

    Display a simple view of a category tree.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    source_tree_id:integer
    target_tree_id:integer
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree:multirow
}

set user_id [ad_maybe_redirect_for_registration]
set tree_id $source_tree_id

array set target_tree [category_tree::get_data $target_tree_id $locale]
set target_tree_name $target_tree(tree_name)

if {$target_tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

array set one_tree [category_tree::get_data $tree_id $locale]
set tree_name $one_tree(tree_name)

set page_title "Simplified tree view"

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $target_tree_name] [list [export_vars -base tree-copy [list [list tree_id $target_tree_id] locale object_id]] "Copy a tree"] "View \"$tree_name\""

template::multirow create tree category_name deprecated_p level left_indent

foreach category [category_tree::get_tree -all $tree_id $locale] {
    util_unlist $category category_id category_name deprecated_p level

    template::multirow append tree $category_name $deprecated_p $level [category::repeat_string "&nbsp;" [expr ($level-1)*5]]
}

template::list::create \
    -name tree \
    -no_data "None" \
    -elements {
	category_name {
	    label "Name"
	    display_template {
		@tree.left_indent;noquote@ @tree.category_name@
	    }
	}
    }

ad_return_template
