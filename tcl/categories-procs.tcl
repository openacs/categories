ad_library {
    Procs for the site-wide categorization package.

    @author Timo Hentschel (timo@timohentschel.de)

    @creation-date 16 April 2003
    @cvs-id $Id:
}


namespace eval category {}

ad_proc -public category::add {
    {-category_id ""}
    -tree_id:required
    -parent_id:required
    -name:required
    {-locale ""}
    {-description ""}
    {-deprecated_p "f"}
    {-user_id ""}
    {-creation_ip ""}
} {
    Insert a new category. The same translation will be added in the default
    language if it's in a different language.

    @option category_id category_id of the category to be inserted.
    @option locale locale of the language. [ad_conn locale] used by default.
    @option name category name.
    @option description description of the category.
    @option deprecated_p is category deprecated?
    @option tree_id tree_id of the category the category should be added.
    @option parent_id id of the parent category. "" if top level category.
    @option user_id user that adds the category. [ad_conn user_id] used by default.
    @option creation_ip ip-address of the user that adds the category. [ad_conn peeraddr] used by default.
    @return category_id
    @author Timo Hentschel (timo@timohentschel.de)
} {
    if {[empty_string_p $user_id]} {
        set user_id [ad_conn user_id]
    }
    if {[empty_string_p $creation_ip]} {
        set creation_ip [ad_conn peeraddr]
    }
    if {[empty_string_p $locale]} {
        set locale [ad_conn locale]
    }
    db_transaction {
        set category_id [db_exec_plsql insert_category ""]

        set default_locale [ad_parameter DefaultLocale acs-lang "en_US"]
        if {$locale != $default_locale} {
    	db_exec_plsql insert_default_category ""
        }
        category_tree::flush_cache $tree_id
        flush_translation_cache $category_id
    }
    return $category_id
}

ad_proc -public category::update {
    -category_id:required
    -name:required
    {-locale ""}
    {-description ""}
    {-user_id ""}
    {-modifying_ip ""}
} {
    Updates/inserts a category translation.

    @option category_id category_id of the category to be updated.
    @option locale locale of the language. [ad_conn locale] used by default.
    @option name category name.
    @option description description of the category.
    @option user_id user that updates the category. [ad_conn user_id] used by default.
    @option modifying_ip ip-address of the user that updates the category. [ad_conn peeraddr] used by default.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    if {[empty_string_p $user_id]} {
        set user_id [ad_conn user_id]
    }
    if {[empty_string_p $modifying_ip]} {
        set modifying_ip [ad_conn peeraddr]
    }
    if {[empty_string_p $locale]} {
        set locale [ad_conn locale]
    }
    db_transaction {
        if {![db_0or1row check_category_existence ""]} {
    	db_exec_plsql insert_category_translation ""
        } else {
    	db_exec_plsql update_category_translation ""
        }
        flush_translation_cache $category_id
    }
}

ad_proc -public category::delete {
    -batch_mode:boolean
    category_id
} {
    Deletes a category.
    category_tree:flush_cache should be used afterwards.

    @option batch_mode Indicates that the cache for category translations
                       should not be flushed. Useful when deleting several
                       categories at once.
                       Don't forget to call reset_translation_cache
    @param category_id category_id of the category to be deleted.
    @see category::reset_translation_cache
    @see category_tree::flush_cache
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_exec_plsql delete_category ""
    if {!$batch_mode_p} {
        flush_translation_cache $category_id
    }
}

ad_proc -public category::change_parent {
    -category_id:required
    -tree_id:required
    {-parent_id [db_null]}
} {
    Changes parent category of a category.
    @option category_id category_id whose parent should change.
    @option tree_id tree_id of the category tree.
    @option parent_id new parent category_id.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_exec_plsql change_parent_category ""
    category_tree::flush_cache $tree_id
}

ad_proc -public category::phase_in { category_id } {
    Marks a category to be visible for categorizing new objects /
    update existing objects.
    Make sure to use category_tree::flush_cache afterwards.

    @param category_id category_id of the category to be phased in
    @see category::phase_out
    @see category_tree::flush_cache
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_exec_plsql phase_in ""
}

ad_proc -public category::phase_out { category_id } {
    Marks a category to be phasing out. That means this category and
    all its subcategories will no longer appear in the categorization
    widget to categorize new objects / update existing objects,
    but all existing categorizations will still remain valid.
    Make sure to use category_tree::flush_cache afterwards.

    @param category_id category_id of the category to be phased out
    @see category::phase_in
    @see category_tree::flush_cache
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_exec_plsql phase_out ""
}

ad_proc -public category::map_object {
    {-remove_old:boolean}
    -object_id:required
    category_id_list
} {
    Map an object to several categories.

    @option remove_old Modifier to be used when categorizing existing objects. Will make sure to delete all old categorizations.
    @option object_id object to be categorized.
    @param category_id_list tcl-list of category_ids to be mapped to the object.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_transaction {
        # Remove any already mapped categories if we are updating
        if { $remove_old_p } {
    	db_dml remove_mapped_categories ""
        }

        foreach category_id $category_id_list {
	    if {![empty_string_p $category_id]} {
		db_dml insert_mapped_categories ""
	    }
        }

	# Adds categorizations to linked categories
	db_dml insert_linked_categories ""
    }
}

ad_proc -public category::get_mapped_categories { object_id } {
    Gets the list of categories mapped to an object.

    @param object_id object of which we want to know the mapped categories.
    @return tcl-list of category_ids
    @author Timo Hentschel (timo@timohentschel.de)
} {
    set result [db_list get_mapped_categories ""]

    return $result
}

ad_proc -public category::reset_translation_cache { } {
    Reloads all category translations in the cache.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    catch {nsv_unset categories}
    set category_id_old 0
    db_foreach reset_translation_cache "" {
        if {$category_id != $category_id_old && $category_id_old != 0} {
    	nsv_set categories $category_id_old [array get cat_lang]
    	unset cat_lang
        }
        set category_id_old $category_id
        set cat_lang($locale) $name
    }
    if {$category_id_old != 0} {
        nsv_set categories $category_id [array get cat_lang]
    }
}

ad_proc -public category::flush_translation_cache { category_id } {
    Flushes category translation cache of one category.

    @param category_id category to be flushed.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_foreach flush_translation_cache "" {
        set cat_lang($locale) $name
    }
    if {[info exists cat_lang]} {
        nsv_set categories $category_id [array get cat_lang]
    } else {
        nsv_set categories $category_id ""
    }
}

ad_proc -public category::get_name {
    category_id
    {locale ""}
} {
    Gets the category name in the specified language, if available.
    Use default language otherwise.

    @param category_id  category_id or list of category_id's for which to get the name. 

    @param locale       language in which to get the name. [ad_conn locale] used by default.

    @return list of names corresponding to the list of category_id's supplied.

    @author Timo Hentschel (timo@timohentschel.de)
} {
    if {[empty_string_p $locale]} {
        set locale [ad_conn locale]
    }
    if { [catch { array set cat_lang [nsv_get categories $category_id] }] } {
        return {}
    }
    if { ![catch { set name $cat_lang($locale) }] } {
        # exact match: found name for this locale
        return $name
    }
    if { ![catch { set name $cat_lang([ad_parameter DefaultLocale acs-lang "en_US"]) }] } {
        # default locale found
        return $name
    } 
    # tried default locale, but nothing found
    return {}
}

ad_proc -public category::get_names {
    category_ids
    {locale ""}
} {
    Gets the category name in the specified language, if available.
    Use default language otherwise.

    @param category_id  category_id or list of category_id's for which to get the name. 

    @param locale       language in which to get the name. [ad_conn locale] used by default.

    @return list of names corresponding to the list of category_id's supplied.

    @author Timo Hentschel (timo@timohentschel.de)
} {
    set result [list]
    foreach category_id $category_ids {
        lappend result [category::get_name $category_id $locale]
    }
    return $result
}

ad_proc -public category::get_object_context { object_id } {
    Returns the object name and url to be used in a context bar.

    @param object_id object_id to get the name of.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    set object_name [db_string object_name ""]
    return [list "/o/$object_id" $object_name]
}

ad_proc -deprecated category::indent_html { indent_width } {
    Creates a series of &nbsp; to indent subcatories in html output.

    @param indent_width width of the html indent.
    @author Timo Hentschel (timo@timohentschel.de)

    use string repeat "&nbsp;" $i
} {
    set indent_string ""
    for { set i 0 } { $i < $indent_width } { incr i } {
        append indent_string "&nbsp;"
    }

    return $indent_string
}

ad_proc -private category::context_bar { tree_id locale object_id } {
    Creates the standard context bar

    @param tree_id
    @param locale
    @param object_id
    @author Timo Hentschel (timo@timohentschel.de)
} {
    if {![empty_string_p $object_id]} {
	set context_bar [list [category::get_object_context $object_id] [list [export_vars -no_empty -base object-map {locale object_id}] "Category Management"]]
    } else {
	set context_bar [list [list ".?[export_vars -no_empty {locale}]" "Category Management"]]
    }
    lappend context_bar [list [export_vars -no_empty -base tree-view {tree_id locale object_id}] [category_tree::get_name $tree_id $locale]]

    return $context_bar
}

ad_proc category::pageurl { object_id } {
    Returns the page that displays a category.
    To be used by the AcsObject.PageUrl service contract.

    @param object_id category to be displayed.
    @author Timo Hentschel (timo@timohentschel.de)
} {
    db_1row get_tree_id_for_pageurl ""
    return "categories-browse?tree_ids=$tree_id&category_ids=$object_id"
}

ad_proc -private category::after_install {} {
    Callback to be called after package installation.
    Adds the service contract implementations.

    @author Timo Hentschel (timo@timohentschel.de)
} {
    acs_sc::impl::new -contract_name AcsObject -name category_idhandler -pretty_name "Category tree handler" -owner categories
    acs_sc::impl::alias::new -contract_name AcsObject -impl_name category_idhandler -operation PageUrl -alias category::pageurl
    acs_sc::impl::binding::new -contract_name AcsObject -impl_name category_idhandler

    acs_sc::impl::new -contract_name AcsObject -name category_tree_idhandler -pretty_name "Category tree handler" -owner categories
    acs_sc::impl::alias::new -contract_name AcsObject -impl_name category_tree_idhandler -operation PageUrl -alias category_tree::pageurl
    acs_sc::impl::binding::new -contract_name AcsObject -impl_name category_tree_idhandler
}

ad_proc -private category::before_uninstall {} {
    Callback to be called before package uninstallation.
    Removes the service contract implementations.

    @author Timo Hentschel (timo@timohentschel.de)
} {
    # shouldn't we first delete the bindings?
    acs_sc::impl::delete -contract_name AcsObject -impl_name category_idhandler
    acs_sc::impl::delete -contract_name AcsObject -impl_name category_tree_idhandler
}
