<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="category::tagcloud::get_tags_no_mem.tagcloud_get_keys">      
  <querytext>
        select category_id, count(com.object_id), min(trans.name)
           from categories
	   natural left join category_object_map com
	   natural join category_trees
           natural join category_translations trans
        where tree_id = :tree_id
	  and trans.locale = :default_locale
          and acs_permission__permission_p(com.object_id, :user_id, 'read')
        group by category_id
  </querytext>
</fullquery>
   
 
</queryset>
