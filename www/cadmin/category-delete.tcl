ad_page_contract {

    Deletes a category

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer,multiple
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

multirow create categories category_id name objects_p

foreach id $category_id {
    multirow append categories \
	$id \
	[category::get_name $id $locale] \
	[db_string check_mapped_objects {}]
}

array set tree [category_tree::get_data $tree_id $locale]
set tree_name $tree(tree_name)

set form_vars [export_vars -form { tree_id category_id:multiple locale object_id }]
set page_title "Delete categories"

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list [export_vars -base one-object {locale object_id}] "Category Management"]]
} else {
    set context_bar [list [list ".?[export_vars {locale}]" "Category Management"]]
}
lappend context_bar [list [export_vars -base tree-view {tree_id locale object_id}] $tree_name] "Delete categories"

ad_return_template 
