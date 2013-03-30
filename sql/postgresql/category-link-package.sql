--
-- The Categories Package
-- Extension for linking categories
--
-- @author Timo Hentschel (timo@timohentschel.de)
-- @creation-date 2004-02-04
--



-- added
select define_function_args('category_link__new','from_category_id,to_category_id');

--
-- procedure category_link__new/2
--
CREATE OR REPLACE FUNCTION category_link__new(
   p_from_category_id integer,
   p_to_category_id integer
) RETURNS integer AS $$
	-- function for adding category links
DECLARE
	v_link_id		integer;
BEGIN
	v_link_id := nextval ('category_links_id_seq');

	insert into category_links (link_id, from_category_id, to_category_id)
	values (v_link_id, p_from_category_id, p_to_category_id);

	return v_link_id;
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_link__del','link_id');

--
-- procedure category_link__del/1
--
CREATE OR REPLACE FUNCTION category_link__del(
   p_link_id integer
) RETURNS integer AS $$
	-- function for deleting category links
DECLARE
BEGIN
	delete from category_links
	where link_id = p_link_id;

	return p_link_id;
END;
$$ LANGUAGE plpgsql;
