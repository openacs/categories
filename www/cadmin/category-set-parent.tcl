ad_page_contract {
    
    Changes the parent category of a category.

    @author Timo Hentschel (thentschel@sussdorff-roy.com)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    tree_name:onevalue
    url_vars:onevalue
    tree:multirow
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

array set one_tree [category_tree::get_data $tree_id $locale]
set tree_name $one_tree(tree_name)

set url_vars [export_url_vars tree_id category_id locale object_id]
set page_title "Choose a parent node"

if {[info exists object_id]} {
    set context_bar [list [category::get_object_context $object_id] [list "one-object?[export_url_vars locale object_id]" "Category Management"]]
} else {
    set context_bar [list [list ".?[export_url_vars locale]" "Category Management"]]
}
lappend context_bar [list "tree-view?[export_url_vars tree_id locale object_id]" $tree_name] "Choose parent"


set subtree_categories_list [db_list subtree {
    select /*+INDEX(child categories_left_ix)*/
           child.category_id
    from categories parent, categories child
    where parent.category_id = :category_id
    and child.left_ind >= parent.left_ind
    and child.left_ind <= parent.right_ind
    and child.tree_id = parent.tree_id
    order by child.left_ind
}]

template::multirow create tree category_name category_id deprecated_p level left_indent url_p

foreach category [category_tree::get_tree -all $tree_id $locale] {
    util_unlist $category category_id category_name deprecated_p level

    if { [lsearch $subtree_categories_list $category_id]==-1 } {
	set url_p 1
    } else {
	set url_p 0
    }
    template::multirow append tree $category_name $category_id $deprecated_p $level [category::repeat_string "&nbsp;" [expr ($level-1)*5]] $url_p
}

ad_return_template
