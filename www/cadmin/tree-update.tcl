ad_page_contract {
    Bulk operation on a category tree:
    sort, phase in, phase out, delete

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    sort_key:array
    {check:array ""}
    {submit_sort ""}
    {submit_phase_in ""}
    {submit_phase_out ""}
    {submit_delete ""}
    {locale ""}
    object_id:integer,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    categories:multirow
    form_vars_delete:onevalue
    form_vars_cancel:onevalue
}

set user_id [ad_maybe_redirect_for_registration]
permission::require_permission -object_id $tree_id -privilege category_tree_write

if {![empty_string_p $submit_sort]} {
	
    db_transaction {

	set count 0
	db_foreach get_tree "" {
	    incr count 10
	    if {[empty_string_p $parent_id]} {
		# need this as an anchor for toplevel categories
		set parent_id -1
	    }
	    if {[info exists sort_key($category_id)]} {
		lappend child($parent_id) [list $sort_key($category_id) $category_id 0 0]
	    } else {
		lappend child($parent_id) [list $count $category_id 0 0]
	    }
	}
	set last_ind [expr ($count / 5) + 1]

	set count 1
	set stack [list]
	set done_list [list]
	# put toplevel categories on stack
	if {[info exists child(-1)]} {
	    set stack [lsort -integer -index 0 $child(-1)]
	}

	while {[llength $stack] > 0} {
	    set next [lindex $stack 0]
	    set act_category [lindex $next 1]
	    set stack [lrange $stack 1 end]
	    if {[lindex $next 2]>0} {
		## the children of this parent are done, so this category is also done
		lappend done_list [list $act_category [lindex $next 2] $count]
	    } elseif {[info exists child($act_category)]} {
		## put category and all children back on stack
		set next [lreplace $next 2 2 $count]
		set stack [linsert $stack 0 $next]
		set stack [concat [lsort -integer -index 0 $child($act_category)] $stack]
	    } else {
		## this category has no children, so it is done
		lappend done_list [list $act_category $count [expr $count + 1]]
		incr count 1
	    }
	    incr count 1
	}

	if {$count == $last_ind} {
	    # we do this so that there is no conflict in the old left_inds and the new ones
	    db_dml reset_category_index ""

	    foreach category $done_list {
		util_unlist $category category_id left_ind right_ind
		db_dml update_category_index ""
	    }
	}
	category_tree::flush_cache $tree_id
    }

    if {$count != $last_ind} {
	ad_return_complaint 1 "Error during update: $done_list"
	return
    }
    ad_returnredirect [export_vars -no_empty -base tree-view {tree_id locale object_id}]
    return

} elseif {![empty_string_p $submit_phase_in]} {
	
    db_transaction {
	foreach category_id [array names check] {
	    category::phase_in $category_id
	}
	category_tree::flush_cache $tree_id
    }

    ad_returnredirect [export_vars -no_empty -base tree-view {tree_id locale object_id}]
    return
   
} elseif {![empty_string_p $submit_phase_out]} {

    db_transaction {
	foreach category_id [array names check] {
	    category::phase_out $category_id
	}
	category_tree::flush_cache $tree_id
    }

    ad_returnredirect [export_vars -no_empty -base tree-view {tree_id locale object_id}]
    return

} elseif {![empty_string_p $submit_delete]} {

    set category_ids [array names check]
    set page_title "Confirm deleting categories"
    set tree_name [category_tree::get_name $tree_id $locale]

    set context_bar [category::context_bar $tree_id $locale [value_if_exists object_id]]
    lappend context_bar "Delete categories"

    set form_vars_cancel [export_form_vars tree_id locale object_id]
    set form_vars_delete [export_form_vars category_ids:multiple tree_id locale object_id]

    template::multirow create categories category_id name used_p
    db_transaction {
	# use temporary table to use only bind vars in queries
	foreach category_id $category_ids {
	    db_dml insert_tmp_categories ""
	}
	
	db_foreach get_used_categories "" {
	    set category_name [category::get_name $category_id $locale]
	    template::multirow append categories $category_id $category_name $used_p
	}
    }

} else {

    ns_log Warning "Unhandled user input in packages/categories/www/tree-update.tcl"
    ad_returnredirect [export_vars -no_empty -base tree-view {tree_id locale object_id}]
    return

}

ad_return_template
