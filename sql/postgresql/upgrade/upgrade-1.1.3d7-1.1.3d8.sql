-- Old updraded instances could still have this version of the
-- function defined, because previous upgrades did not remove it

DROP FUNCTION IF EXISTS category_tree__map(integer, integer, integer, character, character, character varying);
DROP FUNCTION IF EXISTS category_tree__edit(integer, character varying, character varying, character varying, character, timestamp with time zone, integer, character varying);
