<if @trees:rowcount@ gt 0>
  <multiple name=trees>
    @trees.tree_name@:
    <select name="@name@" multiple>
    <group column=tree_id>
      <option value="@trees.category_id@"<if @trees.selected_p@ eq 1> selected</if>>@trees.indent;noquote@@trees.category_name@
    </group>
    </select>
  </multiple>
</if>
