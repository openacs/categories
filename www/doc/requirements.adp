
<property name="context">{/doc/categories {Categories}} {Requirements}</property>
<property name="doc(title)">Requirements</property>
<master>
<include src="/packages/acs-core-docs/lib/navheader"
			leftLink="install" leftLabel="Prev"
			title=""
			rightLink="" rightLabel="">
		    <div class="sect1" lang="en">
<div class="titlepage"><div><div><h2 class="title" style="clear: both">
<a name="requirements" id="requirements"></a>Requirements</h2></div></div></div><div class="authorblurb">
<p>by <a href="mailto:joel\@aufrecht.org" target="_top">Joel
Aufrecht</a>
</p>
OpenACS docs are written by the named authors, and may be edited by
OpenACS documentation staff.</div><div class="sect2" lang="en">
<div class="titlepage"><div><div><h3 class="title">
<a name="requirements-introduction" id="requirements-introduction"></a>Introduction</h3></div></div></div><p>Automated Testing provides a framework for executing tests of
all varieties and for storing and viewing the results.</p>
</div><div class="sect2" lang="en">
<div class="titlepage"><div><div><h3 class="title">
<a name="gatekeeper-functional-requirements" id="gatekeeper-functional-requirements"></a>Functional
Requirements</h3></div></div></div><div class="informaltable"><table cellspacing="0" border="1">
<colgroup>
<col><col><col><col>
</colgroup><thead><tr>
<th><span class="strong">Req #</span></th><th><span class="strong">Status in 5.0</span></th><th><span class="strong">Priority for 5.1 (A=required,
B=optional)</span></th><th><span class="strong">Description</span></th>
</tr></thead><tbody>
<tr>
<td>1</td><td>Done</td><td>Done</td><td>Store trees of category labels</td>
</tr><tr>
<td>1.1</td><td>?</td><td>A</td><td>Category is package-aware. (Data in one package is not visible
from another package. There is a permission-based way to accomplish
this, but it is not obvious in the UI.)</td>
</tr><tr>
<td>2</td><td>Done</td><td>Done</td><td>There is a GUI for administrators to manage category trees
(create, delete, move leaves, edit leaves).</td>
</tr><tr>
<td>3</td><td>Done</td><td>Done</td><td>An OpenACS Object can be associated with zero, one, or more
categories.</td>
</tr><tr>
<td>3.1</td><td>partial</td><td>A</td><td>There is a GUI to control which categories are associated with
an object.</td>
</tr><tr>
<td>3.1.1</td><td>Done</td><td>Done</td><td>A package administrator can choose which category trees apply
to a package or parent object. The list of category trees which
apply to an object or its parent is called the <span class="emphasis"><em>enabled tree</em></span> list.</td>
</tr><tr>
<td>3.1.2</td><td>Done</td><td>Done</td><td>There is a facility to control object/category association.
(via /categories/www/form-page.tcl.)</td>
</tr><tr>
<td>3.1.3</td><td> </td><td>Done</td><td>The <span class="emphasis"><em>enabled trees</em></span> for an
object can be added as fields in form builder. (Current ad_form
implementation supports single select and multiple select; all
enabled trees or none. <kbd class="computeroutput">/categories/www/widget</kbd> is a deprecated
solution.)</td>
</tr><tr>
<td>3.1.4</td><td> </td><td>B</td><td>A GUI for linking any category (even one not in the
<span class="emphasis"><em>enabled trees</em></span>) to an
object.</td>
</tr><tr>
<td>3.2</td><td>partial</td><td>A</td><td>A GUI to see an object&#39;s categories.</td>
</tr><tr>
<td>3.2.1</td><td> </td><td>A</td><td>All of the categories which an object belongs to can be
displayed via an includelet on an object view page. (<kbd class="computeroutput">/categories/www/widget</kbd>)</td>
</tr><tr>
<td>4</td><td> </td><td>A</td><td>List-builder can sort and filter by category. (Implemented; not
documented. single-select only.)</td>
</tr><tr>
<td>5</td><td>partial</td><td>A</td><td>Show all objects in a category. The current implementation is
deprecated - see <a href="http://openacs.org/forums/message-view?message_id=158903" target="_top">TIP #44: Service Contract to resolve the url from an
object_id</a> and <a href="http://openacs.org/forums/message-view?message_id=158875" target="_top">TIP #43: Adding object_name to acs_objects</a>
</td>
</tr>
</tbody>
</table></div>
</div><div class="sect2" lang="en">
<div class="titlepage"><div><div><h3 class="title">
<a name="id2831234" id="id2831234"></a>References</h3></div></div></div><div class="itemizedlist"><ul type="disc"><li><p><a href="http://openacs.org/forums/message-view?message_id=153265" target="_top">Forum Posting</a></p></li></ul></div>
</div><div class="sect2" lang="en">
<div class="titlepage"><div><div><h3 class="title">
<a name="revisions-history" id="revisions-history"></a>Revision History</h3></div></div></div><div class="informaltable"><table cellspacing="0" border="1">
<colgroup>
<col><col><col><col>
</colgroup><thead><tr>
<th><span class="strong">Document Revision #</span></th><th><span class="strong">Action Taken, Notes</span></th><th><span class="strong">When?</span></th><th><span class="strong">By Whom?</span></th>
</tr></thead><tbody><tr>
<td>1</td><td>Creation</td><td>18 Jan 2004</td><td>Joel Aufrecht</td>
</tr></tbody>
</table></div>
</div>
</div>
<include src="/packages/acs-core-docs/lib/navfooter"
			leftLink="install" leftLabel="Prev" leftTitle="Installation"
			rightLink="" rightLabel="" rightTitle=""
			homeLink="index" homeLabel="Home" 
			upLink="index" upLabel="Up"> 
		    