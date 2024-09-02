<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="get_objects_using_category">
    <querytext>
      select r.*
      from (select n.object_id, n.object_name as object_name, o.creation_date,
	           t.pretty_name as package_type, n.package_id, p.instance_name,
	           row_number() over ($order_by_clause) as row_number
	    from acs_objects o, acs_named_objects n, apm_packages p, apm_package_types t,
	    category_object_map m
	    where n.object_id = m.object_id
	    and o.object_id = n.object_id
	    and p.package_id = n.package_id
	    and t.package_key = p.package_key
	    and m.category_id = :category_id
	    and acs_permission.permission_p(m.object_id, :user_id, 'read') = 't'
	    $order_by_clause) r
      where r.row_number between :first_row and :last_row
    </querytext>
  </fullquery>

</queryset>
