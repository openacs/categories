-- Populate the title field of acs_objects with the category 
-- name or tree name
--
-- @author Jeff Davis <davis@xarg.net>
-- @creation-date 2005-02-06



-- added
select define_function_args('category__new','category_id,tree_id,locale,name,description,parent_id,deprecated_p,creation_date,creation_user,creation_ip');

--
-- procedure category__new/10
--
CREATE OR REPLACE FUNCTION category__new(
   p_category_id integer,
   p_tree_id integer,
   p_locale varchar,
   p_name varchar,
   p_description varchar,
   p_parent_id integer,
   p_deprecated_p char,
   p_creation_date timestamp with time zone,
   p_creation_user integer,
   p_creation_ip varchar
) RETURNS integer AS $$
DECLARE

    v_category_id       integer; 
    v_left_ind          integer;
    v_right_ind         integer;
BEGIN
	v_category_id := acs_object__new ( 
		p_category_id,          -- object_id
		'category',           -- object_type
		p_creation_date,        -- creation_date
		p_creation_user,        -- creation_user
		p_creation_ip,          -- creation_ip
		p_tree_id,              -- context_id
                't',                  -- security_inherit_p
                p_name,                 -- title
                null                    -- package_id
	);

	if (p_parent_id is null) then
		select 1, coalesce(max(right_ind)+1,1) into v_left_ind, v_right_ind
		from categories
		where tree_id = p_tree_id;
	else
		select left_ind, right_ind into v_left_ind, v_right_ind
		from categories
		where category_id = p_parent_id;
	end if;

 	insert into categories
        (category_id, tree_id, deprecated_p, parent_id, left_ind, right_ind)
	values
	(v_category_id, p_tree_id, p_deprecated_p, p_parent_id, -1, -2);

	-- move right subtrees to make room for new category
	update categories
	set left_ind = left_ind + 2,
	    right_ind = right_ind + 2
	where tree_id = p_tree_id
	and left_ind > v_right_ind;

	-- expand upper nodes to make room for new category
	update categories
	set right_ind = right_ind + 2
	where tree_id = p_tree_id
	and left_ind <= v_left_ind
	and right_ind >= v_right_ind;

	-- insert new category
	update categories
	set left_ind = v_right_ind,
	    right_ind = v_right_ind + 1
	where category_id = v_category_id;

	insert into category_translations
	    (category_id, locale, name, description)
	values
	    (v_category_id, p_locale, p_name, p_description);

	return v_category_id;
END;

$$ LANGUAGE plpgsql;




-- added
select define_function_args('category_tree__new','tree_id,locale,tree_name,description,site_wide_p,creation_date,creation_user,creation_ip,context_id');

--
-- procedure category_tree__new/9
--
CREATE OR REPLACE FUNCTION category_tree__new(
   p_tree_id integer,
   p_locale varchar,
   p_tree_name varchar,
   p_description varchar,
   p_site_wide_p char,
   p_creation_date timestamp with time zone,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer
) RETURNS integer AS $$
DECLARE
  
    v_tree_id               integer;
BEGIN
	v_tree_id := acs_object__new (
		p_tree_id,         -- object_id
		'category_tree', -- object_type
		p_creation_date,   -- creation_date
		p_creation_user,   -- creation_user
		p_creation_ip,     -- creation_ip
		p_context_id,      -- context_id
                p_tree_name,       -- title
                null               -- package_id
	);

	insert into category_trees
	   (tree_id, site_wide_p)
	values
	   (v_tree_id, p_site_wide_p);

	perform acs_permission__grant_permission (
		v_tree_id,             -- object_id
		p_creation_user,       -- grantee_id
		'category_tree_read' -- privilege
	);
	perform acs_permission__grant_permission (
		v_tree_id,                -- object_id
		p_creation_user,          -- grantee_id
		'category_tree_write'   -- privilege
	);
	perform acs_permission__grant_permission (
		v_tree_id,                          -- object_id
		p_creation_user,                    -- grantee_id
		'category_tree_grant_permissions' -- privilege
	);

	insert into category_tree_translations
	    (tree_id, locale, name, description)
	values
	    (v_tree_id, p_locale, p_tree_name, p_description);

	return v_tree_id;
END;

$$ LANGUAGE plpgsql;

