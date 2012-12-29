<?php

/*
exportReferences.php
   Exports references as BibTex file

   Author: Jonathan Karr
   Affiliation: Covert Lab, Department of Bioengineering, Stanford University
   Last Updated: 6/1/2011
*/

//*********************
//include classes
//*********************
ini_set('error_reporting', E_ALL & ~E_NOTICE);
ini_set('display_errors', 1);

set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once 'src/include.php';

$knowledgeBase = new KnowledgeBase();

$knowledgeBase->selectWID();
$knowledgeBase->loadFromDatabase(array('references'));

$knowledgeBase->exportReferencesBibTex();

?>