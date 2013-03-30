-- add missing alias for $1



-- added
select define_function_args('category__name','category_id');

--
-- procedure category__name/1
--
CREATE OR REPLACE FUNCTION category__name(
   p_category_id integer
) RETURNS integer AS $$
DECLARE
    v_name      varchar;
BEGIN
	select name into v_name
	from category_translations
	where category_id = p_category_id
	and locale = 'en_US';

        return 0;
END;

$$ LANGUAGE plpgsql;