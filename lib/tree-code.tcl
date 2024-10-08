ad_include_contract {
    This include produces a Tcl code snippet that serializes a
    category tree for import.
} {
    tree_id:object_type(category_tree)
}

set default_locale [lang::system::site_wide_locale]

array set tree [category_tree::get_data $tree_id $default_locale]

multirow create categories name level pad
foreach category [category_tree::get_tree -all $tree_id $default_locale] {
    lassign $category category_id category_name deprecated_p level
    multirow append categories $category_name $level [string repeat "&nbsp;" [expr {2 * $level - 2}]]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
