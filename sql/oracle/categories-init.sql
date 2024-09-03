--
-- The Categories Package
--
-- @author Timo Hentschel (timo@timohentschel.de)
-- @creation-date 2003-04-16
--


-- This should eventually be added to the acs-service-contract installation files

declare
    v_id	integer;
begin
    v_id :=  acs_sc_contract.new(
	    contract_name => 'AcsObject',
	    contract_desc => 'Acs Object Id Handler'
    );
    v_id := acs_sc_msg_type.new(
	    msg_type_name => 'AcsObject.PageUrl.InputType',
	    msg_type_spec => 'object_id:integer'
    );
    v_id := acs_sc_msg_type.new(
	    msg_type_name => 'AcsObject.PageUrl.OutputType',
	    msg_type_spec => 'page_url:string'
    );
    v_id := acs_sc_operation.new(
	    contract_name => 'AcsObject',
	    operation_name => 'PageUrl',
	    operation_desc => 'Returns the package specific url to a page that displays an object',
	    operation_iscachable_p => 'f',
	    operation_nargs => 1,
	    operation_inputtype => 'AcsObject.PageUrl.InputType',
	    operation_outputtype => 'AcsObject.PageUrl.OutputType'
    );
end;
/
show errors

-- there should be an implementation of this contract
-- for apm_package, user, group and other object types
