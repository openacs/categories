<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<if @focus@ not nil><property name="focus">@focus;literal@</property></if>

<if @change_locale@ eq t and @languages@ not nil>
  <div style="float: right;">
    <formtemplate id="locale_form"></formtemplate>
  </div>
</if>

<slave>
