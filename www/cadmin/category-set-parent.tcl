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
    tree:multirow
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set page_title "Choose a parent category"
set context_bar [category::context_bar $tree_id $locale [value_if_exists object_id]]
lappend context_bar "Choose parent"


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
    template::multirow append tree $category_name $category_id $deprecated_p $level [string repeat "&nbsp;" [expr ($level-1)*5]] $parent_url
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
