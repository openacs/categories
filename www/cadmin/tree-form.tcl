ad_page_contract {
    Form to add/edit a category tree.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer,optional
    {locale ""}
    object_id:integer,optional
} -properties {
    context_bar:onevalue
    page_title:onevalue
}

set user_id [ad_maybe_redirect_for_registration]
set package_id [ad_conn package_id]

if {[info exists tree_id]} {
    set page_title "Edit tree"
} else {
    set page_title "Add tree"
}

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list "one-object?[export_url_vars locale object_id]" "Category Management"]]
} else {
    set context_bar [list [list ".?[export_url_vars locale]" "Category Management"]]
}
lappend context_bar $page_title

set languages [db_list_of_lists get_ad_locales ""]

ad_form -name tree_form -action tree-form -export { locale object_id } -form {
    {tree_id:key}
    {tree_name:text {label "Name"} {html {size 50 maxlength 50}}}
    {language:text(select) {label "Language"} {value $locale} {options $languages}}
    {description:text(textarea),optional {label "Description"} {html {rows 5 cols 80}}}
} -new_request {
    permission::require_permission -object_id $package_id -privilege category_admin
    set tree_name ""
    set description ""
} -edit_request {
    permission::require_permission -object_id $tree_id -privilege category_tree_write
    set action Edit
    util_unlist [category_tree::get_translation $tree_id $locale] tree_name description
} -on_submit {
    set description [util_close_html_tags $description 4000]
} -new_data {
    db_transaction {
	category_tree::add -tree_id $tree_id -name $tree_name -description $description -locale $language -context_id $package_id
	if { [info exists object_id] } {
	    category_tree::map -tree_id $tree_id -object_id $object_id
	    set return_url "one-object?[export_url_vars locale object_id]"
	} else {
	    set return_url ".?[export_url_vars locale]"
	}
    }
} -edit_data {
    category_tree::update -tree_id $tree_id -name $tree_name -description $description -locale $language
    set return_url "tree-view?[export_url_vars tree_id locale object_id]"
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template
