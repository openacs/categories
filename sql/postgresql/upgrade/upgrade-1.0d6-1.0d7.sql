-- 
-- packages/categories/sql/postgresql/upgrade/upgrade-1.0d6-1.0d7.sql
-- 
-- @author Deds Castillo (deds@i-manila.com.ph)
-- @creation-date 2005-01-13
-- @arch-tag: a966a122-5391-45e3-8176-dc0956fc9450
-- @cvs-id $Id$
--

-----
--
-- drop trigger as we force update the synonyms and we do not want to end
-- up with cyclic problems
--
-----
drop trigger category_synonym__insert_cat_trans_trg on category_translations;
drop trigger category_synonym__update_cat_trans_trg on category_translations;

-----
--
-- fix entries destroyed by old procs
--
----


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
    v_name             category_translations.name%TYPE;
    v_synonym_cursor   RECORD;
BEGIN
    FOR v_synonym_cursor IN
       select category_id,
              locale
       from category_synonyms
            where synonym_p = 'f'
    LOOP
       select name into v_name
       from category_translations
       where category_id = v_synonym_cursor.category_id
             and locale = v_synonym_cursor.locale;

       update category_synonyms
       set name = v_name
       where category_id = v_synonym_cursor.category_id
             and locale = v_synonym_cursor.locale;
    END LOOP;

    return 0;
END;

$$ LANGUAGE plpgsql;

select inline_0 ();
drop function inline_0 ();


-----
--
-- recreate functions that return the proper record
--
-----



--
-- procedure category_synonym__new_cat_trans_trg/0
--
CREATE OR REPLACE FUNCTION category_synonym__new_cat_trans_trg(

) RETURNS trigger AS $$
-- trigger function for inserting category translation
DECLARE
    v_synonym_id     integer;
BEGIN
	-- create synonym
    v_synonym_id := category_synonym__new (NEW.name, NEW.locale, NEW.category_id, null);

	-- mark synonym as not editable for users
    update category_synonyms
    set synonym_p = 'f'
    where synonym_id = v_synonym_id;

    return new;
END;
$$ LANGUAGE plpgsql;



--
-- procedure category_synonym__edit_cat_trans_trg/0
--
CREATE OR REPLACE FUNCTION category_synonym__edit_cat_trans_trg(

) RETURNS trigger AS $$
-- trigger function for updating a category translation
DECLARE
    v_synonym_id    integer;
BEGIN
	-- get synonym_id of updated category translation
    select synonym_id into v_synonym_id
    from   category_synonyms
    where  category_id = OLD.category_id
           and name = OLD.name
           and locale = OLD.locale
           and synonym_p = 'f';

	-- update synonym
    PERFORM category_synonym__edit (v_synonym_id, NEW.name, NEW.locale);

    return new;
END;
$$ LANGUAGE plpgsql;


-----
--
-- recreate triggers
--
-----
create trigger category_synonym__insert_cat_trans_trg 
after insert
on category_translations for each row
execute procedure category_synonym__new_cat_trans_trg();

create trigger category_synonym__update_cat_trans_trg 
before update
on category_translations for each row
execute procedure category_synonym__edit_cat_trans_trg();


-----
--
-- these function have embedded tabs which make pg or is is the driver(?) barf
-- fix them to have spaces
--
-----


-- added
select define_function_args('category__edit','category_id,locale,name,description,modifying_date,modifying_user,modifying_ip');

--
-- procedure category__edit/7
--
CREATE OR REPLACE FUNCTION category__edit(
   p_category_id integer,
   p_locale varchar,
   p_name varchar,
   p_description varchar,
   p_modifying_date timestamp with time zone,
   p_modifying_user integer,
   p_modifying_ip varchar
) RETURNS integer AS $$
DECLARE
BEGIN
	-- change category name
    update category_translations
    set name = p_name,
       description = p_description
    where category_id = p_category_id
          and locale = p_locale;

    update acs_objects
    set last_modified = p_modifying_date,
	    modifying_user = p_modifying_user,
	    modifying_ip = p_modifying_ip
    where object_id = p_category_id;

    return 0;
END;

$$ LANGUAGE plpgsql;
