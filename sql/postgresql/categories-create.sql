--
-- The Categories Package
--
-- @author Timo Hentschel (thentschel@sussdorff-roy.com)
-- @creation-date 2003-04-16
--

          -- create the object types

create function inline_0 ()
returns integer as '
begin

    PERFORM acs_object_type__create_type (
                ''category_tree'',        -- object_type
                ''Category Tree'',        -- pretty_name
                ''Category Trees'',       -- pretty_plural
                ''acs_object'',           -- supertype
                ''category_trees'',       -- table_name
                ''tree_id'',              -- id_column
                ''category_tree.name'',    -- name_method
                ''f'',
                null,
                null
        );
    PERFORM acs_object_type__create_type (
                ''category'',             -- object_type
                ''Category'',             -- pretty_name
                ''Categories'',           -- pretty_plural
                ''acs_object'',           -- supertype
                ''categories'',           -- table_name
                ''category_id'',          -- id_column
                ''category.name'',         -- name_method
                ''f'',
                null,
                null
        );

    return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

create table category_trees (
       tree_id			integer primary key 
                                constraint cat_trees_tree_id_fk 
                                references acs_objects on delete cascade,
       site_wide_p		char(1) default 't' 
                                constraint cat_trees_site_wide_p_ck
                                check (site_wide_p in ('t','f'))
);

comment on table category_trees is '
  This is general data for each category tree.
';
comment on column category_trees.tree_id is '
  ID of a tree.
';
comment on column category_trees.site_wide_p is '
  Declares if a tree is site-wide or local (only usable by users/groups
  that have permissions).
';

create table category_tree_translations (
       tree_id			integer 
                                constraint cat_tree_trans_tree_id_fk 
                                references category_trees on delete cascade,
       locale		        varchar(5) not null 
                                constraint cat_tree_trans_locale_fk 
                                references ad_locales,
       name			varchar(50) not null,
       description		varchar(1000),
       primary key (tree_id, locale)
);

comment on table category_tree_translations is '
  Translations for names and descriptions of trees in different languages.
';
comment on column category_tree_translations.tree_id  is '
  ID of a tree (see category_trees).
';
comment on column category_tree_translations.locale is '
  ACS-Lang style locale if language ad country.
';
comment on column category_tree_translations.name is '
  Name of the tree in the specified language.
';
comment on column category_tree_translations.description is '
  Description of the tree in the specified language.
';

create table categories (
       category_id		integer 
                                primary key constraint cat_category_id_fk 
                                references acs_objects 
                                on delete cascade,
       tree_id			integer 
                                constraint cat_tree_id_fk 
                                references category_trees 
                                on delete cascade,
       parent_id		integer constraint cat_parent_id_fk 
                                references categories,
       deprecated_p		char(1) default 'f' 
                                constraint cat_deprecated_p_ck 
                                check (deprecated_p in ('t','f')),
       left_ind			integer,
       right_ind		integer
);

create index categories_left_ix on categories(tree_id, left_ind);
create index categories_parent_ix on categories(parent_id, category_id);

-- create unique index categories_left_ix on categories(tree_id, left_ind);
-- create unique index categories_parent_ix on categories(parent_id, category_id);
-- analyze table categories compute statistics;

comment on table categories is '
  Information about the categories in the tree structure.
';
comment on column categories.category_id is '
  ID of a category.
';
comment on column categories.tree_id is '
  ID of a tree (see category_trees).
';
comment on column categories.parent_id is '
  Points to a parent category in the tree or null (if topmost category).
';
comment on column categories.deprecated_p is '
  Marks categories to be no longer supported.
';
comment on column categories.left_ind is '
  Left index in nested set structure of a tree.
';
comment on column categories.right_ind is '
  Right index in nested set structure of a tree.
';

create table category_translations (
       category_id	        integer 
                                constraint cat_trans_category_id_fk 
                                references categories on delete cascade,
       locale		        varchar(5) not null 
                                constraint cat_trans_locale_fk 
                                references ad_locales,
       name		        varchar(200),
       description	        varchar(4000),
       primary key (category_id, locale)
);

comment on table category_translations is '
  Translations for names and descriptions of categories in different languages.
';
comment on column category_translations.category_id is '
  ID of a category (see categories).
';
comment on column category_translations.locale is '
  ACS-Lang style locale if language ad country.
';
comment on column category_translations.name is '
  Name of the category in the specified language.
';
comment on column category_translations.description is '
  Description of the category in the specified language.
';

create table category_tree_map (
	tree_id			integer 
                                constraint cat_tree_map_tree_id_fk 
                                references category_trees on delete cascade,
	object_id		integer 
                                constraint cat_tree_map_object_id_fk 
                                references acs_objects on delete cascade,
	subtree_category_id	integer 
                                default null 
                                constraint cat_tree_map_subtree_id_fk 
                                references categories,
	primary key (object_id, tree_id)
);

create unique index cat_tree_map_ix on category_tree_map(tree_id, object_id);

comment on table category_tree_map is '
  Maps trees to objects (usually package instances) so that
  other objects can be categorized.
';
comment on column category_tree_map.tree_id is '
  ID of the mapped tree (see category_trees).
';
comment on column category_tree_map.object_id is '
  ID of the mapped object (usually an apm_package if trees are to be used
  in a whole package instance, i.e. file-storage).
';
comment on column category_tree_map.subtree_category_id is '
  If a subtree is mapped, then this is the ID of the category on top
  of the subtree, null otherwise.
';

create table category_object_map (
       category_id		integer
                                constraint cat_object_map_category_id_fk 
                                references categories on delete cascade,
       object_id		integer 
                                constraint cat_object_map_object_id_fk 
                                references acs_objects on delete cascade,
       primary key (category_id, object_id)
);

create unique index cat_object_map_ix on category_object_map(object_id, category_id);

comment on table category_object_map is '
  Maps categories to objects and thus categorizes and object.
';
comment on column category_object_map.category_id is '
  ID of the mapped category (see categories).
';
comment on column category_object_map.object_id is '
  ID of the mapped object.
';

-- create global temporary table category_temp (
-- 	category_id	integer
-- ) on commit delete rows;

create table category_temp (
	category_id	integer
);

comment on table category_temp is '
  Used mainly for multi-dimensional browsing to use only bind vars
  in queries
';

create or replace view category_object_map_tree as
  select c.category_id,
         c.tree_id,
         m.object_id
  from   category_object_map m,
         categories c
  where  c.category_id = m.category_id;

\i category-tree-package.sql
\i category-package.sql

\i categories-permissions.sql

\i categories-init.sql
