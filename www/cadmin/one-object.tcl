ad_page_contract {
    
    This entry page for different object in ACS that
    need to manage which categories that can be mapped
    to contained objects. 

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    object_id:integer,notnull
    {locale ""}
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    mapped_trees:multirow
    unmapped_trees:multirow
    object_name:onevalue
    url_vars:onevalue
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $object_id -privilege admin

set context_bar [category::get_object_context $object_id]
set object_name [lindex $context_bar 1]
set page_title "Category Management"
set context_bar [list $context_bar $page_title]
set url_vars [export_url_vars locale object_id]

template::multirow create mapped_trees tree_name tree_id site_wide_p subtree_category_id subtree_category_name

db_foreach get_mapped_trees {
         select t.tree_id, t.site_wide_p, m.subtree_category_id
           from category_trees t, category_tree_map m
          where m.object_id = :object_id
            and m.tree_id = t.tree_id
       order by t.tree_id
} {
    if {![empty_string_p $subtree_category_id]} {
	set subtree_category_name [category::get_name $subtree_category_id $locale]
    } else {
	set subtree_category_name ""
    }
    set tree_name [category_tree::get_name $tree_id $locale]
    template::multirow append mapped_trees $tree_name $tree_id $site_wide_p $subtree_category_id $subtree_category_name
}



template::multirow create unmapped_trees tree_id tree_name site_wide_p

db_foreach get_unmapped_trees {
    select tree_id, site_wide_p,
          acs_permission.permission_p(tree_id, :user_id, 'category_tree_read') has_read_permission  
     from category_trees t
    where not exists (select 1 from category_tree_map m
                       where m.object_id = :object_id
                         and m.tree_id = t.tree_id)
    order by t.tree_id
} {
    if { [string equal $has_read_permission t] || [string equal $site_wide_p t] } {
	set tree_name [category_tree::get_name $tree_id $locale]
	template::multirow append unmapped_trees $tree_id $tree_name $site_wide_p
    }
}

ad_return_template
