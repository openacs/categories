ad_page_contract {

    This page checks whether the category tree can be deleted and asks for confirmation.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer,notnull
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree_name:onevalue
    tree_description:onevalue
    instances_using_p:onevalue
    delete_url:onevalue
    cancel_url:onevalue
    used_categories:multirow
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

array set tree [category_tree::get_data $tree_id $locale]
set tree_name $tree(tree_name)
set tree_description $tree(description)

set page_title "Delete Category Tree \"$tree_name\""
if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $tree_name] Delete

set instance_list [category_tree::usage $tree_id]

if {[llength $instance_list] > 0} {
    set instances_using_p t
} else {
    set instances_using_p f
}

set delete_url [export_vars -no_empty -base tree-delete-2 {tree_id locale object_id}]
set cancel_url [export_vars -no_empty -base tree-view {tree_id locale object_id}]

template::multirow create used_categories category_id category_name

db_foreach get_category_in_use "" {
    set category_name [category::get_name $category_id $locale]
    template::multirow append used_categories $category_id $category_name
}

template::list::create \
    -name used_categories \
    -no_data "None" \
    -elements {
	category_name {
	    label "Name"
	}
    }

ad_return_template
