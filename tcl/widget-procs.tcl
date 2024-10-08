ad_library {
    Category widgets for the ArsDigita Templating System

    @author Timo Hentschel (timo@timohentschel.de)

    This is free software distributed under the terms of the GNU Public
    License.  Full text of the license is available from the GNU Project:
    http://www.fsf.org/copyleft/gpl.html
}

namespace eval template {}
namespace eval template::widget {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}

ad_proc -public template::widget::category {
    element_reference
    tag_attributes
} {
    Display the category widget. This has a multitude of options:
    <ul>
    <li>value: Values should be a list of two items: the object_id being viewed and the object_id which the trees are mapped to.
    This will get the mapped trees (if no value provided defaults to package_id) and the mapped categories for the object_id. If you
    do not provide a value, the following options are used:
    <li>category_application_id></li>
    <li>category_object_id</li>
    <li>category_tree_id</li>
    <li>category_subtree_id</li>
    <li>category_assign_single_p</li>
    <li>category_require_category_p</li>
    </ul>
    @author Timo Hentschel (timo@timohentschel.de)
} {
    upvar $element_reference element

    if { [info exists element(html)] } {
        array set attributes $element(html)
        array set ms_attributes $element(html)
    }

    array set attributes $tag_attributes
    array set ms_attributes $tag_attributes

    if { ![info exists element(display_widget)] } {
        set display_widget select
    } else {
        set display_widget $element(display_widget)
    }
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
    set assign_single_p f
    set require_category_p f
    set widget {}

    if { [info exists element(value)] && $element(value) ne ""
         && [llength $element(value)] == 2
     } {
        # Legacy method for passing parameters
        lassign $element(value) object_id package_id
    } else {
        if { [info exists element(category_application_id)] && $element(category_application_id) ne "" } {
            set package_id $element(category_application_id)
        }
        if { [info exists element(category_object_id)] && $element(category_object_id) ne "" } {
            set object_id $element(category_object_id)
        }
        if { [info exists element(category_tree_id)] && $element(category_tree_id) ne "" } {
            set tree_id $element(category_tree_id)
        }
        if { [info exists element(category_subtree_id)] && $element(category_subtree_id) ne "" } {
            set subtree_id $element(category_subtree_id)
        }
        if { [info exists element(category_assign_single_p)] && $element(category_assign_single_p) ne "" } {
            set assign_single_p $element(category_assign_single_p)
        }
        if { [info exists element(category_require_category_p)] && $element(category_require_category_p) ne "" } {
            set require_category_p $element(category_require_category_p)
        }
        if { [info exists element(category_widget)] && $element(category_widget) ne "" } {
            set widget $element(category_widget)
        }
    }
    if { $package_id eq "" } {
        set package_id [ad_conn package_id]
    }

    if { $object_id ne "" && ![info exists element(submit)] } {
        set mapped_categories [category::get_mapped_categories $object_id]
    } elseif { $element(values) ne "" && ![info exists element(submit)] } {
        set mapped_categories $element(values)
    } else {
        set mapped_categories [ns_querygetall $element(id)]
        # QUIRK: ns_querygetall returns a single-element list {{}} for no values
        if { [string equal $mapped_categories {{}}] } {
            set mapped_categories [list]
        }
    }
    set output {}

    if { $tree_id eq "" } {
        set mapped_trees [category_tree::get_mapped_trees $package_id]
    } else {
        set mapped_trees {}
        foreach \
            one_tree $tree_id \
            one_subtree $subtree_id \
            assign_single $assign_single_p \
            require_category $require_category_p \
            widget $widget {
                if {$assign_single eq ""} {
                    set assign_single f
                }
                if {$require_category eq ""} {
                    set require_category f
                }
                lappend mapped_trees [list $one_tree \
                                          [category_tree::get_name $one_tree] \
                                          $one_subtree $assign_single \
                                          $require_category $widget]
            }
    }

    foreach mapped_tree $mapped_trees {
        lassign $mapped_tree tree_id tree_name subtree_id assign_single_p require_category_p widget
        set tree_name [ns_quotehtml [lang::util::localize $tree_name]]
        set one_tree [list]

        if { $require_category_p == "t" } {
            set required_mark "<span class=\"form-required-mark\">*</span>"
        } else {
            set required_mark {}
        }

        foreach category [category_tree::get_tree -subtree_id $subtree_id $tree_id] {
            lassign $category category_id category_name deprecated_p level
            set category_name [ns_quotehtml [lang::util::localize $category_name]]
            if { $level>1 } {
                set category_name "[string repeat . [expr {2*$level -4}]]..$category_name"
            }
            lappend one_tree [list $category_name $category_id]
        }

        if { [llength $mapped_trees] > 1 } {
            append output "<div class=\"categorySelect\"><div class=\"categoryTreeName\">$tree_name$required_mark</div>"
        }

        if {$assign_single_p == "t" || $all_single_p} {
            # single-select widget
            if { $require_category_p == "f" } {
                set one_tree [linsert $one_tree 0 [list "" ""]]
            }
            #
            # We default to the select widget unless the valid option
            # of radio was provided.
            #
            #ns_log notice "template::widget::menu $element(name) $one_tree $mapped_categories" \
                "[array get attributes] $element(mode) $widget $display_widget" \
                [info exists element(display_widget)]

            if { $widget eq "radio" && ![info exists element(display_widget)] } {
                # checkbox was specified at mapping and the display widget was not explicitly defined code
                append output [template::widget::menu $element(name) $one_tree \
                                   $mapped_categories attributes $element(mode) radio]
            } else {
                append output [template::widget::menu $element(name) $one_tree \
                                   $mapped_categories attributes $element(mode) $display_widget]
            }
        } else {
            ns_log notice "template::widget::menu $element(name) $one_tree $mapped_categories [array get ms_attributes] $element(mode) $widget $display_widget [info exists element(display_widget)]"
            # we default to the multiselect widget (if user didn't override with single option) or select checkbox
            if { $widget eq "checkbox" && ![info exists element(display_widget)] } {
                # checkbox was specified at mapping and the display widget was not explicitly defined in code
                append output [template::widget::menu $element(name) $one_tree \
                                   $mapped_categories ms_attributes $element(mode) checkbox]
            } else {
                append output [template::widget::menu $element(name) $one_tree \
                                   $mapped_categories ms_attributes $element(mode) $display_widget]
            }
        }
        if { [llength $mapped_trees] > 1 } {
            append output "</div>"
        }
    }

    return [lang::util::localize $output]
}

ad_proc -public template::data::validate::category {
    value_ref
    message_ref
} {
    Validates the value of a category widget.

    @author Timo Hentschel (timo@timohentschel.de)
} {

    upvar 2 $message_ref message $value_ref values
    set invalid_values [list]

    foreach value $values {
        if {![regexp {^[+-]?\d+$} $value]} {
            lappend invalid_values $value
        }
    }

    set result 1
    if {[llength $invalid_values] > 0} {
        set result 0
        if {[llength $invalid_values] == 1} {
            set message "Invalid category [lindex $invalid_values 0]"
        } else {
            set message "Invalid categories [join $invalid_values ", "]"
        }
    }

    return $result
}

ad_proc -public template::data::transform::category {
    element_ref
} {
    Transform the value from the form request into the widget internal
    representation.

    @author Timo Hentschel (timo@timohentschel.de)
} {
    upvar $element_ref element
    set values [ns_querygetall $element(id)]

    # QUIRK: ns_querygetall returns a single-element list {{}} for no values
    if { [string equal $values {{}}] } {
        set values [list]
    }

    # to mark submission of form for rendering element in case of invalid data
    # (to preselect with last selected values)
    set element(submit) 1

    # Get parameters for the category widget
    set package_id {}
    set tree_id {}
    set subtree_id {}
    set require_category_p f

    if { [info exists element(value)] && $element(value) ne ""
         && [llength $element(value)] == 2
    } {
        # Legacy method for passing parameters
        set package_id [lindex $element(value) 1]
    } else {
        if { [info exists element(category_application_id)] && $element(category_application_id) ne "" } {
            set package_id $element(category_application_id)
        }
        if { [info exists element(category_tree_id)] && $element(category_tree_id) ne "" } {
            set tree_id $element(category_tree_id)
        }
        if { [info exists element(category_subtree_id)] && $element(category_subtree_id) ne "" } {
            set subtree_id $element(category_subtree_id)
        }
        if { [info exists element(category_require_category_p)] && $element(category_require_category_p) ne "" } {
            set require_category_p $element(category_require_category_p)
        }
    }
    if { $package_id eq "" } {
        set package_id [ad_conn package_id]
    }

    if { $tree_id eq "" } {
        set trees [list]
        foreach tree [category_tree::get_mapped_trees $package_id] {
            lassign $tree tree_id tree_name subtree_id assign_single_p require_category_p
            if {$require_category_p == "t" || ![info exists element(optional)]} {
                lappend trees [list $tree_id $subtree_id]
            }
        }
    } else {
        if {$require_category_p == "t"} {
            set trees [list [list $tree_id $subtree_id]]
        } else {
            set trees [list]
        }
    }

    set trees_without_category [list]
    foreach tree $trees {
        lassign $tree tree_id subtree_id
        # get categories of every tree requiring a categorization
        set tree_categories [lmap \
                                 category \
                                 [category_tree::get_tree -all -subtree_id $subtree_id $tree_id] \
                                 {lindex $category 0}]
        set found_p 0
        # check if at least one selected category is among tree categories
        foreach value $values {
            if {$value in $tree_categories} {
                set found_p 1
                break
            }
        }
        if {!$found_p} {
            # no categories of this tree selected, so add for error message
            lappend trees_without_category [category_tree::get_name $tree_id]
        }
    }
    if {[llength $trees_without_category] > 0} {
        # some trees require category, but none selected
        template::element::set_error $element(form_id) $element(id) "Please select a category for [join $trees_without_category ", "]."
        return [list]
    }

    return $values
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
