<?php
/* Displays search box
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once '../pageTemplate.php';

require_once 'src/KnowledgeBaseObject.php';
require_once 'src/KnowledgeBase.php';

//*********************
//session
//*********************
session_start();

//*********************
//options
//*********************
extract($_GET);
$knowledgeBase = new KnowledgeBase();
$KnowledgeBaseWID = $knowledgeBase->findWID($KnowledgeBaseWID, $KnowledgeBaseID);
$knowledgeBase->loadFromDatabase();
$KnowledgeBaseName = $knowledgeBase->name;

//*********************
//navigation
//*********************
if (!$Format) $Format = 'List';
$navigationContents = $knowledgeBase->navigation($Format);
array_push($navigationContents, array(
	'url' => 'search.php',
	'text' => 'Search'));

$sidebarContents = $knowledgeBase->sidebar($Format);
$sidebarContents[0]['title'] = 'Search controls';
array_unshift($sidebarContents, array('title'=>'Search controls', 'content'=>array()));
$sidebarContents[0]['title'] = '<i>Mycoplasma genitalium</i>';
$tableOrder = array(
	'summary',
	'simulations',	
	'processes', 
	'states',
	'genes', 
	'transcriptionUnits', 
	'transcriptionalRegulations', 
	'genomeFeatures', 
	'proteinMonomers', 
	'proteinComplexs', 
	'proteinActivations',
	'reactions', 
	'pathways', 
	'metabolites', 
	'mediaComponents', 
	'biomassCompositions', 
	'stimuli', 
	'stimuliValues', 	
	'parameters',
	'compartments', 	
	'metabolicMapMetabolites',
	'metabolicMapReactions', 
	'notes', 
	'references'); 
foreach ($tableOrder as $tableID){
	$table = $knowledgeBase->schema[$tableID];
	if ($table['displayLevel'] > 0) continue;
	array_push($sidebarContents[0]["content"], array(
		"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&TableID=%s", $Format, $knowledgeBase->wid, $tableID),
		"text" => $table['names'],
		"symbol" => ($table['usedInSimulation'] ? "<span class=\"symbol sup\" title=\"Table used in simulation\">" . KnowledgeBaseObject::symbol_property_usedInSimulation . "</span>" : "")));
}

//*********************
//content
//*********************
$content = <<<HTML
<div id="SearchBox">
	<div>
		<form action="index.php" method="GET">
		<input type="hidden" name="Format" value="$Format"/>
		<input type="hidden" name="KnowledgeBaseWID" value="$KnowledgeBaseWID"/>
			<table cellpadding="0" cellspacing="0">
				<tbody>
					<tr>
						<th>Keywords</th>
						<td><input type="text" class="text" name="Keywords"/></td>
						<td><img src="../images/icons/help.png" title="Keywords will be search against object IDs, names, and other text fields."/></td>
					</tr>
				</tbody>
				<tfoot>
					<tr>
						<td>&nbsp;</td>
						<td colspan="2">
							<input type="submit" class="button" value="Search" style="width:70px;">
							<input type="reset" class="button" value="Clear" style="width:70px;">
						</td>
					</tr>
				</tfoot>
			</table>
		</form>
	</div>
</div>
HTML;

//*********************
//print page
//*********************
echo composePage($content, $navigationContents, $sidebarContents, 'knowledgebase');

?>
