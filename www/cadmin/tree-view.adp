<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale@</property>

<p>
<table>
  <tr><th>Tree Name</th><td>@tree_name@</td></tr>
  <tr><th>Description</th><td> @tree_description@</td></tr>
</table>
</p>

<ul>

<if @can_grant_p@ eq 1>
    <li><a href="permission-manage?@url_vars;noquote@">Manage permissions</a>
    <p>
</if> 

<if @can_write_p@ eq 1 >
  <li><a href="tree-form?@url_vars;noquote@">Edit tree name and description</a>
  <p>
  <li><a href="category-form?@url_vars;noquote@">Add node at top level</a>
  <p>
  <li><a href="tree-copy?@url_vars;noquote@">Copy an existing tree</a>
  <p>
  <li><a href="tree-delete?@url_vars;noquote@">Delete this tree</a>
  <p>
  <li><a href="tree-usage?@url_vars;noquote@">Show modules using this tree</a>
  <p>
</if>

</ul>


<if @one_tree:rowcount@ gt 0>


  <form name="one_tree" action="tree-update">
  @form_vars;noquote@
  <table>
   <tr><th>&nbsp</th><th>Category Name</th><th>Hierarchy Level</th><if @can_write_p@ eq 1><th> Sort Key </th></if></tr>
    <multiple name="one_tree">
      <tr>
        <td> 
          <if @can_write_p@ eq "1">       
            <input name=check.@one_tree.category_id@ type=checkbox>
          </if>
        </td>
        <td> 
          @one_tree.left_indent;noquote@ @one_tree.category_name@ 
          <if @can_write_p@ eq 1>
               [ <font size=-1>
                   <a href="category-set-parent?@url_vars;noquote@&category_id=@one_tree.category_id@">Choose a new parent</a> 
                 | <a href="category-form?@url_vars;noquote@&parent_id=@one_tree.category_id@">Add child</a> 
                  
                 | <a href="category-form?@url_vars;noquote@&category_id=@one_tree.category_id@"> Edit </a> 
                 | <a href="category-delete?category_id=@one_tree.category_id@&@url_vars;noquote@"> Delete </a>  
                 | <if @one_tree.deprecated_p@ eq f><a href="category-phase-out?phase_out_p=1&category_id=@one_tree.category_id@&@url_vars;noquote@"> Phase out </a> </if>
                      <else><a href="category-phase-out?phase_out_p=0&category_id=@one_tree.category_id@&@url_vars;noquote@"> Phase in </a></else>
                 | <a href="category-usage?category_id=@one_tree.category_id@&@url_vars;noquote@"> Show Usage </a>
               </font> ] 
          </if>
        </td>
        <td align=center> 
            @one_tree.level@ 
        </td>
        <if @can_write_p@ eq "1">
           <td>
             @one_tree.left_indent;noquote@ <input name=sort_key.@one_tree.category_id@ value="@one_tree.sort_key@">
           </td>
        </if>
      </tr>  
    </multiple>
    <if @can_write_p@ eq "1"> 
     
     <tr><td>    
          <input type=submit name="submit_delete" value="Delete">
          </td> 
      <td>
	 <input type=submit name="submit_phase_in" value="Phase In">
          <input type=submit  name="submit_phase_out" value="Phase Out">
     
      </td>
      <td>
      </td>
        <td>
            <input type=submit name="submit_sort" value="Save Sort Keys">
        </td>
      </tr>
      </if>
      </table>
  </form>

</if>
<else>
 <I> no categories have been created... </i>
</else>
