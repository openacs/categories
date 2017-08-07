<?xml version="1.0"?>
<queryset>

<fullquery name="toggle_site_wide_status">      
      <querytext>
      
    update category_trees
    set site_wide_p = (:action = '1')
    where tree_id  = :tree_id

      </querytext>
</fullquery>

 
</queryset>
