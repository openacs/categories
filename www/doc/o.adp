
<property name="context">{/doc/categories/ {Categories}} {IdHandler Service Contract}</property>
<property name="doc(title)">IdHandler Service Contract</property>
<master>
<h2>IdHandler Service Contract</h2>

Besides displaying the names of objects, some pages also want to
provide links to the objects. Unfortunately, there currently is no
way to do so.
<p>First, we need to know that package_id of the package
responsible for the object, then we would need to figure out the
url to that package instance. This can be done, but even then we
would need the local url to the page being able to display a
certain object. Since a package may have more than one type of
objects (i.e. file folders, files, file versions), we can not
simply store additional package information about which page to
call to display an object.</p>
<p>The solution to this kind of problem is by not resolving the url
at all during display-time, but doing so at the time the user
actually wants to see an object. The links would simply direct to
/o/$object_id, which is a global virtual-url-handling page that
will figure out the package instance url and then relying upon a
Service Contract to get the local url - that means every package
holding displayable objects should implement this interface for its
objects:</p>
<pre>
declare
    v_id        integer;
begin
    v_id :=  acs_sc_contract.new(
            contract_name =&gt; 'AcsObject',
            contract_desc =&gt; 'Acs Object Id Handler'
    );
    v_id := acs_sc_msg_type.new(
            msg_type_name =&gt; 'AcsObject.PageUrl.InputType',
            msg_type_spec =&gt; 'object_id:integer'
    );
    v_id := acs_sc_msg_type.new(
            msg_type_name =&gt; 'AcsObject.PageUrl.OutputType',
            msg_type_spec =&gt; 'page_url:string'
    );
    v_id := acs_sc_operation.new(
            contract_name =&gt; 'AcsObject',
            operation_name =&gt; 'PageUrl',
            operation_desc =&gt; 'Returns the package specific url to a page
that displays an object',
            operation_iscacheable_p =&gt; 'f',
            operation_nargs =&gt; 1,
            operation_inputtype =&gt; 'AcsObject.PageUrl.InputType',
            operation_outputtype =&gt; 'AcsObject.PageUrl.OutputType'
    );

    v_id := acs_sc_impl.new (
              'AcsObject',
              'apm_package_idhandler',
              'acs-kernel'
    );
    v_id := acs_sc_impl.new_alias (
              'AcsObject',
              'apm_package_idhandler',
              'PageUrl',
              'apm_pageurl',
              'TCL'
    );
    acs_sc_binding.new (
              contract_name =&gt; 'AcsObject',
              impl_name =&gt; 'apm_package_idhandler'
    );                             

    v_id := acs_sc_impl.new (
              'AcsObject',
              'user_idhandler',
              'acs-kernel'
    );
    v_id := acs_sc_impl.new_alias (
              'AcsObject',
              'user_idhandler',
              'PageUrl',
              'acs_user::pageurl',
              'TCL'
    );
    acs_sc_binding.new (
              contract_name =&gt; 'AcsObject',
              impl_name =&gt; 'user_idhandler'
    );                             
end;
</pre>

The appropriate tcl-procs look like the following:
<pre>
ad_proc -public apm_pageurl { object_id } {
    Service Contract Proc to resolve a URL for a package_id
} {
    return
}

namespace eval acs_user {
    ad_proc -public pageurl { object_id } {
        Service Contract Proc to resolve a URL for a user_id
    } {
        return "shared/community-member?user_id=$object_id"
    }
}
</pre>

Note that the name of the implementation has to be the object-type
followed by _idhandler.
<hr>
<address><a href="mailto:timo\@studio-k4.de">timo\@studio-k4.de</a></address>
