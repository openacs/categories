<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="check_permissions_on_trees">
    <querytext>
      select t.tree_id
      from category_trees t, category_temp tmp
      where (t.site_wide_p = 't'
             or acs_permission.permission_p(t.tree_id, :user_id, 'category_tree_read') = 't')
      and t.tree_id = tmp.category_id
    </querytext>
  </fullquery>

  <fullquery name="get_categorized_object_count">
    <querytext>
      select n.object_id
      from acs_named_objects n, ($subtree_sql) s
      where n.object_id = s.object_id
      and acs_permission.permission_p(n.object_id, :user_id, 'read') = 't'
      $letter_sql
    </querytext>
  </fullquery>

  <fullquery name="get_categorized_objects">
    <querytext>
      select r.*
      from (select n.object_id, n.object_name as object_name, o.creation_date,
                   t.pretty_name as package_type, n.package_id, p.instance_name,
                   row_number() over ($order_by_clause) as row_number
            from acs_objects o, acs_named_objects n, apm_packages p, apm_package_types t,
                 ($subtree_sql) s
            where n.object_id = s.object_id
            and o.object_id = n.object_id
            and p.package_id = n.package_id
            and t.package_key = p.package_key
            and acs_permission.permission_p(n.object_id, :user_id, 'read') = 't'
            $letter_sql
            $order_by_clause) r
      where r.row_number between :first_row and :last_row
    </querytext>
  </fullquery>

</queryset>
