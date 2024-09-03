ad_page_contract {

    Adds bidirectional category links

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    link_category_id:naturalnum,multiple
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

db_transaction {
    foreach forward_category_id [db_list check_link_forward_permissions [subst {
        select c.category_id as link_category_id
        from categories c
        where c.category_id in ([ns_dbquotelist $link_category_id])
        and acs_permission.permission_p(c.tree_id,:user_id,'category_tree_write') = 't'
        and c.category_id <> :category_id
        and not exists (select 1
                        from category_links l
                        where l.from_category_id = :category_id
                        and l.to_category_id = c.category_id)
    }]] {
	category_link::add -from_category_id $category_id -to_category_id $forward_category_id
    }

    foreach backward_category_id [db_list check_link_backward_permissions [subst {
        select c.category_id as link_category_id
        from categories c
        where c.category_id in ([ns_dbquotelist $link_category_id])
        and acs_permission.permission_p(c.tree_id,:user_id,'category_tree_write') = 't'
        and c.category_id <> :category_id
        and not exists (select 1
                        from category_links l
                        where l.from_category_id = c.category_id
                        and l.to_category_id = :category_id)
    }]] {
	category_link::add -from_category_id $backward_category_id -to_category_id $category_id
    }
} on_error {
    ad_return_complaint 1 "Error creating category link."
    return
}

ad_returnredirect [export_vars -no_empty -base category-links-view {category_id tree_id locale object_id ctx_id}]
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
