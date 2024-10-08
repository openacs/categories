ad_include_contract {
    Categorize
} {
    object_id:integer,notnull
    {container_id:integer,notnull "[ad_conn subsite_id]"}
}

set name [db_string title {select title from acs_objects where object_id = :object_id} -default $object_id]

# Category mapping stuff
# add category form
ad_form -action map -method GET -name catass -form {
    {object_id:integer(hidden)
        {value $object_id}
    }
    {container_id:integer(hidden)
        {value $container_id}
    }
}

category::ad_form::add_widgets -container_object_id $container_id -form_name catass

# mapped categories:
set catass_list [category::list::get_pretty_list \
                     -category_link_eval "list-categories?cat=\$__category_id" \
                     -remove_link_eval "remove?cat=\$__category_id&object_id=$object_id" \
                     -remove_link_text "<b style=\"color: red\">X</b>" \
                     [category::get_mapped_categories $object_id]]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
