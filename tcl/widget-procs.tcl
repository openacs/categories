ad_proc -public template::widget::category { element_reference tag_attributes } {
    # author: Timo Hentschel (thentschel@sussdorff-roy.com)

    upvar $element_reference element

    if { [info exists element(html)] } {
	array set attributes $element(html)
    }
    array set attributes $tag_attributes
    set attributes(multiple) {}

    # Determine the size automatically for a multiselect
    if { ! [info exists attributes(size)] } {
	set attributes(size) 5
    }

    set object_id [lindex $element(value) 0]
    set package_id [lindex $element(value) 1]
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set mapped_categories [category::get_mapped_categories $object_id]
    set output ""

    foreach tree [category_tree::get_mapped_trees $package_id] {
	util_unlist $tree tree_id tree_name subtree_id
	set tree_name [ad_quotehtml $tree_name]
	set one_tree [list]
	foreach category [category_tree::get_tree -subtree_id $subtree_id $tree_id] {
	    util_unlist $category category_id category_name deprecated_p level
	    set category_name [ad_quotehtml $category_name]
	    if {$level>1} {
		set category_name "[category::repeat_string "&nbsp;" [expr 2*$level -4]]..$category_name"
	    }
	    lappend one_tree [list $category_name $category_id]
	}
	append output " $tree_name\: [template::widget::menu $element(name) $one_tree $mapped_categories attributes $element(mode)]"
    }

    return $output
}
