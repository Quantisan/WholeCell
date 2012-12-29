<?php

/*
exportSimulation.php
   Writes simulation data stored in BioWarehouse database to xml file.

   Author: Jonathan Karr
   Affiliation: Covert Lab, Department of Bioengineering, Stanford University
   Last Updated: 8/15/2008
*/

//load code
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once('library.php');

//load configuration
$options = getConfiguration($argv);

//load schema
$tables = readSchemaXML($options['schemaFile']);

$KnowledgeBaseWID = selectKnowledgeBase($options);
$SimulationWID = selectSimulation($KnowledgeBaseWID, $options);

echo "Please enter the desired file: ";
$fileName = getInput();  

exportSimulation($SimulationWID, $fileName, $options);

?>