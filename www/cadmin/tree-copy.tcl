ad_page_contract {

    Let the user select a category tree which will be copied into the current category tree

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    trees:multirow
    tree_id:onevalue
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set tree_name [category_tree::get_name $tree_id $locale]
set target_tree_id $tree_id
set page_title [_ categories.Tree_copy_title]

set context_bar [category::context_bar $tree_id $locale \
                     [expr {[info exists object_id] ? $object_id : ""}] \
                     [expr {[info exists ctx_id] ? $ctx_id : ""}]]
lappend context_bar [_ categories.Tree_copy]

template::multirow create trees tree_id tree_name site_wide_p view_url copy_url

db_foreach trees_select {
    select tree_id as source_tree_id, site_wide_p,
           acs_permission.permission_p(tree_id, :user_id, 'category_tree_read') as has_read_p
    from category_trees
    where tree_id <> :tree_id
} {
    if {$site_wide_p == "t" || $has_read_p == "t"} {
	set source_tree_name [category_tree::get_name $source_tree_id $locale]

	template::multirow append trees $source_tree_id $source_tree_name $site_wide_p \
	[export_vars -no_empty -base tree-copy-view { source_tree_id target_tree_id locale object_id ctx_id }] \
	[export_vars -no_empty -base tree-copy-2 { source_tree_id target_tree_id locale object_id ctx_id }]
    }
}

template::multirow sort trees -dictionary tree_name

template::list::create \
    -name trees \
    -no_data "#categories.None#" \
    -elements {
	tree_name {
	    label "#acs-admin.Name#"
	    link_url_col view_url
	}
	site_wide_p {
	    display_template {
		<if @trees.site_wide_p;literal@ true> (#categories.SiteWide_tree#) </if>
	    }
	}
	copy {
	    label "#categories.Action#"
	    display_template {
		<a href="@trees.copy_url@">#categories.Tree_copy#</a>
	    }
	}
    }

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
