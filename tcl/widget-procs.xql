<?xml version="1.0"?>
<queryset>

<fullquery name="template::data::transform::category.get_trees_requiring_category">
      <querytext>
      
		select tree_id, subtree_category_id
		from category_tree_map
		where object_id = :package_id
		and require_category_p = 't'
		
      </querytext>
</fullquery>

</queryset>
