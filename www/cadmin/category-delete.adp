<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

<if @mapped_objects_p@ eq 1>
This category is still mapped to some objects.
</if>
Are you sure you want to delete category "@category_name@"?

<center>
<form action="category-delete-2">
  @form_vars;noquote@
  <input type=submit value="Yes">
</form>  


<form action="tree-view">
  @form_vars;noquote@
  <input type=submit value="No">
</form>  

</center>
