<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

<table>
  <if @tree:rowcount@ ne 0>
    <tr><th> Category Name</th></tr>
  </if>
  <ul>
  <multiple name="tree">
    <tr><td><li>@tree.left_indent;noquote@ @tree.category_name@ </tr>
  </multiple>
  </ul>
</table>
