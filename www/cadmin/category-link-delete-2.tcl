ad_page_contract {

    Deletes category links

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    link_id:naturalnum,multiple
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

db_transaction {
    foreach link_id [db_list check_category_link_permissions [subst {
        select l.link_id
        from category_links l, categories c
        where l.link_id in ([ns_dbquotelist $link_id])
        and acs_permission.permission_p(c.tree_id,:user_id,'category_tree_write') = 't'
        and ((l.from_category_id = :category_id
              and l.to_category_id = c.category_id)
             or (l.from_category_id = c.category_id
                 and l.to_category_id = :category_id))
    }]] {
	category_link::delete $link_id
    }
} on_error {
    ad_return_complaint 1 {{Error deleting category link.}}
    return
}

ad_returnredirect [export_vars -no_empty -base category-links-view {category_id tree_id locale object_id ctx_id}]
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
