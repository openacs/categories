ad_page_contract {
    Form to add/edit a category tree.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:naturalnum,optional
    {locale ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} -properties {
    context_bar:onevalue
    page_title:onevalue
}

auth::require_login

if { ![ad_form_new_p -key tree_id] } {
    set page_title "#categories.Edit_tree#"
} else {
    set page_title "#categories.Add_tree#"
}

if { [info exists object_id] } {
    set context_bar [list \
          [category::get_object_context $object_id] \
          [list [export_vars -no_empty -base object-map {locale ctx_id object_id}] \
          [_ categories.cadmin]]]
} else {
    set context_bar [list \
          [list [export_vars -base . -no_empty {locale ctx_id}] \
          [_ categories.cadmin]]]
}
lappend context_bar $page_title

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
