<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

<p>
  Are you sure you want to delete these categories:
</p>

<ul>
  <multiple name="categories">
    <li>
      @categories.name@
      <if @categories.objects_p@ true>(Still mapped to objects)</if>
    </li>
  </multiple>
</ul>

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
