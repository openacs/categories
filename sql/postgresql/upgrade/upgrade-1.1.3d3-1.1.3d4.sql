
select define_function_args('category__change_parent','category_id,tree_id,parent_id');
select define_function_args('category__del','category_id');
select define_function_args('category__edit','category_id,locale,name,description,modifying_date,modifying_user,modifying_ip');
select define_function_args('category__name','category_id');
select define_function_args('category__new','category_id,tree_id,locale,name,description,parent_id,deprecated_p,creation_date,creation_user,creation_ip');
select define_function_args('category__new_translation','category_id,locale,name,description,modifying_date,modifying_user,modifying_ip');
select define_function_args('category__phase_in','category_id');
select define_function_args('category__phase_out','category_id');
select define_function_args('category_link__del','link_id');
select define_function_args('category_link__new','from_category_id,to_category_id');

select define_function_args('category_synonym__convert_string','name');
select define_function_args('category_synonym__del','synonym_id');
select define_function_args('category_synonym__edit','synonym_id,new_name,locale');
select define_function_args('category_synonym__get_similarity','len1,len2,matches');
select define_function_args('category_synonym__new','name,locale,category_id,synonym_id');
select define_function_args('category_synonym__reindex','synonym_id,name,locale');
select define_function_args('category_synonym__search','search_text,locale');

select define_function_args('category_tree__check_nested_ind','tree_id');
select define_function_args('category_tree__copy','source_tree,dest_tree,creation_user,creation_ip');
select define_function_args('category_tree__del','tree_id');
select define_function_args('category_tree__edit','tree_id,locale,tree_name,description,site_wide_p,modifying_date,modifying_user,modifying_ip');
select define_function_args('category_tree__map','object_id,tree_id,subtree_category_id,assign_single_p,require_category_p,widget');
select define_function_args('category_tree__name','tree_id');
select define_function_args('category_tree__new','tree_id,locale,tree_name,description,site_wide_p,creation_date,creation_user,creation_ip,context_id');
select define_function_args('category_tree__new_translation','tree_id,locale,tree_name,description,modifying_date,modifying_user,modifying_ip');
select define_function_args('category_tree__unmap','object_id,tree_id');
