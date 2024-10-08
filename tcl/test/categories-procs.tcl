ad_library {
    Automated tests.

    @author Simon Carstensen
    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 15 November 2003
    @cvs-id $Id$
}

ad_proc -private category_tree::exists_p {
    tree_id
} {
    Checks if category tree exists directly in the DB.

    @param tree_id
    @return 1 if exists, 0 if doesn't
} {
    return [db_0or1row tree_exists {
        select 1 from category_trees where tree_id = :tree_id
    }]
}

ad_proc -private category::exists_p {
    category_id
} {
    Checks if category exists directly in the DB.

    @param category_id
    @return 1 if exists, 0 if doesn't
} {
    return [db_0or1row category_exists {
        select 1 from categories where category_id = :category_id
    }]
}

aa_register_case -procs {
    category_tree::import
    category_tree::exists_p
    category_tree::get_translation
    category_tree::xml::import
    category_tree::xml::import_from_file
} -cats {
    api
} category_tree_import {
    Test the import api
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            aa_section "Tcl Import"

            set tree_id [category_tree::import \
                             -name regions \
                             -description {regions and states} \
                             -categories {
                                 1 europe
                                 2 germany
                                 2 {united kingdom}
                                 2 france
                                 1 asia
                                 2 china
                                 1 {north america}
                                 2 {united states}
                             }]

            aa_true "tree was created successfully" \
                [category_tree::exists_p $tree_id]

            aa_equals "category_tree::get_translation returns expected" \
                [category_tree::get_translation $tree_id] \
                {regions {regions and states}}

            aa_true "Category 'europe' exists" [db_0or1row check {
                select c.category_id as europe_category_id
                from categories c, category_translations t
                where c.category_id = t.category_id
                  and c.parent_id is null
                  and t.locale = 'en_US'
                  and t.name = 'europe'
            }]

            aa_true "Category 'germany' is a child of 'europe'" [db_0or1row check {
                select 1
                from categories c, category_translations t
                where c.category_id = t.category_id
                  and c.parent_id = :europe_category_id
                  and t.locale = 'en_US'
                  and t.name = 'germany'
            }]

            aa_equals "Tree has 8 categories" \
                [db_string count {
                    select count(*) from categories
                    where tree_id = :tree_id
                }] \
                8

            aa_section "XML Import"

            set xml {<?xml version="1.0"?>
                <tree>
                   <translation locale="en_US">
                      <name>A tree</name>
                      <description>I am a tree</description>
                   </translation>
                   <translation locale="it_IT">
                      <name>Un albero</name>
                      <description>Io sono un albero</description>
                   </translation>
                   <category>
                      <translation locale="en_US">
                         <name>A category</name>
                         <description>I am a category</description>
                      </translation>
                      <translation locale="it_IT">
                         <name>Una categoria</name>
                         <description>Io sono una categoria</description>
                      </translation>
                   </category>
                   <category>
                      <translation locale="en_US">
                         <name>Another category</name>
                         <description>I am another category</description>
                      </translation>
                      <translation locale="it_IT">
                         <name>Un'altra categoria</name>
                         <description>Io sono un'altra categoria</description>
                      </translation>
                      <category>
                         <translation locale="en_US">
                            <name>A child category</name>
                            <description>I am a child category</description>
                         </translation>
                         <translation locale="it_IT">
                            <name>Una categoria figlia</name>
                            <description>Io sono una categoria figlia</description>
                         </translation>
                      </category>
                   </category>
                </tree>
            }

            set wfd [ad_opentmpfile tmpfile]
            puts -nonewline $wfd $xml
            close $wfd

            set tree_id [category_tree::xml::import_from_file -site_wide $tmpfile]

            file delete -- $tmpfile

            aa_true "tree was created successfully" \
                [category_tree::exists_p $tree_id]

            aa_equals "category_tree::get_translation returns expected" \
                [category_tree::get_translation $tree_id en_US] \
                {{A tree} {I am a tree}}

            aa_equals "category_tree::get_translation returns expected" \
                [category_tree::get_translation $tree_id it_IT] \
                {{Un albero} {Io sono un albero}}

            aa_equals "Tree has 3 categories" \
                [db_string count {
                    select count(*) from categories
                    where tree_id = :tree_id
                }] \
                3

        }
}

aa_register_case -procs {
    category_tree::add
    category_tree::exists_p
    category::add
    category::exists_p
    category_synonym::add
    category_synonym::search
    category_synonym::edit
    category_synonym::delete
} -cats {
    api
} category_synonyms {
    Test the category::synonym api
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            #Create tree
            set tree_id [category_tree::add -name "foo"]

            aa_true "tree was created successfully" \
                [category_tree::exists_p $tree_id]

            # Create category
            set category_id [category::add \
                                 -tree_id $tree_id \
                                 -parent_id "" \
                                 -name "foo"]

            aa_true "category was created successfully" \
                [category::exists_p $category_id]

            set synonym_id [category_synonym::add \
                                -name foobar \
                                -category_id $category_id]

            aa_true "Synonym was created" [db_0or1row check {
                select 1 from category_synonyms
                where synonym_id = :synonym_id
                and category_id = :category_id
                and name = 'foobar'
            }]

            set query_id [category_synonym::search -search_text foo]

            aa_true "Query was created" [db_0or1row check {
                select 1 from category_search_results
                where synonym_id = :synonym_id
                and query_id = :query_id
            }]

            category_synonym::edit \
                -synonym_id $synonym_id \
                -name barfoo
            aa_true "Synonym was updated" [db_0or1row check {
                select 1 from category_synonyms
                where synonym_id = :synonym_id
                and category_id = :category_id
                and name = 'barfoo'
            }]

            category_synonym::delete $synonym_id
            aa_false "Synonym was deleted" [db_0or1row check {
                select 1 from category_synonyms
                where synonym_id = :synonym_id
            }]

        }
}

aa_register_case -procs {
    category_tree::add
    category::add
    category_link::add
    category_link::delete
} -cats {
    api
} category_link {
    Test the category::link api
} {
    aa_run_with_teardown \
        -rollback \
        -test_code {

            set tree_id_1 [category_tree::add -name "foo"]

            set category_id_1 [category::add \
                                   -tree_id $tree_id_1 \
                                   -parent_id "" \
                                   -name "foo cat"]

            set tree_id_2 [category_tree::add -name "bar"]

            set category_id_2 [category::add \
                                 -tree_id $tree_id_2 \
                                   -parent_id "" \
                                   -name "bar cat"]

            set link_id [category_link::add \
                             -from_category_id $category_id_1 \
                             -to_category_id $category_id_2]

            aa_true "Link was created" [db_0or1row check {
                select 1 from category_links
                where link_id = :link_id
                and from_category_id = :category_id_1
                and to_category_id = :category_id_2
            }]

            category_link::delete $link_id

            aa_false "Link was deleted" [db_0or1row check {
                select 1 from category_links
                where link_id = :link_id
            }]
        }
}

aa_register_case -procs {
    category::add
    category::get_name
    category::get
    category::update
    category::delete
    category_tree::add
    category::exists_p
    category::flush_translation_cache
    category::phase_in
    category::phase_out
    category::get_children
    category_tree::update
    category_tree::reset_cache
    category_tree::get_tree
    category_tree::get_translation
    category_tree::get_multirow
} -cats {
    api
} category_crud {
    Test the CRUD operations on a category.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set locale it_IT

            aa_section "Create tree"
            set tree_id [category_tree::add \
                             -name "foo" -locale $locale]

            category_tree::update \
                -tree_id $tree_id \
                -locale de_DE \
                -name föö \
                -description Descriptiön
            aa_equals "category_tree::get_translation returns expected" \
                [category_tree::get_translation $tree_id de_DE] \
                [list "föö" "Descriptiön"]

            aa_section "Create category"
            set category_id [category::add \
                                 -tree_id $tree_id \
                                 -parent_id "" \
                                 -locale $locale \
                                 -name "foo"]

            aa_equals "Name is right" \
                [category::get_name $category_id $locale] foo

            aa_section "Update category"
            category::update \
                -category_id $category_id \
                -name boo \
                -locale $locale \
                -description something
            set attrs [category::get \
                           -category_id $category_id \
                           -locale $locale]
            aa_equals "name is as expected" \
                [dict get $attrs name] boo
            aa_equals "Description is as expected" \
                [dict get $attrs description] something

            set category_child_1 [category::add \
                                      -tree_id $tree_id \
                                      -parent_id $category_id \
                                      -locale $locale \
                                      -name "foo child 1"]
            set category_child_2 [category::add \
                                      -tree_id $tree_id \
                                      -parent_id $category_id \
                                      -locale $locale \
                                      -name "foo child 2"]

            aa_equals "Category '$category_id' has 2 visible children" \
                [llength [category::get_children -category_id $category_id]] \
                2

            category_tree::get_multirow \
                -tree_id $tree_id \
                -datasource __test_category_crud

            aa_true "Multirow __test_category_crud exists" \
                [::template::multirow exists __test_category_crud]
            aa_equals "Multirow __test_category_crud has 3 rows" \
                [::template::multirow size __test_category_crud] \
                3
            set result [list]
            ::template::multirow -unclobber foreach __test_category_crud {
                lappend result \
                    $tree_id \
                    $tree_name \
                    $category_id \
                    $category_name \
                    $level \
                    $pad \
                    $deprecated_p \
                    $count \
                    $child_sum
            }
            aa_equals "Multirow returns expected" \
                [list \
                     $tree_id foo $category_id foo 1 {} f 0 0 \
                     $tree_id foo $category_child_1 {foo child 1} 2 .. f 0 0 \
                     $tree_id foo $category_child_2 {foo child 2} 2 .. f 0 0] \
                $result

            aa_log "Phase out child '$category_child_1'"
            category::phase_out $category_child_1

            aa_equals "Category '$category_id' has 1 visible child" \
                [llength [category::get_children -category_id $category_id]] \
                1

            aa_log "Phase out child '$category_child_2'"
            category::phase_out $category_child_2

            aa_equals "Category '$category_id' has 0 visible children" \
                [llength [category::get_children -category_id $category_id]] \
                0

            aa_equals "category_tree::get_tree returns expected (pre-flush)" \
                [category_tree::get_tree -all $tree_id] \
                [list \
                     [list $category_id foo f 1] \
                     [list $category_child_1 {foo child 1} f 2] \
                     [list $category_child_2 {foo child 2} f 2] \
                    ]

            aa_log "Flush cache"
            category_tree::reset_cache

            aa_equals "category_tree::get_tree returns expected (post-flush)" \
                [category_tree::get_tree -all $tree_id] \
                [list \
                     [list $category_id foo f 1] \
                     [list $category_child_1 {foo child 1} t 2] \
                     [list $category_child_2 {foo child 2} t 2] \
                    ]

            category_tree::get_multirow \
                -tree_id $tree_id \
                -datasource __test_category_crud

            aa_true "Multirow __test_category_crud exists" \
                [::template::multirow exists __test_category_crud]
            aa_equals "Multirow __test_category_crud has 1 row (phased out categories skipped)" \
                [::template::multirow size __test_category_crud] \
                1

            aa_log "Phase children back in"
            category::phase_in $category_child_1
            category::phase_in $category_child_2

            aa_equals "Category '$category_id' has 2 visible children again" \
                [llength [category::get_children -category_id $category_id]] \
                2

            aa_log "Delete children"
            category::delete $category_child_1
            category::delete $category_child_2

            aa_section "Delete category (batch)"
            category::delete -batch_mode $category_id
            aa_false "category was deleted successfully" \
                [category::exists_p $category_id]
            aa_equals "Cache entry was not flushed" \
                [category::get_name $category_id $locale] boo

            aa_section "Flush cache"
            category::flush_translation_cache $category_id
            aa_false "Cache entry was flushed" \
                {[category::get_name $category_id $locale] ne ""}
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
        aa_equals "Check categories by ids" \
            "[lsort [category::get_names [dict values $children]]]" \
            "[lsort [dict keys $children]]"
    }
}

aa_register_case -procs {
    category::reset_translation_cache
    category_tree::reset_translation_cache
} -cats {
    api
} category_init_procs {
    Test initialization behavior: this package will build up certain
    caches at startup.
} {
    set one_tree_id [db_string get_tree {
        select min(tree_id) from category_trees
    } -default ""]
    aa_equals "Tree translations have already been loaded at startup" \
        [expr {$one_tree_id ne ""}] [nsv_exists category_tree_translations $one_tree_id]

    set one_category_id [db_string get_category {
        select min(category_id) from categories
    } -default ""]
    aa_equals "Categroy translations have already been loaded at startup" \
        [expr {$one_category_id ne ""}] [nsv_exists categories $one_category_id]
}

aa_register_case -procs {
    category_tree::add
    category_tree::get_name
    category_tree::get_data
    category_tree::get_id
    category_tree::get_id_by_object_title
    category_tree::get_categories
    category_tree::map
    category_tree::get_mapped_trees
    category_tree::get_mapped_trees_from_object_list
    category_tree::edit_mapping
    category_tree::unmap
    category_tree::copy
    category_tree::flush_cache
    category_tree::update
    category_tree::flush_translation_cache
    category_tree::delete
    category_tree::usage
    category::add
    category::count_children
    category::change_parent
    category::get_children
    category::get_name
    category::get_names
    category::relation::add_meta_category
    category::relation::get_meta_categories
    category_tree::exists_p
    package_instantiate_object
    relation::get_object_one
} -cats {
    api
} category_tree_procs {
    Test different category_tree procs.
} {
    aa_run_with_teardown -rollback -test_code {
        #
        # Create tree
        #
        set tree_name foo
        set tree_description "Just a dummy category tree"
        set tree_site_wide_p f
        set tree_id [category_tree::add \
                        -description $tree_description \
                        -site_wide_p  $tree_site_wide_p \
                        -name $tree_name]
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
        # Create a couple of objects
        #
        set object_id_1 [package_instantiate_object acs_object]
        set object_id_2 [package_instantiate_object acs_object]
        set object_ids [list $object_id_1 $object_id_2]
        aa_log "New objects: $object_id_1 $object_id_2"
        #
        # Get name
        #
        aa_equals "Check category tree name" \
                    "[category_tree::get_name $tree_id]" $tree_name
        #
        # Get data
        #
        aa_equals "Check category tree data" \
                    "[category_tree::get_data $tree_id]" \
                    "description {$tree_description} tree_name $tree_name site_wide_p $tree_site_wide_p"
        #
        # Get ID by name/title
        #
        aa_equals "Check category tree ID by name" \
                    "[category_tree::get_id $tree_name]" $tree_id
        aa_equals "Check category tree ID by object title" \
                    "[category_tree::get_id_by_object_title -title $tree_name]" \
                    $tree_id
        #
        # Get root categories of a tree
        #
        aa_equals "Check root categories of a tree" \
                    "[category_tree::get_categories -tree_id $tree_id]" \
                    "$root_category_id"
        #
        # Map category tree to an object
        #
        category_tree::map -tree_id $tree_id -object_id $object_id_1
        category_tree::map -tree_id $tree_id -object_id $object_id_2
        aa_equals "Check mapped category trees of an object" \
            "[lindex [category_tree::get_mapped_trees $object_id_1] 0 0]" \
            "$tree_id"
        foreach mapped_trees [category_tree::get_mapped_trees_from_object_list $object_ids] {
            aa_equals "Check mapped category trees of an object list" \
                "[lindex $mapped_trees 0 0]" "$tree_id"
        }

        set user_id [ad_conn user_id]
        aa_equals "category_tree::usage returns expected" \
            [category_tree::usage $tree_id] \
            [db_list_of_lists category_tree_usage {
                select t.pretty_plural, n.object_id, n.title, p.package_id,
                       p.instance_name,
                       acs_permission.permission_p(n.object_id, :user_id, 'read') as read_p
                from category_tree_map m, acs_objects n,
                     apm_packages p, apm_package_types t
                where m.tree_id = :tree_id
                and n.object_id = m.object_id
                and p.package_id = n.package_id
                and t.package_key = p.package_key
        }]

        #
        # Edit mapping
        #
        category_tree::edit_mapping \
            -tree_id $tree_id \
            -object_id $object_id_1 \
            -assign_single_p t \
            -require_category_p t
        set assign_single_p     [lindex [category_tree::get_mapped_trees $object_id_1] 0 3]
        set require_category_p  [lindex [category_tree::get_mapped_trees $object_id_1] 0 4]
        aa_equals "Check edited mapped category trees of an object" \
            "assign_single_p: $assign_single_p require_category_p: $require_category_p" \
            "assign_single_p: t require_category_p: t"
        category_tree::edit_mapping \
            -tree_id $tree_id \
            -object_id $object_id_1 \
            -assign_single_p f \
            -require_category_p f
        set assign_single_p     [lindex [category_tree::get_mapped_trees $object_id_1] 0 3]
        set require_category_p  [lindex [category_tree::get_mapped_trees $object_id_1] 0 4]
        aa_equals "Check edited mapped category trees of an object" \
            "assign_single_p: $assign_single_p require_category_p: $require_category_p" \
            "assign_single_p: f require_category_p: f"
        #
        # Unmap
        #
        category_tree::unmap -tree_id $tree_id -object_id $object_id_1
        category_tree::unmap -tree_id $tree_id -object_id $object_id_2
        aa_equals "Check unmapped category trees of an object" \
            "[category_tree::get_mapped_trees $object_id_1]" ""
        aa_equals "Check unmapped category trees of an object list" \
            "[category_tree::get_mapped_trees_from_object_list $object_ids]" ""
        #
        # Copy
        #
        set copy_tree_name "bar"
        set copy_tree_description "Copied tree"
        set copy_tree_id [category_tree::add \
                        -description $copy_tree_description \
                        -site_wide_p f \
                        -name $copy_tree_name]
        aa_log "Category tree: $copy_tree_name $copy_tree_id"
        category_tree::copy -source_tree $tree_id -dest_tree $copy_tree_id
        set copy_root_category_id [category_tree::get_categories -tree_id $copy_tree_id]
        aa_equals "Check copied category tree root name" \
                    "[category::get_name $copy_root_category_id]" "$tree_name"
        aa_equals "Check copied category children" \
                     "[lsort [category::get_names [category::get_children \
                                -category_id $copy_root_category_id]]]" \
                     "[lsort [dict keys $children]]"
        aa_equals "Count category children" \
            [category::count_children -category_id $copy_root_category_id] 3
        #
        # Change parent (make bar1 parent of bar2)
        #
        set bar1_id [dict get $children bar1]
        set bar2_id [dict get $children bar2]
        category::change_parent \
            -category_id $bar1_id \
            -tree_id $copy_tree_id \
            -parent_id $bar2_id
        aa_equals "Check new parent category children" \
                    "[category::get_children -category_id $bar2_id]" "$bar1_id"
        #
        # Create a meta category from bar1 and bar2
        #
        set user_info [acs::test::user::create]
        set user_id [dict get $user_info user_id]
        set user_meta_category_id [category::relation::add_meta_category \
            -category_id_one $bar1_id \
            -category_id_two $bar2_id \
            -user_id $user_id]
        set meta_category_id [relation::get_object_one \
                -rel_type "user_meta_category_rel" \
                -object_id_two $user_id]
        aa_log "New meta category $meta_category_id from $bar1_id and $bar2_id"
        aa_equals "Check categories from a meta category" \
            "[lsort [category::relation::get_meta_categories \
                        -rel_id $meta_category_id]]" \
            "[lsort [list $bar1_id $bar2_id]]"

        #
        # Update
        #
        set new_description "The new description"
        set new_name "The new name"
        category_tree::update \
            -tree_id $copy_tree_id \
            -name $new_name \
            -description $new_description
        aa_equals "Check updated category tree data" \
                    "[category_tree::get_data $copy_tree_id]" \
                    "description {$new_description} tree_name {$new_name} site_wide_p f"
        #
        # Delete
        #
        aa_true "Check category tree before deletion" \
            [category_tree::exists_p $copy_tree_id]
        category_tree::delete $copy_tree_id
        aa_false "Check category tree after deletion" \
            [category_tree::exists_p $copy_tree_id]
    }
}

aa_register_case -procs {
    category::map_object
    category::get_mapped_categories
    category::get_mapped_categories_multirow
    category::get_objects
    category::get_object_context
    category_tree::get_trees
    category::tagcloud::get_tags
    category::tagcloud::tagcloud
} -cats {
    api smoke
} category_object_mapping {
    Test api to map a category to an object
} {
    aa_run_with_teardown -rollback -test_code {

        #
        # We need a content item to test category::get_objects later
        #
        set folder_id [content::folder::new \
                           -label "One folder" \
                           -name __category_object_mapping_folder]
        content::folder::register_content_type \
            -folder_id $folder_id  -content_type "content_revision"
        set one_object_id [content::item::new \
                               -name __category_object_mapping \
                               -parent_id $folder_id \
                               -title "One Item" \
                               -content_type content_revision \
                               -text {some text}]

        aa_equals "Object context for the object is as expected" \
            [list "/o/$one_object_id" [acs_object_name $one_object_id]] \
            [category::get_object_context $one_object_id]

        aa_section "Create tree"
        set tree_name foo
        set tree_description "Just a dummy category tree"
        set tree_site_wide_p f
        set tree_id [category_tree::add \
                        -description $tree_description \
                        -site_wide_p  $tree_site_wide_p \
                        -name $tree_name]
        aa_log "Category tree: $tree_name $tree_id"
        aa_section "Create root category"
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

        aa_section "Map categories"

        aa_equals "category_tree::get_trees returns expected" \
            [category_tree::get_trees $one_object_id] \
            ""

        set categories [list \
                            $root_category_id \
                            {*}[dict values $children]]
        category::map_object \
            -object_id $one_object_id \
            $categories

        aa_section "Check mappings"

        set mapped_categories [category::get_mapped_categories $one_object_id]
        aa_equals "Api retrieves the expected mapped categories" \
            [lsort $categories] [lsort $mapped_categories]

        set mapped_categories [category::get_mapped_categories -tree_id $one_object_id $one_object_id]
        aa_equals "Api retrieves 0 categories if the tree is wrong" \
            [llength $mapped_categories] 0

        set mapped_categories [category::get_mapped_categories -tree_id $tree_id $one_object_id]
        aa_equals "Api retrieves the expected mapped categories also by tree" \
            [lsort $categories] [lsort $mapped_categories]

        category::get_mapped_categories_multirow -multirow __test_category_map $one_object_id
        aa_true "The multirow was created" \
            [template::multirow exists __test_category_map]
        aa_equals "The multirow has the same size as the mapped categories" \
            [template::multirow size __test_category_map] [llength $mapped_categories]
        template::multirow sort __test_category_map category_id
        set i 0
        template::multirow foreach __test_category_map {
            aa_equals "Category in the multirow corresponds to that from the list" \
                $category_id [lindex $mapped_categories $i]
            incr i
        }

        aa_equals "category_tree::get_trees returns expected" \
            [category_tree::get_trees $one_object_id] \
            [list $tree_id]

        set cloud_tags [category::tagcloud::get_tags -tree_id $tree_id]
        aa_equals "category::tagcloud::get_tags returns expected" \
            [lsort -index 0 $cloud_tags] \
            [list \
                 [list $root_category_id 1 $tree_name] \
                 [list [lindex $categories 1] 1 "bar1"] \
                 [list [lindex $categories 2] 1 "bar2"] \
                 [list [lindex $categories 3] 1 "bar3"] \
                ]

        set tag_cloud [category::tagcloud::tagcloud -tree_id $tree_id]
        set rgxp <.*
        foreach tag $cloud_tags {
            append rgxp [join $tag .*].*
        }
        append rgxp >
        aa_true "Tagcloud looks like '$rgxp'" [regexp $rgxp $tag_cloud]

        foreach category_id $categories {
            set object_ids [category::get_objects -category_id $category_id]
            aa_equals "Getting the object from one of the mapped categories '$category_id' returns our object" \
                $object_ids $one_object_id
            set object_ids [category::get_objects -category_id $category_id -content_type content_revision]
            aa_equals "Getting the content_revision objects from one of the mapped categories '$category_id' returns our object" \
                $object_ids $one_object_id
            set object_ids [category::get_objects -category_id $category_id -object_type content_item]
            aa_equals "Getting the content_item objects from one of the mapped categories '$category_id' returns our object" \
                $object_ids $one_object_id

            set object_ids [category::get_objects -category_id $category_id -content_type text/plain]
            aa_equals "Getting the text/plain objects from one of the mapped categories '$category_id' returns nothing" \
                [llength $object_ids] 0
            set object_ids [category::get_objects -category_id $category_id -object_type user]
            aa_equals "Getting the user objects from one of the mapped categories '$category_id' returns nothing" \
                [llength $object_ids] 0
        }


        aa_section "Unmap categories"
        category::map_object \
            -remove_old \
            -object_id $one_object_id \
            {}

        aa_equals "Mappings were deleted" \
            [llength [category::get_mapped_categories $one_object_id]] 0
        aa_equals "Mappings were deleted also by tree" \
            [llength [category::get_mapped_categories -tree_id $tree_id $one_object_id]] 0
        category::get_mapped_categories_multirow -multirow __test_category_map $one_object_id
        aa_equals "The multirow has size 0" \
            [template::multirow size __test_category_map] 0
    }
}

aa_register_case -procs {
    category::pageurl
    category_tree::pageurl
} -cats {
    api smoke
} AcsObject_service_contract_implementations {
    Test api implementing the AcsObject service contract
} {
    aa_run_with_teardown -rollback -test_code {
        aa_section "Create tree"
        set tree_name foo
        set tree_description "Just a dummy category tree"
        set tree_site_wide_p f
        set tree_id [category_tree::add \
                         -description $tree_description \
                         -site_wide_p $tree_site_wide_p \
                         -name $tree_name]
        aa_log "Category tree: $tree_name $tree_id"
        aa_section "Create root category"
        set category_id [category::add \
                             -tree_id $tree_id \
                             -parent_id "" \
                             -name $tree_name]

        set link [acs_sc::invoke \
                      -contract AcsObject \
                      -operation PageUrl \
                      -impl category_idhandler \
                      -call_args [list $category_id]]
        aa_equals "category_idhandler.PageUrl"\
            $link "categories-browse?tree_ids=$tree_id&category_ids=$category_id"

        set link [acs_sc::invoke \
                      -contract AcsObject \
                      -operation PageUrl \
                      -impl category_tree_idhandler \
                      -call_args [list $tree_id]]
        aa_equals "category_tree_idhandler.PageUrl" \
            $link "categories-browse?tree_ids=$tree_id"
    }
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
