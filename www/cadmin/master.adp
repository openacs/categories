<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context_bar;noquote@</property>

<if @change_locale@ eq t>
  <form action="@current_page@">
    @form_vars;noquote@
    <select name=locale>
      <multiple name=languages>
        <option value="@languages.locale@"<if @locale@ eq @languages.locale@> selected</if>>@languages.label@
      </multiple>
    </select>
    <input type=submit name=xx value="Change">
  </form>
</if>

<slave>
