ad_page_contract {

    Deletes a category

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
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
    form_vars:onevalue
    mapped_objects_p:onevalue
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set category_name [category::get_name $category_id $locale]
array set tree [category_tree::get_data $tree_id $locale]
set tree_name $tree(tree_name)

set mapped_objects_p [db_string check_mapped_objects ""]
    
set form_vars [export_form_vars tree_id category_id locale object_id]
set page_title "Delete category \"$category_name\""

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list "one-object?[export_url_vars locale object_id]" "Category Management"]]
} else {
    set context_bar [list [list ".?[export_url_vars locale]" "Category Management"]]
}
lappend context_bar [list "tree-view?[export_url_vars tree_id locale object_id]" $tree_name] "Delete \"$category_name\""

ad_return_template 
