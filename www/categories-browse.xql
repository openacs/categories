<?xml version="1.0"?>

<queryset>

  <partialquery name="include_subtree_and">
    <querytext>
      select v.object_id
      from (select distinct m.object_id, c.category_id
            from category_object_map m, categories c,
                 categories c_sub
            where c.category_id in $category_clause
            and m.category_id = c_sub.category_id
            and c_sub.tree_id = c.tree_id
            and c_sub.left_ind >= c.left_ind
            and c_sub.left_ind < c.right_ind) v
      group by v.object_id having count(*) = :category_ids_length
    </querytext>
  </partialquery>

  <partialquery name="exact_categorization_and">
    <querytext>
      select m.object_id
      from category_object_map m
      where m.category_id in $category_clause
      group by m.object_id having count(*) = :category_ids_length
    </querytext>
  </partialquery>

  <partialquery name="include_subtree_or">
    <querytext>
      select distinct m.object_id
      from category_object_map m, categories c,
           categories c_sub
      where c.category_id in $category_clause
      and m.category_id = c_sub.category_id
      and c_sub.tree_id = c.tree_id
      and c_sub.left_ind >= c.left_ind
      and c_sub.left_ind < c.right_ind
    </querytext>
  </partialquery>

  <partialquery name="exact_categorization_or">
    <querytext>
      select distinct m.object_id
      from category_object_map m
      where m.category_id in $category_clause
    </querytext>
  </partialquery>

</queryset>
