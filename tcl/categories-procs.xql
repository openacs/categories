<?xml version="1.0"?>
<queryset>

<fullquery name="update.check_category_existence">      
      <querytext>
      
		select 1
		from category_translations
		where category_id = :category_id
		and locale = :locale
	    
      </querytext>
</fullquery>

 
<fullquery name="map_object.remove_mapped_categories">      
      <querytext>
      
		    delete from category_object_map
		    where object_id = :object_id
		
      </querytext>
</fullquery>

 
<fullquery name="map_object.insert_mapped_categories">      
      <querytext>
      
			insert into category_object_map (category_id, object_id)
			values (:category_id, :object_id)
		    
      </querytext>
</fullquery>

 
<fullquery name="get_mapped_categories.get_mapped_categories">      
      <querytext>
      
	    select category_id
	    from category_object_map
	    where object_id = :object_id
	
      </querytext>
</fullquery>

 
<fullquery name="reset_translation_cache.reset_translation_cache">      
      <querytext>
      
	    select category_id, locale, name
	    from category_translations
	    order by category_id, locale
	
      </querytext>
</fullquery>

 
<fullquery name="flush_translation_cache.flush_translation_cache">      
      <querytext>
      
	    select locale, name
	    from category_translations
	    where category_id = :category_id
	    order by locale
	
      </querytext>
</fullquery>

 
<fullquery name="pageurl.get_tree_id_for_pageurl">      
      <querytext>
      
	    select tree_id
	    from categories
	    where category_id = :object_id
	
      </querytext>
</fullquery>

 
</queryset>
