<?php

/*
exportMetabolicMap.php
   Converts knowledgeBase to svg representation of metabolism.

   Instructions for building metabolic knowledgeBase and map:
   I.   1) Add reactions and metabolites and coordinates to knowledgeBase file (excel)
   II.  1) Convert to svg -- knowledgeBaseToMetabolicMap.php
		2) Open svg file in InkScape
		3) Use InkScape to reposition metabolites and reactions, and to draw more complex paths for reactions
		4) Convert svg file to knowledgeBase file (excel) -- metabolicMapToKnowledgeBase.php
   III. 1) Update metabolic knowledgeBase to database -- knowledgeBaseToBioWarehouse.php

   Instructions for obtaining metabolic knowledgeBase and map from database
   I.   BioWarehouseToKnowledgeBase.php -- builds knowledgeBase file from database

   Author: Jonathan Karr
   Affiliation: Covert Lab, Department of Bioengineering, Stanford University
   Last Updated: 8/15/2008
*/

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once 'src/include.php';

$knowledgeBase = new KnowledgeBase();

$knowledgeBase->selectWID();
$knowledgeBase->loadFromDatabase(array('metabolicMapMetabolites', 'metabolicMapReactions'));

/*
list($error, $warning) = $knowledgeBase->importXLS('commandLine');
if ($error !== true){
	echo $error; 
	echo $warning;
	exit;
}
if ($warning !== true){
	echo $warning;
}
*/

$knowledgeBase->exportMetabolicMapSVG();

?>