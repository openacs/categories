<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale@</property>

<if @tree:rowcount@ lt 2>
  <ul>
  <li><i> none available</i>
  </ul>
</if>
<else>
  <table>
    <multiple name="tree">
      <tr><td>@tree.left_indent;noquote@ @tree.category_name@ [ <font size=-1><a href="subtree-map?category_id=@tree.category_id@&source_tree_id=@tree_id@&@url_vars;noquote@">Add this subtree</a> </font> ]</td><td align=center> @tree.level@ </font></td></tr>
    </multiple>
  </table>
</else>
