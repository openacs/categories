
--
-- procedure category__change_parent/3
--
CREATE OR REPLACE FUNCTION category__change_parent(
   p_category_id integer,
   p_tree_id integer,
   p_parent_id integer
) RETURNS integer AS $$
DECLARE

    v_old_left_ind      integer;
    v_old_right_ind     integer;
    v_new_left_ind      integer;
    v_new_right_ind     integer;
    v_width             integer;
BEGIN
 	update categories
	set parent_id = p_parent_id
	where category_id = p_category_id;

	-- first save the subtree, then compact tree, then expand tree to make room
	-- for subtree, then insert it

	select left_ind, right_ind into v_old_left_ind, v_old_right_ind
	from categories
	where category_id = p_category_id;

	v_width := v_old_right_ind - v_old_left_ind + 1;

	-- cut out old subtree
	update categories
	set left_ind = -left_ind, right_ind = -right_ind
	where tree_id = p_tree_id
	and left_ind >= v_old_left_ind
	and right_ind <= v_old_right_ind;

	-- compact parent trees
	update categories
	set right_ind = right_ind - v_width
	where tree_id = p_tree_id
	and left_ind < v_old_left_ind
	and right_ind > v_old_right_ind;

	-- compact right tree portion
	update categories
	set left_ind = left_ind - v_width,
	right_ind = right_ind - v_width
	where tree_id = p_tree_id
	and left_ind > v_old_left_ind;

	if (p_parent_id is null) then
	   select 1, coalesce(max(right_ind)+1, 1) into v_new_left_ind, v_new_right_ind
	   from categories
	   where tree_id = p_tree_id;
	else
	   select left_ind, right_ind into v_new_left_ind, v_new_right_ind
	   from categories
	   where category_id = p_parent_id;
	end if;

	-- move parent trees to make room
	update categories
	set right_ind = right_ind + v_width
	where tree_id = p_tree_id
	and left_ind <= v_new_left_ind
	and right_ind >= v_new_right_ind;

	-- move right tree portion to make room
	update categories
	set left_ind = left_ind + v_width,
	right_ind = right_ind + v_width
	where tree_id = p_tree_id
	and left_ind > v_new_right_ind;

	-- insert subtree at correct place
	update categories
	set left_ind = -left_ind + (v_new_right_ind - v_old_left_ind),
	right_ind = -right_ind + (v_new_right_ind - v_old_left_ind)
	where tree_id = p_tree_id
	and left_ind < 0;

	-- for debugging reasons
        perform category_tree__check_nested_ind(p_tree_id);

        return 0;
END;

$$ LANGUAGE plpgsql;
