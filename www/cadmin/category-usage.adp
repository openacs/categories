<master src="master">
<property name="page_title">@page_title;literal@</property>
<property name="context_bar">@context_bar;literal@</property>
<property name="locale">@locale;literal@</property>

<!-- pagination context bar -->
<table cellpadding="4" cellspacing="0" border="0" width="95%">
<tr><td></td><td align="center">#categories.lt_object_count_objects_#</td><td></td></tr>
<tr>
  <td align="left" width="5%">
    <if @info.previous_group@ not nil>
      <a href="category-usage?page=@info.previous_group@&amp;@url_vars@&amp;orderby=@orderby@">&lt;&lt;</a>&nbsp;
    </if>
    <if @info.previous_page@ gt 0>
      <a href="category-usage?page=@info.previous_page@&amp;@url_vars@&amp;orderby=@orderby@">&lt;</a>&nbsp;
    </if>
  </td>
  <td align="center">
    <multiple name=pages>
      <if @page@ ne @pages.page@>
        <a href="category-usage?page=@pages.page@&amp;@url_vars@&amp;orderby=@orderby@">@pages.page@</a>
      </if>
      <else>
        @page@
      </else>
    </multiple>
  </td>
  <td align="right" width="5%">
    <if @info.next_page@ not nil>
      &nbsp;<a href="category-usage?page=@info.next_page@&amp;@url_vars@&amp;orderby=@orderby@">&gt;</a>
    </if>
    <if @info.next_group@ not nil>
      &nbsp;<a href="category-usage?page=@info.next_group@&amp;@url_vars@&amp;orderby=@orderby@">&gt;&gt;</a>
    </if>
  </td>
</tr>
</table>
<p>
<listtemplate name="items_list"></listtemplate>
