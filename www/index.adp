<master src="master">
<property name="page_title">@page_title;noquote@</property>
<property name="context_bar">@context_bar;noquote@</property>

<if @admin_p@ eq 1>
  <div style="float: right;">
    <a href="cadmin/" class="button">Category Administration</a>
  </div>
</if>

<h3> Select Trees for browsing </h3>

<listtemplate name="trees"></listtemplate>
