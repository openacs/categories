ad_library {

    Procs which may be invoked using similarly named elements in an
    install.xml file.

    @creation-date 2005-02-10
    @author Lee Denison (lee@thaum.net)
    @cvs-id $Id$
}

namespace eval install {}
namespace eval install::xml {}
namespace eval install::xml::action {}

ad_proc -public install::xml::action::load-categories { node } {
    Load categories from a file.
} {
    set src [apm_required_attribute_value $node src]
    set site_wide_p [apm_attribute_value -default 0 $node site-wide-p]
    set format [apm_attribute_value -default "simple" $node format]
    set id [apm_attribute_value -default "" $node id]

    switch -exact $format {
        simple {
            set tree_id [category_tree::xml::import_from_file \
                -site_wide=[template::util::is_true $site_wide_p] \
                [acs_root_dir]$src]
        }
        default {
            error "Unsupported format."
        }
    }

    if {![string equal $id ""]} {
        set ::install::xml::ids($id) $tree_id
    }
}

ad_proc -public install::xml::action::map-category-tree { node } {
    Maps a category tree to a specified object.
} {
    set tree_id [apm_required_attribute_value $node tree-id]
    set object_id [apm_required_attribute_value $node object-id]

    set tree_id [install::xml::util::get_id $tree_id]
    set object_id [install::xml::util::get_id $object_id]

    category_tree::map -tree_id $tree_id -object_id $object_id
}
