if {![exists_and_not_null cat]} {
    set cat {}
}

if {![exists_and_not_null orderby]} {
    set orderby "object_title"
}

# Get category data.
set counts {}
set node_id [ad_conn node_id]
set packages [categories-ui::util::packages -node_id $node_id]
db_foreach category_count "
    SELECT c.category_id as catid, count(*) as count
    FROM category_object_map c, acs_objects o
    where c.object_id = o.object_id
    and o.package_id in ([join $packages ,])
    group by c.category_id
" { 
    lappend counts $catid $count
}

category_tree::get_multirow -datasource categories -container_id [ad_conn subsite_id] -category_counts $counts
