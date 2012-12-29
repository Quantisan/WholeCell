<?php

//display errors
ini_set('max_execution_time', 10 * 60);
set_time_limit(10 * 60);

//load methods
require('config.php');
require_once('library.php');
require_once('../knowledgebase/library.php');

#data
if ($_GET['data'] == 'grid') {
	echo getAllDeletionSimulations($baseDir, $kbConfig, $simulationMetaDataCache);
	exit;
}elseif ($_GET['data'] == 'subgrid') {
	$data = json_decode(getDeletionStrainSimulations($baseDir, $kbConfig, $simulationMetaDataCache));
	if (isset($data->$_GET['id']))
		$data = $data->$_GET['id'];
	else
		$data = array();

	$jsonData = array();
	foreach ($data as $i => $datum){
		$cols = array(
			$i+1,
			$datum->revision,
			sprintf("<a href=\'viewSimulationSet.php?id=%s\'>%s</a>", $datum->batchId, $datum->batchId), 
			$datum->batchIdx,
			$datum->summary,
			$datum->details,
			$datum->time,
			sprintf('%.2f', $datum->mass),
			sprintf('%.3f', $datum->growth),
			$datum->runtime,
			$datum->runLog,
			sprintf("<a href=\'$simulationResultsURL/%s/%d.7z\'>7z</a>", $datum->batchId, $datum->batchIdx),
			$datum->errLog,
			$datum->queue,
			);
		if (!$pageOptions['viewSingleGeneDeletions']['displayQueue']) array_splice($cols, 13, 1);
		if (!$pageOptions['viewSingleGeneDeletions']['displayError']) array_splice($cols, 12, 1);
		if (!$pageOptions['viewSingleGeneDeletions']['displayDownload']) array_splice($cols, 11, 1);
		if (!$pageOptions['viewSingleGeneDeletions']['displayRunTime']) array_splice($cols, 9, 1);
		if (!$pageOptions['viewSingleGeneDeletions']['displayStatusSummary']) array_splice($cols, 4, 2);
		if (!$pageOptions['viewSingleGeneDeletions']['displayRevision']) array_splice($cols, 1, 1);

		array_push($jsonData, '{"id":"'.$i.'", "cell":["'.join('", "', $cols).'"]}');
	}
	
	echo
		"{\n".
		"  \"rows\":[\n".
		"    ".join(",\n    ", $jsonData)."\n".
		"  ]\n".
		"}\n";
	exit;
}

//table
$reactionsHidden = ($pageOptions['viewSingleGeneDeletions']['displayReactions'] ? 'false' : 'true');
$essentialHidden = ($pageOptions['viewSingleGeneDeletions']['displayEssential'] ? 'false' : 'true');
$analysisHidden = ($pageOptions['viewSingleGeneDeletions']['displayAnalysis'] ? 'false' : 'true');

$subGridCols = array(
	array('name' => '#',        'width' =>  16, 'align' => 'right'),
	array('name' => 'R',        'width' =>  20, 'align' => 'right'),
	array('name' => 'Batch',    'width' => 140, 'align' => 'center'),
	array('name' => 'Id',       'width' =>  16, 'align' => 'right'),
	array('name' => 'Summary',  'width' =>  76, 'align' => 'left'),
	array('name' => 'Details',  'width' => 290, 'align' => 'left'),
	array('name' => 'Time',     'width' =>  50, 'align' => 'center'),
	array('name' => 'Mass',     'width' =>  30, 'align' => 'center'),
	array('name' => 'Growth',   'width' =>  40, 'align' => 'center'),
	array('name' => 'Runtime',  'width' =>  50, 'align' => 'center'),
	array('name' => 'Log',      'width' =>  60, 'align' => 'center'),
	array('name' => 'Download', 'width' =>  60, 'align' => 'center'),
	array('name' => 'Error',    'width' =>  60, 'align' => 'left'),
	array('name' => 'Queue',    'width' =>  40, 'align' => 'left'),
);
if (!$pageOptions['viewSingleGeneDeletions']['displayQueue']) array_splice($subGridCols, 13, 1);
if (!$pageOptions['viewSingleGeneDeletions']['displayError']) array_splice($subGridCols, 12, 1);
if (!$pageOptions['viewSingleGeneDeletions']['displayDownload']) array_splice($subGridCols, 11, 1);
if (!$pageOptions['viewSingleGeneDeletions']['displayRunTime']) array_splice($subGridCols, 9, 1);
if (!$pageOptions['viewSingleGeneDeletions']['displayStatusSummary']) array_splice($subGridCols, 4, 2);
if (!$pageOptions['viewSingleGeneDeletions']['displayRevision']) array_splice($subGridCols, 1, 1);

$totalColWidth = 0;
for ($i = 0; $i < count($subGridCols); $i++){
	$totalColWidth += $subGridCols[$i]['width'];
}

$subGridNames = array();
$subGridWidths = array();
$subGridAligns = array();
for ($i = 0; $i < count($subGridCols); $i++){
	array_push($subGridNames, $subGridCols[$i]['name']);
	array_push($subGridWidths, $subGridCols[$i]['width'] * 765 / $totalColWidth);
	array_push($subGridAligns, $subGridCols[$i]['align']);
}
$subGridModel = "{
	name: ['".join("', '", $subGridNames)."'], 
	width: [".join(", ", $subGridWidths)."], 
	align: ['".join("', '", $subGridAligns)."']
	}";
	
$plotsHTML = <<<HTML
<div id="Object" class="List" style="margin-top:20px"><div>
<h1>Summary</h1>
<ul style="margin-top:0px;">
<li>Plot compilation (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/summary.pdf">pdf</a>)</li>
<li>Statistics (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/summary.xls">xls</a>)</li>
<li>Summary plot (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/overview.pdf">pdf</a>)</li>
<li>Summary grid (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/summaryGrid.svg">svg</a> | <a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/summaryGrid.pdf">pdf</a>)</li>
<li>Manual notes (<a class="coloredLink" href="documentation/singleGeneDeletions.xlsx">xlsx</a>)</li>
<li>Summary (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all.pdf">pdf</a>)</li>
<li>Mass (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-01.pdf">pdf</a>)</li>
<li>Growth (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-02.pdf">pdf</a>)</li>
<li>ATP usage (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-03.pdf">pdf</a>)</li>
<li>GTP usage (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-04.pdf">pdf</a>)</li>
<li>Chromosome copy number (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-05.pdf">pdf</a>)</li>
<li>Superhelicity (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-06.pdf">pdf</a>)</li>
<li>RNA (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-07.pdf">pdf</a>)</li>
<li>Protein (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-08.pdf">pdf</a>)</li>
<li>dNTP (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-09.pdf">pdf</a>)</li>
<li>NTP (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-10.pdf">pdf</a>)</li>
<li>Amino acid (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-11.pdf">pdf</a>)</li>
<li>Damaged RNA (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-12.pdf">pdf</a>)</li>
<li>Damaged protein (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-13.pdf">pdf</a>)</li>
<li>Antibiotics (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-14.pdf">pdf</a>)</li>
<li>Replication initiation duration (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-15.pdf">pdf</a>)</li>
<li>Replication duration (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-16.pdf">pdf</a>)</li>
<li>Cytokinesis duration (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-17.pdf">pdf</a>)</li>
<li>Mass doubling duration (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-18.pdf">pdf</a>)</li>
<li>Cell cycle length (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/all-19.pdf">pdf</a>)</li>
</ul>
</div></div>

<div id="Object" class="List" style="margin-top:20px"><div>
<h1>Single-gene disruption strain classes</h1>
<ul style="margin-top:0px;">
<li>Non-essential (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-1.pdf">pdf</a>)</li>
<li>Degrading (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-2.pdf">pdf</a>)</li>
<li>Non-growing (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-3.pdf">pdf</a>)</li>
<li>Decaying growth - non-RNA, non-protein synthesizing (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-4.pdf">pdf</a>)</li>
<li>Decaying growth - non-protein synthesizing (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-5.pdf">pdf</a>)</li>
<li>Non-replicative (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-6.pdf">pdf</a>)</li>
<li>Non-fissive (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-7.pdf">pdf</a>)</li>
<li>Slow growing (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-8.pdf">pdf</a>)</li>
<li>Toxin accumulation (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-9.pdf">pdf</a>)</li>
<li>Non-perpetuating (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-10.pdf">pdf</a>)</li>
<li>No terminal organelle (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/class-11.pdf">pdf</a>)</li>
</ul>
</div></div>

<div id="Object" class="List" style="margin-top:20px">
<h1>Single-gene disruption strain classification</h1>
<ul style="margin-top:0px;">
<li>Disruption strain growth rate distribution (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/deletionGrowthRateDistribution.pdf">pdf</a>)</li>
<li>Decomposing, non-growing, non-essential (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/classification-1.pdf">pdf</a>)</li>
<li>Decaying growth (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/classification-2.pdf">pdf</a>)</li>
<li>Non-replicative (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/classification-3.pdf">pdf</a>)</li>
<li>Non-fissive (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/classification-4.pdf">pdf</a>)</li>
<li>Toxin accumulation (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/classification-6.pdf">pdf</a>)</li>
</ul>
</div>

<div id="Object" class="List" style="margin-top:20px">
<h1>Model / experiment comparison</h1>
<ul style="margin-top:0px;">
<li>Doubling time (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/ModelDoublingTimeVsExperimentDoublingTime.pdf">pdf</a>)</li>
<li>Cell cycle length (<a class="coloredLink" href="$simulationResultsURL/singleGeneDeletions/ModelCellCycleLengthVsExperimentDoublingTime.pdf">pdf</a>)</li>
</ul>
</div>
HTML;

if (!$pageOptions['viewSingleGeneDeletions']['displayPlots'])
	$plotsHTML = '';

$content = <<<HTML
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/smoothness/jquery-ui-1.8.14.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/pixelmatrix-uniform-2446d99/css/uniform.default.css" />
<script src="../lib/jqGrid-4.1.2/js/jquery-1.5.2.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery-ui.custom.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<div id="Object" class="List">
	<h1>Single-gene disruption Simulations</h1>
	This page lists all of the single-gene disruption simulations reported in the manuscript titled "<a class="coloredLink" href="http://simtk.org/frs/download.php?file_id=3122">A Whole-Cell Computational Model Predicts Phenotype from Genotype</a>". Please click on the "+" icons to view the individual simulations of each disruption strain, and then click on the links in the "Log" and "Download" columns to download summaries and the complete predicted dynamics of each <i>in silico</i> <i>M. genitalium</i> cell.
	<center>
	<img src="../images/singleGeneDeletionsSummaryGrid.png" style="padding-bottom:0px; margin-bottom:0px;margin-top:10px;"/>
	</center>
</div>

$plotsHTML

<div style="margin-top:20px;"></div>
<script type="text/javascript">
jQuery(document).ready(function(){
    jQuery("#jqgrid").jqGrid({
		url:'viewSingleGeneDeletions.php?data=grid',
		datatype:'json',
		height:'auto',
		autowidth:true,
		colNames:['Locus', 'Symbol', 'Name', 'Reactions', 'Ess.', '# Sim', 'Summary', 'Analysis'],
		colModel:[
			{name:'locus', index:'locus', width:75, 
				formatter : function(value, options, rData){
					return '<a href="../knowledgebase/index.php?WholeCellModelID='+value+'">'+value+'</a>';
				}
			},
			{name:'symbol', index:'symbol', width:75},
			{name:'name', index:'name', width:252},
			{name:'reactions', index:'reactions', width:178, sortable:false, hidden: $reactionsHidden},
			{name:'essential', index:'essential', width:30, hidden: $essentialHidden},
			{name:'nSimulations', index:'nSimulations', width:45, sorttype:"integer", align:"right"},
			{name:'summary', index:'summary', width:64, 
				formatter : function(value, options, rData){
					return value.replace('href=\'', 'href=\'$simulationResultsURL/singleGeneDeletions/');
				}
			},
			{name:'analysis', index:'analysis', width:64, hidden: $analysisHidden, 
				formatter : function(value, options, rData){
					return value.replace('href=\'', 'href=\'$simulationResultsURL/singleGeneDeletions/');
				}
			}
		],
		subGrid : true,
		subGridUrl: 'viewSingleGeneDeletions.php?data=subgrid',
		subGridModel: [$subGridModel], 
		viewrecords: true,
		rowNum:1000000,
		pager:'#jqnav',
		pgbuttons:false,
		pginput:false,
		rownumbers:false,
		viewrecords:false,
		multiselect:false
	});
	jQuery("#jqgrid").jqGrid('navGrid', "#jqnav", {edit:false, add:false, del:false, refresh:false, view:false});
})
</script>
<table id="jqgrid"></table>
<div id="jqnav"></div>
HTML;

// layout page
require('../pageTemplate.php');
$navigationContents = array(
	array('url' => 'index.php', 'text' => 'Simulation'), 
	array('url' => 'viewSingleGeneDeletions.php', 'text' => 'Single gene deletions simulations'));
echo composePage($content, $navigationContents, array(), 'simulation');

?>
