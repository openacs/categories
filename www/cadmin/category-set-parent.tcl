ad_page_contract {
    
    Changes the parent category of a category.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree_name:onevalue
    tree:multirow
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

array set one_tree [category_tree::get_data $tree_id $locale]
set tree_name $one_tree(tree_name)

set page_title "Choose a parent node"

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $tree_name] "Choose parent"


set subtree_categories_list [db_list subtree ""]

template::multirow create tree category_name category_id deprecated_p level left_indent parent_url
template::multirow append tree "Root Level" 0 f 0 "" \
    [export_vars -no_empty -base category-set-parent-2 {tree_id category_id locale object_id}]

foreach category [category_tree::get_tree -all $tree_id $locale] {
    util_unlist $category category_id category_name deprecated_p level

    if { [lsearch $subtree_categories_list $category_id]==-1 } {
	set parent_url [export_vars -no_empty -base category-set-parent-2 { {parent_id $category_id} tree_id category_id locale object_id }]
    } else {
	set parent_url ""
    }
    template::multirow append tree $category_name $category_id $deprecated_p $level [category::repeat_string "&nbsp;" [expr ($level-1)*5]] $parent_url
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
	set_parent {
	    label "Action"
	    display_template {
		<if @tree.parent_url@ not nil><a href="@tree.parent_url@">Set parent</a></if>
	    }
	}
    }

ad_return_template
