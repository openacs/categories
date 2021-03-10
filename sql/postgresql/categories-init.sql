--
-- The Categories Package
--
-- @author Timo Hentschel (timo@timohentschel.de)
-- @creation-date 2003-04-16
--


-- This should eventually be added to the acs-service-contract installation files

begin;
    select acs_sc_contract__new(
	    'AcsObject',                -- contract_name
	    'Acs Object Id Handler'     -- contract_desc
    );
    select acs_sc_msg_type__new(
	    'AcsObject.PageUrl.InputType',      -- msg_type_name
	    'object_id:integer'                 -- msg_type_spec
    );
    select acs_sc_msg_type__new(
	    'AcsObject.PageUrl.OutputType',     -- msg_type_name
	    'page_url:string'                   -- msg_type_spec
    );
    select acs_sc_operation__new(
	    'AcsObject',                        -- contract_name
	    'PageUrl',                          -- operation_name
	    'Returns the package specific url to a page that displays an object', -- operation_desc
	    'f',                                -- operation_iscachable_p
	    1,                                  -- operation_nargs
	    'AcsObject.PageUrl.InputType',      -- operation_inputtype
	    'AcsObject.PageUrl.OutputType'      -- operation_outputtype
    );
end;

-- there should be an implementation of this contract
-- for apm_package, user, group and other object types
