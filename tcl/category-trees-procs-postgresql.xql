<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="category_tree::copy.copy_tree">      
      <querytext>
	    select category_tree__copy(:source_tree, :dest_tree, :creation_user, :creation_ip)
      </querytext>
</fullquery>

 
<fullquery name="category_tree::add.insert_tree">      
      <querytext>
        	select category_tree__new (
					 :tree_id,
					 :locale,
					 :name,
					 :description,
                                         :site_wide_p,
                                         current_timestamp,
					 :user_id,
					 :creation_ip,
					 :context_id
					 )
      </querytext>
</fullquery>

 
<fullquery name="category_tree::add.insert_default_tree">      
      <querytext>
		    select category_tree__new_translation (
						   :tree_id,
						   :default_locale,
						   :name,
						   :description,
                                                   current_timestamp,
						   :user_id,
						   :creation_ip
						   )
      </querytext>
</fullquery>

 
<fullquery name="category_tree::update.insert_tree_translation">      
      <querytext>
		    select category_tree__new_translation (
						   :tree_id,
						   :locale,
						   :name,
						   :description,
                                                   current_timestamp,
						   :user_id,
						   :modifying_ip
						   )
      </querytext>
</fullquery>

 
<fullquery name="category_tree::update.update_tree_translation">      
      <querytext>
		    select category_tree__edit (
					:tree_id,
					:locale,
					:name,
					:description,
                                        :site_wide_p,
                                        current_timestamp,
					:user_id,
					:modifying_ip
					)
      </querytext>
</fullquery>

 
<fullquery name="category_tree::delete.delete_tree">      
      <querytext>
        	    select category_tree__del ( :tree_id )
      </querytext>
</fullquery>

</queryset>
