#
# author: Timo Hentschel (thentschel@sussdorff-roy.com)
#

# There seems to be no way to elegantly set default values here
if { ![info exists path_id] } {
    set path_id ""
}

if { ![info exists context_bar] } {
    set context_bar ""
}

if { ![info exists change_locale] } {
    set change_locale t
}

if {![exists_and_not_null locale]} {
    set locale [ad_parameter DefaultLocale acs-lang "en_US"]
}

db_multirow languages get_locales {
    select label, locale
    from ad_locales
}

set current_page [ad_conn url]
set form_vars [export_ns_set_vars form [list locale xx] [ad_conn form]]
