<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

<p>
<table>
  <tr><th>Tree Name</th><td>@tree_name@</td></tr>
  <tr><th>Description</th><td> @tree_description@</td></tr>
</table>
</p>

<if @instances_using_p@ eq t>
  This tree is still used by some modules. For a complete list, please go
  <a href="tree-usage?@url_vars;noquote@">here</a>.
</if>

<if @used_categories:rowcount@ gt 0>
  <p>The following categories of this tree are still in use:
  <ul><multiple name=used_categories><li>@used_categories.name@</li></multiple></ul>
</if>

<if @instances_using_p@ ne t>
  Are you sure you want to delete the tree "@tree_name@"?
  <center>
    <form action="tree-delete-2">
      @form_vars;noquote@
      <input type=submit value="Yes">
    </form>  
    <form action="tree-view">
      @form_vars;noquote@
      <input type=submit value="No">
    </form>  
  </center>
</if>
