<?php
/**
 * Description of KnowledgeBase
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

require_once 'PHPExcel.php';
require_once 'PHPExcel/IOFactory.php';
require_once 'PHPExcel/Writer/Excel2007.php';

class KnowledgeBase extends KnowledgeBaseObject {
	public $configuration;
	public $schema;

	public $version;
	public $investigator;
	public $url;
	public $application;
	public $applicationVersion;
	public $taxonomy;
	public $translationTable;
	public $genomeLength;

	public $processes = array();
	public $states = array();
	public $parameters = array();
	public $compartments = array();
	public $pathways = array();
	public $stimuli = array();
	public $metabolites = array();
	public $genes = array();
	public $transcriptionUnits = array();
	public $genomeFeatures = array();
	public $proteinMonomers = array();
	public $proteinComplexs = array();
	public $reactions = array();
	public $references = array();
	public $notes = array();

	public $biomassCompositions = array();
	public $mediaComponents = array();
	public $proteinActivations = array();
	public $stimuliValues = array();
	public $transcriptionalRegulations = array();

	public $metabolicMapMetabolites = array();
	public $metabolicMapReactions = array();

	public $simulations = array();

	public $wholeCellModelIDs = array();
	public $referenceWholeCellModelIDs = array();
	public $metaboliteEmpiricalFormulas = array();
	public $monomerComplexs = array();
	public $moleculeCompartments = array();

	function  __construct() {
		require('configuration.php');	
		
		if (!array_key_exists('enableLogin', $configuration))
			$configuration['enableLogin'] = 1;
		if (!array_key_exists('enableExport', $configuration))
			$configuration['enableExport'] = 1;
		
		$this->configuration = array(
			'knowledgeBaseRead' => 'data/knowledgebase.xlsx',
			'knowledgeBaseWrite' => 'data/knowledgebase.xlsx',
			'knowledgeBaseExport' => 'data/knowledgebase.xml',
			'genomeSequence' => 'data/knowledgebase.fna',
			'proteomeSequence' => 'data/knowledgebase.faa',
			'metabolicMap' => 'data/metabolicMap',
			'genomeBrowser' => array(
				"genes" => 'data/genomeBrowser-genes',
				"transcriptionUnits" => 'data/genomeBrowser-transcriptionUnits'),
			'bibtex'  =>  'data/references.bib',
			'hostName' => $configuration['hostName'],
			'userName' => $configuration['userName'],
			'password' => $configuration['password'],
			'schema' => $configuration['schema'],
			'schemaFile' => 'data/schema.xml',
			'enableLogin' => $configuration['enableLogin'],
			'enableExport' => $configuration['enableExport'],
			'drawMoleculeBaseURL' => (array_key_exists('drawMoleculeBaseURL', $configuration) ? $configuration['drawMoleculeBaseURL'] : ''),
		);

		$this->loadSchema();
		parent::__construct(1, 'summary', $this);
	}

	function loadSchema(){
		$xml = new DOMDocument();
		$xml->load($this->configuration['schemaFile']);

		$this->schema = array();
		foreach ($xml->getElementsByTagName('table') as $xmlTable){
			$table = array();
			$table = array(
				"name" => "",
				"names" => "",
				//"type" => "",
				//"displayLevel" => 0,
				//"uniqueWholeCellModelIDs" => true,
				//"noNewRows" => false,
				//"writeAsColumn" => false,
				//'noCommit' => false,
				//"update" => false,
				"BioWarehouseProcedure" => "",
				"BioWarehouse_parameters_set" => array(),
				//"BioWarehouse_parameters_update" => array(),
				"columns" => array(),
				"protectedColumns" => array());
			$tableID = $xmlTable->attributes->getNamedItem('id')->nodeValue;

			foreach ($xmlTable->childNodes as $xmlProperty){
				if ($xmlProperty->nodeName == 'columns' || $xmlProperty->nodeName == '#text') continue;
				if ($xmlProperty->childNodes->length <= 1){
					if (rtrim(ltrim($xmlProperty->nodeValue)) != "")
						$table[$xmlProperty->nodeName] = $xmlProperty->nodeValue;
				}else{
					$table[$xmlProperty->nodeName] = array();
					foreach ($xmlProperty->childNodes as $childNode){
						if ($childNode->nodeName == '#text') continue;
						if ($id = $childNode->attributes->getNamedItem('id')){
							if ($childNode->childNodes->length>1){
								foreach ($childNode->childNodes as $grandChildNode){
									if ($grandChildNode->nodeName == '#text') continue;
									$table[$xmlProperty->nodeName][$id->nodeValue][$grandChildNode->nodeName] = $grandChildNode->nodeValue;
								}
							}else{
								$table[$xmlProperty->nodeName][$id->nodeValue] = $childNode->nodeValue;
							}
						}else
							array_push($table[$xmlProperty->nodeName], $childNode->nodeValue);
					}
				}
			}

			foreach ($xmlTable->getElementsByTagName('columns')->item(0)->getElementsByTagName('column') as $xmlColumn){
				$column = array();
				$columnID = $xmlColumn->attributes->getNamedItem('id')->nodeValue;

				foreach ($xmlColumn->childNodes as $xmlProperty){
					if ($xmlProperty->nodeName == '#text') continue;
					if ($xmlProperty->childNodes->length <= 1){
						$column[$xmlProperty->nodeName] = $xmlProperty->nodeValue;
					}else{
						$column[$xmlProperty->nodeName] = array();
						foreach ($xmlProperty->childNodes as $childNode){
							if ($childNode->nodeName == '#text') continue;
							if ($id = $childNode->attributes->getNamedItem('id'))
								$column[$xmlProperty->nodeName][$id->nodeValue] = $childNode->nodeValue;
							else
								array_push($column[$xmlProperty->nodeName], $childNode->nodeValue);
						}
					}
				}

				$table['columns'][$columnID] = $column;
			}

			if (!array_key_exists('propertyCategories', $table))
				$table['propertyCategories'] = array();
			$this->schema[$tableID] = $table;
		}
	}

	function loadFromDatabase($tableIDs = array()){
		if(false === parent::loadFromDatabase())
			return false;
		
		if ($tableIDs === true) $tableIDs = array_keys($this->schema);
		$tableIDs = array_intersect(array_keys($this->schema), $tableIDs);
		if (false !== $idx = array_search('summary', $tableIDs))
			array_splice($tableIDs, $idx, 1);

		//objects
		foreach($tableIDs as $tableID)
			$this->loadObjectsByClass($tableID);

		$this->getWholeCellModelIDs();
		//$this->getMetaboliteEmpiricalFormulas();
		//$this->getMonomerComplexs();
		//$this->getMoleculeCompartments();
		return true;
	}

	function saveToDatabase($mode = 'html', $saveChildren = false, $newKnowledgeBase = false){
		if ($newKnowledgeBase){
			$this->wid = null;
			foreach($this->schema as $tableID => $table){
				if($table['writeAsColumn']) continue;
				foreach($this->$tableID as $object)
					$object->wid = null;
			}
			foreach($this->wholeCellModelIDs as $idx => $arr)
				$this->wholeCellModelIDs[$idx]['WID'] = null;
		}
		list($this->wid, $error) = parent::saveToDatabase();
		if ($error !== true) return array($this->wid, $error);
		if (!$saveChildren) return array($this->wid, $error);

		//create object/edit whole cell model ID
		foreach ($this->schema as $tableID => $table){
			if ($table['noCommit']) continue;
			if ($mode == 'commandLine') $this->writeStatusMessage("Creating ".$table['names']);
			foreach ($this->$tableID as $object){
				$error = $object->saveToDatabase_WholeCellModelID();
				if($error !== true) return array($this->wid, $error);
			}
			if ($mode == 'commandLine') echo "done.\n";
		}

		//save objects
		foreach ($this->schema as $tableID => $table){
			if ($table['noCommit']) continue;
			if ($mode == 'commandLine') $this->writeStatusMessage("Saving ".$table['names']);
			foreach ($this->$tableID as $object){
				$error = $object->saveToDatabase_CrossReferences();
				if($error !== true) return array($this->wid, $error);

				$error = $object->saveToDatabase_Properties();
				if ($error !== true) return array($this->wid, $error);
			}
			if ($mode == 'commandLine') echo "done.\n";
		}

		//linking
		foreach ($this->schema as $tableID => $table){
			if ($table['noCommit']) continue;
			if ($mode == 'commandLine') $this->writeStatusMessage("Linking ".$table['names']);
			foreach ($this->$tableID as $object){
				$error = $object->saveToDatabase_References();
				if ($error !== true) return array($this->wid, $error);
			}
			if ($mode == 'commandLine') echo "done.\n";
		}

		if (!$newKnowledgeBase) return array($this->wid, $error);

		//set genome sequence
		if($mode == 'commandLine') $this->writeStatusMessage("Updating genomic sequence");
		$genomeSequence = $this->readGenomeSequence($this->configuration['genomeSequence']);
		$sql = sprintf("CALL set_genome_sequence(%d,'%s')", $this->wid, $genomeSequence);
		runQuery($sql, $this->configuration);
		if ($mode == 'commandLine') echo "done.\n";

		//set gene sequences
		if ($mode == 'commandLine') $this->writeStatusMessage("Updating gene sequences");
		foreach ($this->genes as $gene){
				$geneSequence = substr($genomeSequence, $gene->coordinate-1, $gene->length);
				if ($gene->direction == 'reverse'){
					$geneSequence = strrev($geneSequence);
					$geneSequence = str_replace('A', 'x', $geneSequence);
					$geneSequence = str_replace('T', 'A', $geneSequence);
					$geneSequence = str_replace('x', 'T', $geneSequence);

					$geneSequence = str_replace('C', 'x', $geneSequence);
					$geneSequence = str_replace('G', 'C', $geneSequence);
					$geneSequence = str_replace('x', 'G', $geneSequence);
				}

				$sql = sprintf("CALL set_gene_sequence(%d,'%s','%s')",
					$this->wid, $gene->wholeCellModelID, $geneSequence);
				runQuery($sql, $this->configuration);
		}
		if ($mode == 'commandLine') echo "done.\n";

		if ($mode == 'commandLine') $this->writeStatusMessage("Updating protein sequence");
		$proteomeSequence = $this->readProteomeSequence($this->configuration['proteomeSequence']);
		foreach ($this->proteinMonomers as $proteinMonomer){
				$sql = sprintf("CALL set_proteinmonomer_sequence(%d,'%s','%s')",
					$this->wid,
					$proteinMonomer->wholeCellModelID,
					$proteomeSequence[$proteinMonomer->wholeCellModelID]);
				runQuery($sql, $this->configuration);
		}
		if($mode == 'commandLine') echo "done.\n";

		return array($this->wid, true);
	}

	function loadObjectsByClass($TableID){
		//properties
		$sql = sprintf("CALL get_%ss(%d, null)", $this->schema[$TableID]['BioWarehouseProcedure'], $this->wid);
		$link = databaseConnect($this->configuration);
		$result = mysql_query($sql);
		$idx = 0;
		while ($arr = mysql_fetch_array($result,MYSQL_ASSOC)){
			//object
			$object = new $this->schema[$TableID]['class']($idx++, $TableID, $this);
			$object->loadFromArray($arr);
			array_push($this->$TableID, $object);
		}
		mysql_close($link);

		//meta data
		$sql = sprintf("CALL get_knowledgebaseobjects(%d, null)", $this->wid);
		$link = databaseConnect($this->configuration);
		$result = mysql_query($sql) or die(mysql_error());
		while ($arr = mysql_fetch_array($result, MYSQL_ASSOC)){
			if (false === $object = $this->getObject($arr['WholeCellModelID'], $TableID))
				continue;
			$object->insertDate = $arr['InsertDate'];
			$object->modifiedDate = $arr['ModifiedDate'];
			$object->insertUser = $arr['InsertUser'];
			$object->modifiedUser = $arr['ModifiedUser'];
		}
		mysql_close($link);

		foreach($this->$TableID as $object){
			//comments
			$sql2 = sprintf("CALL get_comments(%d, %d)", $this->wid, $object->wid);
			$link2 = databaseConnect($this->configuration);
			$result2 = mysql_query($sql2) or die(mysql_error());
			while($arr = mysql_fetch_array($result2, MYSQL_ASSOC)){
				$object->comments = $arr['Comments'];
			}
			mysql_close($link2);

			//cross references
			$sql2 = sprintf("CALL get_crossreferences(%d, %d)", $this->wid, $object->wid);
			$link2 = databaseConnect($this->configuration);
			$result2 = mysql_query($sql2) or die(mysql_error());
			while ($arr = mysql_fetch_array($result2, MYSQL_ASSOC)){
				$propertyID = $this->schema[$object->tableID]['columns'][$arr['DatabaseRelationship']]['propertyID'];
				$propertyCategory = $this->schema[$object->tableID]['columns'][$arr['DatabaseRelationship']]['propertyCategory'];
				$object->$propertyCategory->$propertyID = $arr['CrossReference'];
			}
			mysql_close($link2);
		}
	}

	function loadObjectsByKeywordSearch($Keywords){
		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf("CALL search_knowledgebase(%d,'%s')", $this->wid,mysql_escape_string($Keywords))) or die(mysql_error());
		while ($arr = mysql_fetch_array($result)){
			$tableID = $this->wholeCellModelIDs[$arr['WholeCellModelID']]['TableID'];
			if ($tableID != 'summary'){
				$object = new $this->schema[$tableID]['class']($idx++, $tableID, $this);
				$object->loadFromArray($arr);
				array_push($this->$tableID, $object);
			}
		}
		mysql_close($link);
	}

	function objectsPane($Format, $MetaData = false, $Errors = false, $Warnings = false){
		$content = $this->objectsPaneContent($Format, $MetaData, $Errors, $Warnings);
		if ($content === false)
			return null;

		return $this->objectsPaneHeader($Format, $content, $MetaData, $Errors, $Warnings);
	}

	function objectsPaneContent($Format, $MetaData = false, $Errors = false, $Warnings = false){
		$idx = 1;

		$content = '';

		foreach($this->schema as $table){
			$TableID = $table['id'];
			$tableContent = '';
			if(count($this->$TableID) == 0) continue;

			if($Format != 'Table'){
				$tableContent .= "				 <p>".$table['names']."</p>\n";
				$tableContent .= "				 <ul>\n";
			}

			$this->sortObjectsByWholeCellModelID($TableID);
			$objectsContent = '';
			foreach($this->$TableID as $object){
				if(($Errors && !$Warnings && !$object->error) ||
				($Warnings && !$Errors && count($object->warning) == 0) ||
				($Errors && $Warnings && !$object->error && count($object->warning) == 0))
					continue;
				if($Format == 'Table')
					$objectsContent .= $object->viewBreifRow($idx++, $MetaData, $Errors, $Warnings);
				else
					$objectsContent .= "					 ".$object->viewItem($idx++, $MetaData, $Errors, $Warnings)."\n";
			}

			$tableContent .= $objectsContent;

			if($Format != 'Table')
				$tableContent .= "				 </ul>\n";

			if(rtrim(ltrim($objectsContent)) != '')
				$content .= $tableContent;
		}

		if ($idx > 1 && $content != '')
			return $content;

		return false;
	}

	function objectsPaneHeader($Format, $content, $MetaData = false, $Errors = false, $Warnings = false){
		if ($Format == 'Table'){
			$content =
				"<table cellpadding=0 cellspacing=0 id=\"Search\" class=\"Table\">\n".
				"   <thead>\n".
				"	   <tr>\n".
				"		   <th>&nbsp;</th>\n".
				($MetaData ? "		   <th>Created</th>\n" : "").
				($MetaData ? "		   <th>Last Updated</th>\n" : "").
				"		   <th>Class</th>\n".
				"		   <th>Whole Cell Model ID</th>\n".
				"		   <th>Name</th>\n".
				($Errors ? "		   <th>Errors</th>\n" : "").
				($Warnings ? "		   <th>Warnings</th>\n" : "").
				"		   <th>".(isset($_SESSION['UserName']) ? "Edit" : "View")."</th>\n".
				"	   </tr>\n".
				"   </thead>\n".
				"   <tbody>\n".
				$content.
				"   </tbody>\n".
				"</table>\n";
		}else{
			$content="<div id=\"Search\" class=\"List\"><div>$content</div></div>";
		}
		return $content;
	}

	function objectsPaneByClass($Format, $TableID){
		$this->sortObjectsByWholeCellModelID($TableID);
		$idx = 1;
		foreach ($this->$TableID as $object){
			if ($Format == 'Table')
				$content .= $object->viewDetailedRow($idx++);
			else
				$content .= "					 ".$object->viewItem($idx++)."\n";
		}

		if ($Format == 'Table'){
			$headings = array();
			$j = 0;
			foreach ($this->schema[$TableID]['columns'] as $id => $column){
				if ($column['displayLevel'] > 1) continue;
				if ($column['propertyCategory']) continue;
				$j++;
				array_push($headings, "<th name=\"column$j\"".($column['displayLevel'] == 0 ? "" : " style=\"display:none;\"").">".
					$this->formatPropertyName($column).
					"</th>");
			}

			$content =
				"<table cellpadding=0 cellspacing=0 id=\"Object\" class=\"Table\">\n".
				"   <thead>\n".
				"	   <tr>\n".
				"		   <th>&nbsp;</th>\n".
				"		   ".join("\n		   ",$headings)."\n".
				"		   <th>".(isset($_SESSION['UserName']) ? "Edit" : "View")."</th>\n".
				"	   </tr>\n".
				"   </thead>\n".
				"   <tbody>\n".
				$content.
				"   </tbody>\n".
				"</table>\n";
		}else{
			switch ($TableID){
				case 'metabolites':
				case 'reactions':
					$imgURL = $this->configuration['metabolicMap'];
					break;
				case 'genes':
					$imgURL = $this->configuration['genomeBrowser']['genes'];
					break;
				case 'transcriptionUnits':
					$imgURL = $this->configuration['genomeBrowser']['transcriptionUnits'];
					break;
			}

			$type = 'png';

			if ($imgURL){
				switch($type){
					case 'svg':
						$graphicContent = "<embed width=\"100%\" src=\"".str_replace("\\","/","$imgURL.svg")."\" type=\"image/svg+xml\" />";
						break;
					default:
						$graphicContent =
							"<div style=\"width:100%\"><map name=\"map\">\n".file_get_contents("$imgURL.map")."</map>".
							"<img class=\"mapper noborder iopacity50 icolorff0000\" src=\"".str_replace("\\","/","$imgURL.png")."\" usemap=\"#map\" /></div>";
						break;
				}
			}

			$content = "<div id=\"Object\" class=\"List\"><div>$graphicContent<ul>\n$content				</ul></div></div>";
		}
		return $content;
	}

	function errorsWarningsPane($Format){
		$this->getMetaboliteEmpiricalFormulas();
		$this->getMonomerComplexs();
		$this->getMoleculeCompartments();
		$this->loadFromDatabase(true);

		$errors = array();
		$warnings = array();
		foreach ($this->schema as $tableID => $table){
			if ($table['noCommit']) continue;
			foreach ($this->$tableID as $idx => $object){
				list($error, $warning) = $object->validate();
				if ($error !== true) $object->error = $error;
				if ($warning !== true) $object->warning = $warning;
			}
		}

		$content .= $this->objectsPaneContent($Format, false, false, true);
		$content = $this->objectsPaneHeader($Format, $content, false, false, true);
		return $content;
	}

	function recentChangesPane($Format){
		if ($Format == 'List'){
			$this->clearObjects();
			$link = databaseConnect($this->configuration);
			$result = mysql_query(sprintf("CALL get_newknowledgebaseobjects(%d)",$this->wid)) or die(mysql_error());
			while ($arr = mysql_fetch_array($result)){
				$tableID = $this->wholeCellModelIDs[$arr['WholeCellModelID']]['TableID'];
				if($tableID != 'summary'){
					$object = new $this->schema[$tableID]['class']($idx++, $tableID, $this);
					$object->loadFromArray($arr);
					array_push($this->$tableID, $object);
				}
			}
			mysql_close($link);
			$content .= "<h1>Recently Added</h1>\n";
			$content .= $this->objectsPaneContent($Format, true);

			$this->clearObjects();
			$link = databaseConnect($this->configuration);
			$result = mysql_query(sprintf("CALL get_modifiedknowledgebaseobjects(%d)", $this->wid)) or die(mysql_error());
			while($arr = mysql_fetch_array($result)){
				$tableID = $this->wholeCellModelIDs[$arr['WholeCellModelID']]['TableID'];
				if($tableID != 'summary'){
					$object = new $this->schema[$tableID]['class']($idx++, $tableID, $this);
					$object->loadFromArray($arr);
					array_push($this->$tableID, $object);
				}
			}
			mysql_close($link);
			$content .= "<h1>Recently Modified</h1>\n";
			$content .= $this->objectsPaneContent($Format, true);
		}else{
			$link = databaseConnect($this->configuration);
			$result = mysql_query(sprintf("CALL get_newknowledgebaseobjects(%d)", $this->wid)) or die(mysql_error());
			while ($arr = mysql_fetch_array($result)){
				$tableID = $this->wholeCellModelIDs[$arr['WholeCellModelID']]['TableID'];
				if ($tableID != 'summary'){
					$object = new $this->schema[$tableID]['class']($idx++, $tableID, $this);
					$object->loadFromArray($arr);
					array_push($this->$tableID, $object);
				}
			}
			mysql_close($link);

			$link = databaseConnect($this->configuration);
			$result = mysql_query(sprintf("CALL get_modifiedknowledgebaseobjects(%d)", $this->wid)) or die(mysql_error());
			while ($arr = mysql_fetch_array($result)){
				$tableID = $this->wholeCellModelIDs[$arr['WholeCellModelID']]['TableID'];
				if ($tableID != 'summary'){
					$object = new $this->schema[$tableID]['class']($idx++, $tableID, $this);
					$object->loadFromArray($arr);
					array_push($this->$tableID, $object);
				}
			}
			mysql_close($link);

			$content .= $this->objectsPaneContent($Format, true);
		}

		$content = $this->objectsPaneHeader($Format, $content, true);
		return $content;
	}

	function constructObjectByID($WID, $WholeCellModelID){
		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf("CALL get_wholecellmodelids(%d,%s,%s)",
			$this->wid, ($WID ? $WID : "null"), ($WholeCellModelID && !$WID ? "'$WholeCellModelID'" : "null")));
		if (mysql_num_rows($result) == 0){
			mysql_close($link);
			return false;
		}
		$arr = mysql_fetch_array($result);
		$WID = $arr['WID'];
		$TableID = $arr['TableID'];
		mysql_close($link);

		if ($WID == $this->wid)
			return $this;

		$object = new $this->schema[$TableID]['class'](0, $TableID, $this);
		$object->wid = $WID;
		$object->loadFromDatabase();
		return $object;
	}

	function clearObjects(){
		foreach ($this->schema as $tableID => $table){
			if ($table['writeAsColumn']) continue;
			$this->$tableID = array();
		}
	}

	function exportXLS($tableIDs = array()){
		if ($tableIDs === true) $tableIDs = array_keys($this->schema);
		$tableIDs = array_values(array_intersect(array_keys($this->schema), $tableIDs));
		if (!isset($_SESSION['UserName']) && (false !== $idx = array_search('simulations', $tableIDs)))
			array_splice($tableIDs, $idx, 1);

		list($workbook, $protectedFormat, $unprotectedFormat, $firstColFormat, $protectedFirstColFormat, $firstRowFormat) =
			$this->exportXLS_Initialize();

		//table of contents
		$isTOC = !isset($_SESSION['UserName']) && count($tableIDs) > 1;
		if ($isTOC){
			$worksheet = $workbook->createSheet(0);
			$worksheet->getDefaultRowDimension()->setRowHeight(15);
			$worksheet->setTitle('Contents');
			$worksheet->freezePaneByColumnAndRow(2, 5);

			//column widths
			$worksheet->getColumnDimension('A')->setWidth(5 + 0.71);
			$worksheet->getColumnDimension('B')->setWidth(100 + 0.71);

			//fill
			$worksheet->getStyle('A1:B4')->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID);
			$worksheet->getStyle('A1:B1')->getFill()->getStartColor()->setARGB('FF7F7F7F');
			$worksheet->getStyle('A2:B4')->getFill()->getStartColor()->setARGB('FFAAAAAA');

			//border
			$worksheet->getStyle('A1:B1')->getBorders()->getTop()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A1')->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('B1')->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A1:B1')->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A2')->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
			$worksheet->getStyle('A3')->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
			$worksheet->getStyle('A4')->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
			$worksheet->getStyle('B2')->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
			$worksheet->getStyle('B3')->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
			$worksheet->getStyle('B4')->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
			$worksheet->getStyle('A4:B4')->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);

			//center
			$worksheet->getStyle('A1:B4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			//merge
			$worksheet->mergeCells('A1:B1');
			$worksheet->mergeCells('A2:B2');
			$worksheet->mergeCells('A3:B3');
			$worksheet->mergeCells('A4:B4');

			//content
			$richText = new PHPExcel_RichText();
			$richTextRun = $richText->createTextRun("A Whole Cell Model of ");
			$richTextRun->getFont()->setSize(15);
			$richTextRun->getFont()->setBold(true);
			$richTextRun = $richText->createTextRun("Mycoplasma genitalium");
			$richTextRun->getFont()->setSize(15);
			$richTextRun->getFont()->setBold(true);
			$richTextRun->getFont()->setItalic(true);
			$worksheet->getCell('A1')->setValue($richText);
			$worksheet->getRowDimension(1)->setRowHeight(18);

			$worksheet->setCellValueExplicitByColumnAndRow(0, 2, "Knowledge Base", PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->getStyle('A2:B2')->getFont()->setBold(true);
			$worksheet->getStyle('A2:B2')->getFont()->setSize(13);
			$worksheet->getRowDimension(2)->setRowHeight(15);

			$richText = new PHPExcel_RichText();
			$richText->createText("Jonathan R Karr");
			$richTextRun = $richText->createTextRun("1");
			$richTextRun->getFont()->setSubScript();
			$richText->createText(", Jayodita C Sanghvi");
			$richTextRun = $richText->createTextRun("2");
			$richTextRun->getFont()->setSubScript();
			$richText->createText(", Jared M Jacobs");
			$richTextRun = $richText->createTextRun("2");
			$richTextRun->getFont()->setSubScript();
			$richText->createText(", Derek N Macklin");
			$richTextRun = $richText->createTextRun("2");
			$richTextRun->getFont()->setSubScript();
			$richText->createText(", Markus W Covert");
			$richTextRun = $richText->createTextRun("2");
			$richTextRun->getFont()->setSubScript();
			$worksheet->getCell('A3')->setValue($richText);
			$worksheet->getRowDimension(3)->setRowHeight(15);

			$worksheet->setCellValueExplicitByColumnAndRow(0, 4, "1. Graduate Program in Biophysics, 2. Department of Bioengineering, Stanford University", PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->getRowDimension(4)->setRowHeight(15);

			//toc
			$worksheet->setCellValueExplicitByColumnAndRow(0, 6, 1, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			$worksheet->setCellValueExplicitByColumnAndRow(1, 6, "Knowledge Base", PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->getStyle('A6:B6')->getFont()->setBold(true);
			$worksheet->getStyle('A6:B6')->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID);
			$worksheet->getStyle('A6:B6')->getFill()->getStartColor()->setARGB('FFAAAAAA');
			$worksheet->getStyle('A6:B6')->getBorders()->getTop()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A6:B6')->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A6:B6')->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A6:B6')->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle('A6')->getNumberFormat()->setFormatCode("0.");

			$tableNumber = 0;
			foreach($tableIDs as $idx => $tableID){
				if (!isset($_SESSION['UserName']) && $this->schema[$tableID]['spreadSheetDisplayLevel'] >= 1)
					continue;
				$tableNumber++;
				$title = $this->schema[$tableID]['names'];
				$caption = $this->schema[$tableID]['caption'];

				$worksheet->setCellValueExplicitByColumnAndRow(0, 7 + 2 * ($tableNumber - 1), $tableNumber, PHPExcel_Cell_DataType::TYPE_NUMERIC);
				$worksheet->setCellValueExplicitByColumnAndRow(1, 7 + 2 * ($tableNumber - 1), $title, PHPExcel_Cell_DataType::TYPE_STRING);
				$worksheet->getCell('B'.(7 + 2 * ($tableNumber - 1)))->getHyperlink()->setUrl("sheet://'$title'!A1");
				$worksheet->getCell('B'.(7 + 2 * ($tableNumber - 1)))->getHyperlink()->setTooltip("Table $tableNumber. $title");
				$worksheet->getStyle('B'.(7 + 2 * ($tableNumber - 1)).':B'.(7 + 2 * ($tableNumber - 1)))->getFont()->setUnderline(PHPExcel_Style_Font::UNDERLINE_SINGLE);
				$worksheet->setCellValueExplicitByColumnAndRow(1, 7 + 2 * ($tableNumber - 1) + 1, $caption, PHPExcel_Cell_DataType::TYPE_STRING);
				$worksheet->getStyle('A'. (7 + 2 * ($tableNumber - 1)).':B'.(7 + 2 * ($tableNumber - 1)+1))->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID);
				$worksheet->getStyle('A'. (7 + 2 * ($tableNumber - 1)).':B'.(7 + 2 * ($tableNumber - 1)+1))->getFill()->getStartColor()->setARGB(($tableNumber % 2 == 1 ? 'DCDCDC' : 'F2F2F2'));
				$worksheet->getStyle('A'. (7 + 2 * ($tableNumber - 1)).':A'.(7 + 2 * ($tableNumber - 1)+1))->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
				$worksheet->getStyle('B'. (7 + 2 * ($tableNumber - 1)).':B'.(7 + 2 * ($tableNumber - 1)+1))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);
				$worksheet->getStyle('A'.(7 + 2 * ($tableNumber - 1)))->getNumberFormat()->setFormatCode("0.");
			}

			$worksheet->getStyle('A'. (7 + 2 * $tableNumber - 1).':B'.(7 + 2 * $tableNumber - 1))->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THIN);

			//wrapping
			$worksheet->getStyle('A1:B'.(7 + 2 * $tableNumber - 1))->getAlignment()->setWrapText(true);
		}

		//tables
		$tableNumber = 0;
		foreach($tableIDs as $idx => $tableID){
			if (!isset($_SESSION['UserName']) && $this->schema[$tableID]['spreadSheetDisplayLevel'] >= 1)
				continue;
			$tableNumber++;

			$worksheet = $workbook->createSheet($tableNumber + ($isToc - 1) + 1);
			$worksheet->getDefaultRowDimension()->setRowHeight(15);

			/*$protection = $worksheet->getProtection();
			$protection->setSheet(true);
			$protection->setFormatRows(true);
			$protection->setFormatColumns(true);
			$protection->setFormatCells(true);
			$protection->setPivotTables(false);
			$protection->setAutoFilter(false);
			$protection->setSelectLockedCells(false);
			$protection->setSelectUnlockedCells(false);*/

			$worksheet->setTitle((isset($_SESSION['UserName']) ? $tableID : $this->schema[$tableID]['names']));

			if($this->schema[$tableID]['writeAsColumn']){
				/*$protection->setDeleteRows(true);
				$protection->setDeleteColumns(false);
				$protection->setInsertRows(true);
				$protection->setInsertColumns(false);*/
				$this->exportXLS_TableAsColumn($worksheet, $protectedFirstColFormat, $firstColFormat, $firstRowFormat, $protectedFormat, $unprotectedFormat, $tableID, $tableNumber);
			}else{
				/*$protection->setDeleteRows(false);
				$protection->setDeleteColumns(true);
				$protection->setInsertRows(false);
				$protection->setInsertColumns(true);*/
				$this->exportXLS_TableAsRows($worksheet, $protectedFirstColFormat, $firstColFormat, $firstRowFormat, $protectedFormat, $unprotectedFormat, $tableID, $tableNumber);
			}
		}

		//set active sheet
		$workbook->setActiveSheetIndex(0);

		//close excel file
		if ($isTOC)
			$workbook->removeSheetByIndex($tableNumber + $isTOC);
		else
			$workbook->removeSheetByIndex(0);
		$this->exportXLS_Finalize($workbook);
	}

	function exportXLS_Initialize(){
		//create workbook
		$workbook = new PHPExcel();

		//Meta data
		$workbook->getProperties()->setCreator("Jonathan R Karr, Jayodita C Sanghvi, Jared M Jacobs, Derek N Macklin, Markus W Covert");
		$workbook->getProperties()->setLastModifiedBy("Jonathan R Karr, Jayodita C Sanghvi, Jared M Jacobs, Derek N Macklin, Markus W Covert");
		$workbook->getProperties()->setCompany("Stanford University");
		$workbook->getProperties()->setTitle("Mycoplasma genitalium Whole Cell Model Knowledge Base");
		$workbook->getProperties()->setSubject("Mycoplasma genitalium Whole Cell Model Knowledge Base");
		$workbook->getProperties()->setDescription("Mycoplasma genitalium Whole Cell Model Knowledge Base");
		$workbook->getProperties()->setKeywords("whole cell model, Mycoplasma genitalium");
		//$workbook->getProperties()->setCustomProperty('Department', 'Bioengineering', PHPExcel_DocumentProperties::PROPERTY_TYPE_STRING);
		//$workbook->getProperties()->setCustomProperty('Group', 'Covert Lab', PHPExcel_DocumentProperties::PROPERTY_TYPE_STRING);
		//$workbook->getProperties()->setCustomProperty('Project', 'Mycoplasma genitalium Whole Cell Model', PHPExcel_DocumentProperties::PROPERTY_TYPE_STRING);

		//formats
		$protectedFormat = new PHPExcel_Style();
		$protectedFormat->applyFromArray(array(
			/*'protection' => array(
				'locked' => PHPExcel_Style_Protection::PROTECTION_PROTECTED),*/
			'alignment' => array(
				'wrap' => true),
			'borders' => array(
				'left' => array('style' => PHPExcel_Style_Border::BORDER_THIN),
				'right' => array('style' => PHPExcel_Style_Border::BORDER_THIN)
				)));

		$unprotectedFormat = new PHPExcel_Style();
		$unprotectedFormat->applyFromArray(array(
			/*'protection' => array(
				'locked' => PHPExcel_Style_Protection::PROTECTION_UNPROTECTED),*/
			'borders' => array(
				'left' => array('style' => PHPExcel_Style_Border::BORDER_THIN),
				'right' => array('style' => PHPExcel_Style_Border::BORDER_THIN)
				),
			'alignment' => array(
				'wrap' => true)));
		if (isset($_SESSION['UserName'])){
			$unprotectedFormat->applyFromArray(array(
				'fill' => array(
					'type' => PHPExcel_Style_Fill::FILL_SOLID,
					'color' => array('rgb' => 'CCCCCC'))));
		}

		$firstColFormat = new PHPExcel_Style();
		$firstColFormat->applyFromArray(array(
			/*'protection' => array(
					'locked' => PHPExcel_Style_Protection::PROTECTION_UNPROTECTED),*/
			'alignment' => array(
				'wrap' => true),
			'borders' => array(
				'left' => array('style' => PHPExcel_Style_Border::BORDER_THIN),
				'right' => array('style' => PHPExcel_Style_Border::BORDER_THIN)
				),
			'fill' => array(
				'type' => PHPExcel_Style_Fill::FILL_SOLID,
				'color' => array('rgb' => 'AAAAAA')),
			'font' => array(
				'bold' => true)));

		$protectedFirstColFormat = new PHPExcel_Style();
		$protectedFirstColFormat->applyFromArray(array(
			/*'protection' => array(
				'locked' => PHPExcel_Style_Protection::PROTECTION_PROTECTED),*/
			'alignment' => array(
				'wrap' => true),
			'font' => array(
				'bold' => true),
			'borders' => array(
				'left' => array('style' => PHPExcel_Style_Border::BORDER_THIN),
				'right' => array('style' => PHPExcel_Style_Border::BORDER_THIN)
				),
			'fill'=> array(
				'type' => PHPExcel_Style_Fill::FILL_SOLID,
				'color' => array('rgb' => 'AAAAAA'))));

		$firstRowFormat = new PHPExcel_Style();
		$firstRowFormat->applyFromArray(array(
			/*'protection' => array(
				'locked' => PHPExcel_Style_Protection::PROTECTION_PROTECTED),*/
			'alignment' => array(
				'wrap' => true),
			'font' => array(
				'bold' => true),
			'borders' => array(
				'left' => array('style' => PHPExcel_Style_Border::BORDER_THIN),
				'right' => array('style' => PHPExcel_Style_Border::BORDER_THIN)
				),
			'fill' => array(
				'type' => PHPExcel_Style_Fill::FILL_SOLID,
				'color' => array('rgb' => 'AAAAAA'))));

		return array($workbook, $protectedFormat, $unprotectedFormat, $firstColFormat, $protectedFirstColFormat, $firstRowFormat);
	}

	function exportXLS_Finalize($workbook){
		$excelWriter = new PHPExcel_Writer_Excel2007($workbook);
		$excelWriter->save($this->configuration['knowledgeBaseWrite']);
	}

	function exportXLS_TableAsColumn($worksheet, $protectedFirstColFormat, $firstColFormat, $firstRowFormat, $protectedFormat, $unprotectedFormat, $tableID, $tableNumber){
		$columnNames = array_keys($this->schema[$tableID]['columns']);
		if ($tableID == 'summary' && !isset($_SESSION['UserName']))
			$columnNames = array_values(array_intersect($columnNames, array(
				'Name',
				'Taxonomy',
				'TranslationTable',
				'GenomeLength',
				'TaxonomyID',
				'RefSeqID',
				'GenBankID',
				'GenomeProjectID',
				'CMRID',
				'ATCCID')));

		$object = $this->loadToArray();

		if (isset($_SESSION['UserName'])){
			$firstRow = 2;
			$worksheet->setCellValueExplicitByColumnAndRow(0, 1, 'WID', PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($protectedFirstColFormat, "A1");
			$worksheet->setCellValueExplicitByColumnAndRow(1, 1, $object['WID'], PHPExcel_Cell_DataType::TYPE_NUMERIC);
			/*$worksheet->getStyleByColumnAndRow(1, 1)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER);*/
			$worksheet->setSharedStyle($protectedFormat, "B1");
			$worksheet->freezePaneByColumnAndRow(1, 1);
		}else{
			$firstRow = 4;
			$title = $this->schema[$tableID]['names'];
			$caption = $this->schema[$tableID]['caption'];
			$worksheet->setCellValueExplicitByColumnAndRow(0, 1, "Table $tableNumber. $title");
			$worksheet->setCellValueExplicitByColumnAndRow(0, 2, $caption);
			$worksheet->getStyle('A1:I1')->getFont()->setBold(true);
			$worksheet->getStyle('A1:I2')->getAlignment()->setWrapText(true);
			$worksheet->getStyle('A2:I2')->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_TOP);
			$worksheet->mergeCells('A1:I1');
			$worksheet->mergeCells('A2:I2');
			$worksheet->freezePaneByColumnAndRow(1, 4);
			$worksheet->getRowDimension(1)->setRowHeight(15 * ceil(strlen("Table $tableNumber. $title") / 120));
			$worksheet->getRowDimension(2)->setRowHeight(15 * ceil(strlen($caption) / 120));
		}

		//column widths
		$worksheet->getColumnDimension('A')->setAutoSize(true);

		for ($i = 0; $i < count($columnNames); $i++){
			$worksheet->setCellValueExplicitByColumnAndRow (0, $i + $firstRow,
				(isset($_SESSION['UserName']) ? $columnNames[$i] : $this->schema[$tableID]['columns'][$columnNames[$i]]['name']),
				PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($protectedFirstColFormat, "A".($i + $firstRow));

			if(array_search($columnNames[$i], $this->schema[$tableID]['protectedColumns'])!==false)
				$format = $protectedFormat;
			else
				$format = $unprotectedFormat;
			$worksheet->setSharedStyle($format,"B".($i + $firstRow));

			if(($this->schema[$tableID]['columns'][$columnNames[$i]]['type'] == 'numeric' || is_numeric($object[$columnNames[$i]])) && !is_null($object[$columnNames[$i]])){
				$worksheet->setCellValueExplicitByColumnAndRow(1, $i + $firstRow, $object[$columnNames[$i]], PHPExcel_Cell_DataType::TYPE_NUMERIC);
				/*$worksheet->getStyleByColumnAndRow(1, $i + $firstRow)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER);*/
			}else{
				$worksheet->setCellValueExplicitByColumnAndRow(1, $i + $firstRow, 
					(isset($_SESSION['UserName']) && $this->schema[$tableID]['columns'][$columnNames[$i]]['format'] == 'comments' ? strip_tags($object[$columnNames[$i]]) : $object[$columnNames[$i]]), 
					PHPExcel_Cell_DataType::TYPE_STRING);
			}

			//hyperlink
			if (!isset($_SESSION['UserName']) && $this->schema[$tableID]['columns'][$columnNames[$i]]['format'] == 'crossReference' && $this->schema[$tableID]['columns'][$columnNames[$i]]['url'] && $object[$columnNames[$i]]){
				$worksheet->getCell('B'.($i + $firstRow))->getHyperlink()->setUrl($this->encodeURL(
					(false !== strpos($this->schema[$tableID]['columns'][$columnNames[$i]]['url'], '%s')
						? sprintf($this->schema[$tableID]['columns'][$columnNames[$i]]['url'], $object[$columnNames[$i]])
						: $this->schema[$tableID]['columns'][$columnNames[$i]]['url'])));
				$worksheet->getCell('B'.($i + $firstRow))->getHyperlink()->setTooltip(
					$this->schema[$tableID]['columns'][$columnNames[$i]]['databaseName'].' Entry: '.$object[$columnNames[$i]]);
			}

			//row height
			$worksheet->getRowDimension($i + $firstRow)->setRowHeight(15);
		}

		if(false && isset($_SESSION['UserName'])){
			$worksheet->setSharedStyle($protectedFirstColFormat, "A".(count($columnNames)+$firstRow));
			$worksheet->setCellValueExplicitByColumnAndRow (0, count($columnNames)+$firstRow, "Error", PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($format, "B".(count($columnNames)+$firstRow));
			$worksheet->setCellValueExplicitByColumnAndRow(1, count($columnNames)+$firstRow, $this->error, PHPExcel_Cell_DataType::TYPE_STRING);

			$worksheet->setSharedStyle($protectedFirstColFormat, "A".(count($columnNames)+1+$firstRow));
			$worksheet->setCellValueExplicitByColumnAndRow (0, count($columnNames)+1+$firstRow, "Warning", PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($format, "B".(count($columnNames)+1+$firstRow));
			$worksheet->setCellValueExplicitByColumnAndRow(1, count($columnNames)+1+$firstRow, join(' ',$this->warning), PHPExcel_Cell_DataType::TYPE_STRING);
		}

		$firstRow -= isset($_SESSION['UserName'])+0;
		$worksheet->getStyle('A'.$firstRow.':B'.$firstRow)->getBorders()->getTop()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		$worksheet->getStyle('A'.(count($columnNames)+$firstRow-1 + (1 + 2 * false) * isset($_SESSION['UserName'])).':B'.(count($columnNames)+$firstRow-1 + (1 + 2 * false) * isset($_SESSION['UserName'])))->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		$worksheet->getStyle('A'.$firstRow.':A'.(count($columnNames)+$firstRow-1 + (1 + 2 * false) * isset($_SESSION['UserName'])))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		$worksheet->getStyle('A'.$firstRow.':A'.(count($columnNames)+$firstRow-1 + (1 + 2 * false) * isset($_SESSION['UserName'])))->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		$worksheet->getStyle('B'.$firstRow.':B'.(count($columnNames)+$firstRow-1 + (1 + 2 * false) * isset($_SESSION['UserName'])))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
	}

	function exportXLS_TableAsRows($worksheet, $protectedFirstColFormat, $firstColFormat, $firstRowFormat, $protectedFormat, $unprotectedFormat, $tableID, $tableNumber){
		$columnNames = array_keys($this->schema[$tableID]['columns']);
		$title = $this->schema[$tableID]['names'];
		$caption = $this->schema[$tableID]['caption'];


		$j = -1 + isset($_SESSION['UserName']);
		foreach($columnNames as $columnName){
			if (!isset($_SESSION['UserName']) && $this->schema[$tableID]['columns'][$columnName]['spreadSheetDisplayLevel'] >= 1)
				continue;
			$j++;
		}
		$nCols = $j;
		$nRows = count($this->$tableID);

		//freeze pane, title, caption
		if (isset($_SESSION['UserName'])){
			$firstRow = -1;
			$worksheet->freezePaneByColumnAndRow(2, 2);
		}else{
			$firstRow = 2;
			$worksheet->freezePaneByColumnAndRow(1, 5);
			$worksheet->setCellValueExplicitByColumnAndRow(0, 1, "Table $tableNumber. $title");
			$worksheet->setCellValueExplicitByColumnAndRow(0, 2, $caption);
			$worksheet->getStyle('A1:I1')->getFont()->setBold(true);
			$worksheet->getStyle('A1:I2')->getAlignment()->setWrapText(true);
			$worksheet->getStyle('A2:I2')->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_TOP);
			$worksheet->mergeCells('A1:I1');
			$worksheet->mergeCells('A2:I2');
			$worksheet->getRowDimension(1)->setRowHeight(15 * ceil(strlen("Table $tableNumber. $title") / 120));
			$worksheet->getRowDimension(2)->setRowHeight(15 * ceil(strlen($caption) / 120));
		}

		//col widths
		$worksheet->getColumnDimension('A')->setAutoSize(true);

		//col labels
		$i = -1;

		if(isset($_SESSION['UserName'])){
			$worksheet->setCellValueExplicitByColumnAndRow(++$i, $firstRow+2, 'WID', PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($firstRowFormat, $this->columnCode($i).($firstRow+2));
		}
		foreach($columnNames as $columnName){
			if (!isset($_SESSION['UserName']) && $this->schema[$tableID]['columns'][$columnName]['spreadSheetDisplayLevel'] >= 1)
				continue;
			if (!isset($_SESSION['UserName'])){
				$columnName = $this->schema[$tableID]['columns'][$columnName]['name'];
				$columnName = strip_tags(str_replace('&#916;', "Delta ", $columnName));
			}
			$worksheet->setCellValueExplicitByColumnAndRow(++$i, $firstRow+2, $columnName, PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($firstRowFormat, $this->columnCode($i).($firstRow+2));
		}

		if(false && isset($_SESSION['UserName'])){
			$worksheet->setCellValueExplicitByColumnAndRow(++$i, $firstRow+2, 'Error', PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($firstRowFormat,$this->columnCode($i).($firstRow+2));
			$worksheet->setCellValueExplicitByColumnAndRow(++$i, $firstRow+2, 'Warning', PHPExcel_Cell_DataType::TYPE_STRING);
			$worksheet->setSharedStyle($firstRowFormat,$this->columnCode($i).($firstRow+2));
		}
		$worksheet->getStyle($this->columnCode($i).($firstRow+2))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);

		$worksheet->getRowDimension($firstRow + 2)->setRowHeight(15);

		//data
		foreach($this->$tableID as $i => $object){
			$arr = $object->loadToArray();
			
			$j = -1;
			if(isset($_SESSION['UserName'])){
				$worksheet->setSharedStyle($protectedFirstColFormat, $this->columnCode(++$j).($i+2+$firstRow+1));
				$worksheet->setCellValueExplicitByColumnAndRow($j, $i+2+$firstRow+1, $arr['WID'], PHPExcel_Cell_DataType::TYPE_NUMERIC);
			}
			/*$worksheet->getStyleByColumnAndRow($j,$i+2+$firstRow+1)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER);*/
			foreach($columnNames as $columnName){
				if (!isset($_SESSION['UserName']) && $this->schema[$tableID]['columns'][$columnName]['spreadSheetDisplayLevel'] >= 1)
					continue;

				$j++;
				if (($j == 1 && isset($_SESSION['UserName'])) || ($j == 0 && !isset($_SESSION['UserName'])))
					$format = $firstColFormat;
				elseif (array_search($columnName, $this->schema[$tableID]['protectedColumns']) !== false)
					$format = $protectedFormat;
				else
					$format = $unprotectedFormat;
				$worksheet->setSharedStyle($format, $this->columnCode($j).($i+2+$firstRow+1));

				//content
				if (($this->schema[$tableID]['columns'][$columnName]['type'] == 'numeric' || is_numeric($arr[$columnName])) && !is_null($arr[$columnName])){
					$worksheet->setCellValueExplicitByColumnAndRow($j, $i+2+$firstRow+1, $arr[$columnName], PHPExcel_Cell_DataType::TYPE_NUMERIC);
					//$worksheet->getStyleByColumnAndRow($j,$i+2+$firstRow+1)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER);
				}else{
					if(is_array($arr[$columnName]))
						$arr[$columnName] = join(";", $arr[$columnName]);
					$worksheet->setCellValueExplicitByColumnAndRow($j, $i + 2 + $firstRow + 1,
						(isset($_SESSION['UserName']) && $this->schema[$tableID]['columns'][$columnName]['format'] == 'comments' ? strip_tags($arr[$columnName]) : $arr[$columnName]), PHPExcel_Cell_DataType::TYPE_STRING);
				}

				//hyperlink
				if ($columnName == 'WholeCellModelID'){
					$worksheet->getCell($this->columnCode($j).($i+2+$firstRow+1))->getHyperlink()->setUrl(
						"http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?WholeCellModelID=".$arr[$columnName]);
					$worksheet->getCell($this->columnCode($j).($i+2+$firstRow+1))->getHyperlink()->setTooltip(
						'Whole Cell Knowledge Base Entry: '.$arr[$columnName]);
				}elseif (!isset($_SESSION['UserName']) &&
					$this->schema[$tableID]['columns'][$columnName]['format'] == 'crossReference' &&
					$this->schema[$tableID]['columns'][$columnName]['url'] &&
					$arr[$columnName]){
					$worksheet->getCell($this->columnCode($j).($i+2+$firstRow+1))->getHyperlink()->setUrl($this->encodeURL(
						(false !== strpos($this->schema[$tableID]['columns'][$columnName]['url'], '%s')
							? sprintf($this->schema[$tableID]['columns'][$columnName]['url'], $arr[$columnName])
							: $this->schema[$tableID]['columns'][$columnName]['url'])));
					$worksheet->getCell($this->columnCode($j).($i+2+$firstRow+1))->getHyperlink()->setTooltip(
						$this->schema[$tableID]['columns'][$columnName]['databaseName'].' Entry: '.$arr[$columnName]);
				}elseif (!isset($_SESSION['UserName']) &&
					$this->schema[$tableID]['columns'][$columnName]['format'] == 'url' &&
					$arr[$columnName]){
					$worksheet->getCell($this->columnCode($j).($i+2+$firstRow+1))->getHyperlink()->setUrl($this->encodeURL($arr[$columnName]));
					$worksheet->getCell($this->columnCode($j).($i+2+$firstRow+1))->getHyperlink()->setTooltip("Website: ".$arr[$columnName]);
				}
			}

			if(false && isset($_SESSION['UserName'])){
				$worksheet->setSharedStyle($protectedFormat, $this->columnCode($j++).($i+2+$firstRow+1));
				$worksheet->setCellValueExplicitByColumnAndRow($j, $i+2+$firstRow+1, $object->error, PHPExcel_Cell_DataType::TYPE_STRING);
				$worksheet->setSharedStyle($protectedFormat, $this->columnCode($j++).($i+2+$firstRow+1));
				$worksheet->setCellValueExplicitByColumnAndRow($j, $i+2+$firstRow+1, join(' ',$object->warning), PHPExcel_Cell_DataType::TYPE_STRING);
			}

			//row height
			$worksheet->getRowDimension($i + 2 + $firstRow + 1)->setRowHeight(15);

			//left, right border
			$worksheet->getStyle($this->columnCode(0).($i+2+$firstRow+1))->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle($this->columnCode(isset($_SESSION['UserName']) + 0).($i+2+$firstRow+1))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle($this->columnCode($j).($i+2+$firstRow+1))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		}

		//left, right border
		$worksheet->getStyle($this->columnCode(0).($firstRow+2))->getBorders()->getLeft()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		$worksheet->getStyle($this->columnCode(isset($_SESSION['UserName']) + 0).($firstRow+2))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		$worksheet->getStyle($this->columnCode($j).($firstRow+2))->getBorders()->getRight()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);

		//top, bottom border
		for ($j=0; $j <= $nCols; $j++){
			$worksheet->getStyle($this->columnCode($j).($firstRow+2))->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle($this->columnCode($j).($firstRow+2))->getBorders()->getTop()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
			$worksheet->getStyle($this->columnCode($j).($nRows+2+$firstRow))->getBorders()->getBottom()->setBorderStyle(PHPExcel_Style_Border::BORDER_THICK);
		}

		//printing
		$worksheet->getPageSetup()->setRowsToRepeatAtTopByStartAndEnd($firstRow+2, $firstRow+2);
		$worksheet->getPageSetup()->setColumnsToRepeatAtLeftByStartAndEnd($this->columnCode(0), $this->columnCode(isset($_SESSION['UserName'])));
		$worksheet->getPageSetup()->setPrintArea($this->columnCode(0).($firstRow+2).':'.$this->columnCode($nCols).($nRows+2+$firstRow));
	}

	function importXLS($mode = 'html', $autoMap = false){
		$errorList = null;
		$warningList = null;

		//create excel reader
		$xlsReader = PHPExcel_IOFactory::createReader('Excel2007');
		$xlsReader->setReadDataOnly(true);

		//read workbook
		$workbook = $xlsReader->load($this->configuration['knowledgeBaseRead']);

		//read tables
		$duplicateWholeCellModelIDs = array_keys($this->wholeCellModelIDs);
		foreach ($workbook->getWorksheetIterator() as $worksheet) {
			$tableID = $worksheet->getTitle();
			if (!array_key_exists($tableID, $this->schema))
				continue;
			$table = $this->schema[$tableID];

			if ($table['writeAsColumn']){
				$this->importXLS_TableAsColumn($worksheet);
			}else{
				$this->importXLS_TableAsRows($worksheet, $tableID);
			}
		}

		//cleanup
		unset($xlsReader);
		unset($workbook);

		//read whole cell model ids
		if ($mode == 'commandLine'){
			foreach ($this->schema as $tableID => $table){
				if ($table['noCommit']) continue;
				foreach ($this->$tableID as $idx => $object){
					$this->wholeCellModelIDs[$object->wholeCellModelID] = array(
						'TableID' => $tableID,
						'WID' => $object->wid,
						'WholeCellModelID' => $object->wholeCellModelID,
						'Name' => $object->name);
						
					if ($tableID == 'references')
						$this->referenceWholeCellModelIDs[$object->wholeCellModelID] = $object->wholeCellModelID;
				}
			}
		}
			
		//empirical formulas
		$this->metaboliteEmpiricalFormulas = array();
		foreach ($this->metabolites as $metabolite){
			$this->metaboliteEmpiricalFormulas[$metabolite->wholeCellModelID] =
				$this->parseEmpiricalFormula($metabolite->empiricalFormula);
		}

		//monomer-complexs
		$this->monomerComplexs = array();
		foreach ($this->proteinMonomers as $proteinMonomer){
			if ($proteinMonomer->complex){
				$this->monomerComplexs[$proteinMonomer->wholeCellModelID] =
					explode(';', $proteinMonomer->complex);
			}
		}

		//molecule compartments
		$this->moleculeCompartments = array();
		foreach (array_merge($this->genes, $this->transcriptionUnits, $this->proteinMonomers, $this->proteinComplexs) as $molecule){
			$this->moleculeCompartments[$molecule->wholeCellModelID] = $molecule->compartment;
		}

		//basic property validation
		$errors = array();
		$warnings = array();
		foreach ($this->schema as $tableID => $table){
				if ($table['noCommit']) continue;
				foreach ($this->$tableID as $idx => $object){
					list($error, $warning) = $object->validate($mode);
					if ($error !== true)
						array_push($errors, sprintf("%s '%s': %s", $tableID, $object->wholeCellModelID, $error));
					if ($warning !== true){
						if (!is_array($warning))
							$warning = array($warning);
						foreach ($warning as $msg)
							array_push($warnings, sprintf("%s '%s': %s", $tableID, $object->wholeCellModelID, $msg));
					}
				}
		}
		$errorList .= $this->formatError($mode, "The following properties errors were found", $errors);
		$warningList .= $this->formatError($mode, "The following properties warnings were found", $warnings, true);

		if ($mode == 'html')
			return array(($errorList == "" ? true : $errorList), ($warningList == "" ? true : $warningList));

		//validate protein monomer <==> mRNA gene
		$mRNAGenes = array();
		foreach ($this->genes as $gene){
				if($gene->type == 'mRNA')
					array_push($mRNAGenes, $gene->wholeCellModelID);
		}

		$proteinMonomers = array();
		foreach ($this->proteinMonomers as $proteinMonomer){
				preg_match('/^([a-z][a-z0-9_]*)\[([a-z][a-z0-9_]*)\]$/i', $proteinMonomer->gene, $match);
				array_push($proteinMonomers, $match[1]);
		}

		$errorList .= $this->formatError($mode, "The following mRNA genes were not linked to protein monomers", array_diff($mRNAGenes, $proteinMonomers));
		$errorList .= $this->formatError($mode, "The following non-mRNA genes were linked to protein monomers", array_diff($proteinMonomers, $mRNAGenes));
		$errorList .= $this->formatError($mode, "The following mRNA genes were linked to multiple protein monomers", filter_by_value(array_count_values($proteinMonomers),1));

		//validate genes <==> transcription unit
		$genes = array();
		foreach ($this->genes as $gene)
				array_push($genes, $gene->wholeCellModelID);

		$transcriptionUnits = array();
		foreach ($this->transcriptionUnits as $transcriptionUnit){
				$geneCompartments = explode(';', $transcriptionUnit->genes);
				foreach ($geneCompartments as $geneCompartment){
					preg_match('/^([a-z][a-z0-9_]*)\[([a-z][a-z0-9_]*)\]$/i', $geneCompartment, $match);
					array_push($transcriptionUnits, $match[1]);
				}
		}

		$errorList .= $this->formatError($mode, "The following genes are not in any transcription unit", array_diff($genes, $transcriptionUnits));
		$errorList .= $this->formatError($mode, "The following genes are in multiple transcription units", filter_by_value(array_count_values($transcriptionUnits),1));

		//auto map metabolites
		if ($autoMap)
			$this->autoMapMetabolites();

		//auto map reactions
		if ($autoMap)
			$this->autoMapReactions();

		return array(($errorList == "" ? true : $errorList), ($warningList == "" ? true : $warningList));
	}

	function importXLS_TableAsColumn($worksheet){
		$arr = array();
		for($i = 1; $i <= $worksheet->getHighestRow(); $i++){
			$arr[$worksheet->getCellByColumnAndRow(0, $i)->getValue()] =
				$worksheet->getCellByColumnAndRow(1, $i)->getValue();
		}
		$this->loadFromArray($arr);
	}

	function importXLS_TableAsRows($worksheet, $tableID){
		for($i = 2; $i <= $worksheet->getHighestRow(); $i++){
			$arr = array();

			for($j = 0; $j <= $this->columnIndex($worksheet->getHighestColumn()); $j++){
				$arr[$worksheet->getCellByColumnAndRow($j, 1)->getValue()] =
					$worksheet->getCellByColumnAndRow($j, $i)->getValue();
			}

			$object = new $this->schema[$tableID]['class']($i-2, $tableID, $this);
			$object->loadFromArray($arr);
			array_push($this->$tableID, $object);
		}
	}

	function exportXML($tableIDs){
		//initialize xml
		$xml  = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
		$xml .= "<knowledgebase>\n";

		foreach($tableIDs as $tableID){
			$xml .= "	<$tableID>\n";

			$link = databaseConnect($this->configuration);
			$result = mysql_query(sprintf("CALL get_%s%s(%d, null)", $tables[$tableID]['BioWarehouseProcedure'],( $tables[$tableID]['writeAsColumn'] ? "" : 's'), $KnowledgeBaseWID)) or die(mysql_error());
			while ($row = mysql_fetch_array($result, MYSQL_ASSOC)){
				if (!$tables[$tableID]['writeAsColumn']) $xml .= "		<".substr($tableID, 0, -1).">\n";
				foreach ($tables[$tableID]['columns'] as $columnID => $column){
					//$xml.="	  <$key>".str_replace(array("&",">","<"),array("&amp;","&gt;","&lt;"),utf8_decode($val))."</$key>\n";
					$xml .= "			<$columnID>";
					switch ($column['type']){
						case 'string': $xml .= "<![CDATA[".utf8_decode($row[$columnID])."]]>"; break;
						case 'numeric': $xml .= $row[$columnID]; break;
					}
					$xml.="			</$columnID>\n";
				}
				if (!$tables[$tableID]['writeAsColumn']) $xml .= "		</".substr($tableID, 0, -1).">\n";
			}
			mysql_close($link);

			$xml .= "  </$tableID>\n";
		}

		$xml .= "</knowledgebase>";

		return $xml;
	}

	function exportMetabolicMapSVG(){
		$svg = '';
		$map = '';

		//style
		$metaboliteRadius = 5;
		$reactionLabelSize = 10;
		$reactionValueSize = 10;
		$metaboliteFillColor = '#666666';
		$metaboliteStrokeColor = '#000000';
		$reactionStrokeColor = '#000000';

		$metabolicMapMinX = $this->statistic->metabolicMapMinX - $metaboliteRadius;
		$metabolicMapMinY = $this->statistic->metabolicMapMinY - $metaboliteRadius;
		$metabolicMapMaxX = $this->statistic->metabolicMapMaxX + $metaboliteRadius;
		$metabolicMapMaxY = $this->statistic->metabolicMapMaxY + $metaboliteRadius;

		$width  = $metabolicMapMaxX - $metabolicMapMinX;
		$height = $metabolicMapMaxY - $metabolicMapMinY;
		$scale = 785 / $width;

		//reactions
		foreach ($this->metabolicMapReactions as $reaction){
			$svg .= sprintf("   <a target=\"_top\" xlink:href=\"../index.php?KnowledgeBaseID=%s&amp;WholeCellModelID=%s\">\n",
				$this->wholeCellModelID, $reaction->wholeCellModelID);
			$svg .= sprintf("	   <path id=\"%s:%s\" style=\"marker-end:url(#Arrow2Lend);\" d=\"%s\"/>\n",
				$reaction->wholeCellModelID, $reaction->reaction, $reaction->path);
			$svg .= sprintf("	   <text class=\"label\" id=\"label:%s\" x=\"%f\" y=\"%f\">%s</text>\n",
				$reaction->wholeCellModelID,
				$reaction->labelX, $reaction->labelY,
				$reaction->reaction);
			//$svg.=sprintf("	   <text class=\"value\" id=\"value:%s\" x=\"%s\" y=\"%s\">%s</text>\n",
			//	$reaction->wholeCellModelID,
			//	$reaction->valueX, $reaction->valueY,
			//	$value);
			$svg .= sprintf("   </a>\n");

			$map .= sprintf("<area href=\"index.php?KnowledgeBaseID=%s&amp;WholeCellModelID=%s\" alt=\"%s\" title=\"%s\" shape=\"rect\" coords=\"%d,%d,%d,%d\"/>\n",
				$this->wholeCellModelID, $reaction->wholeCellModelID,
				$reaction->wholeCellModelID.($reaction->name ? ": ".$reaction->name : "" ),
				$reaction->wholeCellModelID.($reaction->name ? ": ".$reaction->name : "" ),
				(($reaction->labelX - 3 * $reactionLabelSize) - $metabolicMapMinX) * $scale, (($reaction->labelY - 2 * $reactionLabelSize) - $metabolicMapMinY) * $scale,
				(($reaction->labelX + 0 * $reactionLabelSize) - $metabolicMapMinX) * $scale, (($reaction->labelY - 1 * $reactionLabelSize) - $metabolicMapMinY) * $scale);
		}

		//metabolites
		foreach ($this->metabolicMapMetabolites as $metabolite){
		  $svg .= sprintf("   <a target=\"_top\" xlink:href=\"../index.php?KnowledgeBaseID=%s&amp;WholeCellModelID=%s\">\n",
			  $this->wholeCellModelID, $metabolite->wholeCellModelID);
		  $svg .= sprintf("	   <g>\n");
		  $svg .= sprintf("		  <ellipse id=\"%s:%s:%s\" cx=\"%f\" cy=\"%f\" rx=\"%f\" ry=\"%f\"/>\n",
			  $metabolite->wholeCellModelID, $metabolite->metabolite, $metabolite->compartment,
			  $metabolite->x, $metabolite->y,
			  $metaboliteRadius, $metaboliteRadius);
		  $svg .= sprintf("		  <text id=\"label:%s:%s:%s\" x=\"%f\" y=\"%f\" class=\"value\">%s</text>\n",
			  $metabolite->wholeCellModelID, $metabolite->metabolite, $metabolite->compartment,
			  $metabolite->x, ($metabolite->y+.3*$reactionLabelSize),
			  $metabolite->metabolite);
		  $svg .= sprintf("	   </g>\n");
		  $svg .= sprintf("   </a>\n");

		  $map .= sprintf("<area href=\"index.php?KnowledgeBaseID=%s&amp;WholeCellModelID=%s\" alt=\"%s\" title=\"%s\" shape=\"circle\" coords=\"%d,%d,%d\"/>\n",
				$this->wholeCellModelID, $metabolite->wholeCellModelID,
				$metabolite->wholeCellModelID . ($metabolite->name ? ": ".$metabolite->name : "" ),
				$metabolite->wholeCellModelID . ($metabolite->name ? ": ".$metabolite->name : "" ),
				(($metabolite->x - $metaboliteRadius) - $metabolicMapMinX) * $scale,
				(($metabolite->y + $metaboliteRadius) - $metabolicMapMinY) * $scale,
				$metaboliteRadius * $scale);
		}

		$reactionLabelSize .= 'px';
		$reactionValueSize .= 'px';
		$metaboliteFillColor = str_replace('0x', '#', $metaboliteFillColor);
		$metaboliteStrokeColor = str_replace('0x', '#', $metaboliteStrokeColor);
		$reactionStrokeColor = str_replace('0x', '#', $reactionStrokeColor);
		$reactionStrokeWeight = '1px';
		$metaboliteStrokeWeight = '1px';

		$width = 785;
		$height = round($height * $scale);

		$svg = <<<ENDSVG
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   viewBox="$metabolicMapMinX $metabolicMapMinY $metabolicMapMaxX $metabolicMapMaxY" width="$width" height="$height">
  <style type="text/css">
	path{
	  stroke:$reactionStrokeColor;
	  stroke-width:$reactionStrokeWeight;
	  fill:none;
	}
	ellipse{
	  stroke:$metaboliteStrokeColor;
	  stroke-width:$metaboliteStrokeWeight;
	  fill:$metaboliteFillColor;
	}
	text{
	  font-family:Arial, "sans-serif";
	  text-anchor:middle;
	  alignment-baseline:middle;
	}
	text.label{
	  font-size:$reactionLabelSize;
	}
	text.value{
	  font-size:$reactionValueSize;
	}
	tspan.sub{
	  font-size:60%;
	}
  </style>
  <defs>
	<marker orient="auto" id="Arrow2Lend" style="overflow:visible;">
	  <path
		 d="M 8.7185878,4.0337352 L -2.2072895,0.016013256 L 8.7185884,-4.0017078 C 6.97309,-1.6296469 6.9831476,1.6157441 8.7185878,4.0337352 z"
		 transform="matrix(-1.1,0,0,-1.1,-1.1,0)"
		 style="stroke-width:1;fill:#000000;"/>
	</marker>
  </defs>
$svg
</svg>
ENDSVG;

		file_put_contents($this->configuration['metabolicMap'].".svg", str_replace("\r\n", "\n", $svg));
		file_put_contents($this->configuration['metabolicMap'].".map", $map);

		exec(sprintf('lib/inkscape/inkscape -f %s --export-png=%s --export-area-page',
			$this->configuration['metabolicMap'].".svg",
			$this->configuration['metabolicMap'].".png"));
	}

	function importMetabolicMapSVG(){
		//styles
		$metaboliteRadius = 5;
		$reactionLabelSize = 10;
		$reactionValueSize = 10;

		// read svg file
		$svg = new DOMDocument();
		$svg->load($this->configuration['metabolicMap'].".svg");

		$metabolicMapMinX = $metabolicMapMinY =	pow(10, 6);
		$metabolicMapMaxX = $metabolicMapMaxY = -1 * pow(10, 6);

		$metabolicMapReactions = array();
		$metabolicMapMetabolites = array();

		$reactions = $svg->getElementsByTagName("path");
		for($i = 0; $i < $reactions->length; $i++){
			if ($reactions->item($i)->getAttribute("d") == "M 8.7185878,4.0337352 L -2.2072895,0.016013256 L 8.7185884,-4.0017078 C 6.97309,-1.6296469 6.9831476,1.6157441 8.7185878,4.0337352 z" || substr($reactions->item($i)->getAttribute("id"), 0, 4) == "path") continue;

			$path=preg_replace('/(\d+)\.\d+/e', '\1', $reactions->item($i)->getAttribute("d"));

			list($wholeCellModelID, $reaction) = explode(':', $reactions->item($i)->getAttribute("id"));

			$texts = $svg->getElementsByTagName("text");
			for ($j = 0; $j < $texts->length; $j++){
				list($type, $id) = explode(':', $texts->item($j)->getAttribute("id"));
				if ($id != $wholeCellModelID) continue;
				$x = round($texts->item($j)->getAttribute("x"));
				$y = round($texts->item($j)->getAttribute("y"));
				switch ($type){
					case 'label':
						$labelX = $x;
						$labelY = $y;
						break;
					case 'value':
						$valueX = $x;
						$valueY = $y;
						break;
				}
			}

			$object = new MetabolicMapReaction($i, 'metabolicMapReactions', $this);
			$object->wholeCellModelID = $wholeCellModelID;
			$object->reaction = $reaction;
			$object->path = $path;
			$object->labelX = $labelX;
			$object->labelY = $labelY;
			$object->valueX = $valueX;
			$object->valueY = $valueY;
			array_push($metabolicMapReactions, $object);

			$tmp = explode(" ",$path);
			list($startX, $startY) = explode(",", $tmp[1]);
			list($endX, $endY) = explode(",", array_pop($tmp));

			$metabolicMapMinX = min($metabolicMapMinX, min($startX,$endX) - $ReactionStrokeWeight);
			$metabolicMapMaxX = max($metabolicMapMaxX, max($startX,$endX) + $ReactionStrokeWeight);
			$metabolicMapMinY = min($metabolicMapMinY, min($startY,$endY) - $ReactionStrokeWeight, $labelY, $valueY);
			$metabolicMapMaxY = max($metabolicMapMaxY, max($startY,$endY) + $ReactionStrokeWeight, $labelY + $reactionLabelSize, $valueY + $reactionValueSize);
		}

		$metabolites = $svg->getElementsByTagName("ellipse");
		for ($i = 0; $i < $metabolites->length; $i++){
			if(substr($metabolites->item($i)->getAttribute("id"), 0, 7) == "ellipse") continue;
			$x = round($metabolites->item($i)->getAttribute("cx"));
			$y = round($metabolites->item($i)->getAttribute("cy"));

			list($wholeCellModelID, $metabolite, $compartment) = explode(':', $metabolites->item($i)->getAttribute("id"));

			$object = new MetabolicMapMetabolite($i, 'metabolicMapMetabolites', $this);
			$object->wholeCellModelID = $wholeCellModelID;
			$object->metabolite = $metabolite;
			$object->compartment = $compartment;
			$object->x = $x;
			$object->y = $y;
			array_push($metabolicMapMetabolites, $object);

			$metabolicMapMinX = min($metabolicMapMinX, $x - $metaboliteRadius);
			$metabolicMapMaxX = max($metabolicMapMaxX, $x + $metaboliteRadius);
			$metabolicMapMinY = min($metabolicMapMinY, $y - $metaboliteRadius);
			$metabolicMapMaxY = max($metabolicMapMaxY, $y + $metaboliteRadius);
		}

		$this->statistic->metabolicMapMinX = $metabolicMapMinX;
		$this->statistic->metabolicMapMinY = $metabolicMapMinY;
		$this->statistic->metabolicMapMaxX = $metabolicMapMaxX;
		$this->statistic->metabolicMapMaxY = $metabolicMapMaxY;
		$this->metabolicMapReactions = $metabolicMapReactions;
		$this->metabolicMapMetabolites = $metabolicMapMetabolites;
	}

	function exportGenomeBrowserSVG($tableID = 'genes'){
		//style
		$genomeStrokeWidth = 2;
		$unitStrokeWidth = 1;
		$genomeStrokeColor = '#000000';
		$unitStrokeColors =array(
			'#3366FF', '#6633FF', '#CC33FF', '#FF33CC',
			'#33CCFF', '#003DF5', '#002EB8', '#FF3366',
			'#33FFCC', '#B88A00', '#F5B800', '#FF6633',
			'#33FF66', '#66FF33', '#CCFF33', '#FFCC33');
		$labelSize = 10;
		$unitFillOpacity = 0.3;
		$unitStrokeOpacity = 1.0;

		$width = 785 - $genomeStrokeWidth - 1;
		$height = 600;

		$aspectRatio = 1;
		$margin = 0.4;
		$a = (1 + $margin);
		$b = -$margin;
		$c = -$height / $width * count($this->$tableID) * $aspectRatio;
		$arrowLength = 5;

		$rows = ceil((-$b + sqrt(pow($b, 2) - 4 * $a * $c)) / (2 * $a));
		$unitWidth = $rows * $width / count($this->$tableID);
		$unitHeight = $height / ($rows * (1 + $margin) - $margin);
		$basesPerRow = $this->genomeLength / $rows;
		$widthPerBase = $width / $basesPerRow;

		$genome = "";
		for ($i = 0; $i < $rows; $i++)
			$genome .= "  <line class=\"genome\" x1=\"0\" x2=\"$width\" y1=\"".($unitHeight * ($i + 1 + $i * $margin) + $genomeStrokeWidth)."\" y2=\"".($unitHeight * ($i + 1 + $i * $margin) + $genomeStrokeWidth)."\"/>\n";

		$units = "";
		$unitMap = "";
		$objects = $this->$tableID;
		for ($i = 0; $i < count($objects); $i++) {
			$row = floor($objects[$i]->coordinate / $this->genomeLength * $rows);
			$y = $row * $unitHeight * (1 + $margin);
			$x = ($objects[$i]->coordinate-$row * $basesPerRow) * $widthPerBase;
			$w = $objects[$i]->length * $widthPerBase;
			$h = $unitHeight;
			$color = $unitStrokeColors[$i % count($unitStrokeColors)];

			if ($objects[$i]->direction == 'forward'){
				$points = sprintf("%f,%f %f,%f %f,%f %f,%f %f,%f",
					$x, $y,
					min($width, $x + max(0, $w - $arrowLength)), $y,
					min($width, $x + $w), $y + $h / 2,
					min($width, $x + max(0, $w - $arrowLength)), $y + $h,
					$x, $y + $h);
				$points2 = sprintf("%f,%f %f,%f %f,%f %f,%f %f,%f",
					0, $y + $unitHeight * (1 + $margin),
					max(0, ($x + $w) - $width - $arrowLength), $y + $unitHeight * (1 + $margin),
					($x + $w) - $width, $y + $h / 2 + $unitHeight * (1 + $margin),
					max(0, ($x + $w) - $width - $arrowLength), $y + $h + $unitHeight * (1 + $margin),
					0, $y + $h + $unitHeight * (1 + $margin));
			}else{
				$points = sprintf("%f,%f %f,%f %f,%f %f,%f %f,%f",
					$x, $y + $h/2,
					min($width, $x + $arrowLength), $y,
					min($width, $x + $w), $y,
					min($width, $x + $w), $y + $h,
					min($width, $x + $arrowLength), $y + $h);
				$points2 = sprintf("%f,%f %f,%f %f,%f %f,%f %f,%f",
					0, $y + $h / 2 + $unitHeight * (1 + $margin),
					max(0, $x + $arrowLength - $width), $y + $unitHeight * (1 + $margin),
					$x + $w - $width, $y + $unitHeight * (1 + $margin),
					$x + $w - $width, $y + $h + $unitHeight * (1 + $margin),
					max(0, $x + $arrowLength - $width), $y + $h + $unitHeight * (1 + $margin));
			}

			$units .= "  <a xlink:href=\"../index.php?KnowledgeBaseID=".$this->wholeCellModelID."&amp;WholeCellModelID=".$objects[$i]->wholeCellModelID."\" target=\"_top\">\n";
			$units .= "	  <g>\n";
			$units .= "		<polygon class=\"unit\" points=\"$points\" style=\"fill:$color;stroke:$color;\"/>\n";
			if ($x + $w > $width)
				$units .= "		  <polygon class=\"unit\" points=\"$points2\" style=\"fill:$color;stroke:$color;\"/>\n";
			$units .= "		  <text x=\"" . ($x + $w / 2) . "\" y=\"" . ($y + $h / 2 + 0.4 * $labelSize) . "\">" . $objects[$i]->wholeCellModelID."</text>\n";
			$units .= "	  </g>\n";
			$units .= "  </a>\n";

			$unitMap .= sprintf("<area href=\"index.php?KnowledgeBaseID=%s&amp;WholeCellModelID=%s\" alt=\"%s\" title=\"%s\" shape=\"poly\"  coords=\"%s\"/>\n",
				$this->wholeCellModelID, $objects[$i]->wholeCellModelID,
				$objects[$i]->wholeCellModelID.($objects[$i]->name ? ': '.$objects[$i]->name : ""),
				$objects[$i]->wholeCellModelID.($objects[$i]->name ? ': '.$objects[$i]->name : ""),
				str_replace(" ", ",", preg_replace('/(\d+)\.(\d+)/e', '\1', $points)));
			if ($x + $w > $width)
				$unitMap .= sprintf("<area href=\"index.php?KnowledgeBaseID=%s&amp;WholeCellModelID=%s\" alt=\"%s\" title=\"%s\" shape=\"poly\"  coords=\"%s\"/>\n",
					$this->wholeCellModelID, $objects[$i]->wholeCellModelID,
					$objects[$i]->wholeCellModelID.($objects[$i]->name ? ': '.$objects[$i]->name : ""),
					$objects[$i]->wholeCellModelID.($objects[$i]->name ? ': '.$objects[$i]->name : ""),
					str_replace(" ", ",", preg_replace('/(\d+)\.(\d+)/e', '\1', $points2)));
		}

		$genomeStrokeWidth .= 'px';
		$unitStrokeWidth .= 'px';
		$labelSize .= 'px';
		$genomeStrokeColor = str_replace('0x', '#', $genomeStrokeColor);

		$height += $genomeStrokeWidth+1;

		$svg = <<<ENDSVG
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   viewBox="0 0 $width $height" width="$width" height="$height">
  <style type="text/css">
	line.genome{
	  stroke:$genomeStrokeColor;
	  stroke-width:$genomeStrokeWidth;
	  fill:none;
	}
	polygon.unit{
	  stroke-width:$unitStrokeWidth;
	  fill-opacity:$unitFillOpacity;
	  stroke-opacity:$unitStrokeOpacity;
	}
	text{
	  font-family:Arial, "sans-serif";
	  text-anchor:middle;
	  alignment-baseline:middle;
	}
	text{
	  font-size:$labelSize;
	}
	tspan.sub{
	  font-size:60%;
	}
  </style>
<g id="genome">
$genome
</g>
<g id="units">
$units
</g>
</svg>
ENDSVG;

		file_put_contents($this->configuration['genomeBrowser'][$tableID].".svg", str_replace("\r\n", "\n", $svg));
		file_put_contents($this->configuration['genomeBrowser'][$tableID].".map", $unitMap);

		exec(sprintf('lib/inkscape/inkscape -f %s --export-png=%s --export-area-page',
			$this->configuration['genomeBrowser'][$tableID].".svg",
			$this->configuration['genomeBrowser'][$tableID].".png"));
	}

	function exportReferencesBibTex(){
		$bibtex = array();

		//referencs
		foreach ($this->references as $reference) {
			switch ($reference->type){
				case 'article':
					array_push($bibtex, $this->formatReferenceBibTex_Article($reference));
					break;
				case 'book':
					array_push($bibtex, $this->formatReferenceBibTex_Book($reference));
					break;
				case 'misc':
					array_push($bibtex, $this->formatReferenceBibTex_Misc($reference));
					break;
				case 'thesis':
					array_push($bibtex, $this->formatReferenceBibTex_Thesis($reference));
					break;
			}
		}
		
		//empty references
		$maxID = 0;
		$refIDs = array();
		foreach($this->references as $reference){
			$id = substr($reference->wholeCellModelID, 4)+0;
			$maxID = max($maxID, $id);
			array_push($refIDs, $id);
		}
		
		for($i = 1; $i<= $maxID; $i++){
			if(array_search($i, $refIDs) === false){
				array_push($bibtex, sprintf("@MISC{PUB_%04d,\n\tnote = {empty reference to get numbering correct}\n}", $i, $i));
			}
		}

		//save file
		file_put_contents($this->configuration['bibtex'], str_replace(array("\r\n"), array("\n"), join("\n\n", $bibtex)));
	}

	function formatReferenceBibTex_Article($reference){
		$result = "";		

		if ($reference->authors) {
			$result = $result.",\n\tAUTHOR  = {".$this->formatReferenceBibTex_Authors($reference->authors)."}";
		}
		if ($reference->title) {
			$result = $result.",\n\tTITLE   = \"{".str_replace(array("_", "&"), array("\\_", "\&"), $reference->title)."}\"";
		}
		if ($reference->publication) {
			$result = $result.",\n\tJOURNAL = {".str_replace("&", "\&", $reference->publication)."}";
		}
		if ($reference->year) {
			$result = $result.",\n\tYEAR	= {".$reference->year."}";
		}
		if ($reference->volume) {
			$result = $result.",\n\tVOLUME  = {".$reference->volume."}";
		}
		if ($reference->issue) {
			$result = $result.",\n\tNUMBER  = {".$reference->issue."}";
		}
		if ($reference->pages) {
			$result = $result.",\n\tPAGES   = {".$reference->pages."}";
		}
		if ($reference->crossReference->pmid) {
			$result = $result.",\n\teprint  = {".$reference->crossReference->pmid."}";
			$result = $result.",\n\teprinttype = {pubmed}";
		}
		if ($reference->url) {
			$result = $result.",\n\tURL = {".$reference->url."}";
		}

		return "@ARTICLE{".$reference->wholeCellModelID.$result."\n}";
	}

	function formatReferenceBibTex_Book($reference){
		$result = "";

		if ($reference->editors) {
			$result = $result.",\n\tEDITOR	= {".$this->formatReferenceBibTex_Authors($reference->editors)."}";
		}elseif ($reference->authors) {
			$result = $result.",\n\tAUTHOR	= {".$this->formatReferenceBibTex_Authors($reference->authors)."}";
		}
		if ($reference->title) {
			$result = $result.",\n\tTITLE	 = \"{".str_replace(array("_", "&"), array("\\_", "\&"), $reference->title)."}\"";
		}
		if ($reference->year) {
			$result = $result.",\n\tYEAR	  = {".$reference->year."}";
		}
		if ($reference->volume) {
			$result = $result.",\n\tVOLUME	= {".$reference->volume."}";
		}
		if ($reference->publisher) {
			$result = $result.",\n\tPUBLISHER = {".str_replace("&", "\&", $reference->publisher)."}";
		}
		if ($reference->crossReference->isbn) {
			$result = $result.",\n\tISBN	  = {".$reference->crossReference->isbn."}";
		}
		if ($reference->url) {
			$result = $result.",\n\tURL = {".$reference->url."}";
		}

		return "@BOOK{".$reference->wholeCellModelID.$result."\n}";
	}

	function formatReferenceBibTex_Misc($reference){
		$result = "";

		if ($reference->authors) {
			$result = $result.",\n\tAUTHOR	   = {".$this->formatReferenceBibTex_Authors($reference->authors)."}";
		}
		if ($reference->title) {
			$result = $result.",\n\tTITLE		= \"{".str_replace(array("_", "&"), array("\\_", "\&"), $reference->title)."}\"";
		}
		if ($reference->year) {
			$result = $result.",\n\tYEAR		 = {".$reference->year."}";
		}
		if ($reference->url) {
			$result = $result.",\n\tURL = {".$reference->url."}";
		}

		return "@MISC{".$reference->wholeCellModelID.$result."\n}";
	}

	function formatReferenceBibTex_Thesis($reference){
		$result = "";

		if ($reference->authors) {
			$result = $result.",\n\tAUTHOR = {".$this->formatReferenceBibTex_Authors($reference->authors)."}";
		}
		if ($reference->title) {
			$result = $result.",\n\tTITLE  = \"{".str_replace(array("_", "&"), array("\\_", "\&"), $reference->title)."}\"";
		}
		if ($reference->year) {
			$result = $result.",\n\tYEAR   = {".$reference->year."}";
		}
		if ($reference->publisher) {
			$result = $result.",\n\tSCHOOL = {".str_replace("&", "\&", $reference->publisher)."}";
		}
		if ($reference->url) {
			$result = $result.",\n\tURL = {".$reference->url."}";
		}

		return "@PHDTHESIS{".$reference->wholeCellModelID.$result."\n}";
	}

	/*
	echo $knowledgeBase->formatReferenceBibTex_Authors('Karr JR'). "\n";
	echo $knowledgeBase->formatReferenceBibTex_Authors('Karr JR 3rd'). "\n";
	echo $knowledgeBase->formatReferenceBibTex_Authors('Covert MW, Karr JR 3rd'). "\n";
	echo $knowledgeBase->formatReferenceBibTex_Authors('Covert MW, Karr JR 3rd, Covert MW'). "\n";
	echo $knowledgeBase->formatReferenceBibTex_Authors('Covert MW, von der Karr JR 3rd, Covert MW'). "\n";
	*/
	function formatReferenceBibTex_Authors($authorsStr){
		$authors = explode(", ", $authorsStr);
		foreach ($authors as $idx => $author){		
			$names = explode(" ", $author);
			for ($fNameIdx = 0; $fNameIdx <count($names); $fNameIdx++){
				if (strcmp(strtoupper($names[$fNameIdx ]), $names[$fNameIdx]) == 0){
					break;
				}
			}
			$lastName = join(" ", array_slice($names, 0, $fNameIdx ));
			$tmpFirstName = $names[$fNameIdx ];
			$firstName = "";
			for ($i = 0; $i < strlen($tmpFirstName); $i++){
				$firstName = $firstName.$tmpFirstName[$i].". ";
			}
			$firstName = trim($firstName);

			$suffix = join(" ", array_slice($names, $fNameIdx + 1, count($names) - $fNameIdx - 1));
			$authors[$idx] = "$lastName".($firstName ? ", $firstName".($suffix ? " $suffix" : "") : "");								
		}		
		return join(" and ", $authors);
	}

	function selectWID(){
		$link = databaseConnect($this->configuration);
		$result = mysql_query("CALL get_knowledgebases('WholeCell','Y');") or die(mysql_error());

		echo sprintf("%3s  %-24s  %-7s  %-19s  %-12s\n", "#", "Name", "Version", "Insert Date", "Investigator");
		echo sprintf("%3s  %-24s  %-7s  %-19s  %-12s\n", str_repeat("=", 3), str_repeat("=", 24), str_repeat("=", 7), str_repeat("=", 19), str_repeat("=", 12));
		$knowledgeBases = array();
		$idx = 1;
		while ($knowledgeBase = mysql_fetch_array($result, MYSQL_ASSOC)){
			echo sprintf("%3s  %-24s  %-7s  %-19s  %-12s\n", 
				$idx++,
				substr($knowledgeBase['Name'], 0, min(24, strlen($knowledgeBase['Name']))),
				substr($knowledgeBase['Version'], 0, min(7, strlen($knowledgeBase['Version']))),
				$knowledgeBase['InsertDate'],
				substr($knowledgeBase['Investigator'], 0, min(12, strlen($knowledgeBase['Investigator'])))
				);
			array_push($knowledgeBases, $knowledgeBase);
		}
		mysql_close($link);

		$idx = 0;
		while (!is_int($idx) || $idx < 1 || $idx > count($knowledgeBases)){
				echo "Please select a knowledgeBase: ";
				$idx = $this->getInput() + 0;
				$KnowledgeBaseWID = $knowledgeBases[$idx-1]['WID'];
		}
		$this->wid = $KnowledgeBaseWID;
		return $this->wid;
	}

	function findWID($WID, $WholeCellModelID){
		if (!$WID){
			if ($WholeCellModelID){
				$result = runQuery("SELECT DataSet.WID FROM DataSet JOIN DBID ON DBID.OtherWID=DataSet.WID WHERE DBID.XID='$WholeCellModelID' ORDER BY DataSet.Version DESC, InsertDate DESC, WID DESC LIMIT 1", $this->configuration);
				$WID = $result['WID'];
			}
			if (!$WID){
				$result = runQuery("CALL get_latest_knowledgebase('WholeCell')", $this->configuration);
				$WID = $result['WID'];
			}
		}
		$this->wid = $WID;
		return $this->wid;
	}

	function getObject($WholeCellModelID, $tableID){
		if ($tableID == 'summary'){
			if ($this->wholeCellModelIDs == $WholeCellModelID)
				return this;
			return false;
		}

		foreach ($this->$tableID as $object){
			if ($object->wholeCellModelID == $WholeCellModelID)
				return $object;
		}
		return false;
	}

	function getWholeCellModelIDs(){
		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf("CALL get_wholecellmodelids(%d, null, null)", $this->wid)) or die(mysql_error());
		$this->wholeCellModelIDs = array();
		$this->referenceWholeCellModelIDs = array();
		while ($object = mysql_fetch_array($result)){
			$this->wholeCellModelIDs[$object['WholeCellModelID']] = array(
				'TableID' => $object['TableID'],
				'WID' => $object['WID'],
				'WholeCellModelID' => $object['WholeCellModelID'],
				'Name' => $object['Name']);
			if ($object['TableID'] == 'references')
				$this->referenceWholeCellModelIDs[$object['WholeCellModelID']] = $object['WID'];
		}
		mysql_close($link);
	}

	function getMetaboliteEmpiricalFormulas(){
		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf('call get_metaboliteempiricalformulas(%d, null)', $this->wid))
			or die(mysql_error());
		$this->metaboliteEmpiricalFormulas = array();
		while ($metabolite = mysql_fetch_array($result)){
			$this->metaboliteEmpiricalFormulas[$metabolite['WholeCellModelID']] =
				$this->parseEmpiricalFormula($metabolite['EmpiricalFormula']);
		}
		mysql_close($link);
	}

	function getMonomerComplexs(){
		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf('call get_proteinmonomers(%d, null)', $this->wid))
			or die(mysql_error());
		$this->monomerComplexs = array();
		while ($proteinMonomer = mysql_fetch_array($result)){
			if ($proteinMonomer['Complex']){
				$this->monomerComplexs[$proteinMonomer['WholeCellModelID']] =
					explode(';', $proteinMonomer['Complex']);
			}
		}
		mysql_close($link);
	}

	function getMoleculeCompartments(){
		$this->moleculeCompartments = array();

		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf('call get_genes(%d, null)', $this->wid))
			or die(mysql_error());
		while ($molecule = mysql_fetch_array($result)){
			$this->moleculeCompartments[$molecule['WholeCellModelID']] = $molecule['Compartment'];
		}
		mysql_close($link);

		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf('call get_transcriptionunits(%d, null)', $this->wid))
			or die(mysql_error());
		while ($molecule = mysql_fetch_array($result)){
			$this->moleculeCompartments[$molecule['WholeCellModelID']] = $molecule['Compartment'];
		}
		mysql_close($link);

		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf('call get_proteinmonomers(%d, null)', $this->wid))
			or die(mysql_error());
		while ($molecule = mysql_fetch_array($result)){
			$this->moleculeCompartments[$molecule['WholeCellModelID']] = $molecule['Compartment'];
		}
		mysql_close($link);

		$link = databaseConnect($this->configuration);
		$result = mysql_query(sprintf('call get_proteincomplexs(%d, null)', $this->wid))
			or die(mysql_error());
		while ($molecule = mysql_fetch_array($result)){
			$this->moleculeCompartments[$molecule['WholeCellModelID']] = $molecule['Compartment'];
		}
		mysql_close($link);
	}

	function sortObjectsByWholeCellModelID($TableID){
		$wholeCellModelIDs = array();
		foreach ($this->$TableID as $object)
			array_push($wholeCellModelIDs, $object->wholeCellModelID);
		usort($this->$TableID, array($this, 'objectSortByWholeCellModelIDCallback'));
	}

	function objectSortByWholeCellModelIDCallback($object1, $object2){
		return strnatcasecmp($object1->wholeCellModelID, $object2->wholeCellModelID);
	}

	function readGenomeSequence($fileName){
		return str_replace("\n", "", join("", array_slice(file($fileName), 1)));
	}

	function readProteomeSequence($fileName){
		$file = array_slice(explode(">", file_get_contents($fileName)), 1);
		$sequences = array();
		foreach ($file as $protein){
			$temp = explode("\n", $protein);
			$name = "MG_".substr(array_shift($temp), 3, 3) . "_MONOMER";
			$sequence = join("", $temp);
			$sequences[$name] = $sequence;
		}
		return $sequences;
	}

	function autoMapMetabolites(){
		$metabolicMapMetabolites = $this->metabolicMapMetabolites;

		//get list of mapped metabolites, center map
		$mappedMetabolites = array();
		$minX = Inf;
		$maxX = -Inf;
		$minY = Inf;
		$maxY = -Inf;
		$wholeCellModelIDs = $this->wholeCellModelIDs;
		foreach ($metabolicMapMetabolites as $metabolite){
			array_push($mappedMetabolites, $metabolite->wholeCellModelID);

			unset($wholeCellModelIDs[$metabolite->metabolite]);

			$minX = min($minX, $metabolite->x);
			$maxX = max($maxX, $metabolite->x);
			$minY = min($minY, $metabolite->y);
			$maxY = max($maxY, $metabolite->y);
		}
		$this->statistic->metabolicMapMinX = $minX;
		$this->statistic->metabolicMapMinY = $minY;
		$this->statistic->metabolicMapMaxX = $maxX;
		$this->statistic->metabolicMapMaxY = $maxY;

		//get unmapped metabolites
		$unmappedMetabolites = array();
		foreach ($wholeCellModelIDs as $wholeCellModelID => $arr){
			if ($arr['TableID'] == 'metabolites')
				array_push($unmappedMetabolites, $wholeCellModelID);
		}

		//add unmapped metabolites to map
		$x = $maxX + ($maxX - $minX) / 10;
		$y = $minY;
		$dx = 0;
		$dy = ($maxY - $minY) / (count($unmappedMetabolites) - 1);
		$j = 1;
		foreach ($unmappedMetabolites as $idx => $metabolite){
			while (array_search($wholeCellModelID = sprintf('MetabolicMap_Metabolite_%3d',$j), $mappedMetabolites) !== false)
				$j++;

			$object = new MetabolicMapMetabolite(0, 'metabolicMapMetabolites', $this);
			$object->wholeCellModelID = $wholeCellModelID;
			$object->metabolite = $metabolite;
			$object->x = $x;
			$object->y = $y + $idx * $dy;

			array_push($this->metabolicMapMetabolites, $object);
		}
	}


	function autoMapReactions(){
		$metabolicMapReactions = $this->metabolicMapReactions;

		//get list of mapped reactions
		$mappedReactions = array();
		$wholeCellModelIDs = $this->wholeCellModelIDs;
		foreach($metabolicMapReactions as $reaction){
			array_push($mappedReactions, $reaction->wholeCellModelID);

			unset($wholeCellModelIDs[$reaction->reaction]);
		}

		//get unmapped reactions
		$unmappedReactions = array();
		foreach ($wholeCellModelIDs as $wholeCellModelID => $object){
			if (array_search($object['TableID'], array('reactions')))
				array_push($unmappedReactions, $wholeCellModelID);
		}

		//add unmapped reactions to map
		$minX = $this->statistic->metabolicMapMinX;
		$minY = $this->statistic->metabolicMapMinY;
		$maxX = $this->statistic->metabolicMapMaxX;
		$maxY = $this->statistic->metabolicMapMaxY;
		$x = $maxX + 2 * ($maxX - $minX) / 10;
		$y = $minY;
		$dx = ($maxX - $minX) / 10;
		$dy = ($maxY - $minY) / (count($unmappedReactions)-1);
		$j = 1;
		foreach ($unmappedReactions as $idx => $reaction){
			while (array_search($wholeCellModelID = sprintf('MetabolicMap_Reaction_%3d', $j), $mappedReactions) !== false)
				$j++;

			$object=new MetabolicMapReaction(0, 'metabolicMapReactions', $this);
			$object->wholeCellModelID = $wholeCellModelID;
			$object->reaction = $reaction;
			$object->path = sprintf('M %f,%f L %f,%f', $x, $y+$dy*$idx, $x+$dx, $y+$dy*$idx);
			$object->labelX = $x + $dx / 2;
			$object->labelY = $y + $dy * $idx;
			$object->valueX = $x + $dx / 2;
			$object->valueY = $y + $dy * $idx;

			array_push($this->metabolicMapReactions,$object);
		}
	}

	function writeStatusMessage($msg){
		echo $msg . " " . str_repeat(".", 50 - strlen($msg)) . " ";
	}

	function formatError($mode, $text,$arr){
		if (count($arr) == 0) return;

		switch($mode){
			case 'commandLine':
				$error .= "$text:\n";
				$error .= " - " . join("\n - ", array_unique($arr)) . "\n";
				break;
			case 'html':
				$error .= "<li>$text:\n";
				$error .= "	<ul>\n		<li>" . join("</li>\n		<li>", array_unique($arr)) . "</li>\n	</ul>\n</li>\n";
				break;
		}
		return $error;
	}

	function displayChoice($prompt, $choices){
		$choice = '';
		while (false === array_search(strtoupper($choice), $choices)){
			echo "$prompt ";
			$choice = $this->getInput();
			if ($choice != 'N' && $choice != 'n') return strtoupper($choice);
		}
		exit;
	}

	function getInput(){
		return rtrim(fgets(STDIN));
	}

	function columnCode($idx){
		$idx++;

		$code = '';
		while ($idx > 0){
			$j = (($idx - 1) % 26) + 1;
			$code = chr(65 + $j - 1) . $code;
			$idx -= $j;
			$idx /= 26;
		}

		return $code;
	}

	function columnIndex($code){
		$idx = 0;
		for($i = 0; $i < strlen($code); $i++){
			$idx += pow(26, strlen($code) - $i - 1) * (ord(substr($code, $i, 1)) - 65 + 1);
		}
		return $idx - 1;
	}
	
	function encodeURL($url){
		$url = trim($url);
		$urlparts = explode("?", $url);
		for ($k = 1; $k < count($urlparts); $k++){
			$urlparts[$k] = explode("&", $urlparts[$k]);
			for ($l = 0; $l < count($urlparts[$k]); $l++){
				$urlparts[$k][$l] = join("=", array_map('urlencode', explode("=", $urlparts[$k][$l])));
			}
			$urlparts[$k] = join("&", $urlparts[$k]);
		}
		return join("?", $urlparts);
	}
}
?>
