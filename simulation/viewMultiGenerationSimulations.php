<?php

//display errors
ini_set('max_execution_time', 10 * 60);
set_time_limit(10 * 60);

//load methods
require('config.php');
require_once('library.php');
require_once('../knowledgebase/library.php');

//parameters
$id = '2012_10_24_00_49_53';
$nGenZero = 8;
$nGenerations = 3;
$useCachedData = true;
$useCachedTree = true;
$graphDeadAncestors = false;

extract($_GET);

if (!is_dir("$baseDir/$id")){
	echo "Unknown simulation batch.\n";
	exit;
}

$useCachedData = ($useCachedData + 0) && file_exists("$baseDir/$id/summary.json");
$useCachedTree = ($useCachedTree + 0) && file_exists("$baseDir/$id/ancestors.dot") && $useCachedData;
$graphDeadAncestors = $graphDeadAncestors + 0;
	
$simGroupDate = join("-", array_slice(explode('_', $id), 0, 3)).' '.join(":", array_slice(explode('_', $id), 3, 3));

//data
if (!$useCachedData){
	$simulationData = array();
	$iSimGlobalOff = 0;
	for ($iGen = 0; $iGen < $nGenerations; $iGen++){
		for ($iSim = 0; $iSim < $nGenZero * pow(2, $iGen); $iSim++){
			$idx = $iSimGlobalOff + $iSim + 1;
			
			$iParent = ($iGen == 0 ? null : $iSimGlobalOff - $nGenZero * pow(2, $iGen - 1) + floor($iSim / 2) + 1);
			$iChild1 = ($iGen < $nGenerations - 1 ? $iSimGlobalOff + $nGenZero * pow(2, $iGen) + 2 * $iSim + 1 : null);
			$iChild2 = ($iGen < $nGenerations - 1 ? $iSimGlobalOff + $nGenZero * pow(2, $iGen) + 2 * $iSim + 2 : null);
			
			list($status, $statusDetails, $time, $mass, $growth, $runtime, $run, $err, $currpbsid) = getSimulationStatus($id, null, $idx, null, $baseDir);
			$err = ($err ? json_decode("$err") : null);
			
			list($stateDetails, $junk) = getSimulationState($id, $idx, $baseDir);
			
			$pbsid = trim(file_get_contents("$baseDir/$id/$idx/simulation.pbsid"));
			
			$simulationData[$idx] = array(
				'id' => $id,
				'timestamp' => $id,
				'pbsid' => $pbsid,
				'idx' => $idx,
				'status' => $status,
				'statusDetails' => $statusDetails,
				'stateDetails'=> $stateDetails,
				'time' => $time,
				'mass' => sprintf('%e', $mass),
				'growth' => sprintf('%e', $growth),
				'runtime' => $runtime,
				'run' => $run,
				'err' => $err,
				'currpbsid' => $currpbsid,
				'generation' => $iGen,
				'idx_parent' => $iParent,
				'idx_child1' => $iChild1,
				'idx_child2' => $iChild2,
				);
		}
		$iSimGlobalOff += $nGenZero * pow(2, $iGen);
	}
	if (false === file_put_contents("$baseDir/$id/summary.json", json_encode($simulationData)))
		die("Unable to write file $baseDir/$id/summary.json.\n");
}

if (!$useCachedTree){
	$simulationData = objectToArray(json_decode(file_get_contents("$baseDir/$id/summary.json")));

	$ancestorsDotFH = fopen("$baseDir/$id/ancestors.dot", 'w');
	fprintf($ancestorsDotFH, "digraph ancestors {\n");
	fprintf($ancestorsDotFH, "	rankdir = TB;\n");
	fprintf($ancestorsDotFH, "	ranksep = 0.25;\n");
	fprintf($ancestorsDotFH, "	arrowsize = 0.6;\n");
	#fprintf($ancestorsDotFH, "	size = \"8,10.5\";\n");
	fprintf($ancestorsDotFH, "	center = true;\n");
	fprintf($ancestorsDotFH, "	margin = 0.01;\n");
	fprintf($ancestorsDotFH, "	node [shape=circle, fixedsize=true];\n");

	$iSimGlobalOff = 0;
	for ($iGen = 0; $iGen < $nGenerations; $iGen++){
		for ($iSim = 0; $iSim < $nGenZero * pow(2, $iGen); $iSim++){
			$idx = $iSimGlobalOff + $iSim + 1;		
			$iParent = ($iGen == 0 ? null : $iSimGlobalOff - $nGenZero * pow(2, $iGen - 1) + floor($iSim / 2) + 1);
			
			$status = $simulationData[$idx]['status'];
			$stateDetails = $simulationData[$idx]['stateDetails'];
			$err = $simulationData[$idx]['err'];
			
			$simulationData[$idx]['showChildren'] = 
				(is_null($iParent) || $simulationData[$iParent]['showChildren']) && 
				!(preg_match('/Terminated without division/', $stateDetails) || $err);
			
			$edge = ($err ? 'red' : 'black');
			$arrowColor = 'black';
			
			if (!$graphDeadAncestors && $iParent && !$simulationData[$iParent]['showChildren']){
				$arrowStyle = 'invis';
				$style = 'invis';
				$fill = 'black'; 
				$text = 'black';
			}else{			
				$style = 'filled';			
				switch ($status){
					case null:
					case '':
					case 'Held':
					case 'Queued':
						$arrowColor = 'gray90';
						$fill = 'gray90';
						$text = 'gray70';
						$edge = ($err ? 'red' : 'gray70');
						$arrowStyle = 'solid';
						break;
					case 'Running':
						$arrowStyle = 'solid';
						$fill = 'gray70';
						$text = 'gray50';
						break;
					case 'Reindexing':
					case 'Reindexing held':
					case 'Reindexing queued':
					case 'Analyzing':
					case 'Analysis held':
					case 'Analysis queued':
					case 'Finished':
						$arrowStyle = 'solid';
						if (preg_match('/Terminated with division/', $stateDetails)){
							$fill = 'white';
							$text = 'black';
						}
						elseif (preg_match('/Terminated without division/', $stateDetails)){
							$fill = 'black';
							$text = 'white';
						}else{
							$fill = 'red';
							$text = 'white';
						}
						break;
				}
			}
			
			fprintf($ancestorsDotFH, "%d [style=\"%s\", color=\"%s\", fillcolor=\"%s\", fontcolor=\"%s\"];\n", $idx, $style, $edge, $fill, $text);
				
			if ($iParent)
				fprintf($ancestorsDotFH, "	%d->%d [style=\"%s\", color=\"%s\"];\n", $iParent, $idx, $arrowStyle, $arrowColor);
		}
		$iSimGlobalOff += $nGenZero * pow(2, $iGen);
	}

	#draw family tree
	fprintf($ancestorsDotFH, "}\n");
	fclose($ancestorsDotFH);
	`dot -Tpng -o "$baseDir/$id/ancestors.png" "$baseDir/$id/ancestors.dot"`;
	`dot -Tpdf -o "$baseDir/$id/ancestors.pdf" "$baseDir/$id/ancestors.dot"`;
	`dot -Tsvg -o "$baseDir/$id/ancestors.svg" "$baseDir/$id/ancestors.dot"`;
}

//page content
$simulationData = objectToArray(json_decode(file_get_contents("$baseDir/$id/summary.json")));
$data = json_encode(array_values($simulationData));

$statusSummaryHidden = ($pageOptions['viewSimulationSet']['displayStatusSummary'] ? 'false' : 'true');
$runTimeHidden = (false && $pageOptions['viewSimulationSet']['displayRunTime'] ? 'false' : 'true');
$downloadHidden = ($pageOptions['viewSimulationSet']['displayDownload'] ? 'false' : 'true');
$errorLogHidden = ($pageOptions['viewSimulationSet']['displayErrorLog'] ? 'false' : 'true');
$queueHidden = ($pageOptions['viewSimulationSet']['displayQueue'] ? 'false' : 'true');

$content = <<<HTML
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/smoothness/jquery-ui-1.8.14.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/pixelmatrix-uniform-2446d99/css/uniform.default.css" />
<style>
#key{
	padding-top:10px;
}
#key tr td{
	padding:0px;
	margin:0px;
	vertical-alignment:middle;
}
#key tr td:first-child{
	width:10px;	
	padding-right:4px;	
}
#key tr td:first-child hr{
	height:4px;
	border:1px solid black;
}
</style>
<script src="../lib/jqGrid-4.1.2/js/jquery-1.5.2.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery-ui.custom.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<div id="Object" class="List">
<h1>Multi-generation simulation Set $simGroupDate</h1>
<p>Please use the links in the "Log" and "Download" columns in the table below to download summaries and the complete predicted dynamics of each <i>in silico</i> <i>M. genitalium</i> cell.</p>
</div>

<div id="Object" class="List" style="margin-top:20px">
<h1>Lineage summary</h1>
<a href="$simulationResultsURL/$id/ancestors.pdf">
	<img src="$simulationResultsURL/$id/ancestors.png" style="padding-bottom:0px; margin-bottom:0px; margin-top:10px; width:100%;"/>
</a>

<table id="key" cellspacing="0" cellpadding="0">
<tr><td><hr style="background:white"/></td><td>Divided sucessfully</td></tr>
<tr><td><hr style="background:black"/></td><td>Did not divide</td></tr>
<tr><td><hr style="background:rgb(179,179,179); "/></td><td>Running</td></tr>
<tr><td><hr style="background:rgb(230,230,230);"/></td><td>Held/queued</td></tr>
<tr><td><hr style="background:red;"/></td><td>Error</td></tr>
</table>

</div>

<div style="margin-top:20px">
<h1>Individual simulations</h1>
</div>
<script type="text/javascript">
jQuery(document).ready(function(){
    jQuery("#individualSimulationsGrid").jqGrid({
		datatype:"local",
		height:'auto',
		autowidth:true,
		colNames:['Timestamp', '#', 'Gen', 'Parent', 'Child-1', 'Child-2', 'Summary', 'Details', 'Time', 'Mass', 'Growth', 'Run time', 'Log', 'Download', 'Error', 'Queue'],
		colModel:[
			{name:'timestamp', index:'timestamp', sorttype:"integer", hidden:true, align:"right", width:30, sortable:true},
			{name:'idx', index:'idx', sorttype:"integer", hidden:false, align:"right", width:20, sortable:true},
			{name:'generation', index:'generation', sorttype:"integer", hidden:false, align:"right", width:10, sortable:true},
			{name:'idx_parent', index:'idx_parent', sorttype:"integer", hidden:false, align:"right", width:20, sortable:true},
			{name:'idx_child1', index:'idx_child1', sorttype:"integer", hidden:false, align:"right", width:20, sortable:true},
			{name:'idx_child2', index:'idx_child2', sorttype:"integer", hidden:false, align:"right", width:20, sortable:true},
			{name:'status', index:'status', width:50, sortable:true, hidden: $statusSummaryHidden},
			{name:'statusDetails', index:'statusDetails', width:85, sortable:true, hidden: $statusSummaryHidden},
			{name:'time', index:'time', width:50, sortable:true, align:"center"},
			{name:'mass', index:'mass', width:25, sortable:true, sorttype:'float', formatter:'number', formatoptions:{decimalPlaces:2}, align:"right"},
			{name:'growth', index:'growth', width:25, sortable:true, sorttype:'float', formatter:'number', formatoptions:{decimalPlaces:2}, align:"right"},
			{name:'runtime', index:'runtime', width:50, sortable:true, hidden: $runTimeHidden},
			{name:'run', index:'run', width:55, sortable:true, align:"center",
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
			{name:'download', index:'download', width:55, sortable:true, align:"center", hidden: $downloadHidden,
				formatter : function(value, options, rData){
					if (rData['run'] == 1 || rData['run'] == 2){
						return '<a href="$simulationResultsURL/'+rData['timestamp']+'/'+rData['idx']+'.zip">zip</a>';
					}else{
						return '&nbsp;';
					}
				}
			},
			{name:'err', index:'err', width:55, sortable:true, hidden: $errorLogHidden,
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
			{name:'currpbsid', index:'currpbsid', width:55, sortable:true, hidden: $queueHidden,
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
	jQuery("#individualSimulationsGrid").jqGrid('navGrid', "#individualSimulationsNav", {edit:false, add:false, del:false, refresh:false, view:false});

	var data = $data;
	for(var i=0; i <= data.length; i++)
		jQuery("#individualSimulationsGrid").jqGrid('addRowData', i+1, data[i]);
})
</script>
<table id="individualSimulationsGrid"></table>
<div id="individualSimulationsNav"></div>
HTML;

// layout page
require('../pageTemplate.php');
$navigationContents = array(
	array('url' => 'index.php', 'text' => 'Simulation'), 
	array('url' => 'viewGenerationSimulation.php', 'text' => 'Multi-generation simulations'));
echo composePage($content, $navigationContents, array(), 'simulation');