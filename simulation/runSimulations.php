<?php

//display errors
ini_set('display_errors', 1);

//load methods
require('config.php');
require_once '../knowledgebase/library.php';
require_once 'library.php';

#get KB WID
$result = runQuery("CALL get_latest_knowledgebase('WholeCell');", $kbConfig); $kbWID = $result['WID'];

#get data from knowledge base
$link = databaseConnect($kbConfig);
$result = mysql_query("
  select DBID.XID, Gene.symbol, Gene.Name, CommentTable.Comm Comment
  from Gene 
  join DBID on DBID.otherwid=Gene.wid
  join CommentTable on CommentTable.otherwid=Gene.wid
  where DataSetWid = $kbWID;") or die(mysql_error());
$genes = array();
while ($arr = mysql_fetch_array($result, MYSQL_ASSOC)){  
  array_push($genes, $arr);
}
mysql_close($link);

#get user information
$userName = '';
$ipAddress = $_SERVER['REMOTE_ADDR'];
$hostName = gethostbyaddr($ipAddress);

$firstName = '';
$lastName = '';
$email = '';
$affiliation = '';

if ($pageOptions['runSimulations']['enableQueueSimulation']){
	$userName = $_SERVER['REMOTE_USER'];
	$result = runQuery("SELECT * FROM LabMembers WHERE sunetid='$userName';", $dbConfig);
	$firstName = $result['fname'];
	$lastName = $result['lname'];
	$email = $result['email'];
	$affiliation = 'Covert Lab, Department of Bioengineering, Stanford University';	
}

#replicats
$replicates = 1;

#content
if ($pageOptions['runSimulations']['enableQueueSimulation']){
	$pageTitle = 'Queue Simulations';
	
	$firstNameFieldData = "class=\"readonly\" readonly=\"true\"";
	$lastNameFieldData = "class=\"readonly\" readonly=\"true\"";
	$affiliationFieldData = "class=\"readonly\" readonly=\"true\"";
	$emailFieldData = "class=\"readonly\" readonly=\"true\"";
	$userNameFieldData = "class=\"readonly\" readonly=\"true\"";
}else{
	$pageTitle = 'Generate XML Simulation Configuration File';
}
$ipAddressFieldData = "class=\"readonly\" readonly=\"true\"";
$hostNameFieldData = "class=\"readonly\" readonly=\"true\"";
	
$content = <<<HTML
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/smoothness/jquery-ui-1.8.14.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/pixelmatrix-uniform-2446d99/css/uniform.default.css" />
<style type="text/css">
input.readonly, input.readonly:focus{
	background-color:#eee;
	background-image:none;
	-webkit-box-shadow:none;
	-moz-box-shadow:none;
	box-shadow:none;
	border-color: #999;
}

table{
	width:800px;
}
th {
  text-align:right;
  width:70px;
  padding-right:10px;
  vertical-align:top;    
}
th, td{
  padding-bottom:2px;
}
th{
	width:75px;
}
td:first-child{
	width:750px;
}
td:last-child{
	color:red;
	width:20px;
}
input, textarea {
   width:100%;
   height:18px;
}
input.button {
   width:60px;
   height:24px;
   vertical-align:middle;
   padding:4px;
   padding-top:2px;
   margin:0px;
   margin-top:40px;
}
textarea {
   height:100px;
}
table.upload th{
	vertical-align:middle;
	padding-left:0px;
	width:45px;
}
table.upload input.file {
	background: url('../lib/quirksmode/input_boxes.gif') no-repeat 0 -58px;
	border: none;
	margin: 0;
	height: 22px;
	padding-left: 3px;
	padding-top: 3px;
}
</style>
<script src="../lib/jqGrid-4.1.2/js/jquery-1.5.2.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery-ui.custom.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>
<script src="../lib/pixelmatrix-uniform-2446d99/jquery.uniform.min.js" type="text/javascript"></script>
<script type="text/javascript">
$(function() {
	$( "input:submit").button();	
	$("select, input:text, textarea").uniform();
});
</script>

<form method="post" action="queueSimulations.php" id="form" enctype="multipart/form-data">

<div id="Object" class="List">
<h1>Configure your own whole-cell simulation!</h1>
This page provides an interactive interface to configure a whole-cell simulation to run on your own machine. This page displays all of the default parameter values of whole-cell model, allows you to modify the values of those parameters, and generates and XML file describing the specified modifications to the default parameter values which can be used with the whole-cell model software to simulate <i>M. genitalium</i>. See the <a class="coloredLink" href="http://simtk.org/project/xml/downloads.xml?group_id=714">whole-cell model user guide</a> for detailed instructions how to install and run whole-cell simulations.
</div>

<div id="Object" class="List" style="margin-top:20px;">
<h1>Enter user meta data</h1>
<table cellpadding="0" cellspacing="0" style="border-top:none; border-bottom:none;">
	<tr><th>First name</th><td><input name="firstName" type="text" $firstNameFieldData value="$firstName"/></td><td>*</td></tr>
	<tr><th>Last name</th><td><input name="lastName" type="text" $lastNameFieldData value="$lastName"/></td><td>*</td></tr>
	<tr><th>Affiliation</th><td><input name="affiliation" type="text" $affiliationFieldData value="$affiliation"/></td><td>*</td></tr>
	<tr><th>Email</th><td><input name="email" type="text" $emailFieldData value="$email"/></td><td>*</td></tr>
	<tr><th>User name</th><td><input name="userName" type="text" $userNameFieldData value="$userName"/></td><td>*</td></tr>
	<tr><th>IP Address</th><td><input name="ipAddress" type="text" $ipAddressFieldData value="$ipAddress"/></td><td>*</td></tr>
	<tr><th>Host name</th><td><input name="hostName" type="text" $hostNameFieldData value="$hostName"/></td><td>*</td></tr>
</table>
<p style="color:red; padding:0px; margin:0px; padding-top:12px;">* Required</p>
</div>
  
<div id="Object" class="List" style="margin-top:20px;">
<h1>Enter simulation meta data $beginComment and replicates $endComment</h1>
<table cellpadding="0" cellspacing="0" style="border-top:none; border-bottom:none;">
	<tr><th>Name</th><td><input name="shortDescription" type="text"/></td><td>*</td></tr>
	<tr><th>Description</th><td><textarea name="longDescription"></textarea></td><td>*</td></tr>
	$beginComment
	<tr><th>Replicates</th><td><input name="replicates" type="text" value="$replicates"/></td><td>*</td></tr>
	$endComment
</table>
<p style="color:red; padding:0px; margin:0px; padding-top:12px;">* Required</p>
</div>
  
<h1 style="margin-top:20px;">Set parameter values</h1>
<input type="hidden" id="options" name="options"/>
<script type="text/javascript">
var lastsel;
jQuery(document).ready(function(){	
    jQuery("#jqgrid").jqGrid({
		url:'getSimulationOptions.php',
		jsonReader:{"repeatitems":false, "subgrid":{"repeatitems":false}},
		treedatatype:'json',
		treeGridModel:'adjacency',
		treeReader:{
			level_field: "level",
			parent_id_field: "parent",
			leaf_field: "isLeaf",
			expanded_field: "expanded"
		},
		treeGrid:true,
		datatype:'json',
		height:600,
		autowidth:true,
		colNames:['ID', 'WholeCellModelID', 'Name', 'Value', 'Editable', 'Modified'],
		colModel:[			
			{name:'id', index:'id', key:true, width:45, hidden:true, editable:false, sortable:false},
			{name:'wholeCellModelID', index:'wholeCellModelID', width:45, hidden:true, editable:false, sortable:false},			
			{name:'name', index:'name', width:300, editable:false, sortable:false},
			{name:'value', index:'value', width:300, editable:true, sortable:false},
			{name:'editable', index:'editable', width:45, hidden:true, editable:false, sorttype:'integer', sortable:false},
			{name:'modified', index:'modified', width:45, editable:false, sorttype:'integer', formatoptions:{disabled:true}, formatter:'checkbox', sortable:false}
		],
		ExpandColumn:'name',
		ExpandColClick:true,
		viewrecords: true,
		pager:'#jqnav',
		pgbuttons:false,
		pginput:false,
		rownumbers:false,
		viewrecords:false,
		rowNum:1000000,
		onSelectRow: function(id){
			grid = jQuery('#jqgrid');
			if(id && id!==lastsel){				
				saveData();
				if (grid.getRowData(id).editable == 'true'){
					grid.jqGrid('editRow', id, true);
				}
				lastsel = id;
			}
		}
	});
	jQuery("#jqgrid").jqGrid('navGrid', "#jqnav", {edit:false, add:false, del:false, refresh:false, view:false});
})	
	
function saveData(){
	if (lastsel && grid.getRowData(lastsel).editable == 'true') {
		rData = grid.getLocalRow(lastsel);
		value = document.getElementById(lastsel+'_value').value;
		grid.jqGrid('restoreRow', lastsel);
		if (rData.value != value) {
			rData = grid.getRowData(lastsel);
			rData.value = value;
			rData.modified = true;
			grid.setRowData(lastsel, rData);
			
			while (rData = grid.getNodeParent(rData)){
				rData.modified = true;
				grid.setRowData(rData.id, rData);
			}
		}
	}
}
</script>
<table id="jqgrid"></table>
<div id="jqnav"></div>

$beginComment
<br/><br/><b>OR</b><br/><br/>

<table cellpadding="0" cellspacing="0" class="upload">
	<tr><th>XML File</th><td><input type="file" name="conditionsXMLFile" class="file"/></td></tr>
</table>
$endComment

<input class="button" type="submit" value="Submit" onClick="javascript:return submitForm();" style="float:right;"/>
<script type="text/javascript">
function submitForm(){
	saveData();
	
	grid = jQuery("#jqgrid");
	data = new Array();
	for (i = 1; i <= grid.jqGrid('getGridParam', 'reccount'); i++){
		rData = grid.getRowData(i);
		if (rData.modified=='Yes' && rData.editable=='true'){
			data.push({id:rData.wholeCellModelID, value:rData.value});
		}
	}
	document.getElementById('options').value = JSON.stringify(data);
	
	return true;
}
</script>
  
</form>
HTML;

require('../pageTemplate.php');
$navigationContents = array(
	array('url' => 'index.php', 'text' => 'Simulation'), 
	array('url' => 'runSimulations.php', 'text' => $pageTitle));
echo composePage($content, $navigationContents, array(), 'simulation');

?>