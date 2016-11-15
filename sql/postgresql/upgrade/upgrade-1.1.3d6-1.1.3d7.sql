-- Very old updraded instances could still have this version of the
-- proc defined, because previous upgrades did not remove it
DROP FUNCTION IF EXISTS category_tree__new(
   p_tree_id integer,
   p_locale varchar,
   p_tree_name varchar,
   p_description varchar,
   p_site_wide_p char, -- now there is boolean here
   p_creation_date timestamp with time zone,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer
);
