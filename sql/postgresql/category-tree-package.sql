--
-- The Categories Package
--
-- @author Timo Hentschel (timo@timohentschel.de)
-- @author Michael Steigman (michael@steigman.net)
-- @creation-date 2003-04-16
--



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



-- added
select define_function_args('category_tree__new_translation','tree_id,locale,tree_name,description,modifying_date,modifying_user,modifying_ip');

--
-- procedure category_tree__new_translation/7
--
CREATE OR REPLACE FUNCTION category_tree__new_translation(
   p_tree_id integer,
   p_locale varchar,
   p_tree_name varchar,
   p_description varchar,
   p_modifying_date timestamp with time zone,
   p_modifying_user integer,
   p_modifying_ip varchar
) RETURNS integer AS $$
DECLARE
BEGIN
	insert into category_tree_translations
	    (tree_id, locale, name, description)
	values
	    (p_tree_id, p_locale, p_tree_name, p_description);

	update acs_objects
	set last_modified = p_modifying_date,
	    modifying_user = p_modifying_user,
	    modifying_ip = p_modifying_ip
	where object_id = p_tree_id;
        return 0;
END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_tree__del','tree_id');

--
-- procedure category_tree__del/1
--
CREATE OR REPLACE FUNCTION category_tree__del(
   p_tree_id integer
) RETURNS integer AS $$
DECLARE
BEGIN

       delete from category_tree_map where tree_id = p_tree_id;

       delete from category_object_map where category_id in (select category_id from categories where tree_id = p_tree_id);

       delete from category_translations where category_id in (select category_id from categories where tree_id = p_tree_id);
 
       delete from categories where tree_id = p_tree_id;
 
       delete from acs_objects where context_id = p_tree_id;

       delete from acs_permissions where object_id = p_tree_id;

       delete from category_tree_translations where tree_id  = p_tree_id;
       delete from category_trees where tree_id  = p_tree_id;
 
       perform acs_object__delete(p_tree_id);

       return 0;
END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_tree__edit','tree_id,locale,tree_name,description,site_wide_p,modifying_date,modifying_user,modifying_ip');

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



-- added
select define_function_args('category_tree__map','object_id,tree_id,subtree_category_id,assign_single_p,require_category_p,widget');

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



-- added
select define_function_args('category_tree__unmap','object_id,tree_id');

--
-- procedure category_tree__unmap/2
--
CREATE OR REPLACE FUNCTION category_tree__unmap(
   p_object_id integer,
   p_tree_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
	delete from category_tree_map
	where object_id = p_object_id
	and tree_id = p_tree_id;
        return 0;
END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_tree__name','tree_id');

--
-- procedure category_tree__name/1
--
CREATE OR REPLACE FUNCTION category_tree__name(
   p_tree_id integer
) RETURNS varchar AS $$
DECLARE
    v_name                   varchar;
BEGIN
	select name into v_name
	from category_tree_translations
	where tree_id = p_tree_id
	and locale = 'en_US';

	return v_name;
END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_tree__check_nested_ind','tree_id');

--
-- procedure category_tree__check_nested_ind/1
--
CREATE OR REPLACE FUNCTION category_tree__check_nested_ind(
   p_tree_id integer
) RETURNS integer AS $$
DECLARE
    v_negative               numeric;
    v_order                  numeric;
    v_parent                 numeric;
BEGIN
        select count(*) into v_negative from categories
	where tree_id = p_tree_id and (left_ind < 1 or right_ind < 1);

	if v_negative > 0 then 
           raise EXCEPTION '-20001: negative index not allowed!';
        end if;

        select count(*) into v_order from categories
	where tree_id = p_tree_id
	and left_ind >= right_ind;
	
	if v_order > 0 then 
           raise EXCEPTION '-20002: right index must be greater than left index!';
        end if;

        select count(*) into v_parent
	from categories parent, categories child
		where parent.tree_id = p_tree_id
		and child.tree_id = parent.tree_id
		and (parent.left_ind >= child.left_ind or parent.right_ind <= child.right_ind)
		and child.parent_id = parent.category_id;

	if v_parent > 0 then 
           raise EXCEPTION '-20003: child index must be between parent index!';
        end if;

        return 0;
END;

$$ LANGUAGE plpgsql;
