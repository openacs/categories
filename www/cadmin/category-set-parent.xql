<?xml version="1.0"?>
<queryset>

<fullquery name="subtree">      
      <querytext>
    select child.category_id
    from categories parent, categories child
    where parent.category_id = :category_id
    and child.left_ind >= parent.left_ind
    and child.left_ind <= parent.right_ind
    and child.tree_id = parent.tree_id
    order by child.left_ind

      </querytext>
</fullquery>

 
</queryset>
