ad_page_contract {

    This page displays a category tree.
    Next to each category there will be a map subtree link. 

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    {locale ""}
    object_id:integer,notnull
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree:multirow
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $object_id -privilege admin

array set tree_data [category_tree::get_data $tree_id $locale]
if {$tree_data(site_wide_p) == "f"} {
    permission::require_permission -object_id $tree_id -privilege category_tree_read
}

set page_title "Map subtree"

set context_bar [list [category::get_object_context $object_id] [list [export_vars -no_empty -base one-object {locale object_id}] "Category Management"] "Map subtree"]

template::multirow create tree category_id category_name level left_indent map_url

foreach category [category_tree::get_tree -all $tree_id $locale] {
    util_unlist $category category_id category_name deprecated_p level

    template::multirow append tree $category_id $category_name $level \
	[string repeat "&nbsp;" [expr ($level-1)*5]] \
	[export_vars -no_empty -base tree-map { category_id tree_id locale object_id }]
}

template::list::create \
    -name tree \
    -no_data "None" \
    -elements {
	category_name {
	    label "Name"
	    display_template {
		@tree.left_indent;noquote@ @tree.category_name@
	    }
	}
	map {
	    label "Action"
	    display_template {
		<a href="@tree.map_url@">Map this subtree</a>
	    }
	}
    }

ad_return_template
