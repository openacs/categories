ad_page_contract {

    The index page of the category trees administration
    presenting a list of trees the person has a permission to see/modify

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    {locale ""}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    url_vars:onevalue
    trees_with_write_permission:multirow
    trees_with_read_permission:multirow
}

set page_title "Category Management"
set context_bar [list $page_title]
set url_vars [export_url_vars locale]

set user_id [ad_maybe_redirect_for_registration]
set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege category_admin

template::multirow create trees_with_write_permission tree_id tree_name site_wide_p short_name
template::multirow create trees_with_read_permission tree_id tree_name site_wide_p short_name


db_foreach trees {
         select tree_id, site_wide_p,
                acs_permission.permission_p(tree_id, :user_id, 'category_tree_write') has_write_p,
                acs_permission.permission_p(tree_id, :user_id, 'category_tree_read') has_read_p
           from category_trees t
} {
    if { [string equal $has_write_p "t"] } {
	set tree_name [category_tree::get_name $tree_id $locale]
	template::multirow append trees_with_write_permission $tree_id $tree_name $site_wide_p
    } elseif { [string equal $has_read_p "t"] || [string equal $site_wide_p "t"] } {
	set tree_name [category_tree::get_name $tree_id $locale]
	template::multirow append trees_with_read_permission $tree_id $tree_name $site_wide_p
    }
}


ad_return_template
