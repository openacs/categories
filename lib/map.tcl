ad_include_contract {
    UI to map an object to a container
} {
    object_id:integer,notnull
    container_id:integer,notnull
} -errors {
    object_id {You must specify an item to map}
    container_id {You must specify a container to map the object to}
}

ad_form -name catass -form {
    {object_id:integer(hidden)
        {value $object_id}
    }
    {container_id:integer(hidden)
        {value $container_id}
    }
}
category::ad_form::add_widgets -container_object_id $container_id -form_name catass
ad_form -extend -name catass -on_submit {
    ns_log Notice "JCD: trees [category_tree::get_mapped_trees $container_id]"
    set category_ids [category::ad_form::get_categories -container_object_id $container_id]
    ns_log Notice "JCD: mapping $category_ids"
    category::map_object \
        -object_id $object_id \
        $category_ids
}

ad_returnredirect [util::get_referrer]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
