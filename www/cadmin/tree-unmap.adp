<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale@</property>

Are you sure you want to unmap the tree "@tree_name@" from "@object_name@"?

<center>
<form action="tree-unmap-2">
  @form_vars;noquote@
  <input type=submit value="Yes">
</form>  


<form action="one-object">
  @cancel_form_vars;noquote@
  <input type=submit value="No">
</form>  

</center>
