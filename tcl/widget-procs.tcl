ad_proc -public template::widget::category { element_reference tag_attributes } {
    # author: Timo Hentschel (timo@timohentschel.de)

    upvar $element_reference element

    if { [info exists element(html)] } {
	array set attributes $element(html)
    }
    array set attributes $tag_attributes
    array set ms_attributes $tag_attributes
    set ms_attributes(multiple) {}
    
    set all_single_p [info exists attributes(single)]

    # Determine the size automatically for a multiselect
    if { ![info exists ms_attributes(size)] } {
	set ms_attributes(size) 5
    }

    # Get parameters for the category widget
    set object_id {}
    set package_id {}
    set tree_id {}
    set subtree_id {}
    if { [exists_and_not_null element(value)] && [llength $element(value)] == 2 } {
        # Legacy method for passing parameters
        set object_id [lindex $element(value) 0]
        set package_id [lindex $element(value) 1]
    } else {
        if { [exists_and_not_null element(category_application_id)] } {
            set package_id $element(category_application_id)
        }
        if { [exists_and_not_null element(category_object_id)] } {
            set object_id $element(category_object_id)
        }
        if { [exists_and_not_null element(category_tree_id)] } {
            set tree_id $element(category_tree_id)
        }
        if { [exists_and_not_null element(category_subtree_id)] } {
            set subtree_id $element(category_subtree_id)
        }
    }
    if { [empty_string_p $package_id] } {
	set package_id [ad_conn package_id]
    }

    if { ![empty_string_p $object_id] } {
        set mapped_categories [category::get_mapped_categories $object_id]
    } else {
        set mapped_categories {}
    }
    set output {}

    if { [empty_string_p $tree_id] } {
        set mapped_trees [category_tree::get_mapped_trees $package_id]
    } else {
        set mapped_trees [list [list $tree_id [category_tree::get_name $tree_id] $subtree_id f]]
    }

    foreach tree $mapped_trees {
	util_unlist $tree tree_id tree_name subtree_id assign_single_p
	set tree_name [ad_quotehtml $tree_name]
	set one_tree [list]
	foreach category [category_tree::get_tree -subtree_id $subtree_id $tree_id] {
	    util_unlist $category category_id category_name deprecated_p level
	    set category_name [ad_quotehtml $category_name]
	    if { $level>1 } {
		set category_name "[category::repeat_string "&nbsp;" [expr 2*$level -4]]..$category_name"
	    }
	    lappend one_tree [list $category_name $category_id]
	}
        if { [llength $mapped_trees] > 1 } {
            append output " $tree_name\: "
        }
	if {$assign_single_p == "t" || $all_single_p} {
	    # single-select widget
	    append output [template::widget::menu $element(name) $one_tree $mapped_categories attributes $element(mode)]
	} else {
	    # multiselect widget (if user didn't override with single option)
	    append output [template::widget::menu $element(name) $one_tree $mapped_categories ms_attributes $element(mode)]
	}
    }

    return $output
}
