
-- added
select define_function_args('category_tree__copy','source_tree,dest_tree,creation_user,creation_ip');

--
-- procedure category_tree__copy/4
--
CREATE OR REPLACE FUNCTION category_tree__copy(
   p_source_tree integer,
   p_dest_tree integer,
   p_creation_user integer,
   p_creation_ip varchar
) RETURNS integer AS $$
DECLARE
    v_new_left_ind          integer;
    v_category_id	    integer;
    source record;
BEGIN
	select coalesce(max(right_ind),0) into v_new_left_ind 
	from categories
	where tree_id = p_dest_tree;

	for source in (select category_id, parent_id, left_ind, right_ind from categories where tree_id = p_source_tree) loop

	   v_category_id := acs_object__new ( 
                null,
		'category',     -- object_type
		now(),            -- creation_date
		p_creation_user,  -- creation_user
		p_creation_ip,    -- creation_ip
	  	p_dest_tree       -- context_id
	   );

	   insert into categories
	   (category_id, tree_id, parent_id, left_ind, right_ind)
	   values
	   (v_category_id, p_dest_tree, source.parent_id, source.left_ind + v_new_left_ind, source.right_ind + v_new_left_ind);
	end loop;

	-- correct parent_ids
	update categories 
	set parent_id = (select t.category_id
			from categories s, categories t
			where s.category_id = categories.parent_id
			and t.tree_id = p_dest_tree
			and s.left_ind + v_new_left_ind = t.left_ind)
	where tree_id = p_dest_tree;

	-- copy all translations
	insert into category_translations
	(category_id, locale, name, description)
	(select ct.category_id, t.locale, t.name, t.description
	from category_translations t, categories cs, categories ct
	where ct.tree_id = p_dest_tree
	and cs.tree_id = p_source_tree
	and cs.left_ind + v_new_left_ind = ct.left_ind
	and t.category_id = cs.category_id);

	-- for debugging reasons
	perform category_tree__check_nested_ind(p_dest_tree);

       return 0;
END;

$$ LANGUAGE plpgsql;
