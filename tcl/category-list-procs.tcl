ad_library {
    Procs for the integration in listbuilder of the site-wide categorization package.

    Please note: This is highly experimental and is subject to ongoing development
                 so the interfaces might be unstable.

    @author Timo Hentschel (timo@timohentschel.de)

    @creation-date 17 February 2004
    @cvs-id $Id:
}

namespace eval category::list {}

# Scenario: you prepare a multirow which is then displated via template::list::create
#
# Usage: instead of using db_foreach or db_multirow you now use
#        category::list::db_foreach or category::list::db_multirow
#        these procs will do exactly the same as the original procs, but
#        they will also join the table category_object_map to get the
#        tcl list of all categories per object. for this you need to
#        specify the sql column of the object_id with the option -join_column
#        the procs will add another variable/multirow column "categories"
#        with the tcl-list of category_ids per row - you can change that name
#        with the -categories_varname option.
#
#        After you got the multirow, use
#        category::list::extend_multirow -name <<multirowname>> -container_object_id $package_id
#        (or an object other than package_id that the trees are mapped to).
#        This proc will generate one extra multirow column per mapped tree that
#        will hold a pretty list of the categories. The pretty list can be changed
#        with various options (delimiter, links etc).
#        If you want to have only one extra multirow column holding a pretty list
#        of the mapped trees and categories, then you should use the -one_category_list
#        option.
#
#        To automatically generate the appropriate input to be used in the elements
#        section of template::list::create, use 
#        category::list::elements -name <<multirowname>>
#        followed by extra spec to be used per element. Again, to display only one
#        column use the -one_category_list option.


ad_proc -public category::list::get_pretty_list {
    {-category_delimiter ", "}
    {-category_link ""}
    {-category_link_eval ""}
    {-category_link_html ""}
    {-tree_delimiter "; "}
    {-tree_colon ": "}
    {-tree_link ""}
    {-tree_link_eval ""}
    {-tree_link_html ""}
    {-category_varname "__category_id"}
    {-tree_varname "__tree_id"}
    {-uplevel 1}
    category_id_list
    {locale ""}
} {
    Accepts a list of category_ids and returns a pretty list of tree-names and
    category-names with optional links for each tree and category.

    @param category_delimiter string that seperates the categories in the pretty list
    @param category_link optional link for every category-name
    @param category_link_eval optional command that returns the link for every category-name.
                              normaly this would be a export_vars command that could
                              contain __category_id and __tree_id which refer to
                              category_id and tree_id of the category-name the link will wrap.
    @param category_link_html optional list of key value pairs for additional html in a link.
    @param tree_delimiter string that seperates the tree-names in the pretty list
    @param tree_colon string that seperates a tree-name from the category-names in that tree.
    @param tree_link optional link for every tree-name
    @param tree_link_eval optional command that returns the link for every tree-name.
                          normaly this would be a export_vars command that could
                          contain __tree_id which refer to tree_id of the tree-name
                          the link will wrap.
    @param tree_link_html optional list of key value pairs for additional html in a link.
    @param category_varname name of the variable that will hold the category_id for
                            category link generation.
    @param tree_varname name of the variable that will hold the tree_id for category
                        and tree link generation.
    @param uplevel upvar level to set __tree_id and __category_id for link generation.
    @param category_id_list tcl-list of categories to display.
    @param locale locale of the category-names and tree-names.
    @return pretty list of tree-names and category-names
    @author Timo Hentschel (timo@timohentschel.de)
    @see category::list::db_foreach
    @see category::list::db_multirow
    @see category::list::extend_multirow
    @see category::list::elements
} {
    if {![empty_string_p $category_link_eval]} {
	upvar $uplevel $category_varname category_id $tree_varname tree_id
    } elseif {![empty_string_p $tree_link_eval]} {
	upvar $uplevel $tree_varname tree_id
    }

    set sorted_categories [list]
    foreach category_id $category_id_list {
	lappend sorted_categories [category::get_data $category_id $locale]
    }
    set sorted_categories [lsort -dictionary -index 3 [lsort -dictionary -index 1 $sorted_categories]]

    set cat_link_html ""
    foreach {key value} $category_link_html {
	append cat_link_html " $key=\"$value\""
    }
    set cat_tree_link_html ""
    foreach {key value} $tree_link_html {
	append cat_tree_link_html " $key=\"$value\""
    }

    set result ""
    set old_tree_id 0
    foreach category $sorted_categories {
	util_unlist $category category_id category_name tree_id tree_name

	set category_name [ad_quotehtml $category_name]
	if {![empty_string_p $category_link_eval]} {
	    set category_link [uplevel $uplevel concat $category_link_eval]
	}
	if {![empty_string_p $category_link]} {
	    set category_name "<a href=\"$category_link\"$cat_link_html>$category_name</a>"
	}

	if {$tree_id != $old_tree_id} {
	    if {![empty_string_p $result]} {
		append result $tree_delimiter
	    }
	    set tree_name [ad_quotehtml $tree_name]
	    if {![empty_string_p $tree_link_eval]} {
		set tree_link [uplevel $uplevel concat $tree_link_eval]
	    }
	    if {![empty_string_p $tree_link]} {
		set tree_name "<a href=\"$tree_link\"$cat_tree_link_html>$tree_name</a>"
	    }
	    append result "$tree_name$tree_colon$category_name"
	} else {
	    append result "$category_delimiter$category_name"
	}
	set old_tree_id $tree_id
    }

    return $result
}

ad_proc -public category::list::extend_multirow {
    {-category_delimiter ", "}
    {-category_link ""}
    {-category_link_eval ""}
    {-category_link_html ""}
    {-tree_delimiter "; "}
    {-tree_colon ": "}
    {-tree_link ""}
    {-tree_link_eval ""}
    {-tree_link_html ""}
    {-category_varname "__category_id"}
    {-tree_varname "__tree_id"}
    {-categories_varname "categories"}
    {-tree_ids ""}
    {-exclude_tree_ids ""}
    {-container_object_id ""}
    {-locale ""}
    -one_category_list:boolean
    -name:required
} {
    Extends a given multirow with either one extra column holding a pretty list
    of the tree-names and category-names or one column per tree holding a pretty
    list of category-names. These extra column can then be used in the listbuilder
    to display a pretty list of categorized objects.

    @param category_delimiter string that seperates the categories in the pretty list
    @param category_link optional link for every category-name
    @param category_link_eval optional command that returns the link for every category-name.
                              normaly this would be a export_vars command that could
                              contain __category_id and __tree_id which refer to
                              category_id and tree_id of the category-name the link will wrap.
    @param category_link_html optional list of key value pairs for additional html in a link.
    @param tree_delimiter string that seperates the tree-names in the pretty list
    @param tree_colon string that seperates a tree-name from the category-names in that tree.
    @param tree_link optional link for every tree-name
    @param tree_link_eval optional command that returns the link for every tree-name.
                          normaly this would be a export_vars command that could
                          contain __tree_id which refer to tree_id of the tree-name
                          the link will wrap.
    @param tree_link_html optional list of key value pairs for additional html in a link.
    @param category_varname name of the variable that will hold the category_id for
                            category link generation.
    @param tree_varname name of the variable that will hold the tree_id for category
                        and tree link generation.
    @param categories_varname name of the column in the multirow holding the tcl-list
                              of mapped categories.
    @param tree_ids tcl-list of trees that should be displayed.
    @param exclude_tree_ids tcl-list of trees that should not be displayed.
    @param container_object_id object the trees are mapped to (instead of providing tree_ids).
    @param locale locale of the category-names and tree-names.
    @param one_category_list switch to generate only one additional column in the multirow
                             that holds a pretty list of tree-names and category-names.
    @param name name of the multirow to extend.
    @author Timo Hentschel (timo@timohentschel.de)
    @see category::list::db_foreach
    @see category::list::db_multirow
    @see category::list::elements
    @see category::list::get_pretty_list
} {
    if {![empty_string_p $category_link_eval]} {
	upvar 1 $category_varname category_id $tree_varname tree_id
    } elseif {![empty_string_p $tree_link_eval]} {
	upvar 1 $tree_varname tree_id
    }

    set cat_link_html ""
    foreach {key value} $category_link_html {
	append cat_link_html " $key=\"$value\""
    }
    set cat_tree_link_html ""
    foreach {key value} $tree_link_html {
	append cat_tree_link_html " $key=\"$value\""
    }

    # get trees to display
    if {[empty_string_p $tree_ids]} {
	foreach mapped_tree [category_tree::get_mapped_trees $container_object_id] {
	    lappend tree_ids [lindex $mapped_tree 0]
	}
    }
    set valid_tree_ids ""
    foreach tree_id $tree_ids {
	if {[lsearch -integer $exclude_tree_ids $tree_id] == -1} {
	    lappend valid_tree_ids $tree_id
	}
    }

    template::multirow upvar $name list_data
    # check for existing multirow
    if {![info exists list_data:rowcount] || ![info exists list_data:columns]} { 
        return 
    } 

    if {!$one_category_list_p} {
	# extend multirow with a variable per tree
	foreach tree_id $valid_tree_ids {
	    uplevel 1 template::multirow extend $name $categories_varname\_$tree_id
	}

	# loop over multirow
	for {set i 1} {$i <= ${list_data:rowcount}} {incr i} {

	    upvar 1 $name:$i row
	    if {![empty_string_p $category_link_eval]} {
		foreach column_name ${list_data:columns} {
		    upvar 1 $column_name column_value
		    if { [info exists row($column_name)] } {
			set column_value $row($column_name)
		    } else {
			set column_value ""
		    }
		}
	    }

	    # get categories per tree
	    foreach tree_id $valid_tree_ids {
		set tree_categories($tree_id) ""
	    }
	    foreach category_id $row($categories_varname) {
		set tree_id [category::get_tree $category_id]
		if {[lsearch -integer $valid_tree_ids $tree_id] > -1} {
		    lappend tree_categories($tree_id) [list $category_id [category::get_name $category_id $locale]]
		}
	    }

	    # generate pretty category list per tree
	    foreach tree_id [array names tree_categories] {
		set tree_categories($tree_id) [lsort -dictionary -index 1 $tree_categories($tree_id)]
		set pretty_category_list ""

		foreach category $tree_categories($tree_id) {
		    util_unlist $category category_id category_name
		    set category_name [ad_quotehtml $category_name]
		    if {![empty_string_p $category_link_eval]} {
			set category_link [uplevel 1 concat $category_link_eval]
		    }
		    if {![empty_string_p $category_link]} {
			set category_name "<a href=\"$category_link\"$cat_link_html>$category_name</a>"
		    }
		    if {![empty_string_p $pretty_category_list]} {
			append pretty_category_list "$category_delimiter$category_name"
		    } else {
			set pretty_category_list $category_name
		    }
		}
		
		# set multirow columns with pretty category lists
		set row($categories_varname\_$tree_id) $pretty_category_list
	    }
	    unset tree_categories
	}

	############
    } else {
	############

	# extend multirow with one variable for pretty list of trees and categories
	template::multirow extend list_data $categories_varname\_all

	# loop over multirow
	for {set i 1} {$i <= ${list_data:rowcount}} {incr i} {

	    upvar 1 $name:$i row
	    if {![empty_string_p $category_link_eval]} {
		foreach column_name ${list_data:columns} {
		    upvar 1 $column_name column_value
		    if { [info exists row($column_name)] } {
			set column_value $row($column_name)
		    } else {
			set column_value ""
		    }
		}
	    }

	    # get categories of given trees
	    set valid_categories ""
	    foreach category_id $row($categories_varname) {
		set tree_id [category::get_tree $category_id]
		if {[lsearch -integer $valid_tree_ids $tree_id] > -1} {
		    lappend valid_categories $category_id
		}
	    }

	    # set multirow column with pretty list of trees and categories
	    set row($categories_varname\_all) [category::list::get_pretty_list \
						   -category_delimiter $category_delimiter \
						   -category_link $category_link \
						   -category_link_eval $category_link_eval \
						   -category_link_html $category_link_html \
						   -tree_delimiter $tree_delimiter \
						   -tree_colon $tree_colon \
						   -tree_link $tree_link \
						   -tree_link_eval $tree_link_eval \
						   -tree_link_html $tree_link_html \
						   -category_varname $category_varname \
						   -tree_varname $tree_varname \
						   -uplevel 2 $valid_categories $locale]
	}
    }
}

ad_proc -public category::list::elements {
    {-categories_varname "categories"}
    {-tree_ids ""}
    {-locale ""}
    -one_category_list:boolean
    -name:required
    {spec ""}
} {
    Adds list-elements to display mapped categories. To be used in list::create.

    @param categories_varname beginning of the names of the multirow columns holding
                              the category-names.
    @param tree_ids trees to be displayed. if not provided all tree columns in the
                    multirow will be displayed.
    @param locale locale to display the tree-names in columns.
    @param one_category_list switch to generate only one additional column in the list
                             that holds a pretty list of tree-names and category-names.
    @param name name of the multirow for the list.
    @param spec extra spec used for the list-elements. you can override the display_template
                with using "categories" as column holding the pretty list of category-names.
    @author Timo Hentschel (timo@timohentschel.de)
    @see template::list::create
    @see template::list::element::create
    @see category::list::db_foreach
    @see category::list::db_multirow
    @see category::list::extend_multirow
    @see category::list::get_pretty_list
} {
    # todo: deal with display_template and label tags in spec

    array set spec_array $spec
    if {[info exists spec_array(display_template)]} {
	set display_template $spec_array(display_template)
	array unset spec_array display_template
    } else {
	set display_template " @$name\.$categories_varname;noquote@ "
    }
    if {[info exists spec_array(label)]} {
	set label $spec_array(label)
	array unset spec_array label
    } else {
	set label "Categories"
    }
    set spec [array get spec_array]

    if {$one_category_list_p} {
	# generate listbuilder input to display one column with pretty list
	# of tree-names and category-names
	set result "$categories_varname\_all {
	    label \"$label\"
	    display_template {[regsub -all "@$name\.$categories_varname\(;noquote\)?@" $display_template "@$name\.$categories_varname\_all\\1@"]}
	    $spec
	}"
	return $result
    } else {
	if {[empty_string_p $tree_ids]} {
	    # get tree columns in multirow
	    template::multirow upvar $name list_data
	    foreach column ${list_data:columns} {
		if {[regexp "$categories_varname\_(\[0-9\]+)\$" $column match tree_id]} {
		    lappend tree_ids $tree_id
		}
	    }
	    foreach tree_id $tree_ids {
		lappend trees [list [category_tree::get_name $tree_id $locale] $tree_id]
	    }
	    set trees [lsort -dictionary -index 0 $trees]
	} else {
	    foreach tree_id $tree_ids {
		lappend trees [list [category_tree::get_name $tree_id $locale] $tree_id]
	    }
	}

	# generate listbuilder input to display one column per tree-name showing
	# pretty list of category-names
	set result ""
	foreach tree $trees {
	    util_unlist $tree tree_name tree_id
	    append result "$categories_varname\_$tree_id {
		label \"$tree_name\"
		display_template {[regsub -all "@$name\.$categories_varname\(;noquote\)?@" $display_template "@$name\.$categories_varname\_$tree_id\\1@"]}
		$spec
	    }\n"
	}
	return $result
    }
}

ad_proc -public category::list::db_foreach {
    -join_column:required
    {-categories_varname "categories"}
    { -dbn "" }
    statement_name
    sql
    args
} {
    Behaves just like db_foreach, but will also generate an extra variable holding
    a tcl-list of all mapped categories.

    @param join_column column name that holds the object_id of the categorized object.
    @param categories_varname variable name that will hold the list of mapped categories.
    @author Timo Hentschel (timo@timohentschel.de)
    @see db_foreach
    @see category::list::db_multirow
    @see category::list::extend_multirow
    @see category::list::elements
    @see category::list::get_pretty_list
} {
    ad_arg_parser { bind column_array column_set args } $args

    # Do some syntax checking.
    set arglength [llength $args]
    if { $arglength == 1 } {
        # Have only a code block.
        set code_block [lindex $args 0]
    } elseif { $arglength == 3 } {
        # Should have code block + if_no_rows + code block.
        if { ![string equal [lindex $args 1] "if_no_rows"] && ![string equal [lindex $args 1] "else"] } {
            return -code error "Expected if_no_rows as second-to-last argument"
        }
        set code_block [lindex $args 0]
        set if_no_rows_code_block [lindex $args 2]
    } else {
        return -code error "Expected 1 or 3 arguments after switches"
    }

    if { [info exists column_array] && [info exists column_set] } {
        return -code error "Can't specify both column_array and column_set"
    }

    if { [info exists column_array] } {
        upvar 1 $column_array array_val
    }

    if { [info exists column_set] } {
        upvar 1 $column_set selection
    }

    db_with_handle -dbn $dbn db {
	# Query Dispatcher (OpenACS - ben)
	set full_statement_name [db_qd_get_fullname $statement_name]
	set sql [db_qd_replace_sql $full_statement_name $sql]
	set driverkey [db_driverkey -handle_p 1 $db]

	switch $driverkey {
	    oracle {
		set new_sql "select s.*, m.category_id as $categories_varname
		from ($sql) s, category_object_map m
		where s.$join_column = m.object_id(+)"
	    }
	    postgresql {
		set new_sql "select s.*, m.category_id as $categories_varname
		from ($sql) s left outer join category_object_map m
		on (s.$join_column = m.object_id)"
	    }
	}

        set selection [db_exec select $db __invalid_query_name__ $new_sql]

        set counter 0
	set old_row_id ""
	set category_list ""
        set more_rows_p 1
        while { 1 } {

            if { $more_rows_p } {
                set more_rows_p [db_getrow $db $selection]
            } else {
                break
            }

	    set cur_row_id [ns_set get $selection $join_column]
	    set cur_category_id [ns_set get $selection $categories_varname]
	    if {![empty_string_p $cur_category_id]} {
		lappend category_list $cur_category_id
	    }

	    # check if new row needs be started
	    if { ($cur_row_id != $old_row_id && $counter > 0) || !$more_rows_p} {
		if {![empty_string_p $cur_category_id]} {
		    set category_list $cur_category_id
		} else {
		    set category_list ""
		}

		if { ![info exists column_set] } {
		    if { [info exists column_array] } {
			set array_val($categories_varname) \"$old_category_list\"
		    } else {
			uplevel 1 set $categories_varname \"$old_category_list\"
		    }
		} else {
		    ns_set update $selection $categories_varname $old_category_list
		}

		set errno [catch { uplevel 1 $code_block } error]
		
		# Handle or propagate the error. Can't use the usual "return -code $errno..." trick
		# due to the db_with_handle wrapped around this loop, so propagate it explicitly.
		switch $errno {
		    0 {
			# TCL_OK
		    }
		    1 {
			# TCL_ERROR
			global errorInfo errorCode
			error $error $errorInfo $errorCode
		    }
		    2 {
			# TCL_RETURN
			error "Cannot return from inside a db_foreach loop"
		    }
		    3 {
			# TCL_BREAK
			ns_db flush $db
			break
		    }
		    4 {
			# TCL_CONTINUE - just ignore and continue looping.
		    }
		    default {
			error "Unknown return code: $errno"
		    }
		}
	    }
	    incr counter
	    if { [info exists array_val] } {
		unset array_val
	    }

	    if {$more_rows_p} {
		if { ![info exists column_set] } {
		    for { set i 0 } { $i < [ns_set size $selection] } { incr i } {
			if { [info exists column_array] } {
			    set array_val([ns_set key $selection $i]) [ns_set value $selection $i]
			} else {
			    upvar 1 [ns_set key $selection $i] column_value
			    set column_value [ns_set value $selection $i]
			}
		    }
		}
	    }
	    set old_row_id $cur_row_id
	    set old_category_list $category_list
	}

        # If the if_no_rows_code is defined, go ahead and run it.
        if { $counter == 0 && [info exists if_no_rows_code_block] } {
            uplevel 1 $if_no_rows_code_block
        }
    }
}

ad_proc -public category::list::db_multirow {
    -join_column:required
    {-categories_varname "categories"}
    -local:boolean
    -append:boolean
    {-upvar_level 1}
    -unclobber:boolean
    {-extend {}}
    {-dbn ""}
    var_name
    statement_name
    sql
    args 
} {
    Behaves just like db_multirow, but will also generate an extra multirow column holding
    a tcl-list of all mapped categories.

    @param join_column column name that holds the object_id of the categorized object.
    @param categories_varname name of the multirow column that will hold the list
                              of mapped categories.
    @author Timo Hentschel (timo@timohentschel.de)
    @see db_multirow
    @see category::list::db_foreach
    @see category::list::extend_multirow
    @see category::list::elements
    @see category::list::get_pretty_list
} {
    # Query Dispatcher (OpenACS - ben)
    set full_statement_name [db_qd_get_fullname $statement_name]

    if { $local_p } {
        set level_up $upvar_level
    } else {
        set level_up \#[template::adp_level]
    }

    ad_arg_parser { bind args } $args

    # Do some syntax checking.
    set arglength [llength $args]
    if { $arglength == 0 } {
        # No code block.
        set code_block ""
    } elseif { $arglength == 1 } {
        # Have only a code block.
        set code_block [lindex $args 0]
    } elseif { $arglength == 3 } {
        # Should have code block + if_no_rows + code block.
        if {   ![string equal [lindex $args 1] "if_no_rows"] \
            && ![string equal [lindex $args 1] "else"] } {
            return -code error "Expected if_no_rows as second-to-last argument"
        }
        set code_block [lindex $args 0]
        set if_no_rows_code_block [lindex $args 2]
    } else {
        return -code error "Expected 1 or 3 arguments after switches"
    }
    
    upvar $level_up "$var_name:rowcount" counter
    upvar $level_up "$var_name:columns" columns

    if { !$append_p || ![info exists counter]} {
        set counter 0
    }

    db_with_handle -dbn $dbn db {
	# Query Dispatcher (OpenACS - ben)
	set full_statement_name [db_qd_get_fullname $statement_name]
	set sql [db_qd_replace_sql $full_statement_name $sql]
	set driverkey [db_driverkey -handle_p 1 $db]

	switch $driverkey {
	    oracle {
		set new_sql "select s.*, m.category_id as $categories_varname
		from ($sql) s, category_object_map m
		where s.$join_column = m.object_id(+)"
	    }
	    postgresql {
		set new_sql "select s.*, m.category_id as $categories_varname
		from ($sql) s left outer join category_object_map m
		on (s.$join_column = m.object_id)"
	    }
	}

        set selection [db_exec select $db __invalid_query_name__ $new_sql]
        set local_counter 0

        # Make sure 'next_row' array doesn't exist
        # The this_row and next_row variables are used to always execute the code block one result set row behind,
        # so that we have the opportunity to peek ahead, which allows us to do group by's inside
        # the multirow generation
        # Also make the 'next_row' array available as a magic __db_multirow__next_row variable
        upvar 1 __db_multirow__next_row next_row
        if { [info exists next_row] } {
            unset next_row
        }
        
	set old_row_id ""
	set category_list ""
        set more_rows_p 1
        while { 1 } {

            if { $more_rows_p } {
                set more_rows_p [db_getrow $db $selection]
            } else {
                break
	    }
            
            # Setup the 'columns' part, now that we know the columns in the result set
            # And save variables which we might clobber, if '-unclobber' switch is specified.
            if { $local_counter == 0 } {
                for { set i 0 } { $i < [ns_set size $selection] } { incr i } {
                    lappend local_columns [ns_set key $selection $i]
                }
                set local_columns [concat $local_columns $extend]
                if { !$append_p || ![info exists columns] } {
                    # store the list of columns in the var_name:columns variable
                    set columns $local_columns
                } else {
                    # Check that the columns match, if not throw an error
                    if { ![string equal [join [lsort -ascii $local_columns]] [join [lsort -ascii $columns]]] } {
                        error "Appending to a multirow with differing columns.
Original columns     : [join [lsort -ascii $columns] ", "].
Columns in this query: [join [lsort -ascii $local_columns] ", "]" "" "ACS_MULTIROW_APPEND_COLUMNS_MISMATCH"
                    }
                }

                # Save values of columns which we might clobber
                if { $unclobber_p && ![empty_string_p $code_block] } {
                    foreach col $columns {
                        upvar 1 $col column_value __saved_$col column_save

                        if { [info exists column_value] } {
                            if { [array exists column_value] } {
                                array set column_save [array get column_value]
                            } else {
                                set column_save $column_value
                            }

                            # Clear the variable
                            unset column_value
                        }
                    }
                }
            }

	    set cur_row_id [ns_set get $selection $join_column]
	    set cur_category_id [ns_set get $selection $categories_varname]
	    if {![empty_string_p $cur_category_id]} {
		lappend category_list $cur_category_id
	    }

	    # check if new row needs to be added to the multirow
	    if { $cur_row_id != $old_row_id || !$more_rows_p } {
		if {![empty_string_p $cur_category_id]} {
		    set category_list $cur_category_id
		} else {
		    set category_list ""
		}

		if { [empty_string_p $code_block] } {
		    # No code block - pull values directly into the var_name array.
		    if {$local_counter > 0} {
			set array_val($categories_varname) $old_category_list
		    }

		    # The extra loop after the last row is only for when there's a code block
		    if { !$more_rows_p } {
			break
		    }

		    incr counter
		    upvar $level_up "$var_name:$counter" array_val
		    set array_val(rownum) $counter
		    for { set i 0 } { $i < [ns_set size $selection] } { incr i } {
			set array_val([ns_set key $selection $i]) \
			    [ns_set value $selection $i]
		    }
		} else {
		    # There is a code block to execute

		    # Copy next_row to this_row, if it exists
		    if { [info exists this_row] } {
			unset this_row 
		    }
		    set array_get_next_row [array get next_row]
		    if { ![empty_string_p $array_get_next_row] } {
			array set this_row [array get next_row]
		    }

		    # Pull values from the query into next_row
		    if { [info exists next_row] } {
			unset next_row 
		    }
		    if { $more_rows_p } {
			for { set i 0 } { $i < [ns_set size $selection] } { incr i } {
			    set next_row([ns_set key $selection $i]) [ns_set value $selection $i]
			}   
		    }

		    # Process the row
		    if { [info exists this_row] } {
			# Pull values from this_row into local variables
			foreach name [array names this_row] {
			    upvar 1 $name column_value
			    set column_value $this_row($name)
			}
			uplevel 1 set $categories_varname \"$old_category_list\"

			# Initialize the "extend" columns to the empty string
			foreach column_name $extend {
			    upvar 1 $column_name column_value
			    set column_value ""
			}

			# Execute the code block
			set errno [catch { uplevel 1 $code_block } error]

			# Handle or propagate the error. Can't use the usual
			# "return -code $errno..." trick due to the db_with_handle
			# wrapped around this loop, so propagate it explicitly.
			switch $errno {
			    0 {
				# TCL_OK
			    }
			    1 {
				# TCL_ERROR
				global errorInfo errorCode
				error $error $errorInfo $errorCode
			    }
			    2 {
				# TCL_RETURN
				error "Cannot return from inside a db_multirow loop"
			    }
			    3 {
				# TCL_BREAK
				ns_db flush $db
				break
			    }
			    4 {
				# TCL_CONTINUE
				continue
			    }
			    default {
				error "Unknown return code: $errno"
			    }
			}
			
			# Pull the local variables back out and into the array.
			incr counter
			upvar $level_up "$var_name:$counter" array_val
			set array_val(rownum) $counter
			foreach column_name $columns {
			    upvar 1 $column_name column_value
			    set array_val($column_name) $column_value
			}
		    }
		}
	    }
	    set old_row_id $cur_row_id
	    set old_category_list $category_list
            incr local_counter
        }
    }

    # Restore values of columns which we've saved
    if { $unclobber_p && ![empty_string_p $code_block] && $local_counter > 0 } {
        foreach col $columns {
            upvar 1 $col column_value __saved_$col column_save

            # Unset it first, so the road's paved to restoring
            if { [info exists column_value] } {
                unset column_value
            }

            # Restore it
            if { [info exists column_save] } {
                if { [array exists column_save] } {
                    array set column_value [array get column_save]
                } else {
                    set column_value $column_save
                }
                
                # And then remove the saved col
                unset column_save
            }
        }
    }
    # Unset the next_row variable, just in case
    if { [info exists next_row] } {
        unset next_row
     }

    # If the if_no_rows_code is defined, go ahead and run it.
    if { $counter == 0 && [info exists if_no_rows_code_block] } {
        uplevel 1 $if_no_rows_code_block
    }
}
