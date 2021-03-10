
-- Cleanup of obsolete acs_named_objects table and object type is
-- optional, as there might be running systems with object types
-- depending on acs_named_object.
-- begin;

-- drop table if exists acs_named_objects;
-- select acs_object_type__drop_type('acs_named_object', 't');

-- end;
