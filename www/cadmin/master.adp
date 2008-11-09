<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context_bar;noquote@</property>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<if @change_locale@ eq t and @languages@ not nil>
  <div style="float: right;">
    <formtemplate id="locale_form">
      @form_vars;noquote@
      <table cellspacing="2" cellpadding="2" border="0">
        <tr class="form-element"><td class="form-label">Language</td>
        <td class="form-widget"><formwidget id="locale"></td></tr>
        <tr class="form-element">
        <td align="right" colspan="2"><formwidget id="formbutton:ok"></td></tr>
      </table>
    </formtemplate>
  </div>
</if>

<slave>
