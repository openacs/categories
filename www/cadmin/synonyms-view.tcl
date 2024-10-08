ad_page_contract {

    Displays list of synonyms of a category.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    category_id:naturalnum,notnull
    tree_id:naturalnum,notnull
    {locale:word ""}
    object_id:naturalnum,optional
    orderby:token,optional
    ctx_id:naturalnum,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    synonyms:multirow
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

set tree_name [category_tree::get_name $tree_id $locale]
set category_name [category::get_name $category_id $locale]
set page_title "Synonyms for category \"$tree_name :: $category_name\""

set context_bar [category::context_bar $tree_id $locale \
                     [expr {[info exists object_id] ? $object_id : ""}] \
                     [expr {[info exists ctx_id] ? $ctx_id : ""}]]
lappend context_bar "Synonyms of $category_name"


#----------------------------------------------------------------------
# List builder
#----------------------------------------------------------------------

template::list::create \
    -name synonyms \
    -no_data "None" \
    -key synonym_id \
    -actions [list "Add synonym" [export_vars -no_empty -base synonym-form { category_id tree_id locale object_id ctx_id}] "Add new synonym"] \
    -bulk_actions {
	"Delete" "synonym-delete" "Delete checked synonyms"
    } -bulk_action_export_vars { category_id tree_id locale object_id ctx_id
    } -orderby {
	default_value language,asc
	synonym_name {
	    label synonym_name
	    orderby_asc {lower(s.name) asc, lower(l.label) asc}
	    orderby_desc {lower(s.name) desc, lower(l.label) desc}
	}
	language {
	    label language
	    orderby_asc {lower(l.label) asc, lower(s.name) asc}
	    orderby_desc {lower(l.label) desc, lower(s.name) desc}
	}
    } -filters {
	category_id {}
	tree_id {}
	locale {}
	object_id {}
    } -elements {
	edit {
	    sub_class narrow
	    display_template {
		<img src="/resources/acs-subsite/Edit16.gif" height="16" width="16" alt="Edit" style="border:0">
	    }
	    link_url_col edit_url
	    link_html {title "Edit this synonym"}
	}
	synonym_name {
	    label "Synonym"
	    link_url_col edit_url
	    link_html {title "Edit this synonym"}
	}
	language {
	    label "Language"
	}
	delete {
	    sub_class narrow
	    display_template {<adp:icon name="trash" title="Delete">}
	    link_url_col delete_url
	    link_html { title "Delete synonym" }
	}
    }


db_multirow synonyms get_synonyms ""

multirow extend synonyms edit_url delete_url
multirow foreach synonyms {
    set edit_url [export_vars -no_empty -base synonym-form { synonym_id category_id tree_id locale object_id ctx_id}]
    set delete_url [export_vars -no_empty -base synonym-delete { synonym_id category_id tree_id locale object_id ctx_id}]
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
