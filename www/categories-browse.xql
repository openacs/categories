<?xml version="1.0"?>

<queryset>

  <fullquery name="insert_tmp_category_trees">
    <querytext>
      insert into category_temp
      values (:tree_id)
    </querytext>
  </fullquery>

  <partialquery name="other_letter">
    <querytext>
      and (upper(n.object_name) < 'A' or upper(n.object_name) > 'Z')
    </querytext>
  </partialquery>

  <partialquery name="regular_letter">
    <querytext>
      and upper(n.object_name) like :bind_letter
    </querytext>
  </partialquery>

  <partialquery name="include_subtree">
    <querytext>
      select v.object_id
      from (select distinct m.object_id, c.category_id
            from category_object_map m, categories c, category_temp t
            where c.category_id = t.category_id
            and m.category_id in (select c_sub.category_id
                                  from categories c_sub
                                  where c_sub.tree_id = c.tree_id
                                  and c_sub.left_ind >= c.left_ind
                                  and c_sub.left_ind < c.right_ind)) v
      group by v.object_id having count(*) = :category_ids_length
    </querytext>
  </partialquery>

  <partialquery name="exact_categorization">
    <querytext>
      select m.object_id
      from category_object_map m, category_temp t
      where m.category_id = t.category_id
      group by m.object_id having count(*) = :category_ids_length
    </querytext>
  </partialquery>

  <fullquery name="insert_tmp_categories">
    <querytext>
      insert into category_temp
      values (:category_id)
    </querytext>
  </fullquery>

</queryset>
