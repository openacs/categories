<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="map.map_tree">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category_tree__map(
			      object_id           => :object_id,
			      subtree_category_id => :subtree_category_id,
			      tree_id             => :tree_id);
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="unmap.unmap_tree">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category_tree__unmap(
				object_id => :object_id,
				tree_id   => :tree_id);
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="copy.copy_tree">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category_tree__copy(
			       source_tree         => :source_tree,
			       dest_tree           => :dest_tree
			       );
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="add.insert_tree">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		begin
		:1 := category_tree__new (
					 tree_id       => :tree_id,
					 tree_name     => :name,
					 description   => :description,
					 locale        => :locale,
					 creation_user => :user_id,
					 creation_ip   => :creation_ip,
					 context_id    => :context_id
					 );
		end;
	    
      </querytext>
</fullquery>

 
<fullquery name="add.insert_default_tree">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		    begin
		    category_tree__new_translation (
						   tree_id        => :tree_id,
						   tree_name      => :name,
						   description    => :description,
						   locale         => :default_locale,
						   modifying_user => :user_id,
						   modifying_ip   => :creation_ip
						   );
		    end;
		
      </querytext>
</fullquery>

 
<fullquery name="update.insert_tree_translation">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		    begin
		    category_tree__new_translation (
						   tree_id        => :tree_id,
						   tree_name      => :name,
						   description    => :description,
						   locale         => :locale,
						   modifying_user => :user_id,
						   modifying_ip   => :modifying_ip
						   );
		    end;
		
      </querytext>
</fullquery>

 
<fullquery name="update.update_tree_translation">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		    begin
		    category_tree__edit (
					tree_id        => :tree_id,
					tree_name      => :name,
					description    => :description,
					locale         => :locale,
					modifying_user => :user_id,
					modifying_ip   => :modifying_ip
					);
		    end;
		
      </querytext>
</fullquery>

 
<fullquery name="delete.delete_tree">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category_tree__del ( :tree_id );
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="usage.category_tree_usage">      
      <querytext>
      
	    select t.pretty_plural, n.object_id, n.object_name, p.package_id,
	           p.instance_name,
	           acs_permission__permission_p(n.object_id, :user_id, 'read') as read_p
	    from category_tree_map m, acs_named_objects n,
	         apm_packages p, apm_package_types t
	    where m.tree_id = :tree_id
	    and n.object_id = m.object_id
	    and p.package_id = n.package_id
	    and t.package_key = p.package_key
	
      </querytext>
</fullquery>

 
</queryset>
