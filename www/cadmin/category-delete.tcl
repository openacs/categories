ad_page_contract {

    Deletes a category

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id$
} {
    tree_id:naturalnum,notnull
    category_id:naturalnum,multiple
    {locale:word ""}
    object_id:naturalnum,optional
    ctx_id:naturalnum,optional
} -properties {
    page_title:onevalue
    context_bar:onevalue
    locale:onevalue
    delete_url:onevalue
    cancel_url:onevalue
    mapped_objects_p:onevalue
}

set user_id [auth::require_login]
permission::require_permission -object_id $tree_id -privilege category_tree_write

multirow create categories category_id category_name objects_p view_url

foreach id $category_id {
    multirow append categories \
	$id \
	[category::get_name $id $locale] \
	[db_string check_mapped_objects {}] \
	[export_vars -no_empty -base category-usage { {category_id $id} tree_id locale object_id ctx_id}]
}

multirow sort categories -dictionary category_name

set delete_url [export_vars -no_empty -base category-delete-2 { tree_id category_id:multiple locale object_id ctx_id}]
set cancel_url [export_vars -no_empty -base tree-view { tree_id locale object_id ctx_id}]
set page_title "Delete categories"

set context_bar [category::context_bar $tree_id $locale \
                     [expr {[info exists object_id] ? $object_id : ""}] \
                     [expr {[info exists ctx_id] ? $ctx_id : ""}]]
lappend context_bar "Delete categories"

template::list::create \
    -name categories \
    -no_data "None" \
    -elements {
	category_name {
	    label "Name"
	    display_template {
		<if @categories.objects_p;literal@ true><a href="@categories.view_url@">@categories.category_name@</a></if>
		<else>@categories.category_name@</else>
	    }
	}
	objects_p {
	    display_template {
		<if @categories.objects_p;literal@ true>(Still mapped to objects)</if>
	    }
	}
    }

ad_return_template 

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
