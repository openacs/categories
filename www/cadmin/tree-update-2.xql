<?xml version="1.0"?>
<queryset>

<fullquery name="insert_tmp_categories">      
      <querytext>
      
	    insert into category_temp
	    values (:category_id)
	
      </querytext>
</fullquery>

<fullquery name="delete_tmp_category_trees">
      <querytext>
            delete from category_temp
      </querytext>
</fullquery>

 
<fullquery name="sort_categories_to_delete">      
      <querytext>
      
	select c.category_id
	from categories c, category_temp t
	where c.category_id = t.category_id
	order by right_ind-left_ind
    
      </querytext>
</fullquery>

 
</queryset>
