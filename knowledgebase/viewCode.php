<?php

/* Prints highlighted code using GeSHi syntax highlight.
 *
 * References
 * 1. GeSHi - Generic Syntax Highlighter
 *	http://qbnz.com/highlighter/  
 *
 * Author: Jonathan Karr, jkarr@stanford.edu
 * Affiliation: Covert Lab, Department of Bioengineering, Stanford University
 * Last Updated: 3/23/2010
 */

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once '../pageTemplate.php';
require_once 'geshi.php';

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
//parse code
//*********************

//file name
$tmp = pathinfo($File);
$FileName = $tmp['filename'];

//parse file
$CFG->geshifilterexternalcss = false;
$geshi = new GeSHi(file_get_contents($File), $Language, 'lib/geshi');
$geshi->enable_classes(false);
$geshi->enable_line_numbers(GESHI_NORMAL_LINE_NUMBERS);
$geshi->set_overall_style('color:#666;');
$geshi->set_code_style('color:#000000;');
$geshi->set_line_style('color:#666;');
$content = "<div id=\"Code\"><div>" . $geshi->parse_code() . "</div></div>";

//*********************
//print page
//*********************
$navigationContent = array(
	array("url" => "viewCode.php?Language=$Language&File=" . urlencode($File), "text" => $FileName));

$sidebarContents = array(array("title" => "Controls", "style" => "icons", "content" => array(
	array("url" => "export.php?Format=File&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID&Language=$Language&File=" . urlencode($File),
			"title" => "Export",
			"icon" => "../images/icons/page.png",
			"text" => "Export"),
		array("onclick" => "window.print()",
			"title" => "Print",
			"icon" => "../images/icons/printer.png",
			"text" => "Print"))));
			
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