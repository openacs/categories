<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale;noquote@</property>

<ul>
  <multiple name="trees">
    <li>
      <a href="tree-view-simple?tree_id=@trees.tree_id@&target_tree_id=@tree_id@&@url_vars;noquote@">
        @trees.tree_name@</a> &nbsp 
       <if @trees.site_wide_p@ eq "t"> (Site-Wide Tree) </if> 
       &nbsp
        [<a href="tree-copy-2?source_tree_id=@trees.tree_id@&tree_id=@tree_id@&@url_vars;noquote@">
        Copy this one</a>] 
    </li>
  </multiple>
</ul>

<if @trees:rowcount@ eq 0>
<blockquote>
There are no category trees available
</blockquote>
</if>
</p>
