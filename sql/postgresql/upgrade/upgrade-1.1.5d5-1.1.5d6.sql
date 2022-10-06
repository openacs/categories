
-- create indices on FK constraints
create index IF NOT EXISTS category_object_map_object_id_idx on category_object_map(object_id);
create index IF NOT EXISTS category_object_map_category_id_idx on category_object_map(category_id);
