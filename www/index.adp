<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>

<if @admin_p@ eq 1>
  <div style="float: right;">
    <a href="cadmin/" class="button">Category Administration</a>
  </div>
</if>

<h3> Select Trees for browsing: </h3>

<if @trees:rowcount@ gt "0">
  <form action="categories-browse">
    <table>
      <multiple name="trees">
        <tr>
         <td><input type="checkbox" name="tree_ids" value="@trees.tree_id@" id="tree_id_@trees.tree_id@">&nbsp;</td>
         <td><label for="tree_id_@trees.tree_id@">@trees.tree_name@</label></td>
        </tr>
      </multiple>
      <tr><td></td><td><input type=submit name=button value="Browse"></td></tr>
    </table>
  </form>
</if>
<else>
  <ul><li><i>No Trees added yet.</i></li></ul>
</else>
