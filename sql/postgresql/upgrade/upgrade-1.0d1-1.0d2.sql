alter table category_tree_map add column
	assign_single_p		char(1) constraint cat_tree_map_single_p_ck check (assign_single_p in ('t','f'))
;
alter table category_tree_map alter column assign_single_p set default 'f';

alter table category_tree_map add column
	require_category_p	char(1) constraint cat_tree_map_categ_p_ck check (require_category_p in ('t','f'))
;
alter table category_tree_map alter column require_category_p set default 'f';
update category_tree_map set assign_single_p = 'f', require_category_p = 'f';

comment on column category_tree_map.assign_single_p is '
  Are the users allowed to assign multiple or only a single category
  to objects?
';
comment on column category_tree_map.require_category_p is '
  Do the users have to assign at least one category to objects?
';

drop function category_tree__map (integer,integer,integer);



-- added
select define_function_args('category_tree__map','object_id,tree_id,subtree_category_id,assign_single_p,require_category_p');

--
-- procedure category_tree__map/5
--
CREATE OR REPLACE FUNCTION category_tree__map(
   p_object_id integer,
   p_tree_id integer,
   p_subtree_category_id integer,
   p_assign_single_p char,
   p_require_category_p char
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
	    assign_single_p, require_category_p)
	   values (p_tree_id, p_subtree_category_id, p_object_id,
	           p_assign_single_p, p_require_category_p);
	end if;
        return 0;
END;

$$ LANGUAGE plpgsql;
