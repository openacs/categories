<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>

<if @admin_p;literal@ true>
  <div style="float: right;">
    <a href="cadmin/" class="button">#categories.lt_Category_Administrati#</a>
  </div>
</if>

<h3> #categories.lt_Select_Trees_for_brow# </h3>
<listtemplate name="trees"></listtemplate>

<h3> #categories.lt_Search_for_a_category# </h3>
<formtemplate id="search_form"></formtemplate>

