<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale@</property>

<h3> Trees you have the write permission on: </h3>

<if @trees_with_write_permission:rowcount@ gt "0">
  <table>

    <tr><th> Name</th><th></th></tr>
    <multiple name="trees_with_write_permission">
     <tr>
      <td>
        <a href="tree-view?tree_id=@trees_with_write_permission.tree_id@&@url_vars;noquote@">@trees_with_write_permission.tree_name@</a> 
      </td>
      <td> 
        <if @trees_with_write_permission.site_wide_p@ eq "t"> (Site-Wide Tree) </if>
      </td>
     </tr>
      </multiple>

  </table>
</if>
<else>
  <ul><li><i>None</i></li></ul>
</else>


<p>

<h3> Trees you have only the read permission on: </h3>

<if @trees_with_read_permission:rowcount@ not nil and @trees_with_read_permission:rowcount@ gt "0">
  <table>
    <tr><th> Name</th><th></th></tr> 
    <multiple name="trees_with_read_permission">
      <tr>
       <td>
         <a href="tree-view?tree_id=@trees_with_read_permission.tree_id@&@url_vars;noquote@">@trees_with_read_permission.tree_name@</a>
       </td>
       <td>
        <if @trees_with_read_permission.site_wide_p@ eq "t"> (Site-Wide Tree) </if>
       </td>
      </tr>
    </multiple>
  </table>
</if>
<else>
  <ul><li><i>None</i></li></ul>
</else>

<p>
<a href="tree-form?@url_vars;noquote@">Create a new tree</a>
<p>
