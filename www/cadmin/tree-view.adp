<master src="master">
<property name="page_title">@page_title;literal@</property>
<property name="context_bar">@context_bar;literal@</property>
<property name="locale">@locale;literal@</property>
<property name="tree_id">@tree_id;literal@</property>

<include src="/packages/categories/lib/tree-form" &="tree_id" &="locale" &="ctx_id">

<listtemplate name="one_tree"></listtemplate>
