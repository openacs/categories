ad_page_contract {

    Display a category tree

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer,notnull
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    tree_name:onevalue
    tree_description:onevalue
    context_bar:onevalue
    locale:onevalue
    one_tree:multirow
    form_vars:onevalue
    url_vars:onevalue
    can_grant_p:onevalue
    can_write_p:onevalue
}

set user_id [ad_maybe_redirect_for_registration]

array set tree [category_tree::get_data $tree_id $locale]
if {$tree(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

set url_vars [export_vars {tree_id locale object_id}]
set form_vars [export_form_vars tree_id locale object_id]

set tree_name $tree(tree_name)
set tree_description $tree(description)

set page_title "Category Tree \"$tree_name\""
if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"] $tree_name]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"] $tree_name]
}

set can_write_p [permission::permission_p -object_id $tree_id -privilege category_tree_write]
set can_grant_p [permission::permission_p -object_id $tree_id -privilege category_tree_grant_permissions]

template::multirow create one_tree category_name sort_key category_id deprecated_p level left_indent

set sort_key 0

foreach category [category_tree::get_tree -all $tree_id $locale] {
    util_unlist $category category_id category_name deprecated_p level
    incr sort_key 10

    template::multirow append one_tree $category_name $sort_key $category_id $deprecated_p $level [category::repeat_string "&nbsp;" [expr ($level-1)*5]]
}



#----------------------------------------------------------------------
# List builder
#----------------------------------------------------------------------

multirow extend one_tree edit_url delete_url usage_url set_parent_url add_child_url phase_in_url phase_out_url
multirow foreach one_tree {
    set usage_url [export_vars -base category-usage { category_id tree_id locale object_id }]
    if { $can_write_p } {
	set edit_url [export_vars -base category-form { category_id tree_id locale object_id }]
	set delete_url [export_vars -base category-delete { category_id tree_id locale object_id }]
	set set_parent_url [export_vars -base category-set-parent { category_id tree_id locale object_id }]
	set add_child_url [export_vars -base category-form { { parent_id $category_id } tree_id locale object_id }]
	if { [template::util::is_true $deprecated_p] } {
	    set phase_in_url [export_vars -base category-phase-out { category_id { phase_out_p 0 } tree_id locale object_id }]
	} else {
	    set phase_out_url [export_vars -base category-phase-out { category_id { phase_out_p 1 } tree_id locale object_id }]
	}
    }
}

set elements [list]

if { $can_write_p } {
    lappend elements edit {
	sub_class narrow
	display_template {
	    <img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="Edit" border="0">
	}
	link_url_col edit_url
    }
}

lappend elements category_name {
    label "Category"
    display_template {
	@one_tree.left_indent;noquote@<a href="@one_tree.usage_url@" title="Show usage of this category">@one_tree.category_name@</a>
	<if @one_tree.deprecated_p@ true>(Deprecated - <a href="@one_tree.phase_in_url@">Restore</a>)</if>
    }
}

if { $can_write_p } {
    lappend elements add_child {
	sub_class narrow
	display_template {
	    <img src="/resources/acs-subsite/Add16.gif" height="16" width="16" alt="Add" border="0">
	}
	link_url_col add_child_url
	link_html { title "Add subcategory" }
    }
    lappend elements sort_key {
	label "Ordering"
	display_template {
	    <input name="sort_key.@one_tree.category_id@" value="@one_tree.sort_key@" size="8">
	}
    }
    lappend elements actions {
	label "Actions"
	display_template {
	    <if @one_tree.set_parent_url@ not nil><a href="@one_tree.set_parent_url@">Choose a new parent</a></if>
	}
    }

    lappend elements delete {
	sub_class narrow
	display_template {
	    <img src="/resources/acs-subsite/Delete16.gif" height="16" width="16" alt="Delete" border="0">
	}
	link_url_col delete_url
	link_html { title "Delete category and all subcategories" }
    }
}

set actions [list]
set bulk_actions [list]
if { $can_write_p } {
    set bulk_actions {
	"Delete" "category-delete" "Delete checked categories"
	"Deprecate" "category-phase-out" "Deprecate checked categories"
	"Restore" "category-phase-in" "Restore checked categories"
	"Update ordering" "tree-order-update" "Update ordering from values in list"
    }
    set actions [list \
		     "Add root category" [export_vars -base category-form { tree_id locale object_id }] "Add category at the root level" \
		     "Copy tree" [export_vars -base tree-copy { tree_id locale object_id }] "Copy categories from other tree" \
		     "Delete tree" [export_vars -base tree-delete { tree_id locale object_id }] "Delete this category tree" \
		     "Applications" [export_vars -base tree-usage { tree_id locale object_id }] "Applications using this tree"]

    if { $can_grant_p } {
	lappend actions "Permissions" [export_vars -base permission-manage { tree_id locale object_id }] "Manage permissions for tree"
    }

}

template::list::create \
    -name one_tree \
    -elements $elements \
    -key category_id \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars { tree_id locale object_id }

ad_return_template
