--
-- The Categories Package
--
-- @author Timo Hentschel (thentschel@sussdorff-roy.com)
-- @creation-date 2003-04-16
--

drop table category_temp;

drop table category_object_map;

drop table category_tree_map;
drop index cat_tree_map_ix;
drop index cat_object_map_ix;

drop table category_translations;

drop table categories;
drop index categories_left_ix;
drop index categories_parent_ix;

drop table category_tree_translations;

drop table category_trees;

delete from acs_permissions where object_id in
  (select object_id from acs_objects where object_type = 'category_tree');
delete from acs_objects where object_type='category';
delete from acs_objects where object_type='category_tree';


begin;
   select acs_object_type__drop_type('category', 't');
   select acs_object_type__drop_type('category_tree', 't');
end;

drop function category_tree__new (integer,varchar,varchar,varchar,
        char,timestamp,integer,varchar,integer);
drop function category_tree__new_translation (integer,varchar,varchar,
        varchar,timestamp,integer,varchar);
drop function category_tree__del (integer);
drop function category_tree__edit (integer,varchar,varchar,varchar,
        char,timestamp,integer,varchar);
drop function category_tree__copy (integer,integer,integer,varchar);
drop function category_tree__map (integer,integer,integer);
drop function category_tree__unmap (integer,integer);
drop function category_tree__check_nested_ind (integer);
-- drop function category_tree__index_children (integer,integer);
drop function category__new (integer,integer,varchar,varchar,varchar,
        integer,char,timestamp,integer,varchar);
drop function category__new_translation (integer,varchar,varchar,varchar,
        timestamp,integer,varchar);
drop function category__phase_out (integer);
drop function category__phase_in (integer);
drop function category__del (integer);
drop function category__edit (integer,varchar,varchar,varchar,
        timestamp,integer,varchar);
drop function category__change_parent (integer,integer,integer);
drop function category__name (integer);

-- delete privileges;
-- this shouldn't be necessary
begin;
delete from acs_privilege_descendant_map where privilege like 'category%';
end;

select acs_privilege__remove_child('category_admin','category_tree_read');
select acs_privilege__remove_child('category_admin','category_tree_write');
select acs_privilege__remove_child('category_admin','category_tree_grant_permissions');
select acs_privilege__remove_child('admin','category_admin');

select acs_privilege__drop_privilege('category_admin');
select acs_privilege__drop_privilege('category_tree_write');
select acs_privilege__drop_privilege('category_tree_read');
select acs_privilege__drop_privilege('category_tree_grant_permissions');

-- from categories-init
drop table acs_named_objects;
select acs_object_type__drop_type('acs_named_object', 't');
select acs_sc_contract__delete(acs_sc_contract__get_id('AcsObject'));
select acs_sc_msg_type__delete(acs_sc_msg_type__get_id('AcsObject.PageUrl.InputType'));
select acs_sc_msg_type__delete(acs_sc_msg_type__get_id('AcsObject.PageUrl.OutputType'));
select acs_sc_operation__delete(acs_sc_operation__get_id('AcsObject','PageUrl'));

-- this should be being handled at the tcl callback level but isn't?
select acs_sc_impl__delete('AcsObject','category_idhandler');
select acs_sc_impl__delete('AcsObject','category_tree_idhandler');
