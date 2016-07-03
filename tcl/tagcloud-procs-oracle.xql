<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="category::tagcloud::get_tags_no_mem.tagcloud_get_keys">      
  <querytext>
        select category_id, count(com.object_id), min(trans.name)
        from categories natural left join category_object_map com natural join category_trees
        natural join category_translations trans
        where tree_id = :tree_id and trans.locale = :default_locale
	and exists (select 1 from acs_object_party_privilege_map ppm
                    where ppm.object_id = com.object_id
                    and ppm.privilege = 'read'
                    and ppm.party_id = :user_id)
        group by category_id
  </querytext>
</fullquery>
 
</queryset>
