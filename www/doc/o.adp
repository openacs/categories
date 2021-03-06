
<property name="context">{/doc/categories {Categories}} {Object Names and IdHandler Service Contract}</property>
<property name="doc(title)">Object Names and IdHandler Service Contract</property>
<master>
<h2>Object Names and IdHandler Service Contract</h2>
<h3>Object Names</h3>

When presenting a list of objects in a package not native to the
objects (i.e. permissioning, community-member, category-usage)
there has to be a fast and easy way to figure out the name of
objects. Until now, this has been done by using something like
<pre>
acs_objects.name(object_id)
</pre>

which essential means that for every object to be displayed (and
since the mentioned pages are in no means scalable and therefore
are likely to display a huge amount of objects) this pl/sql proc
will have to figure out which package-specific pl/sql proc to call
which itself will do at least one query to get the object-name.
<p>Obviously, this is highly undesirable since it is not scalable
at all. Therefore, a new way had to be found to get the name of an
object:</p>
<pre>
-------------------
-- NAMED OBJECTS --
-------------------

create table acs_named_objects (
        object_id       integer not null
                        constraint acs_named_objs_pk primary key
                        constraint acs_named_objs_object_id_fk
                        references acs_objects(object_id) on delete cascade,
        object_name     varchar2(200),
        package_id      integer
                        constraint acs_named_objs_package_id_fk
                        references apm_packages(package_id) on delete cascade
);

create index acs_named_objs_name_ix on acs_named_objects (substr(upper(object_name),1,1));
create index acs_named_objs_package_ix on acs_named_objects(package_id);

begin
        acs_object_type.create_type (
                supertype       =&gt;      'acs_object',
                object_type     =&gt;      'acs_named_object',
                pretty_name     =&gt;      'Named Object',
                pretty_plural   =&gt;      'Named Objects',
                table_name      =&gt;      'acs_named_objects',
                id_column       =&gt;      'object_id'
        );
end;
/
show errors
</pre>

This means that every displayable object-type should no longer be
derived from acs_objects, but from acs_named_objects and that by
using triggers or extending the appropriate pl/sql procs, every
displayable object (certainly not acs_rels or something the like)
should have an evtry in that extension of the acs_objects table.
<p>In that way, when having to display a list of objects, one can
simply join the acs_named_objects table to get the names and
package_ids in an easy and - more importantly - fast and scalable
way.</p>
<p>The only shortcomming of this solution is the disregard of
internationalization, but in cases where there objects in more than
one language, it should be the triggers / pl/sql procs task to make
sure that acs_named_objects contains names in the default language
if possible.</p>
<h3>IdHandler Service Contract</h3>

Besides displaying the names of objects, some pages also want to
provide links to the objects. Unfortunately, there currently is no
way to do so.
<p>First, we need to know that package_id of the package
responsible for the object. This information is currently
impossible to get since we would need to go up the context
hierarchy until we finally get hold of an apm_package object. But
lets assume we get this information by using the new
acs_named_objects table, then we would need to figure out the url
to that package instance. This can be done, but again by calling a
highly unefficient pl/sql proc. But even then we would need the
local url to the page being able to display a certain object. Since
a package may have more than one type of objects (i.e. file
folders, files, file versions), we can not simply store additional
package information about which page to call to display an
object.</p>
<p>The solution to this kind of problem is by not resolving the url
at all during display-time, but doing so at the time the user
actually wants to see an object. The links would simply direct to
/o/$object_id, which is a global virtual-url-handling page that
will figure out the package instance url (by using
acs_named_objects and the pl/sql proc) and then relying upon a
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
            operation_iscachable_p =&gt; 'f',
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
