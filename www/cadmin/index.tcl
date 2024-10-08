ad_page_contract {

    The index page of the category trees administration
    presenting a list of trees the person has a permission to see/modify

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    {locale:word ""}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    trees_with_write_permission:multirow
    trees_with_read_permission:multirow
}

set page_title "[_ categories.cadmin]"
set context_bar [list $page_title]

set user_id [auth::require_login]
set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege category_admin

set trees_with_write_permission [list]
set trees_with_read_permission  [list]
db_foreach trees {
    select tree_id, site_wide_p,
           acs_permission.permission_p(tree_id, :user_id, 'category_tree_write') as has_write_p,
           acs_permission.permission_p(tree_id, :user_id, 'category_tree_read') as has_read_p
      from category_trees
} {
    set tree [category_tree::get_data $tree_id $locale]
    dict set tree tree_id     $tree_id
    dict set tree site_wide_p $site_wide_p
    dict set tree view_url    [export_vars -no_empty -base tree-view { tree_id locale }]

    if {$has_write_p == "t"} {
	lappend trees_with_write_permission $tree
    } elseif { $has_read_p == "t" || $site_wide_p == "t" } {
	lappend trees_with_read_permission $tree
    }
}

::template::util::list_to_multirow \
    trees_with_write_permission $trees_with_write_permission
::template::multirow sort trees_with_write_permission -dictionary tree_name

::template::util::list_to_multirow \
    trees_with_read_permission $trees_with_read_permission
::template::multirow sort trees_with_read_permission -dictionary tree_name

set elements {
    tree_name {
	label "#acs-subsite.Name#"
	link_url_col view_url
    }
    description {
	label "#categories.Description#"
    }
}

list::create \
    -name trees_with_write_permission \
    -no_data "#categories.None#" \
    -elements $elements \
    -key tree_id \
    -bulk_action_export_vars {locale} \
    -bulk_actions [list "[_ categories.export]" trees-code "[_ categories.code_export]"] \

list::create \
    -name trees_with_read_permission \
    -no_data "#categories.None#" \
    -elements $elements

set create_url [export_vars -no_empty -base tree-form { locale }]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
