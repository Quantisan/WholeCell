<?php
/* Displays import file box
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

ini_set('memory_limit', '2048M');

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
//process uploaded data
//*********************
if ($_FILES['file']['tmp_name']){
	$notPrintJSON = true;
	require_once('editKnowledgeBase.php');
	
	$response = "<div class=\"response\">\n";
	
	if ($error !== true){
		$response .= "The following errors were found, and the uploaded file could not be imported.\n<ul>\n$error\n</ul>\n";
		$file = $_FILES['file']['name'];
	}else{
		$response .= "The uploaded file was successfully imported.\n";
	}
	
	if ($warning !== true){
		if ($error === true) $response .= "<br/>\n";
		$response .= "<br/>\nThe following warnings were found.\n<ul>\n$warning\n</ul>\n";
	}
	
	$response .= "</div>\n";
}

//*********************
//content
//*********************
$content = <<<HTML
<div id="ImportBox">
	<div>
		<form action="import.php" method="POST" enctype="multipart/form-data">
		<input type="hidden" name="Format" value="$Format"/>
		<input type="hidden" name="Method" value="BatchEdit"/>
		<input type="hidden" name="KnowledgeBaseWID" value="$KnowledgeBaseWID"/>		
		<input type="hidden" name="TableID" value="summary"/>
			<table cellpadding="0" cellspacing="0">
				<tbody>
					<tr>
						<th>File</th>
						<td><input type="file" class="file" name="file" size="95" value="$file"/></td>
						<td><img src="../images/icons/help.png" title="Select file to import."/></td>
					</tr>
				</tbody>
				<tfoot>
					<tr>
						<td>&nbsp;</td>
						<td colspan="2">
							<input type="submit" class="button" value="Import" style="width:70px;">
							<input type="reset" class="button" value="Clear" style="width:70px;">
						</td>
					</tr>
				</tfoot>
			</table>
		</form>
	</div>
	$response
</div>
HTML;

//*********************
//print page
//*********************
$navigationContents = array(
	array("url" => "index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID", "text" => "$KnowledgeBaseName", "fontStyle" => "italic"),
	array("url" => "import.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID", "text" => "Import"));
	
$sidebarContents = $knowledgeBase->sidebar($Format);
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

echo composePage($content, $navigationContents, $sidebarContents, 'knowledgebase');

?>
