<?php

 /* Exports
  * - Knowledge base as Excel workbook or XML
  * - Files such as MATLAB code
  *
  * Requirements:
  * - PHPExcel
  *   http://phpexcel.codeplex.com/
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
require_once 'src/include.php';

//*********************
//initialize
//*********************
//set time limit
set_time_limit(10 * 60);

if ($_GET['TableID'] == 'summary') {
	ini_set('memory_limit', '2048M');
	set_time_limit(15 * 60);
}

//ini_set('display_errors', 1);

//*********************
//start session
//*********************
session_start();

//*********************
//options
//*********************
extract($_GET);

if(!is_dir('tmp')) 
	mkdir('tmp');

//--------------------------
//compose file, output
//--------------------------
switch($Format){
	case 'Excel':
		//knowledge base
		$knowledgeBase = new KnowledgeBase();
		$knowledgeBase->configuration['knowledgeBaseWrite'] = 'tmp/tmp.xlsx';
		$KnowledgeBaseWID = $knowledgeBase->findWID($KnowledgeBaseWID, $KnowledgeBaseID);
		$tableIDs = ($TableID == 'summary' ? true : array($TableID));
		if (false === $knowledgeBase->loadFromDatabase($tableIDs)) exit;

		$knowledgeBase->exportXLS($tableIDs);

		header("Content-type: application/xlsx");
		header("Content-Disposition: attachment; filename=\"" . $knowledgeBase->name . " Knowledge Base.xlsx\"");
		readfile('tmp/tmp.xlsx');
		break;
	case 'XML':
		//knowledge base
		$knowledgeBase = new KnowledgeBase();
		$knowledgeBase->configuration['knowledgeBaseWrite'] = 'tmp/tmp.xlsx';
		$KnowledgeBaseWID = $knowledgeBase->findWID($KnowledgeBaseWID, $KnowledgeBaseID);
		$tableIDs = ($TableID == 'summary' ? true : array($TableID));
		if (false === $knowledgeBase->loadFromDatabase($tableIDs)) exit;

		header("Content-type: text/xml");
		header("Content-Disposition: attachment; filename=\"" . $knowledgeBase->name . " Knowledge Base.xml\"");
		echo $knowledgeBase->exportXML($tableIDs);
		break;
	case 'File':
		$tmp = pathinfo($File);
		$FileName = $tmp['filename'];
		$Extension = $tmp['extension'];

		header("Content-type: application/$Extension");
		header("Content-Disposition: attachment; filename=\"$FileName.$Extension\"");
		readfile($File);
		break;
}

?>