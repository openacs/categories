ad_page_contract {
    
    Let user decide from which category tree to add a category link.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    category_id:integer,notnull
    tree_id:integer,notnull
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    trees:multirow
}

set user_id [ad_maybe_redirect_for_registration]

array set tree [category_tree::get_data $tree_id $locale]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set tree_name $tree(tree_name)
set category_name [category::get_name $category_id $locale]
set page_title "Select target to add a link to category \"$tree(tree_name) :: $category_name\""

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -no_empty -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars -no_empty {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -no_empty -base tree-view {tree_id locale object_id}] $tree_name] [list [export_vars -no_empty -base category-links-view {category_id tree_id locale object_id}] "Links to $category_name"] "Select link target"


template::multirow create trees tree_name tree_id link_add_url

db_foreach get_trees_to_link "" {
    set tree_name [category_tree::get_name $link_tree_id $locale]
    template::multirow append trees $tree_name $link_tree_id \
	[export_vars -no_empty -base category-link-add-2 { link_tree_id category_id tree_id locale object_id }]
}

template::multirow sort trees -dictionary tree_name

template::list::create \
    -name trees \
    -no_data "None" \
    -elements {
	tree_name {
	    label "Name"
	}
	action {
	    label "Action"
	    display_template {
		<a href="@trees.link_add_url@">View tree to add link</a>
	    }
	}
    }

ad_return_template
