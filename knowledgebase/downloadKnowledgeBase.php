<?php

/*
BioWarehouseToKnowledgeBase.php
   Writes knowledgeBase data stored in BioWarehouse database to excel file.

   Instructions for building knowledgeBase:
   I.   Load BioWarehouse data into excel file -- BioWarehouseToKnowledgeBase.php
   II.  Edit knowledgeBase file (excel)
   III. Save knowledgeBase file -- knowledgeBaseToBioWarehouse.php

   Repeat steps I-III as necessary.

   Author: Jonathan Karr
   Affiliation: Covert Lab, Department of Bioengineering, Stanford University
   Last Updated: 1/31/2011
*/

//*********************
//increase memory available to php
//*********************
ini_set('memory_limit', '1024M');

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once '../pageTemplate.php';
require_once 'src/include.php';

//*********************
//initialize session
//*********************
if (count($argv) >= 4){
	$userName = $argv[2];
	$password = $argv[3];
	require('configuration.php');

	session_start();	

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
}

//*********************
//download knowledge base
//*********************
$knowledgeBase = new KnowledgeBase();
if ($argv[1] == 'latest')
	$knowledgeBase->findWID('', '');
else
	$knowledgeBase->selectWID();
if (false === $knowledgeBase->loadFromDatabase(true)) exit;
$knowledgeBase->exportXLS(true);

?>