<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_used_categories">      
      <querytext>
      
	    select c.category_id,
	    (select case when count(*) = 0 then 0 else 1 end from dual
	     where exists (select 1 from category_object_map
			   where category_id = c.category_id)) as used_p
	    from categories c, category_temp t
	    where c.category_id = t.category_id
	
      </querytext>
</fullquery>

 
</queryset>
