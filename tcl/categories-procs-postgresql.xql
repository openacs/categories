<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="category::add.insert_category">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		begin
		:1 := category__new (
				    category_id   => :category_id,
				    locale        => :locale,
				    name          => :name,
				    description   => :description,
				    tree_id       => :tree_id,
				    parent_id     => :parent_id,
				    creation_user => :user_id,
				    creation_ip   => :creation_ip
				    );
		end;
	    
      </querytext>
</fullquery>

 
<fullquery name="category::add.insert_default_category">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		    begin
		    category__new_translation (
					      category_id    => :category_id,
					      locale         => :default_locale,
					      name           => :name,
					      description    => :description,
					      modifying_user => :user_id,
					      modifying_ip   => :creation_ip
					      );
		    end;
		
      </querytext>
</fullquery>

 
<fullquery name="category::update.insert_category_translation">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		    begin
		    category__new_translation (
					      category_id    => :category_id,
					      locale         => :locale,
					      name           => :name,
					      description    => :description,
					      modifying_user => :user_id,
					      modifying_ip   => :modifying_ip
					      );
		    end;
		
      </querytext>
</fullquery>

 
<fullquery name="category::update.update_category_translation">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

		    begin
		    category__edit (
				   category_id    => :category_id,
				   locale         => :locale,
				   name           => :name,
				   description    => :description,
				   modifying_user => :user_id,
				   modifying_ip   => :modifying_ip
				   );
		    end;
		
      </querytext>
</fullquery>

 
<fullquery name="category::delete.delete_category">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category__del ( :category_id );
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="category::change_parent.change_parent_category">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category__change_parent (
				    category_id  => :category_id,
				    tree_id      => :tree_id,
				    parent_id    => :parent_id
				    );
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="category::phase_in.phase_in">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category__phase_in(:category_id);
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="category::phase_out.phase_out">      
      <querytext>
      FIX ME PLSQL
FIX ME PLSQL

	    begin
	    category__phase_out(:category_id);
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="category::get_object_context.object_name">      
      <querytext>
      select acs_object__name(:object_id) 
      </querytext>
</fullquery>

 
</queryset>
