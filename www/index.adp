<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>

<if @admin_p@ eq 1>
  <a href="cadmin/">Category Administration</a><br>
</if>

<h3> Select Trees for browsing: </h3>

<if @trees:rowcount@ gt "0">
  <form action="categories-browse">
    <table>
      <multiple name="trees">
        <tr>
         <td><input type=checkbox name=tree_ids value=@trees.tree_id@>&nbsp;</td>
         <td>@trees.tree_name@</td>
        </tr>
      </multiple>
      <tr><td></td><td><input type=submit name=button value="Browse"></td></tr>
    </table>
  </form>
</if>
<else>
  <ul><li><i>No Trees added yet.</i></li></ul>
</else>
