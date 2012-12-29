<?php

/* Edit/delete knowledge base objects
 *
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
require_once '../pageTemplate.php';
require_once 'src/include.php';

$error = true;
$warning = true;

//*********************
//start session
//*********************
session_start();

//*********************
//options
//*********************
foreach ($_POST as $key => $value){
	if (!is_array($value)){
		//$_POST[$key] = htmlspecialchars_decode($_POST[$key], ENT_COMPAT);
		$_POST[$key] = str_replace(array("\'", "\\\\", '\"'), array("'", "\\", '"'), $_POST[$key]);
	}
}
extract($_GET);
extract($_POST);

//format
if ($Format != 'Table') $Format = 'List';
if ($Mode != 'Ajax') $Mode = null;

//knowledge base
$knowledgeBase = new KnowledgeBase();
$KnowledgeBaseWID = $knowledgeBase->findWID($KnowledgeBaseWID, $KnowledgeBaseID);
if (false === $knowledgeBase->loadFromDatabase())
	$error = "Knowledge base does not exist.";
$KnowledgeBaseName = $knowledgeBase->name;

//object
if ($TableID != 'summary'){
	if($WID)
		$object = $knowledgeBase->constructObjectByID($WID, null);
	else 
		$object = new $knowledgeBase->schema[$TableID]['class'](0, $TableID, $knowledgeBase);
}else{
	$object = $knowledgeBase;
}

//*********************
//process commands
//*********************

//check user permissions
if ($error !== true){
}elseif (!isset($_SESSION['UserName'])){
	$error = 'Insufficient permissions.';
}else{
	switch ($Method){
		case 'BatchEdit':
			ini_set('max_execution_time', 30 * 60);
			$knowledgeBase->getMetaboliteEmpiricalFormulas();
			$knowledgeBase->configuration['knowledgeBaseRead'] = $_FILES['file']['tmp_name'];
			list($error, $warning) = $knowledgeBase->importXLS('html');
			if ($error === true)
				list($wid, $error) = $knowledgeBase->saveToDatabase('html', true, false);
			$reloadURL = sprintf("import.php?Format=%s&KnowledgeBaseWID=%d&TableID=%s", $Format, $knowledgeBase->wid, 'summary');
			break;
		case 'Edit':
			$object->loadFromArray($_POST);
			list($error, $warning) = $object->validate();
			if ($error === true)
				list($wid, $error) = $object->saveToDatabase();
			if ($Mode == 'Ajax')
				$reloadURL = sprintf('index.php?Format=%s&KnowledgeBaseWID=%d&TableID=%s#%d', $Format, $knowledgeBase->wid, $object->tableID, $object->wid);
			else
				$reloadURL = sprintf('index.php?Format=%s&KnowledgeBaseWID=%d&WID=%d', $Format, $knowledgeBase->wid, $object->wid);
			break;
		case 'Delete':
			$error = $object->deleteFromDatabase();
			$reloadURL = sprintf('index.php?Format=%s&KnowledgeBaseWID=%d&TableID=%s', $Format, $knowledgeBase->wid, $object->tableID);
			break;
		default:
			$error = 'Unknown request.';
			break;
	}
}

if (!$notPrintJSON){
	echo "{";
	echo "	\"status\":" . ($error === true ? ($warning === true ? "1" : "2") : "0").",";
	echo "	\"message\":\"" . str_replace("\"","\\\"",($error !== true ? $error : "").($warning !== true ? join(", ", $warning) : "")) . "\",";
	echo "	\"reloadURL\":\"$reloadURL\"";
	echo "}";
}
?>