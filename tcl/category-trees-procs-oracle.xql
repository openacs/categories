<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="category_tree::copy.copy_tree">      
      <querytext>
      
	    begin
	    category_tree.copy(
			       source_tree         => :source_tree,
			       dest_tree           => :dest_tree
			       );
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="category_tree::add.insert_tree">      
      <querytext>
      
		begin
		:1 := category_tree.new (
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

 
<fullquery name="category_tree::add.insert_default_tree">      
      <querytext>
      
		    begin
		    category_tree.new_translation (
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

 
<fullquery name="category_tree::update.insert_tree_translation">      
      <querytext>
      
		    begin
		    category_tree.new_translation (
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

 
<fullquery name="category_tree::update.update_tree_translation">      
      <querytext>
      
		    begin
		    category_tree.edit (
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

 
<fullquery name="category_tree::delete.delete_tree">      
      <querytext>
      
	    begin
	    category_tree.del ( :tree_id );
	    end;
	
      </querytext>
</fullquery>

</queryset>
