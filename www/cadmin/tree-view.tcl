ad_page_contract {

    Display a category tree

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
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

set url_vars [export_url_vars tree_id locale object_id]
set form_vars [export_form_vars tree_id locale object_id]

set tree_name $tree(tree_name)
set tree_description $tree(description)

set page_title "Category Tree \"$tree_name\""
if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list "one-object?[export_url_vars locale object_id]" "Category Management"] $tree_name]
} else {
    set context_bar [list [list ".?[export_url_vars locale]" "Category Management"] $tree_name]
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

ad_return_template
