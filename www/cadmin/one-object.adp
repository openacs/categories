<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

<ul>
  <li>
  <p>
  <if @mapped_trees:rowcount@ not nil and @mapped_trees:rowcount@ gt "0">
The following category trees are mapped to "@object_name@":

<table>
    <tr><th> Name</th><th></th></tr>
     <multiple name="mapped_trees">
     <tr>
        <td>
            <a href="tree-view?tree_id=@mapped_trees.tree_id@&@url_vars;noquote@">@mapped_trees.tree_name@ <if @mapped_trees.subtree_category_name@ not nil> :: </if>@mapped_trees.subtree_category_name@</a>
        </td>
        <td>
          [ <a href="tree-unmap?tree_id=@mapped_trees.tree_id@&@url_vars;noquote@">unmap</a> ] 
        </td>
        <td>
          <if @mapped_trees.site_wide_p@ eq "t"> (Site-Wide Tree) </if> 
        </td>
    </tr>
  </multiple>
 </table>
</if>
<else>
There are no category trees mapped to "@object_name@"
</else>
</p>
</ul>

<ul>
<if @unmapped_trees:rowcount@ gt "0">
  <p>
  <li> The following category trees are available:

  <table>
    <tr><th> Name</th><th></th><th></th></tr>
      <multiple name="unmapped_trees">
      <tr>
        <td>
           <a href="tree-view?tree_id=@unmapped_trees.tree_id@&@url_vars;noquote@">@unmapped_trees.tree_name@</a> 
        </td>
        <td align=center>
           [ <a href="tree-map?tree_id=@unmapped_trees.tree_id@&@url_vars;noquote@"> map tree </a>]
        </td>
        <td>
           [ <a href="subtree-choose?tree_id=@unmapped_trees.tree_id@&@url_vars;noquote@"> Choose a subtree to map </a> ]
        </td>
        <td>
          <if @unmapped_trees.site_wide_p@ eq "t"> (Site-Wide Tree) </if> 
        </td> 
      </tr>
  </multiple>
  </table>
  

</if>
</ul>

<p>
<a href="tree-form?@url_vars;noquote@">Create and map a new category tree</a>
