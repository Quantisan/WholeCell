<?php

//display errors
ini_set('display_errors', 1);

//load methods
require('config.php');
require_once('library.php');

//configuration
$id = $_GET['id'];
$simGroupDate = join("-", array_slice(explode('_', $id), 0, 3)).' '.join(":", array_slice(explode('_', $id), 3, 3));

$tmp = json_decode(getSimulationBatches($baseDir, $simulationMetaDataCache));
$tmp = $tmp->$id;
$data = json_encode($tmp->data);
$conditionSet = objectToArray($tmp->conditionSet);
$pbsid = $tmp->pbsid;

//content
if ($pageOptions['viewSimulationSet']['enableRefresh']) 
	$metaData = '<meta http-equiv="refresh" content="60">';

//files
$files = array(
	'Summary'=>array(
		array('name'=>'Summary', 'paths'=>array(array('path'=>'summary.pdf', 'type'=>'pdf'))),
		array('name'=>'Summary', 'paths'=>array(array('path'=>'summary.html', 'type'=>'html'))),
		array('name'=>'Initial and final states', 'paths'=>array(array('path'=>'initialAndFinalStates.html', 'type'=>'html'))),
		array('name'=>'Error summary', 'paths'=>array(array('path'=>'errors.html', 'type'=>'html')))),
	'Single Cell Dynamics'=>array(
		array('name'=>'Growth', 'paths'=>array(array('path'=>'singleCell-Growth.pdf', 'type'=>'pdf'))),
		array('name'=>'Mass', 'paths'=>array(array('path'=>'singleCell-Mass.pdf', 'type'=>'pdf'), array('path'=>'singleCell-MassNormalized.pdf', 'type'=>'pdf'))),
		array('name'=>'Metabolites', 'paths'=>array(array('path'=>'singleCell-Metabolites.pdf', 'type'=>'pdf'), array('path'=>'singleCell-MetabolitesNormalized.pdf', 'type'=>'pdf'))),
		array('name'=>'Ribosomes', 'paths'=>array(array('path'=>'singleCell-Ribosomes.pdf', 'type'=>'pdf'), array('path'=>'singleCell-RibosomesGenomicCoordinates.pdf', 'type'=>'pdf'))),
		array('name'=>'Translation', 'paths'=>array(array('path'=>'TranslationAnalysis-MonomerSynthesis.pdf', 'type'=>'pdf'))),
		array('name'=>'Translation Pauses', 'paths'=>array(array('path'=>'TranslationAnalysis-Pauses.pdf', 'type'=>'pdf'))),
		array('name'=>'Translation Pause Distribution', 'paths'=>array(array('path'=>'TranslationAnalysis-PauseDistribution.pdf', 'type'=>'pdf'))),
		array('name'=>'Chromosome Space-Time Overlay', 'paths'=>array(array('path'=>'ChromosomeSpaceTimePlot-SpaceTimeOverlay.pdf', 'type'=>'pdf'))),
		array('name'=>'Chromosome Space-Time Ring', 'paths'=>array(array('path'=>'ChromosomeSpaceTimePlot-Ring.pdf', 'type'=>'pdf'))),
		array('name'=>'Chromosome Position Histogram', 'paths'=>array(array('path'=>'ChromosomePositionHistogram-1.pdf', 'type'=>'pdf'), array('path'=>'ChromosomePositionHistogram-2.pdf', 'type'=>'pdf')))),
	'Population Dynamics'=>array(
		array('name'=>'Growth', 'paths'=>array(array('path'=>'population-Growth.pdf', 'type'=>'pdf'))),
		array('name'=>'Energy Production', 'paths'=>array(array('path'=>'population-EnergyProduction.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Mass Distribution', 'paths'=>array(array('path'=>'population-MassDistribution.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Shape', 'paths'=>array(array('path'=>'population-CellShape.pdf', 'type'=>'pdf'))),
		array('name'=>'Metabolism', 'paths'=>array(array('path'=>'population-Metabolism.pdf', 'type'=>'pdf'), array('path'=>'population-Metabolism.xls', 'type'=>'xls'))),
		array('name'=>'Nucleotide Distribution', 'paths'=>array(array('path'=>'population-NucleotideDistribution.pdf', 'type'=>'pdf'), array('path'=>'population-NucleotideDistribution.xls', 'type'=>'xls'))),
		array('name'=>'Amino Acid Counts', 'paths'=>array(array('path'=>'population-AminoAcidCounts.pdf', 'type'=>'pdf'))),
		array('name'=>'RNA Maturation', 'paths'=>array(array('path'=>'population-RnaSynthesis.pdf', 'type'=>'pdf'))),
		array('name'=>'RNA Synthesis Duration', 'paths'=>array(array('path'=>'population-RnaSynthesisDuration.pdf', 'type'=>'pdf'))),
		array('name'=>'Translation', 'paths'=>array(array('path'=>'population-Translation.pdf', 'type'=>'pdf'))),
		array('name'=>'Protein Maturation', 'paths'=>array(array('path'=>'population-ProteinSynthesis.pdf', 'type'=>'pdf'))),
		array('name'=>'Protein Synthesis Duration', 'paths'=>array(array('path'=>'population-ProteinSynthesisDuration.pdf', 'type'=>'pdf'))),
		array('name'=>'Macromolecular Complexes', 'paths'=>array(array('path'=>'population-MacromolecularComplexes.pdf', 'type'=>'pdf'))),
		array('name'=>'RNA Polymerases', 'paths'=>array(array('path'=>'population-RnaPolymerases.pdf', 'type'=>'pdf'))),
		array('name'=>'Ribosomes', 'paths'=>array(array('path'=>'population-Ribosomes.pdf', 'type'=>'pdf'))),
		array('name'=>'Gene Copy Number', 'paths'=>array(array('path'=>'population-GeneCopyNumber.pdf', 'type'=>'pdf'))),
		array('name'=>'SSBs', 'paths'=>array(array('path'=>'population-SSBs.pdf', 'type'=>'pdf'))),
		array('name'=>'DNA Repair', 'paths'=>array(array('path'=>'population-DnaRepair.pdf', 'type'=>'pdf'))),
		array('name'=>'Immune Activation', 'paths'=>array(array('path'=>'population-ImmuneActivation.pdf', 'type'=>'pdf'))),
		array('name'=>'SMC Spacing', 'paths'=>array(array('path'=>'population-SmcSpacing.pdf', 'type'=>'pdf'))),
		array('name'=>'Unsynchronized Population', 'paths'=>array(array('path'=>'population-UnsynchronizedPopulation.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Growth', 'paths'=>array(array('path'=>'summary-CellOverview-Lines1.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Energy', 'paths'=>array(array('path'=>'summary-CellOverview-Lines4.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - RNA Maturation', 'paths'=>array(array('path'=>'summary-CellOverview-Lines5.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Protein Maturation', 'paths'=>array(array('path'=>'summary-CellOverview-Lines6.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Supercoiling', 'paths'=>array(array('path'=>'summary-CellOverview-Lines8.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Replication Initiation', 'paths'=>array(array('path'=>'summary-CellOverview-Lines2.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Replication', 'paths'=>array(array('path'=>'summary-CellOverview-Lines3.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Cytokinesis', 'paths'=>array(array('path'=>'summary-CellOverview-Lines7.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Overview - Run time', 'paths'=>array(array('path'=>'summary-CellOverview-Lines9.pdf', 'type'=>'pdf'))),
		array('name'=>'Process ATP Requirements', 'paths'=>array(array('path'=>'processMetaboliteUsage-ATP-Requirements.pdf', 'type'=>'pdf'))),
		array('name'=>'Process ATP Allocations', 'paths'=>array(array('path'=>'processMetaboliteUsage-ATP-Allocations.pdf', 'type'=>'pdf'))),
		array('name'=>'Process ATP Usages', 'paths'=>array(array('path'=>'processMetaboliteUsage-ATP-Usages.pdf', 'type'=>'pdf'))),
		array('name'=>'Process GTP Requirements', 'paths'=>array(array('path'=>'processMetaboliteUsage-GTP-Requirements.pdf', 'type'=>'pdf'))),
		array('name'=>'Process GTP Allocations', 'paths'=>array(array('path'=>'processMetaboliteUsage-GTP-Allocations.pdf', 'type'=>'pdf'))),
		array('name'=>'Process GTP Usages', 'paths'=>array(array('path'=>'processMetaboliteUsage-GTP-Usages.pdf', 'type'=>'pdf')))),
	'Population Statistics' => array(
		array('name'=>'Metabolite Concentrations', 'paths'=>array(array('path'=>'population-MetaboliteConcentrations.pdf', 'type'=>'pdf'))),
		array('name'=>'DNA Bound Protein Displacement', 'paths'=>array(array('path'=>'population-DnaBoundProteinDisplacement.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Cycle Phase Distribution', 'paths'=>array(array('path'=>'population-CellCyclePhases.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Cycle Phase Durations', 'paths'=>array(array('path'=>'cellCyclePhaseDurations.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Cycle Phase Lengths', 'paths'=>array(array('path'=>'cellCyclePhaseLengths.pdf', 'type'=>'pdf'))),
		array('name'=>'Cumulative Growth Vs. Cell Cycle Phase Durations', 'paths'=>array(array('path'=>'cumulativeGrowthVsCellCyclePhaseDurations.pdf', 'type'=>'pdf'))),
		array('name'=>'Cumulative Growth Vs. Cell Cycle Phase Times', 'paths'=>array(array('path'=>'cumulativeGrowthVsCellCyclePhaseTimes.pdf', 'type'=>'pdf'))),
		array('name'=>'Initial Growth Vs. Cell Cycle Phase Durations', 'paths'=>array(array('path'=>'initialGrowthVsCellCyclePhaseDurations.pdf', 'type'=>'pdf'))),
		array('name'=>'Initial Growth Vs. Cell Cycle Phase Times', 'paths'=>array(array('path'=>'initialGrowthVsCellCyclePhaseTimes.pdf', 'type'=>'pdf'))),
		array('name'=>'Initial Vs. Cumulative Growth', 'paths'=>array(array('path'=>'initialVsCumulativeGrowth.pdf', 'type'=>'pdf'))),
		array('name'=>'Initial Growth Rate Vs. End Time', 'paths'=>array(array('path'=>'summary-CellOverview-InitialGrowthRateVsEndTimes.pdf', 'type'=>'pdf'))),
		array('name'=>'Final Growth Rate Vs. End Time', 'paths'=>array(array('path'=>'summary-CellOverview-FinalGrowthRateVsEndTimes.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell Mass Distribution', 'paths'=>array(array('path'=>'population-CellMassDistribution.pdf', 'type'=>'pdf'))),
		array('name'=>'Biomass Composition Production', 'paths'=>array(array('path'=>'BiomassCompositionProduction.xls', 'type'=>'xls'))),
		array('name'=>'Biomass Composition', 'paths'=>array(array('path'=>'BiomassCompositionProduction.pdf', 'type'=>'pdf'))),
		array('name'=>'Biomass Composition - Weight Fractions', 'paths'=>array(array('path'=>'BiomassCompositionProduction-WeightFractions.pdf', 'type'=>'pdf'))),
		array('name'=>'Biomass Composition - dNMP Composition', 'paths'=>array(array('path'=>'BiomassCompositionProduction-dNMPComposition.pdf', 'type'=>'pdf'))),
		array('name'=>'Biomass Composition - NMP Composition', 'paths'=>array(array('path'=>'BiomassCompositionProduction-NMPComposition.pdf', 'type'=>'pdf'))),
		array('name'=>'Biomass Composition - AA Composition', 'paths'=>array(array('path'=>'BiomassCompositionProduction-AAComposition.pdf', 'type'=>'pdf'))),
		array('name'=>'Cell State', 'paths'=>array(array('path'=>'CellState.xls', 'type'=>'xls'), array('path'=>'CellState-OnChromosome.pdf', 'type'=>'pdf'))),
		array('name'=>'Constants', 'paths'=>array(array('path'=>'Constants.xls', 'type'=>'xls'))),
		array('name'=>'Experimental Vs Calculated Gene Expression', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_Gene_Expression.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated Monomer Expression', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_Monomer_Expression.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated tRNA Expression', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_TRNA_Expression.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated NMP Composition', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_NMP_Composition.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated AA Composition', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_AA_Composition.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated RNA Weight Fractions', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_RNA_Weight_Fractions.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated Gene Decay Rates', 'paths'=>array(array('path'=>'Constants-Experimental_Vs_Calculated_Gene_Decay_Rates.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated Gene Expression Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_Gene_Expression_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated Monomer Expression Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_Monomer_Expression_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated tRNA Expression Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_TRNA_Expression_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated NMP Composition Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_NMP_Composition_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated AA Composition Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_AA_Composition_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated RNA Weight Fraction Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_RNA_Weight_Fraction_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Experimental Vs Calculated Gene Decay Rate Ratios', 'paths'=>array(array('path'=>'Constants-Experimental_Calculated_Gene_Decay_Rate_Ratios.pdf', 'type'=>'pdf'))),
		array('name'=>'Macromolecule Expression', 'paths'=>array(array('path'=>'population-MacromoleculeExpression.pdf', 'type'=>'pdf'))),
		array('name'=>'Blocked Decay Events', 'paths'=>array(array('path'=>'population-BlockedDecayEvents.pdf', 'type'=>'pdf'))),
		array('name'=>'Replication', 'paths'=>array(array('path'=>'population-Replication.pdf', 'type'=>'pdf'))),
		array('name'=>'Secondary Replication Initiation', 'paths'=>array(array('path'=>'population-SecondaryReplicationInitiation.pdf', 'type'=>'pdf'))),
		array('name'=>'Process ATP Usages (Expected)', 'paths'=>array(array('path'=>'processMetaboliteUsage-Expected-ATP-Usages.pdf', 'type'=>'pdf'))),
		array('name'=>'Process GTP Usages (Expected)', 'paths'=>array(array('path'=>'processMetaboliteUsage-Expected-GTP-Usages.pdf', 'type'=>'pdf'))),
		array('name'=>'DNA Damage', 'paths'=>array(array('path'=>'DNADamage.xls', 'type'=>'xls'))),
		array('name'=>'FBA', 'paths'=>array(array('path'=>'FBA.xls', 'type'=>'xls'), array('path'=>'FBA-NetworkReduction.pdf', 'type'=>'pdf'))),
		array('name'=>'Simulation Structure', 'paths'=>array(array('path'=>'SimulationStructure.xls', 'type'=>'xls'))),
		array('name'=>'Simulation Structure - Process Metabolite Sharing', 'paths'=>array(array('path'=>'SimulationStructure-ProcessMetaboliteSharing.pdf', 'type'=>'pdf'))),
		array('name'=>'Simulation Structure - Process Metabolites', 'paths'=>array(array('path'=>'SimulationStructure-ProcessMetabolites.pdf', 'type'=>'pdf'))),
		array('name'=>'Simulation Structure - Process Shared Metabolites', 'paths'=>array(array('path'=>'SimulationStructure-ProcessSharedMetabolites.pdf', 'type'=>'pdf'))),
		array('name'=>'Simulation Structure - Process Gene Products', 'paths'=>array(array('path'=>'SimulationStructure-ProcessGeneProducts.pdf', 'type'=>'pdf'))),
		array('name'=>'Warnings', 'paths'=>array(array('path'=>'population-Warnings.pdf', 'type'=>'pdf'), array('path'=>'population-Warnings.xls', 'type'=>'xls'))))
	);

if ($pageOptions['viewSimulationSet']['displaySummary']){
	$filesHTML = "";
	foreach ($files as $category => $categoryFiles) {
		$filesHTML .= "<li>$category<ul style=\"margin-top:0px;\">\n";
		foreach ($categoryFiles as $file){
			extract($file);
			$links = "";
			$fileExists = false;
			foreach ($paths as $path){
				if (file_exists("$baseDir/$id/".$path['path'])){
					$fileExists = true;
					$links .= "<a class=\"coloredLink\" href=\"$simulationResultsURL/$id/".$path['path']."\">".$path['type']."</a> | ";
				}else{
					$links .= "<span class=\"disabled\">".$path['type']."</span> | ";
				}
			}
			$links = substr($links, 0, -3);
			$filesHTML .= "<li class=\"".($fileExists ? "en" : "dis")."abled\">$name ($links)</li>\n";
		}
		$filesHTML.="</ul></li>\n";
	}

	$summaryHTML = <<<HTML
<div id="Object" class="List" style="margin-top:20px">
<h1>Summary</h1>
<ul style="margin-top:0px;">
$filesHTML
</ul>
</div>
HTML;
}

$webSVNURLRevision = sprintf($webSVNURL, $revision);
extract($conditionSet);
$metadataHTML = '';
$metadataHTML.=	"\t<tr><th>ID</th><td>$id</td></tr>\n";
if ($pageOptions['viewSimulationSet']['displayPBSID']) 
	$metadataHTML.=	"\t<tr><th>PBS ID</th><td>$pbsid</td></tr>\n";
if ($pageOptions['viewSimulationSet']['displayEmail']) 
	$metadataHTML.=	"\t<tr><th>Researcher</th><td>$firstName $lastName, <a class=\"coloredLink\" href=\"mailto:$email\">$email</a></td></tr>\n";
else
	$metadataHTML.=	"\t<tr><th>Researcher</th><td>$firstName $lastName</td></tr>\n";
$metadataHTML.=	"\t<tr><th>Affiliation</th><td>$affiliation</td></tr>\n";
if ($pageOptions['viewSimulationSet']['displayHostName']) 
	$metadataHTML.=	"\t<tr><th>Host name</th><td>$hostName, $ipAddress</td></tr>\n";
if ($pageOptions['viewSimulationSet']['displayRevision']) {
	$metadataHTML.=	"\t<tr><th>Revision</th><td><a class=\"coloredLink\" href=\"$webSVNURLRevision\">$revision</a></td></tr>\n";
	$metadataHTML.=	"\t<tr><th>Differences</th><td><pre>$differencesFromRevision</pre></td></tr>\n";
}

$statusSummaryHidden = ($pageOptions['viewSimulationSet']['displayStatusSummary'] ? 'false' : 'true');
$runTimeHidden = ($pageOptions['viewSimulationSet']['displayRunTime'] ? 'false' : 'true');
$downloadHidden = ($pageOptions['viewSimulationSet']['displayDownload'] ? 'false' : 'true');
$errorLogHidden = ($pageOptions['viewSimulationSet']['displayErrorLog'] ? 'false' : 'true');
$queueHidden = ($pageOptions['viewSimulationSet']['displayQueue'] ? 'false' : 'true');

$conditionsHTML = formatConditions($conditionSet['conditions']);

$content = <<<HTML
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/smoothness/jquery-ui-1.8.14.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/jqGrid-4.1.2/css/ui.jqgrid.css" />
<link rel="stylesheet" type="text/css" media="screen" charset="utf-8" href="../lib/pixelmatrix-uniform-2446d99/css/uniform.default.css" />
<style type="text/css">
th {
	font-weight:bold;
	text-align:left;
}
th, td {
	padding-left:10px;
	vertical-align:top;
}
th:first-child, td:first-child{
	padding-left:0px;
}
.disabled{
	color:grey;
}
</style>
<script src="../lib/jqGrid-4.1.2/js/jquery-1.5.2.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery-ui.custom.min.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="../lib/jqGrid-4.1.2/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<div id="Object" class="List">
<h1>Simulation Set $simGroupDate</h1>
Please use the links in the "Log" and "Download" columns in the table below to download summaries and the complete predicted dynamics of each <i>in silico</i> <i>M. genitalium</i> cell.
</div>


<div id="Object" class="List" style="margin-top:20px">
<h1>Metadata</h1>
<table cellspacing="0" cellpadding="0" style="border-top:none; border-bottom:none;">
	$metadataHTML
</table>
</div>

<div id="Object" class="List" style="margin-top:20px">
<h1>Conditions</h1>
<table style="border-top:none; border-bottom:none;">
$conditionsHTML
</table>
</div>

$summaryHTML

<div style="margin-top:20px"></div>
<script type="text/javascript">
jQuery(document).ready(function(){
    jQuery("#individualSimulationsGrid").jqGrid({
		datatype:"local",
		height:'auto',
		autowidth:true,
		colNames:['Timestamp', '#', 'Condition set', 'Summary', 'Details', 'Time', 'Mass', 'Growth', 'Run time', 'Log', 'Download', 'Error', 'Queue'],
		colModel:[
			{name:'timestamp', index:'timestamp', sorttype:"integer", hidden:true, align:"right", width:30, sortable:true},
			{name:'idx', index:'idx', sorttype:"integer", hidden:false, align:"right", width:30, sortable:true},
			{name:'conditionSet', index:'conditionSet', sorttype:"integer", align:"right", width:80, sortable:true},
			{name:'status', index:'status', width:105, sortable:true, hidden: $statusSummaryHidden},
			{name:'statusDetails', index:'statusDetails', width:105, sortable:true, hidden: $statusSummaryHidden},
			{name:'time', index:'time', width:60, sortable:true, align:"center"},
			{name:'mass', index:'mass', width:60, sortable:true, sorttype:'float', formatter:'number', formatoptions:{decimalPlaces:2}, align:"right"},
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
	array('url' => "viewSimulationSet.php?id=$id", 'text' => "Simulation Set ".($pageOptions['viewSimulationSet']['displayPBSID'] ? "#$pbsid " : "")."$simGroupDate"));
echo composePage($content, $navigationContents, array(), 'simulation');
?>
