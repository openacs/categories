if {![info exists cat]} {
    set cat ""
}

if { ![info exists orderby] || $orderby eq "" } {
    set orderby "object_title"
}
set user_id [ad_conn user_id]

# Get category data.
set counts {}
set node_id [ad_conn node_id]
set packages [subsite::util::packages -node_id $node_id]

db_foreach category_count {} {
    lappend counts $catid $count
}

category_tree::get_multirow -datasource categories -container_id [ad_conn subsite_id] -category_counts $counts

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
