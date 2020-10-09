ad_library {
    Automated tests.

    @author Simon Carstensen
    @creation-date 15 November 2003
    @cvs-id $Id$
}

aa_register_case -procs {
        category_tree::add
    } -cats {
        api
    } category_tree_add {
        Test the category_tree::add proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            #Create tree
            set tree_id [category_tree::add -name "foo"]

            set success_p [db_string success_p {
                select 1 from category_trees where tree_id = :tree_id
            } -default "0"]

            aa_equals "tree was created successfully" $success_p 1
        }
}

aa_register_case -procs {
        category_tree::add
        category::add
    } -cats {
        api
    } category_add {
        Test the category::add proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            #Create tree
            set tree_id [category_tree::add -name "foo"]

            # Create category
            set category_id [category::add \
                                 -tree_id $tree_id \
                                 -parent_id "" \
                                 -name "foo"]

            set success_p [db_string success_p {
                select 1 from categories where category_id = :category_id
            } -default "0"]

            aa_equals "category was created successfully" $success_p 1
        }
}

aa_register_case -procs {
        category::add
        category::delete
        category_tree::add
    } -cats {
        api
    } category_delete {
        Test the category::delete proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            #Create tree
            set tree_id [category_tree::add -name "foo"]

            # Create category
            set category_id [category::add \
                                 -tree_id $tree_id \
                                 -parent_id "" \
                                 -name "foo"]

            # Delete category
            category::delete -batch_mode $category_id

            set success_p [db_string success_p {
                select 0 from categories where category_id = :category_id
            } -default "1"]

            aa_equals "category was deleted successfully" $success_p 1
        }
}

aa_register_case -procs {
        category_tree::add
        category::add
        category::get
        category::get_children
        category::get_tree
        category::get_data
        category::get_id
        category::get_id_by_object_title
        category::get_name
        category::get_names
        category::get_parent
    } -cats {
        api
    } category_get_procs {
        Test different category::get procs.
} {
    aa_run_with_teardown -rollback -test_code {
        #
        #Create tree
        #
        set tree_name foo
        set tree_id [category_tree::add -name $tree_name]
        aa_log "Category tree: $tree_name $tree_id"
        #
        # Create root category
        #
        set root_category_id [category::add \
                                 -tree_id $tree_id \
                                 -parent_id "" \
                                 -name $tree_name]
        aa_log "Root category: $root_category_id"
        #
        # Create children categories
        #
        set children {bar1 "" bar2 "" bar3 ""}
        dict for { name id } $children {
            set category_id [category::add \
                                -tree_id $tree_id \
                                -parent_id $root_category_id \
                                -description "My category $name" \
                                -name $name]
            dict set children $name $category_id
            aa_log "New children category: $name $category_id"
        }
        #
        # Get
        #
        dict for { name id } $children {
            aa_equals "Check name and description" \
                     "[category::get -category_id $id]" \
                     "name $name description {My category $name}"
        }
        #
        # Get children
        #
        aa_equals "Check for children" \
                     "[lsort [category::get_children \
                                -category_id $root_category_id]]" \
                     "[lsort [dict values $children]]"
        #
        # Get tree
        #
        dict for { name id } $children {
            aa_equals "Check category tree" \
                     "[category::get_tree $id]" "$tree_id"
        }
        #
        # Get data
        #
        dict for { name id } $children {
            aa_equals "Check category data" \
                     "[category::get_data $id]" "$id $name $tree_id $tree_name"
        }
        #
        # Get id by name/title
        #
        dict for { name id } $children {
            aa_equals "Check category by name" "[category::get_id $name]" "$id"
            aa_equals "Check category by object title" \
                         "[category::get_id_by_object_title $name]" "$id"
        }
        #
        # Get name by id
        #
        dict for { name id } $children {
            aa_equals "Check category by id" "[category::get_name $id]" "$name"
        }
        aa_equals "Chec categories by ids" \
            "[lsort [category::get_names [dict values $children]]]" \
            "[lsort [dict keys $children]]"
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
