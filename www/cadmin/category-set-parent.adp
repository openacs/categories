<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>
<property name="locale">@locale@</property>

<if @tree:rowcount@ gt 0>
  <table>
   <tr><th>Category Name</th><th>Hierarchy Level</th></tr>
   <tr><td> <a href="category-set-parent-2?@url_vars;noquote@">Root Level </a></td><td align=center>0</td></tr>

   <multiple name="tree">
     <tr>
       <td>
         @tree.left_indent;noquote@
         <if @tree.url_p@ eq "1">
           <a href="category-set-parent-2?parent_id=@tree.category_id@&@url_vars;noquote@">@tree.category_name@</a>
         </if>
         <else>
             @tree.category_name@
         </else>
                    
       </td>
       <td align=center>
           @tree.level@
       </td>
      </tr>
    </multiple>
  </table>
</if>
