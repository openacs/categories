<master src="master">
<property name="page_title">@page_title;literal@</property>
<property name="context_bar">@context_bar;literal@</property>
<property name="locale">@locale;literal@</property>

<p>
<table>
  <tr><th>#categories.Tree_Name#</th><td>@tree_name@</td></tr>
  <tr><th>#categories.Description#</th><td>@tree_description@</td></tr>
</table>
</p>

<if @instances_using_p;literal@ true>
  #categories.lt_This_tree_is_still_us#
  <a href="@usage_url@">#categories.here#</a>.
</if>

<if @used_categories:rowcount@ gt 0>
  <p><strong>#categories.lt_Categories_still_used#</strong>
  <listtemplate name="used_categories"></listtemplate>
  <p>
</if>

<if @instances_using_p@ ne t>
  #categories.lt_Are_you_sure_you_want_3#
  <p>
    <a href="@delete_url@" class="button">#categories.Delete#</a>
    &nbsp;&nbsp;&nbsp;
    <a href="@cancel_url@" class="button">#categories.No_Cancel#</a>
  </p>
</if>

