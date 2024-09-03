
-- Cleanup of obsolete acs_named_objects table and object type is
-- optional, as there might be running systems with object types
-- depending on acs_named_object.
-- UNTESTED

-- drop table acs_named_objects;

-- begin
--    acs_object_type.drop_type('acs_named_object', 't');
--    acs_object_type.drop_type('category_tree', 't');
-- end;
