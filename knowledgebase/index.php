<?php

/*
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

 //*********************
//display errors
//*********************
ini_set('display_errors', 1);

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once '../pageTemplate.old.php';
require_once 'src/include.php';

//*********************
//start session
//*********************
session_start();

//*********************
//options
//*********************
extract($_GET);
extract($_POST);

//format
if ($Format != 'Table') $Format = 'List';
if ($Mode != 'Ajax') $Mode = null;

//knowledge base
$knowledgeBase = new KnowledgeBase();
$KnowledgeBaseWID = $knowledgeBase->findWID($KnowledgeBaseWID, $KnowledgeBaseID);
if (false === $knowledgeBase->loadFromDatabase()) exit;
$KnowledgeBaseName = $knowledgeBase->name;

if ($WID || $WholeCellModelID)
	$object = $knowledgeBase->constructObjectByID($WID, $WholeCellModelID);
elseif ($Method == 'Edit' && $TableID)
	$object = new $knowledgeBase->schema[$TableID]['class'](0, $TableID, $knowledgeBase);

//*********************
//process commands
//*********************
if ($object){
	switch ($Method){
		case 'Edit':
			$content = $object->editPane($Format, $Mode, $Method);
			break;
		case 'Delete':
			$content = $object->deletePane($Format, $Mode, $Method);
			break;
		default:
			$content = $object->viewPane($Format);
			break;
	}
	$navigationContents = $object->navigation($Format);
	$sidebarContents = $object->sidebar($Format);
}elseif ($Keywords){
	$knowledgeBase->loadObjectsByKeywordSearch($Keywords);
	$content = $knowledgeBase->objectsPane($Format);
	if (!$content)
		$content = "<div id=\"Search\" class=\"List\"><div>No entries were found matching the term '$Keywords'.</div></div>";

	$navigationContents = array(array("url" => "search.php?Format=$Format&KnowledgeBaseWID=" . $knowledgeBase->wid, "text" => "Search", "text" => "Search"));

	$sidebarContents = array();
	$sidebarContents[0]["title"] = "Search controls";
	$sidebarContents[0]["style"] = "icons";
	$sidebarContents[0]["content"] = array();
	if ($Format == 'Table')
		array_push($sidebarContents[0]["content"], array(
			"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&Keywords=%s", 'List', $knowledgeBase->wid, $Keywords),
			"title" => "List View",
			"text" => "List View",
			"icon" => "../images/icons/text_list_bullets.png"));
	else
		array_push($sidebarContents[0]["content"], array(
			"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&Keywords=%s", 'Table', $knowledgeBase->wid, $Keywords),
			"title" => "Table View",
			"text" => "Table View",
			"icon" => "../images/icons/table.png"));
	array_push($sidebarContents[0]["content"], array(
		"onclick" => "window.print()",
		"title" => "Print",
		"text" => "Print",
		"icon" => "../images/icons/printer.png"));
}elseif ($Page){
	$navigationContents = $knowledgeBase->navigation($Format);
	switch ($Page){
		case 'ErrorsWarnings':
			ini_set('max_execution_time', 5 * 60);
			$content = $knowledgeBase->errorsWarningsPane($Format);
			array_push($navigationContents, array("url" => "index.php?Format=$Format&KnowledgeBaseWID=" . $knowledgeBase->wid . "&Page=$Page", "text" => "Errors/Warnings"));
			break;
		case 'RecentChanges':
			$content = $knowledgeBase->recentChangesPane($Format);
			array_push($navigationContents, array("url" => "index.php?Format=$Format&KnowledgeBaseWID=" . $knowledgeBase->wid . "&Page=$Page", "text" => "Recent Changes"));
			break;
	}
	$sidebarContents = array();
	$sidebarContents[0]["title"] = "Controls";
	$sidebarContents[0]["style"] = "icons";
	$sidebarContents[0]["content"] = array();
	if ($Format == 'Table')
		array_push($sidebarContents[0]["content"], array(
			"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&Page=%s", 'List', $knowledgeBase->wid, $Page),
			"title" => "List View",
			"text" => "List View",
			"icon" => "../images/icons/text_list_bullets.png"));
	else
		array_push($sidebarContents[0]["content"], array(
			"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&Page=%s", 'Table', $knowledgeBase->wid, $Page),
			"title" => "Table View",
			"text" => "Table View",
			"icon" => "../images/icons/table.png"));
	array_push($sidebarContents[0]["content"], array(
		"onclick" => "window.print()",
		"title" => "Print",
		"text" => "Print",
		"icon" => "../images/icons/printer.png"));
}elseif ($TableID && $TableID != 'summary'){
	$knowledgeBase->loadObjectsByClass($TableID);
	$content = $knowledgeBase->objectsPaneByClass($Format,$TableID);
	$navigationContents = $knowledgeBase->navigation($Format, $TableID);
	$sidebarContents = $knowledgeBase->sidebar($Format, $TableID);
}else{
	switch ($Method){
		case 'Edit':
			$content = $knowledgeBase->editPane($Format, $Mode, $Method);
			break;
		default:
			$content = $knowledgeBase->viewPane("List");
			break;
	}
	$navigationContents = $knowledgeBase->navigation($Format);
	$sidebarContents = $knowledgeBase->sidebar($Format);
}

if (!is_array($sidebarContents)) $sidebarContents = array();
array_splice($sidebarContents, 0, 0, array(array("title" => "<i>$KnowledgeBaseName</i>", "content" => array())));
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
//print page
//*********************
if ($Mode == 'Ajax')
	echo $content;
else
	echo composePage($content, $navigationContents, $sidebarContents, 'knowledgebase');

?>
