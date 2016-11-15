--
-- Alter caveman style booleans (type character(1)) to real SQL boolean types.
--

ALTER TABLE categories
      DROP constraint IF EXISTS cat_deprecated_p_ck,
      ALTER COLUMN deprecated_p DROP DEFAULT,
      ALTER COLUMN deprecated_p TYPE boolean
      USING deprecated_p::boolean,
      ALTER COLUMN deprecated_p SET DEFAULT false;

ALTER TABLE category_synonyms
      DROP constraint IF EXISTS category_synonyms_synonym_p_ck,
      ALTER COLUMN synonym_p DROP DEFAULT,
      ALTER COLUMN synonym_p TYPE boolean
      USING synonym_p::boolean,
      ALTER COLUMN synonym_p SET DEFAULT true;

ALTER TABLE category_tree_map
      DROP constraint IF EXISTS cat_tree_map_single_p_ck,
      ALTER COLUMN assign_single_p DROP DEFAULT,
      ALTER COLUMN assign_single_p TYPE boolean
      USING assign_single_p::boolean,
      ALTER COLUMN assign_single_p SET DEFAULT false;

ALTER TABLE category_tree_map
      DROP constraint IF EXISTS cat_tree_map_categ_p_ck,
      ALTER COLUMN require_category_p DROP DEFAULT,
      ALTER COLUMN require_category_p TYPE boolean
      USING require_category_p::boolean,
      ALTER COLUMN require_category_p SET DEFAULT false;

ALTER TABLE category_trees
      DROP constraint IF EXISTS cat_trees_site_wide_p_ck,
      ALTER COLUMN site_wide_p DROP DEFAULT,
      ALTER COLUMN site_wide_p TYPE boolean
      USING site_wide_p::boolean,
      ALTER COLUMN site_wide_p SET DEFAULT true;


-- procedure category__new/10
--
CREATE OR REPLACE FUNCTION category__new(
   p_category_id integer,
   p_tree_id integer,
   p_locale varchar,
   p_name varchar,
   p_description varchar,
   p_parent_id integer,
   p_deprecated_p boolean,
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

--
-- procedure category_tree__map/6
--
CREATE OR REPLACE FUNCTION category_tree__map(
   p_object_id integer,
   p_tree_id integer,
   p_subtree_category_id integer,
   p_assign_single_p boolean,
   p_require_category_p boolean,
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

--
-- procedure category_tree__new/9
--

-- need to drop old version first, as arguments change type
DROP FUNCTION IF EXISTS category_tree__new(
   p_tree_id integer,
   p_locale varchar,
   p_tree_name varchar,
   p_description varchar,
   p_site_wide_p char,
   p_creation_date timestamp with time zone,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer
);

CREATE OR REPLACE FUNCTION category_tree__new(
   p_tree_id integer,
   p_locale varchar,
   p_tree_name varchar,
   p_description varchar,
   p_site_wide_p boolean,
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


--
-- procedure category_tree__edit/8
--
CREATE OR REPLACE FUNCTION category_tree__edit(
   p_tree_id integer,
   p_locale varchar,
   p_tree_name varchar,
   p_description varchar,
   p_site_wide_p boolean,
   p_modifying_date timestamp with time zone,
   p_modifying_user integer,
   p_modifying_ip varchar
) RETURNS integer AS $$
DECLARE
BEGIN
	update category_trees
	set site_wide_p = p_site_wide_p
	where tree_id = p_tree_id;

	update category_tree_translations
	set name = p_tree_name,
	    description = p_description
	where tree_id = p_tree_id
	and locale = p_locale;

	update acs_objects
	set last_modified = p_modifying_date,
	    modifying_user = p_modifying_user,
	    modifying_ip = p_modifying_ip
	where object_id = p_tree_id;

       return 0;
END;

$$ LANGUAGE plpgsql;
