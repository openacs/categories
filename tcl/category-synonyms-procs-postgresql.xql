<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="category_synonym::add.insert_synonym">
      <querytext>
		select category_synonym__new (
				    :name,
				    :locale,
				    :category_id,
				    :synonym_id
				    )
      </querytext>
</fullquery>

<fullquery name="category_synonym::edit.update_synonym">
      <querytext>
		select category_synonym__edit (
				    :synonym_id,
				    :name,
				    :locale
				    )
      </querytext>
</fullquery>

<fullquery name="category_synonym::delete.delete_synonym">
      <querytext>
		select category_synonym__del (
				    :synonym_id
				    )
      </querytext>
</fullquery>

<fullquery name="category_synonym::search.new_search">
      <querytext>
		select category_synonym__search (
				    :search_text,
				    :locale
				    )
      </querytext>
</fullquery>

</queryset>
