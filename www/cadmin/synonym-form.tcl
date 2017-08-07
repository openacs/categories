ad_page_contract {

    Form to add/edit a synonym.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    synonym_id:naturalnum,optional
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} -properties {
    context_bar:onevalue
    page_title:onevalue
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set tree_name [category_tree::get_name $tree_id $locale]
set category_name [category::get_name $category_id $locale]

if {[info exists synonym_id]} {
    set action "Edit"
} else {
    set action "Add"
}
set page_title "$action category synonym of \"$tree_name :: $category_name\""

set context_bar [category::context_bar $tree_id $locale \
                     [value_if_exists object_id] \
                     [value_if_exists ctx_id]]

lappend context_bar [list [export_vars -no_empty -base synonyms-view { category_id tree_id locale object_id ctx_id}] "Synonyms of $category_name"] "$action synonym"


set languages [lang::system::get_locale_options]

ad_form -name synonym_form -action synonym-form -export { category_id tree_id locale object_id ctx_id} -form {
    {synonym_id:key(category_synonyms_id_seq)}
    {name:text {label "Name"} {html {size 50 maxlength 200}}}
    {language:text(select) {label "Language"} {options $languages}}
} -new_request {
    set name ""
    if { [ad_conn locale] ne ""} {
	set language [ad_conn locale]
    } else {
	set language [parameter::get -parameter DefaultLocale -default en_US]
    }
} -edit_request {
    db_1row get_synonym ""
} -new_data {
    category_synonym::add -name $name -locale $language -category_id $category_id -synonym_id $synonym_id
} -edit_data {
    category_synonym::edit -name $name -locale $language -synonym_id $synonym_id
} -after_submit {
    ad_returnredirect [export_vars -no_empty -base synonyms-view {category_id tree_id locale object_id ctx_id}]
    ad_script_abort
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
