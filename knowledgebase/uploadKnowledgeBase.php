<?php

/*
knowledgeBaseFileToBioWarehouse.php
   Interactively allows user to add metabolites and reactions to database, make cross references between metabolites and reactions here and BioCyc metabolites and reactions.

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
//increase memory available to php
//*********************
ini_set('memory_limit', '4096M');

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once '../pageTemplate.php';
require_once 'src/include.php';

//database configuration
require('configuration.php');

//start session
session_start();

//get username, password
$userName = $argv[1];
$password = $argv[2];

if (!$userName){
	echo "Enter user name: ";
	$userName = rtrim(fgets(STDIN));
}

if (!$password){
	echo "Enter password: ";
	$password = rtrim(fgets(STDIN));
}

//decide whether or not to auto map metabolites and reactions
if ($argv[3])
	$autoMap = ($argv[3] == 'true');
else{
	$choice = '';
	while (false === array_search(strtoupper($choice), array('Y', 'N'))){
		echo "To automatically map metabolites type 'Y' or 'N. ";	
		$choice = rtrim(fgets(STDIN));
	}
	$autoMap = ('Y' == $choice);
}

//initialize session 
$link = databaseConnect($configuration);
$result = mysql_query(sprintf("CALL loginuser('%s', '%s')", $userName, $password)) or die(mysql_error());
if (mysql_num_rows($result) == 0){
	session_unset();
	echo "Invalid username and/or password.\n";
	exit;
}
$user = mysql_fetch_array($result);
mysql_close($link);

$_SESSION['UserName'] = $userName;
$_SESSION['UserID'] = $user['ID'];

//create dataset	
$knowledgeBase = new KnowledgeBase();
list($error, $warning) = $knowledgeBase->importXLS('commandLine', $autoMap);
if ($error !== true){
	echo $error;
	if ($argv[4] != 'false')
		echo $warning;
	exit;
}
if ($warning !== true && $argv[4] != 'false'){
	echo $warning;
}
list($wid, $error) = $knowledgeBase->saveToDatabase('commandLine', true, true);
if($error !== true)
  echo $error;
  
//end session
session_unset();

?>
