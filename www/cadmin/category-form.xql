<?xml version="1.0"?>
<queryset>

<fullquery name="get_ad_locales">      
      <querytext>
      
    select label as name, locale as value
    from ad_locales

      </querytext>
</fullquery>

 
<fullquery name="get_category">      
      <querytext>
      
	select name, description
	from category_translations
	where category_id = :category_id
	and locale = :locale
    
      </querytext>
</fullquery>

 
<fullquery name="get_default_category">      
      <querytext>
      
	    select name, description
	    from category_translations
	    where category_id = :category_id
	    and locale = :default_locale
	
      </querytext>
</fullquery>

 
</queryset>
