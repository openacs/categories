<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context_bar;noquote@</property>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<if @change_locale@ eq t and @languages:rowcount@ gt 1>
  <div style="float: right;">
    <form action="@current_page@">
      @form_vars;noquote@
      <select name=locale>
        <multiple name=languages>
          <option value="@languages.locale@"<if @locale@ eq @languages.locale@> selected</if>>@languages.label@
        </multiple>
      </select>
      <input type=submit name=xx value="Change">
    </form>
  </div>
</if>

<slave>
