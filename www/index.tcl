ad_page_contract {

    The index page to browse category trees.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
} -properties {
    page_title:onevalue
    context_bar:onevalue
    trees:multirow
}

set page_title "Categories"
set context_bar ""

set user_id [ad_maybe_redirect_for_registration]
set package_id [ad_conn package_id]
set locale [ad_conn locale]

set admin_p [permission::permission_p -object_id $package_id -privilege category_admin]

template::multirow create trees tree_id tree_name site_wide_p short_name

db_foreach get_trees "" {
    if { [string equal $has_read_p "t"] || [string equal $site_wide_p "t"] } {
	set tree_name [category_tree::get_name $tree_id $locale]
	template::multirow append trees $tree_id $tree_name $site_wide_p
    }
}

ad_return_template
