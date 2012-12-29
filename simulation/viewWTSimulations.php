<?php

//display errors
ini_set('max_execution_time', 10 * 60);
set_time_limit(10 * 60);

//load methods
require('config.php');
require_once('library.php');
require_once('../knowledgebase/library.php');

#data
$individualSimulationsData = getWildTypeSimulations($baseDir, $simulationMetaDataCache);

//table
$statusSummaryHidden = ($pageOptions['viewWTSimulations']['displayStatusSummary'] ? 'false' : 'true');
$runTimeHidden = ($pageOptions['viewWTSimulations']['displayRunTime'] ? 'false' : 'true');
$downloadHidden = ($pageOptions['viewWTSimulations']['displayDownload'] ? 'false' : 'true');
$errorLogHidden = ($pageOptions['viewWTSimulations']['displayErrorLog'] ? 'false' : 'true');
$queueHidden =  ($pageOptions['viewWTSimulations']['displayQueue'] ? 'false' : 'true');

$content = <<<HTML
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/smoothness/jquery-ui-1.8.14.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/pixelmatrix-uniform-2446d99/css/uniform.default.css" />
<script src="../lib/jqGrid-4.1.2/js/jquery-1.5.2.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery-ui.custom.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<div id="Object" class="List" style="margin-bottom:20px;">
		<h1>Wild type simulations</h1>
		<p>The table below lists all of the wild type simulations reported in the manuscript titled "<a class="coloredLink" href="http://simtk.org/frs/download.php?file_id=3122">A Whole-Cell Computational Model Predicts Phenotype from Genotype</a>". Please click on the links in the "Log" column to view/download a summaries of each simulation. Please click on the links in the "Download" column to download the complete simulated dynamics of each <i>in silico</i> <i>M. genitalium</i> cell.</p>
</div>

<script type="text/javascript">
jQuery(document).ready(function(){
    jQuery("#jqgrid").jqGrid({
		datatype:"local",
		height:'auto',
		autowidth:true,
		colNames:['Batch', 'Condition', '#', 'Summary', 'Details', 'Time', 'Mass', 'Growth', 'Run time', 'Log', 'Download', 'Error', 'Queue'],
		colModel:[
			{name:'timestamp', index:'timestamp', sorttype:"integer", hidden:false, align:"center", width:150, sortable:true,
				formatter : function(value, options, rData){
					return '<a href="viewSimulationSet.php?id='+rData['timestamp']+'">'+value+'</a>';
				}
			},			
			{name:'conditionSet', index:'conditionSet', sorttype:"integer", align:"right", width:30, sortable:true},
			{name:'idx', index:'idx', sorttype:"integer", hidden:false, align:"right", width:30, sortable:true},
			{name:'status', index:'status', width:65, sortable:true, hidden: $statusSummaryHidden},
			{name:'statusDetails', index:'statusDetails', width:65, sortable:true, hidden: $statusSummaryHidden},
			{name:'time', index:'time', width:50, sortable:true, align:"right"},
			{name:'mass', index:'mass', width:50, sortable:true, sorttype:'float', formatter:'number', formatoptions:{decimalPlaces:2}, align:"right"},
			{name:'growth', index:'growth', width:60, sortable:true, sorttype:'float', formatter:'number', formatoptions:{decimalPlaces:3}, align:"right"},
			{name:'runtime', index:'runtime', width:70, sortable:true, hidden: $runTimeHidden},
			{name:'run', index:'run', width:70, sortable:true, align:"center",
				formatter : function(value, options, rData){
					if (value == 2){
						return '<a href="viewSimulationLog.php?id='+rData['timestamp']+'&idx='+rData['idx']+'&job=simulation&log=out">log</a> | <a href="viewSimulationLog.php?id='+rData['timestamp']+'&idx='+rData['idx']+'&job=simulation&log=out&format=mat">mat</a>';
					}else if (value == 1){
						return '<a href="viewSimulationLog.php?id='+rData['timestamp']+'&idx='+rData['idx']+'&job=simulation&log=out">log</a>';
					}else{
						return '&nbsp;';
					}
				}
			},
			{name:'download', index:'download', width:70, sortable:true, align:"center", hidden: $downloadHidden,
				formatter : function(value, options, rData){
					if (rData['run'] == 1 || rData['run'] == 2){
						return '<a href="$simulationResultsURL/'+rData['timestamp']+'/'+rData['idx']+'.7z">7z</a>';
					}else{
						return '&nbsp;';
					}
				}
			},
			{name:'err', index:'err', width:70, sortable:true, hidden: $errorLogHidden,
				formatter : function(value, options, rData){
					if (value){
						if (typeof(value)=='string'){
							if (value.length > 0) {
								return '<a href="viewSimulationLog.php?id='+rData['timestamp']+'&idx='+rData['idx']+'&job='+value+'&log=err">log</a>';
							}else{
								return '&nbsp';
							}
						}else{
							html = '';
							for (type in value){
								html += '<a href="viewSimulationLog.php?id='+rData['timestamp']+'&idx='+rData['idx']+'&job='+value[type]+'&log=err">'+type+'</a> | ';
							}
							return html.substr(0, html.length - 3);
						}
					}else{
						return '&nbsp';
					}
				}
			},
			{name:'currpbsid', index:'currpbsid', width:70, sortable:true, hidden: $queueHidden,
				formatter : function(value, options, rData){
					if (value){
						return '<a href="$checkJobURL'+rData['currpbsid']+'">html</a>';
					}else{
						return '&nbsp';
					}
				}
			}
		],
		viewrecords: true,
		rowNum:1000000,
		pager:'#individualSimulationsNav',
		pgbuttons:false,
		pginput:false,
		rownumbers:true,
		viewrecords:false
	});
	jQuery("#jqgrid").jqGrid('navGrid', "#individualSimulationsNav", {edit:false, add:false, del:false, refresh:false, view:false});

	var individualSimulationsData = $individualSimulationsData;
	for(var i=0; i <= individualSimulationsData.length; i++)
		jQuery("#jqgrid").jqGrid('addRowData', i+1, individualSimulationsData[i]);
})
</script>
<table id="jqgrid"></table>
<div id="jqnav"></div>
HTML;

// layout page
require('../pageTemplate.php');
$navigationContents = array(
	array('url' => 'index.php', 'text' => 'Simulation'), 
	array('url' => 'viewWTSimulations.php', 'text' => 'Wild type simulations'));
echo composePage($content, $navigationContents, array(), 'simulation');

?>
