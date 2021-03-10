<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>

<form action="categories-browse">
  #categories.lt_form_varsnoquote__Com# <input type="radio" name="join" value="and"<if @join@ eq "and"> #categories.checked#</if>#categories.AND__# <input type="radio" name="join" value="or"<if @join@ eq "or"> #categories.checked#</if>#categories.OR_#
  <br>
  <multiple name=trees>
    @trees.tree_name@:
    <select name=category_ids multiple size="5">
    <group column=tree_id>
      <option value="@trees.category_id@"<if @trees.selected_p;literal@ true> #categories.selected#</if>>@trees.indent;noquote@@trees.category_name@
    </group>
    </select>
  </multiple>
  <input type="submit" name="button" value="Show">
</form>

#categories.lt_To_deselect_or_select#
<p>@dimension_bar;noquote@</p>
<p>#categories.lt_object_count_objects_#</p>

<listtemplate name="items_list"></listtemplate>
