--
-- The Categories Package
--
-- @author Timo Hentschel (thentschel@sussdorff-roy.com)
-- @creation-date 2003-04-16
--

drop table category_temp;

drop table category_object_map;

drop table category_tree_map;

drop table category_translations;

drop table categories;

drop table category_tree_translations;

drop table category_trees;

delete from acs_permissions where object_id in
  (select object_id from acs_objects where object_type = 'category_tree');
delete from acs_objects where object_type='category';
delete from acs_objects where object_type='category_tree';


begin
   acs_object_type.drop_type('category', 't');
   acs_object_type.drop_type('category_tree', 't');
end;
/
show errors

delete from acs_permissions
    where privilege in
        ('category_tree_write','category_tree_read',
          'category_tree_grant_permissions','category_admin');

delete from acs_privilege_hierarchy
    where privilege in
        ('category_tree_write','category_tree_read',
          'category_tree_grant_permissions','category_admin');

delete from acs_privilege_hierarchy
    where child_privilege in
        ('category_tree_write','category_tree_read',
          'category_tree_grant_permissions','category_admin');

delete from acs_privileges
    where privilege in
        ('category_tree_write','category_tree_read',
          'category_tree_grant_permissions','category_admin');
/

drop package category_tree;
drop package category;
