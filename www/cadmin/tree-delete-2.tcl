ad_page_contract {

    This page checks whether the category tree can be deleted and deletes it.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:naturalnum,notnull
    {locale ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set instance_list [category_tree::usage $tree_id]

if {[llength $instance_list] > 0} {
    ad_return_complaint 1 {{This category tree is still in use.}}
    return
}

category_tree::delete $tree_id

if {![info exists object_id]} {
    ad_returnredirect [export_vars -base . -no_empty {locale ctx_id}]
} else {
    ad_returnredirect [export_vars -no_empty -base object-map {locale object_id ctx_id}]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
