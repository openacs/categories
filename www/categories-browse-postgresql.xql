<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="get_categorized_objects">
    <querytext>
      select n.object_id, n.object_name as object_name, o.creation_date,
                   t.pretty_name as package_type, n.package_id, p.instance_name
        from acs_objects o, acs_named_objects n, apm_packages p, apm_package_types t,
             ($subtree_sql) s
       where n.object_id = s.object_id
         and o.object_id = n.object_id
         and p.package_id = n.package_id
         and t.package_key = p.package_key
         and acs_permission__permission_p(n.object_id, :user_id, 'read')
             $letter_sql
             $package_sql
             $order_by_clause
       limit $last_row offset $first_row
    </querytext>
  </fullquery>

  <fullquery name="check_permissions_on_trees">
    <querytext>
      select t.tree_id
      from category_trees t, category_temp tmp
      where (
         t.site_wide_p = 't'
         or acs_permission__permission_p(t.tree_id, :user_id, 'category_tree_read')
      )
      and t.tree_id = tmp.category_id
    </querytext>
  </fullquery>

  <fullquery name="get_categorized_object_count">
    <querytext>
      select n.object_id
      from acs_named_objects n, ($subtree_sql) s
      where n.object_id = s.object_id
      and   acs_permission__permission_p(n.object_id, :user_id, 'read')
      $letter_sql
      $package_sql
    </querytext>
  </fullquery>
  
  
</queryset>
