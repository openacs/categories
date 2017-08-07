--
-- The Categories Package
-- Extension for category synonyms
--
-- @author Bernd Schmeil (bernd@thebernd.de)
-- @author Timo Hentschel (timo@timohentschel.de)
-- @creation-date 2004-01-08
--



-- added
select define_function_args('category_synonym__convert_string','name');

--
-- procedure category_synonym__convert_string/1
--
CREATE OR REPLACE FUNCTION category_synonym__convert_string(
   p_name varchar(100)
) RETURNS varchar(200) AS $$
-- return string to build search index
DECLARE
        v_index_string	varchar(200);
BEGIN
	-- convert string to uppercase and substitute special chars
        -- TODO: complete
        v_index_string := upper (
                        replace (
                        replace (
                        replace (
                        replace (
                        replace (
                        replace (
			replace (p_name, 'ä', 'AE'), 
					 'Ä', 'AE'),
					 'ö', 'OE'),
					 'Ö', 'OE'),
					 'ü', 'UE'),
					 'Ü', 'UE'),
					 'ß', 'SS'));
					  
	return (' ' || v_index_string || ' ');
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_synonym__get_similarity','len1,len2,matches');

--
-- procedure category_synonym__get_similarity/3
--
CREATE OR REPLACE FUNCTION category_synonym__get_similarity(
   p_len1 integer,
   p_len2 integer,
   p_matches bigint
) RETURNS integer AS $$
-- calculates similarity of two strings
DECLARE
BEGIN
	return (p_matches * 200 / (p_len1 + p_len2));
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_synonym__search','search_text,locale');

--
-- procedure category_synonym__search/2
--
CREATE OR REPLACE FUNCTION category_synonym__search(
   p_search_text varchar(100),
   p_locale varchar(5)
) RETURNS integer AS $$
-- return id for search string
DECLARE
	v_search_text	varchar(200);
	v_query_id	integer;
	v_len		integer;
	v_i		integer;
BEGIN
	-- check if search text already exists
	select	query_id into v_query_id
	from	category_search
	where	search_text = p_search_text
	and 	locale = p_locale;

	-- simply update old search data if already exists
	if (v_query_id is not null) then
		update	category_search
		set	queried_count = queried_count + 1,
			last_queried = date('now')
		where	query_id = v_query_id;
		return (v_query_id);
	end if;

	-- get new search query id
	v_query_id := nextval ('category_search_id_seq');

	-- convert string to uppercase and substitute special chars
	v_search_text := category_synonym__convert_string (p_search_text);

	-- insert search data
	insert into category_search (query_id, search_text, locale, queried_count, last_queried)
	values (v_query_id, p_search_text, p_locale, 1, date('now'));

	-- build search index
	v_len := length (v_search_text) - 2;
	v_i := 1;
	while (v_i <= v_len) loop
		insert into category_search_index 
		values (v_query_id, substring (v_search_text, v_i , 3));
		v_i := v_i + 1;
	end loop;

	-- build search result
	insert into category_search_results
	select	v_query_id, s.synonym_id, 
		category_synonym__get_similarity (v_len, length (s.name) - 2, count(*))
	from	category_search_index si, 
		category_synonym_index i,
		category_synonyms s
	where	si.query_id = v_query_id
	and	si.trigram = i.trigram
	and	s.synonym_id = i.synonym_id
	and	s.locale = p_locale
	group by s.synonym_id, s.name;

	return (v_query_id);
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_synonym__reindex','synonym_id,name,locale');

--
-- procedure category_synonym__reindex/3
--
CREATE OR REPLACE FUNCTION category_synonym__reindex(
   p_synonym_id integer,
   p_name varchar(100),
   p_locale varchar(5)
) RETURNS integer AS $$
-- build search index for synonym
DECLARE
	v_name		varchar(200);
	v_len		integer;
	v_i		integer;
BEGIN
	-- delete old search results for this synonym
	delete	from category_search_results
	where	synonym_id = p_synonym_id;

	-- delete old synonym index for this synonym
	delete	from category_synonym_index
	where	synonym_id = p_synonym_id;

	-- convert string to uppercase and substitute special chars
	v_name := category_synonym__convert_string (p_name);

	-- rebuild synonym index
	v_len := length (v_name) - 2;
	v_i := 1;
	while (v_i <= v_len) loop
		insert into category_synonym_index
		values (p_synonym_id, substring (v_name, v_i , 3));
		v_i := v_i + 1;
	end loop;

	-- rebuild search results
	insert into category_search_results
	select	s.query_id, p_synonym_id, 
		category_synonym__get_similarity (v_len, length (s.search_text) - 2, count(*))
	from	category_search_index si, 
		category_synonym_index i,
		category_search s
	where	i.synonym_id = p_synonym_id
	and	si.trigram = i.trigram
	and	si.query_id = s.query_id
	and	s.locale = p_locale
	group by s.query_id, s.search_text;

	return (1);
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_synonym__new','name,locale,category_id,synonym_id');

--
-- procedure category_synonym__new/4
--
CREATE OR REPLACE FUNCTION category_synonym__new(
   p_name varchar(100),
   p_locale varchar(5),
   p_category_id integer,
   p_synonym_id integer
) RETURNS integer AS $$
DECLARE
	v_synonym_id	integer;
BEGIN
	-- get new synonym_id
	if (p_synonym_id is null) then
		v_synonym_id := nextval ('category_synonyms_id_seq');
	else 
		v_synonym_id := p_synonym_id;
	end if;

	-- insert synonym data
	insert into category_synonyms (synonym_id, category_id, locale, name, synonym_p)
	values (v_synonym_id, p_category_id, p_locale, p_name, true);

	-- insert in synonym index and search results
	PERFORM category_synonym__reindex (v_synonym_id, p_name, p_locale);

	return (v_synonym_id);
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('category_synonym__del','synonym_id');

--
-- procedure category_synonym__del/1
--
CREATE OR REPLACE FUNCTION category_synonym__del(
   p_synonym_id integer
) RETURNS integer AS $$
-- delete synonym
DECLARE
BEGIN
	-- delete search results
	delete	from category_search_results
	where	synonym_id = p_synonym_id;

	-- delete synonym index
	delete	from category_synonym_index
	where	synonym_id = p_synonym_id;

	-- delete synonym
	delete	from category_synonyms
	where	synonym_id = p_synonym_id;

	return (1);
END;
$$ LANGUAGE plpgsql;
	


-- added
select define_function_args('category_synonym__edit','synonym_id,new_name,locale');

--
-- procedure category_synonym__edit/3
--
CREATE OR REPLACE FUNCTION category_synonym__edit(
   p_synonym_id integer,
   p_new_name varchar(100),
   p_locale varchar(5)
) RETURNS integer AS $$
DECLARE
BEGIN
	-- update synonym data
	update	category_synonyms
	set	name = p_new_name,
		locale = p_locale
	where	synonym_id = p_synonym_id;

	-- update synonym index and search results
	PERFORM category_synonym__reindex (p_synonym_id, p_new_name, p_locale);

	return (p_synonym_id);
END;
$$ LANGUAGE plpgsql;


-----
-- triggers for category synonyms
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
    set synonym_p = false
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
           and synonym_p = false;

	-- update synonym
    PERFORM category_synonym__edit (v_synonym_id, NEW.name, NEW.locale);

    return new;
END;
$$ LANGUAGE plpgsql;


create trigger category_synonym__insert_cat_trans_trg 
after insert
on category_translations for each row
execute procedure category_synonym__new_cat_trans_trg();

create trigger category_synonym__update_cat_trans_trg 
before update
on category_translations for each row
execute procedure category_synonym__edit_cat_trans_trg();
