alter table category_tree_map add column widget varchar(20);

drop function category_tree__map ( integer, integer, integer, char, char );



-- added
select define_function_args('category_tree__map','object_id,tree_id,subtree_category_id,assign_single_p,require_category_p,widget');

--
-- procedure category_tree__map/6
--
CREATE OR REPLACE FUNCTION category_tree__map(
   p_object_id integer,
   p_tree_id integer,
   p_subtree_category_id integer,
   p_assign_single_p char,
   p_require_category_p char,
   p_widget varchar
) RETURNS integer AS $$
DECLARE

    v_map_count              integer;
BEGIN
	select count(*) 
	into v_map_count
	from category_tree_map
	where object_id = p_object_id
	and tree_id = p_tree_id;

	if v_map_count = 0 then
	   insert into category_tree_map
	   (tree_id, subtree_category_id, object_id,
	    assign_single_p, require_category_p, widget)
	   values (p_tree_id, p_subtree_category_id, p_object_id,
	           p_assign_single_p, p_require_category_p, p_widget);
	end if;
        return 0;
END;

$$ LANGUAGE plpgsql;
