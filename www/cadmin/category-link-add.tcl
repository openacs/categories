ad_page_contract {
    
    Let user decide from which category tree to add a category link.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    trees:multirow
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set tree_name [category_tree::get_name $tree_id $locale]
set category_name [category::get_name $category_id $locale]
set page_title "Select target to add a link to category \"$tree_name :: $category_name\""

set context_bar [category::context_bar $tree_id $locale \
                     [expr {[info exists object_id] ? $object_id : ""}] \
                     [expr {[info exists ctx_id] ? $ctx_id : ""}]]
lappend context_bar \
    [list [export_vars -no_empty -base category-links-view {category_id tree_id locale object_id  ctx_id}] "Links to $category_name"] \
    "Select link target"


template::multirow create trees tree_name tree_id link_add_url

db_foreach get_trees_to_link {
    select tree_id as link_tree_id
    from category_trees
    where acs_permission.permission_p(tree_id,:user_id,'category_tree_write') = 't'
} {
    set tree_name [category_tree::get_name $link_tree_id $locale]
    template::multirow append trees $tree_name $link_tree_id \
	[export_vars -no_empty -base category-link-add-2 { link_tree_id category_id tree_id locale object_id ctx_id}]
}

template::multirow sort trees -dictionary tree_name

template::list::create \
    -name trees \
    -no_data "None" \
    -elements {
	tree_name {
	    label "Name"
	}
	action {
	    label "Action"
	    display_template {
		<a href="@trees.link_add_url@">View tree to add link</a>
	    }
	}
    }

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
