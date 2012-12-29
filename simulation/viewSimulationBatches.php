<?php

//load methods
require('config.php');
require_once('library.php');
require_once('../pageTemplate.php');

//content
$data = getAllSimulationBatches($baseDir, $simulationMetaDataCache);

$pbsIDHidden = ($pageOptions['index']['displayPBSIDs'] ? 'false' : 'true');
$revisionHidden = ($pageOptions['index']['displayRevision'] ? 'false' : 'true');
$emailHidden = ($pageOptions['index']['displayEmail'] ? 'false' : 'true');
$userNameHidden = ($pageOptions['index']['displayUserName'] ? 'false' : 'true');
$hostNameHidden = ($pageOptions['index']['displayHostName'] ? 'false' : 'true');
$ipAddressHidden = ($pageOptions['index']['displayIpAddress'] ? 'false' : 'true');
$downloadHidden = ($pageOptions['index']['displayDownload'] ? 'false' : 'true');

$content = <<<HTML
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/smoothness/jquery-ui-1.8.14.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/pixelmatrix-uniform-2446d99/css/uniform.default.css" />
<script src="../lib/jqGrid-4.1.2/js/jquery-1.5.2.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery-ui.custom.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<div id="Object" class="List" style="margin-bottom:20px;">
	<h1>Simulation batches</h1>
	<p>The whole-cell model simulations were executed in the batches listed below. Please click on the entries in date column in the table below to browse and download the simulations in each batch.</p>
</div>

<script type="text/javascript">
jQuery(document).ready(function(){
    jQuery("#jqgrid").jqGrid({
		datatype: "local",
		height:'auto',
		autowidth:true,
		colNames:['Timestamp', 'PBS ID', 'Date', 'Revision', 'No. Conditions', 'No. Simulations', 'First Name', 'Last Name', 'Investigator', 'Affiliation', 'Email', 'User name', 'Host name', 'IP Address', 'Download'],
		colModel:[
			{name:'timestamp', index:'timestamp', width:80, hidden:true},
			{name:'pbsid', index:'pbsid', width:44, 'sorttype':'integer', 'align':'right', hidden: $pbsIDHidden,
				formatter : function(value, options, rData){
					return '<a href="viewSimulationSet.php?id='+rData['timestamp']+'">'+value+'</a>';
				}
			},
			{name:'date', index:'date', width:120, align:"center",
				formatter : function(value, options, rData){
					return '<a href="viewSimulationSet.php?id='+rData['timestamp']+'">'+value+'</a>';
				}
			},
			{name:'revision', index:'revision', width:55, sorttype:"integer", align:"right", hidden: $revisionHidden},
			{name:'nConditions', index:'nConditions', width:55, sorttype:"integer", align:"right"},
			{name:'nSimulations', index:'nSimulations', width:55, sorttype:"integer", align:"right"},
			{name:'firstName', index:'firstName', width:80, hidden:true},
			{name:'lastName', index:'lastName', width:80, hidden:true},
			{name:'investigator', index:'investigator', width:80, 
				formatter : function(value, options, rData){
					return rData['firstName']+" "+rData['lastName'];
				}
			},
			{name:'affiliation', index:'affiliation', width:280},
			{name:'email', index:'email', width:78, hidden: $emailHidden,
				formatter : function(value, options, rData){
					return '<a href="mailto:'+value+'">'+value+'</a>';
				}
			},
			{name:'userName', index:'userName', width:65, hidden: $userNameHidden},
			{name:'hostName', index:'hostName', width:78, hidden: $hostNameHidden},
			{name:'ipAddress', index:'ipAddress', width:82, hidden: $ipAddressHidden},
			{name:'download', index:'download', width:120, sortable:true, align:"center", hidden: $downloadHidden,
				formatter : function(value, options, rData){
					return '<a href="$simulationResultsURL/'+rData['timestamp']+'.7z">7z</a>';				}
			},
		],
		viewrecords: true,
		rowNum:1000000,
		pager:'#jqnav',
		pgbuttons:false,
		pginput:false,
		rownumbers:true,
		viewrecords:false
	});
	jQuery("#jqgrid").jqGrid('navGrid', "#jqnav", {edit:false, add:false, del:false, refresh:false, view:false});
	
	var data = $data;
	for(var i=0; i <= data.length; i++)
		jQuery("#jqgrid").jqGrid('addRowData', i+1, data[i]);
})
</script>
<table id="jqgrid"></table>
<div id="jqnav"></div>
HTML;

$navigationContents = array(
	array('url' => 'index.php', 'text' => 'Simulation'), 
	array('url' => 'viewSimulationBatches.php', 'text' => 'Simulation batches'));
echo composePage($content, $navigationContents, array(), 'simulation');

?>
