<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="trees">      
      <querytext>
      
         select tree_id, site_wide_p,
                acs_permission__permission_p(tree_id, :user_id, 'category_tree_write') has_write_p,
                acs_permission__permission_p(tree_id, :user_id, 'category_tree_read') has_read_p
           from category_trees t

      </querytext>
</fullquery>

 
</queryset>
