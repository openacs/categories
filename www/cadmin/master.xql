<?xml version="1.0"?>
<queryset>

<fullquery name="get_locales">      
      <querytext>
      
    select label, locale
    from   ad_locales
    where  enabled_p = 't'

      </querytext>
</fullquery>

 
</queryset>
