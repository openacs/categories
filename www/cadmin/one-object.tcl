ad_page_contract {
    
    This entry page for different object in ACS that
    need to manage which categories that can be mapped
    to contained objects. 

    @author Timo Hentschel (timo@timohentschel.de)
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
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $object_id -privilege admin

set context_bar [category::get_object_context $object_id]
set object_name [lindex $context_bar 1]
set page_title "Category Management"
set context_bar [list $context_bar $page_title]

template::multirow create mapped_trees tree_name tree_id site_wide_p assign_single_p require_category_p unmap_url

db_foreach get_mapped_trees "" {
    set tree_name [category_tree::get_name $tree_id $locale]
    if {![empty_string_p $subtree_category_id]} {
	append tree_name " :: [category::get_name $subtree_category_id $locale]"
    }
    template::multirow append mapped_trees $tree_name $tree_id $site_wide_p \
	$assign_single_p $require_category_p \
	[export_vars -no_empty -base tree-unmap { tree_id locale object_id }]
}


template::multirow create unmapped_trees tree_id tree_name site_wide_p map_url subtree_url

db_foreach get_unmapped_trees "" {
    if { [string equal $has_read_permission t] || [string equal $site_wide_p t] } {
	set tree_name [category_tree::get_name $tree_id $locale]

	template::multirow append unmapped_trees $tree_id $tree_name $site_wide_p \
	[export_vars -no_empty -base tree-map { tree_id locale object_id }] \
	[export_vars -no_empty -base subtree-choose { tree_id locale object_id }]
    }
}

template::list::create \
    -name mapped_trees \
    -no_data "None" \
    -elements {
	tree_name {
	    label "Name"
	    link_url_eval {[export_vars -no_empty -base tree-view { tree_id locale object_id }]}
	}
        flags {
	    display_template {
		(<if @mapped_trees.site_wide_p@ eq t>Site-Wide Tree,</if>
		 <if @mapped_trees.assign_single_p@ eq t>single, </if><else>multiple, </else>
		 <if @mapped_trees.require_category_p@ eq t>required) </if><else>optional) </else>
	    }
	}
	unmap {
	    label "Action"
	    display_template {
		<a href="@mapped_trees.unmap_url@">Unmap</a>
	    }
	}
    }

template::list::create \
    -name unmapped_trees \
    -no_data "None" \
    -elements {
	tree_name {
	    label "Name"
	    link_url_eval {[export_vars -no_empty -base tree-view { tree_id locale object_id }]}
	}
	site_wide_p {
	    display_template {
		<if @unmapped_trees.site_wide_p@ eq t> (Site-Wide Tree) </if>
	    }
	}
	map {
	    label "Action"
	    display_template {
		<a href="@unmapped_trees.map_url@">Map tree</a> &nbsp; &nbsp;
		<a href="@unmapped_trees.subtree_url@">Choose subtree to map</a>
	    }
	}
    }

set create_url [export_vars -no_empty -base tree-form { locale }]

ad_return_template
