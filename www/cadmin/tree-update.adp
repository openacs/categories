<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

Are you sure that you want to delete these categories?
<ul>
<multiple name=categories>
<li>@categories.name@<if @categories.used_p@ eq 1> (<font color=red>still used</font>)</if></li>
</multiple>
</ul>

<p><table>
<tr>
  <td>
    <form action="tree-update-2" method=post>
      @form_vars_delete;noquote@
      <input type=submit name=submit value="Yes, Proceed">
    </form>
 </td> 
 <td>
    <form action="tree-view" method=get>
      @form_vars_cancel;noquote@
      <input type=submit name=submit value="No, Cancel">
    </form>
  </td>
 </tr>
</table>
