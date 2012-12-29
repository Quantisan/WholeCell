<?php
/**
 * Description of KnowledgeBaseObject
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class KnowledgeBaseObject {
	const symbol_property_usedInSimulation = "&#8224;";
	const symbol_property_required = "*";
	const symbol_property_calculcated_1 = "a";
	const symbol_property_calculcated_2 = "b";
	const symbol_property_calculcated_3 = "c";
	
	public $tableID;
	public $idx;

	public $wid;
	public $wholeCellModelID;
	public $name;
	public $insertDate;
	public $modifiedDate;
	public $insertUser;
	public $modifiedUser;
	public $comments;

	public $knowledgeBase;
	public $references = array();
	public $crossReference;

	public $count;
	public $statistic;	
	
	public $error = '';
	public $warning = array();

	function  __construct($idx, $tableID, $knowledgeBase = null) {
		$this->idx = $idx;
		$this->tableID = $tableID;
		$this->knowledgeBase = $knowledgeBase;

		$this->crossReference = new stdClass();
		$this->count = new stdClass();
		$this->statistic = new stdClass();
	}

	function loadFromDatabase(){
		//whole cell model id, insert date, modified date, etc.
		$sql = sprintf("CALL get_knowledgebaseobjects(%d, %d)",
			$this->knowledgeBase->wid,
			$this->wid);
		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query($sql);
		if (!$result){
			mysql_close($link);
			return false;
		}elseif (mysql_num_rows($result) > 0){
			$arr = mysql_fetch_array($result, MYSQL_ASSOC);
			$this->wholeCellModelID = $arr['WholeCellModelID'];		
			$this->insertDate = $arr['InsertDate'];	
			$this->modifiedDate = $arr['ModifiedDate'];
			$this->insertUser = $arr['InsertUser'];	
			$this->modifiedUser = $arr['ModifiedUser'];
		}
		mysql_close($link);
	
		//properties
		if ($this->knowledgeBase->schema[$this->tableID]['writeAsColumn'])
			$sql=sprintf("CALL get_%s(%d)", $this->knowledgeBase->schema[$this->tableID]['BioWarehouseProcedure'], $this->knowledgeBase->wid);
		else
			$sql=sprintf("CALL get_%ss(%d,%d)", $this->knowledgeBase->schema[$this->tableID]['BioWarehouseProcedure'], $this->knowledgeBase->wid, $this->wid);

		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query($sql);
		if (!$result){
			mysql_close($link);
			return false;
		}elseif (mysql_num_rows($result) > 0){
			$this->loadFromArray(mysql_fetch_array($result));
		}
		mysql_close($link);	

		//comments
		$sql = sprintf("CALL get_comments(%d,%d)",
			$this->knowledgeBase->wid,
			$this->wid);
		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query($sql);
		if (!$result){
			mysql_close($link);
			return false;
		}elseif (mysql_num_rows($result) > 0){
			$arr = mysql_fetch_array($result, MYSQL_ASSOC);
			$this->comments = $arr['Comments'];
		}
		mysql_close($link);

		//cross reference
		$sql = sprintf("CALL get_crossreferences(%d,%d)",
			$this->knowledgeBase->wid,
			$this->wid);
		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query($sql);
		if (!$result){
			mysql_close($link);
			return false;
		}
		while ($arr = mysql_fetch_array($result, MYSQL_ASSOC)){
			$propertyID = $this->knowledgeBase->schema[$this->tableID]['columns'][$arr['DatabaseRelationship']]['propertyID'];
			$propertyCategory = $this->knowledgeBase->schema[$this->tableID]['columns'][$arr['DatabaseRelationship']]['propertyCategory'];
			$this->$propertyCategory->$propertyID = $arr['CrossReference'];
		}
		mysql_close($link);

		return true;
	}

	function saveToDatabase(){
		$error = true;

		if ($error === true)
			$error = $this->saveToDatabase_WholeCellModelID();

		if ($error === true)
			$error = $this->saveToDatabase_CrossReferences();

		if ($error === true)
			$error = $this->saveToDatabase_Properties();

		if ($error === true)
			$error = $this->saveToDatabase_References();

		return array($this->wid, $error);
	}

	//whole cell model id
	//comments
	function saveToDatabase_WholeCellModelID(){
		$sql = sprintf("CALL set_knowledgebaseobject(%s, %s, '%s',%s,%d)",
			($this->knowledgeBase->wid ? $this->knowledgeBase->wid : "null"),
			($this->wid ? $this->wid : "null"),
			$this->wholeCellModelID,
			($this->comments ? "'".mysql_escape_string($this->comments)."'" : "null"),
			$_SESSION['UserID']);
		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query($sql);
		if (!$result) $error = mysql_error();
		else{
			$arr = mysql_fetch_array($result, MYSQL_ASSOC);
			$this->wid = $arr['WID'];
			$error = true;
		}
		mysql_close($link);
		return $error;
	}

	function saveToDatabase_CrossReferences(){
		foreach($this->knowledgeBase->schema[$this->tableID]['columns'] as $columnID => $column){
			if ($column['format'] != 'crossReference') continue;
			if (false !== array_search($columnID, $this->knowledgeBase->schema[$this->tableID]['protectedColumns'])) continue;

			$sql = sprintf("CALL set_crossreference(%d, %s, '%s', '%s', '%s')",
				$this->wid,
				($this->$column['propertyCategory']->$column['propertyID'] ? "'".$this->$column['propertyCategory']->$column['propertyID'] ."'": "null"),
				$column['databaseName'],
				$column['columnID'],
				$column['databaseType']);
			$link = databaseConnect($this->knowledgeBase->configuration);
			$result = mysql_query($sql);
			if (!$result){
				$error = mysql_error();
				mysql_close($link);
				return $error;
			}else{
				mysql_close($link);
			}
		}
		return true;
	}

	function saveToDatabase_Properties(){
		$parameters = $this->serializeParameters($this->knowledgeBase->schema[$this->tableID]['BioWarehouse_parameters_set']);
		if($parameters) $parameters = ",".$parameters;
		if($this->knowledgeBase->schema[$this->tableID]['writeAsColumn'])
			$sql = sprintf("CALL set_%s(%d %s)",
				$this->knowledgeBase->schema[$this->tableID]['BioWarehouseProcedure'],
				$this->knowledgeBase->wid,
				$parameters);
		else
			$sql = sprintf("CALL set_%s(%d,%s %s)",
				$this->knowledgeBase->schema[$this->tableID]['BioWarehouseProcedure'],
				$this->knowledgeBase->wid,
				($this->wid ? $this->wid : "null"),
				$parameters);
		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query($sql);
		if (!$result) $error = $sql . mysql_error();
		else{
			$error = true;
		}
		mysql_close($link);

		return $error;
	}

	function saveToDatabase_References(){
		$hasReferences = false;
		$usedReferenceWholeCellModelIDs = array();
		foreach($this->knowledgeBase->schema[$this->tableID]['columns'] as $columnID => $column){
			if(array_search($columnID, $this->knowledgeBase->schema[$this->tableID]['protectedColumns']) !== false) continue;
			if($column['format'] == 'comments'){
				$usedReferenceWholeCellModelIDs = array_merge($this->parseComments($data[$columnID], $this->knowledgeBase->referenceWholeCellModelIDs));
				$hasReferences = true;
			}
		}
		if (!$hasReferences) return true;

		$usedReferenceWholeCellModelIDs = array_unique($usedReferenceWholeCellModelIDs);
		$link = databaseConnect($this->knowledgeBase->configuration);
		$result = mysql_query(sprintf("CALL update_entry_references(%d,%d,'%s')", $this->knowledgeBase->wid, $this->wid, join(";",$usedReferenceWholeCellModelIDs))) or die(mysql_error());
		if (!$result) $error = mysql_error();
		else $error = true;
		mysql_close($link);

		return $error;
	}

	function deleteFromDatabase(){
		if ($this->wid == $this->knowledgeBase->wid)
			return "Insufficient permissons.";

		$link = databaseConnect($this->knowledgeBase->configuration);
		$sql = sprintf("CALL delete_%s(%d,%d)", $this->knowledgeBase->schema[$this->tableID]['BioWarehouseProcedure'], $this->knowledgeBase->wid, $this->wid);
		$result = mysql_query($sql);
		if (!$result) $error = mysql_error();
		else $error = true;
		mysql_close($link);

		return $error;
	}

	function loadFromArray($arr, $knowledgeBase = null){
		$this->wid = $arr['WID'];
		
		if (array_key_exists('InsertDate', $arr))   $this->insertDate   = $arr['InsertDate'];
		if (array_key_exists('ModifiedDate', $arr)) $this->modifiedDate = $arr['ModifiedDate'];
		if (array_key_exists('InsertUser', $arr))   $this->insertUser   = $arr['InsertUser'];
		if (array_key_exists('ModifiedUser', $arr)) $this->modifiedUser = $arr['ModifiedUser'];
				
		foreach($this->knowledgeBase->schema[$this->tableID]['columns'] as $column){
			if (!array_key_exists($column['columnID'], $arr)) continue;
			$value = $arr[$column['columnID']];
			if(is_array($value)) $value = join(";",$value);

			if ($column['propertyCategory']){
				if ($arr[$column['columnID']]) $this->$column['propertyCategory']->$column['propertyID']=$value;
				else unset($this->$column['propertyCategory']->$column['propertyID']);
			}else{
				$this->$column['propertyID'] = $value;
			}
		}
	}

	function loadToArray(){
		$arr = array('WID' => $this->wid);
		foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $column){
			if($column['propertyCategory']){
				$value = $this->$column['propertyCategory']->$column['propertyID'];
			}else{
				$value = $this->$column['propertyID'];
			}

			$arr[$column['columnID']] = $value;
		}
		return $arr;
	}

	function validate($mode = 'html'){
		//unique whole cell model id
		$wholeCellModelIDs = array_keys($this->knowledgeBase->wholeCellModelIDs);
		$idx = array_search(strtolower($this->wholeCellModelID), array_map('strtolower', $wholeCellModelIDs));
		if ($mode != 'commandLine' && $idx !== false && $this->knowledgeBase->wholeCellModelIDs[$wholeCellModelIDs[$idx]]['WID'] != $this->wid){
			return array("Whole Cell Model ID must be unique", array());
		}
		
		//add whole cell model id to lists of whole cell model ids, reference whole cell model ids
		$this->knowledgeBase->wholeCellModelIDs[$this->wholeCellModelID] = array(
			'TableID' => $this->tableID,
			'WID' => $this->wid,
			'WholeCellModelID' => $this->wholeCellModelID,
			'Name' => $this->name);
			
		if ($this->tableID == 'references')
			$this->knowledgeBase->referenceWholeCellModelIDs[$this->wholeCellModelID] = $this->wholeCellModelID;
			
		//core properties
		$arr = $this->loadToArray();
		foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $columnID => $column){
			if (array_search($columnID, $this->knowledgeBase->schema[$this->tableID]['protectedColumns']) !== false)
				continue;
			list($arr, $error) = $this->validateProperty($arr[$columnID], $arr, $column);
			if (!$error) return array($column['name'], array());
		}

		//check other properties
		foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $columnID => $column){
			if ($column['format'] != 'reactionStoichiometry') continue;

			list($reactants, $products) = $this->parseReactionEquation($arr[$columnID]);
			if (true !== $deltaMass = $this->validReactionMassBalance($reactants, $products)){
				$leftDifference = $rightDifference = array();
				foreach( $deltaMass as $atom => $cofficient){
					$cofficient *= -1;
					if ($cofficient > 0) array_push($leftDifference, ($cofficient == 1 ? "" : "($cofficient) ")."$atom");
				}
				foreach ($deltaMass as $atom => $cofficient){
					if ($cofficient > 0) array_push($rightDifference, ($cofficient == 1 ? "" : "($cofficient) ")."$atom");
				}				
				$difference = join(" + ", $leftDifference)." ==> ".join(" + ", $rightDifference);
				return array(true, array("Atom inbalance: $difference"));
			}
		}
		
		$this->loadFromArray($arr);
		return array(true, array());
	}
	
	function calculateProperties(){
	}

	function viewBreifRow($idx, $MetaData=false, $Errors=false, $Warnings=false){
		$KnowledgeBaseWID = $this->knowledgeBase->wid;
		$TableName = $this->knowledgeBase->schema[$this->tableID]['name'];

		$content .= "<tr>";
		$content .= "<td>$idx.</td>";
		if ($MetaData){
			$content .= sprintf("<td>%s %s</td>", $this->insertDate, $this->insertUser);
			$content .= sprintf("<td>%s %s</td>", $this->modifiedDate, $this->modifiedUser);
		}
		$content .= "<td>".$this->knowledgeBase->schema[$this->tableID]['name']."</td>";
		$content .= "<td>".$this->wholeCellModelID."</td>";
		$content .= "<td>".$this->name."</td>";
		if ($Errors){
			$content .= "<td>".($this->error ? $this->error : "")."</td>";
		}
		if ($Warnings){
			$content .= "<td>".(count($this->warning)>0 ? join(' ',$this->warning) : "")."</td>";
		}
		$content .= "<td>";
		$content .= "  <img class=\"button\" title=\"View Details\" onClick=\"modalWindow=dhtmlmodal.open('modalBox', 'ajax', 'index.php?Mode=Ajax&Format=Table&Method=View&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid."', 'View $TableName <span style=\'font-style:italic;\'>".$this->wholeCellModelID."</span>', 'width=700px,height=450px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=View,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID."'); return false\" src=\"../images/icons/magnifier.png\"/>";
		if (isset($_SESSION['UserName'])){
			$content .= "  <img class=\"button\" title=\"Edit\" onClick=\"modalWindow=dhtmlmodal.open('modalBox', 'ajax', 'index.php?Mode=Ajax&Format=Table&Method=Edit&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid."', 'Edit $TableName <span style=\'font-style:italic;\'>".$this->wholeCellModelID."</span>', 'width=700px,height=450px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=Edit,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID."'); return false\" src=\"../images/icons/pencil.png\"/>";
			$content .= "  <img class=\"button\" title=\"Delete\" src=\"../images/icons/delete.png\" onClick=\"modalWindow=dhtmlmodal.open('modalBox', 'ajax', 'index.php?Mode=Ajax&Format=Table&Method=Delete&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid."', 'Delete $TableName <span style=\'font-style:italic;\'>".$this->wholeCellModelID."</span>?', 'width=400px,height=70px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=Delete,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID."'); return false\"/></a>";
		}
		$content .= "</td>";
		$content .= "</tr>\n";
		return $content;
	}

	function viewDetailedRow($idx){
		$content .= "<tr>";
		$content .= "<td><a name=\"".$this->wid."\"></a>$idx.</td>";
		$j = 0;

		foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $id => $column){
			if ($column['displayLevel']>1) continue;
			if ($column['propertyCategory']) continue;
			$j++;
			$content .= "<td name=\"column$j\"".($column['displayLevel']==0 ? "" : " style=\"display:none;\"").($column['format']=='comments' ? " class=\"comments\"" : "" ).">".$this->formatProperty($this->$column['propertyID'], $column, $Format)."</td>";
		}

		$KnowledgeBaseWID = $this->knowledgeBase->wid;
		$TableName = $this->knowledgeBase->schema[$this->tableID]['name'];
		$content .= "<td>";
		$content .= "  <img class=\"button\" title=\"View Details\" onClick=\"modalWindow=dhtmlmodal.open('modalBox', 'ajax', 'index.php?Mode=Ajax&Format=Table&Method=View&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid."', 'View $TableName <span style=\'font-style:italic;\'>".$this->wholeCellModelID."</span>', 'width=700px,height=450px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=View,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID."'); return false\" src=\"../images/icons/magnifier.png\"/>";
		if (isset($_SESSION['UserName'])){
			$content .= "  <img class=\"button\" title=\"Edit\" onClick=\"modalWindow=dhtmlmodal.open('modalBox', 'ajax', 'index.php?Mode=Ajax&Format=Table&Method=Edit&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid."', 'Edit $TableName <span style=\'font-style:italic;\'>".$this->wholeCellModelID."</span>', 'width=700px,height=450px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=Edit,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID."'); return false\" src=\"../images/icons/pencil.png\"/>";
			$content .= "  <img class=\"button\" title=\"Delete\" src=\"../images/icons/delete.png\" onClick=\"modalWindow=dhtmlmodal.open('modalBox', 'ajax', 'index.php?Mode=Ajax&Format=Table&Method=Delete&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid."', 'Delete $TableName <span style=\'font-style:italic;\'>".$this->wholeCellModelID."</span>?', 'width=400px,height=70px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=Delete,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID."'); return false\"/></a>";
		}
		$content .= "</td>";
		$content .= "</tr>\n";

		return $content;
	}

	function viewItem($idx, $MetaData = false, $Errors = false, $Warnings = false){
		$WID = $this->wid;
		$KnowledgeBaseWID = $this->knowledgeBase->wid;
		$text = $this->wholeCellModelID.($this->name ? ": ".$this->name : "");
		$content .= "<li>";
		$content .= "<a name=\"$WID\"></a>";
		$content .= "<a href=\"index.php?Format=List&KnowledgeBaseWID=$KnowledgeBaseWID&WID=$WID\">$text</a>";
		if ($Errors && $this->error){
			$content .= " :: <span class=\"error\">".$this->error."</span>";
		}
		if ($Warnings && count($this->warning) > 0){
			$content .= " :: <span class=\"warning\">".join(' ', $this->warning)."</span>";
		}
		$content .= "</li>";

		return $content;
	}

	function viewPane($Format){
		$content = "	<table id=\"ViewTable\" class=\"$Format\" cellpadding=0 cellspacing=0><tbody>\n";
		if (preg_replace('/<(.*?)>/', '', $this->knowledgeBase->schema[$this->tableID]['image']) !=
			$imageURL = preg_replace_callback('/<(.*?)>/', array(&$this,'parseTableImageURLCallback'), $this->knowledgeBase->schema[$this->tableID]['image'])){
			
			if ($this->knowledgeBase->configuration['drawMoleculeBaseURL'] && preg_match('/drawMolecule.php/', $imageURL)){
				$imageURL = $this->knowledgeBase->configuration['drawMoleculeBaseURL'].'/'.$imageURL;
			}

			$content .= "		<tr class=\"image\">\n";
			$content .= "			<td colspan=\"3\" class=\"image\"><center><img src=\"$imageURL\"/></center>\n";
			$content .= "		</tr>\n";
		}			

		//general fields
		foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $id => $column){
			if ($column['displayLevel']>2) continue;
			if ($column['propertyCategory']) continue;
			if (!$this->$column['propertyID']) continue;
			$content.="		<tr>\n";
			$content.="			<th>".$this->formatPropertyName($column)."</th>\n";
			$content.="			<td".($column['format'] == 'comments' ? " class=\"comments\"" : "").">".$this->formatProperty($this->$column['propertyID'], $column, $Format, true)."</td>\n";
			$content.="			<td>".$this->formatDescription($column)."</td>\n";
			$content.="		</tr>\n";
			
			if ($id == 'WholeCellModelID' && isset($_SESSION['UserID'])){
				$content .= "		<tr>\n";
				$content .= "			<th>Created</th>\n";
				$content .= "			<td>".$this->insertDate.", ".$this->insertUser."</td>\n";
				$content .= "			<td>&nbsp;</td>\n";
				$content .= "		</tr>\n";
				
				$content .= "		<tr>\n";
				$content .= "			<th>Last Updated</th>\n";
				$content .= "			<td>".$this->modifiedDate.", ".$this->modifiedUser."</td>\n";
				$content .= " 			<td>&nbsp;</td>\n";
				$content .= "		</tr>\n";		
			}
		}

		//categories
		foreach ($this->knowledgeBase->schema[$this->tableID]['propertyCategories'] as $propertyCategoryID => $propertyCategory){
			if (count(object2array($this->$propertyCategoryID)) > 0 && $propertyCategory['displayLevel'] <= 2){
				$content .= "		<tr class=\"category\">\n";
				$content .= "			<th>".$propertyCategory['name']."</th>\n";
				$content .= "			<td colspan=\"2\">\n";
				$content .= "				<table cellpadding=\"0\" cellspacing=\"0\">\n";
				foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $id => $column){
					if ($column['displayLevel'] > 2) continue;
					if ($column['propertyCategory'] != $propertyCategoryID) continue;
					if (!$this->$column['propertyCategory']->$column['propertyID']) continue;
					$content .= "				<tr>\n";
					$content .= "					<th>".$this->formatPropertyName($column)."</th>\n";
					$content .= "					<td".($column['format'] == 'comments' ? " class=\"comments\"" : "").">".$this->formatProperty($this->$column['propertyCategory']->$column['propertyID'], $column, $Format, true)."</td>\n";
					$content .= "					<td>".$this->formatDescription($column)."</td>\n";
					$content .= "				</tr>\n";
				}
				$content .= "				</table>\n";
				$content .= "			</td>\n";
				$content .= "		</tr>\n";
			}
		}

		$content.="	</tbody></table>\n";

		return $content;
	}

	function editPane($Format, $Mode, $Method){
		$content .= "	<form action=\"#\" method=\"POST\" id=\"editForm\" onsubmit=\"saveEntry($(this).serialize(),'$TableName','$WholeCellModelID'); return false;\">\n";
		$content .= "	<input type=\"hidden\" name=\"KnowledgeBaseWID\" value=\"".$this->knowledgeBase->wid."\"/>\n";
		$content .= "	<input type=\"hidden\" name=\"TableID\" value=\"".$this->knowledgeBase->schema[$this->tableID]['id']."\"/>\n";
		$content .= "	<input type=\"hidden\" name=\"WID\" value=\"".$this->wid."\"/>\n";
		$content .= "	<input type=\"hidden\" name=\"Mode\" value=\"$Mode\"/>\n";
		$content .= "	<input type=\"hidden\" name=\"Method\" value=\"$Method\"/>\n";
		$content .= "	<input type=\"hidden\" name=\"Format\" value=\"$Format\"/>\n";

		$content .= "	<table id=\"EditTable\" class=\"$Format\" cellpadding=0 cellspacing=0>\n";
		$content .= "	<tbody>\n";

		//general fields
		foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $id => $column){
			if ($column['displayLevel'] > 2) continue;
			if ($column['propertyCategory']) continue;
			if (array_search($id, $this->knowledgeBase->schema[$this->tableID]['protectedColumns']) !== false) continue;
			$content .= "		<tr>\n";
			$content .= "			<th>".$this->formatPropertyName($column)."</th>\n";
			$content .= "			<td>".$this->formatPropertyInputBox($this->$column['propertyID'], $id, $column)."</td>\n";
			$content .= "			<td>".(!$column['null'] ? "<span class=\"symbol required\" title=\"Required\">".self::symbol_property_required."</span>" : "")."</td>\n";
			$content .= "			<td>".$this->formatInstructions($column)."</td>\n";
			$content .= "		</tr>\n";
		}

		//categories
		foreach ($this->knowledgeBase->schema[$this->tableID]['propertyCategories'] as $propertyCategoryID => $propertyCategory){
			if ($propertyCategory['displayLevel'] <= 2 && !$propertyCategory['protected']){
				$content .= "		<tr class=\"category\">\n";
				$content .= "			<th>".$propertyCategory['name']."</th>\n";
				$content .= "			<td colspan=\"3\">\n";
				$content .= "				<table cellpadding=\"0\" cellspacing=\"0\">\n";
				foreach ($this->knowledgeBase->schema[$this->tableID]['columns'] as $id => $column){
					if ($column['displayLevel'] > 2) continue;
					if ($column['propertyCategory'] != $propertyCategoryID) continue;
					if (array_search($id, $this->knowledgeBase->schema[$this->tableID]['protectedColumns']) !== false) continue;
					$content .= "				<tr>\n";
					$content .= "					<th>".$this->formatPropertyName($column)."</th>\n";
					$content .= "					<td>".$this->formatPropertyInputBox($this->$column['propertyCategory']->$column['propertyID'], $id, $column)."</td>\n";
					$content .= "					<td>".(!$column['null'] ? "<span class=\"symbol required\" title=\"Required\">".self::symbol_property_required."</span>" : "")."</td>\n";
					$content .= "					<td>".$this->formatInstructions($column)."</td>\n";
					$content .= "				</tr>\n";
				}
				$content .= "				</table>\n";
				$content .= "			</td>\n";
				$content .= "		</tr>\n";
			}
		}

		$content .= "	</tbody>\n";
		$content .= "	<tfoot>\n";
		$content .= "		<tr>\n";
		$content .= "			<td>&nbsp;</td>\n";
		$content .= "			<td colspan=\"2\">\n";	
		$content .= "				<input type=\"submit\" class=\"button\" value=\"".($this->wid ? "Save" : "Add")."\">\n";
		$content .= "				<input type=\"button\" class=\"button\" value=\"Cancel\" onclick=\"".($Format == 'Table' ? "modalWindow.hide();" : "window.location='index.php?Format=$Format&Method=View&KnowledgeBaseWID=".$this->knowledgeBase->wid."&WID=".$this->wid."';")."\">\n";
		$content .= "			</td>\n";
		$content .= "		</tr>\n";
		$content .= "	</tfoot>\n";
		$content .= "	</table>\n";
		$content .= "	</form>\n";

		return $content;
	}

	function deletePane($Format, $Mode, $Method){
		$TableName = $this->knowledgeBase->schema[$this->tableID]['name'];
		$KnowledgeBaseWID = $this->knowledgeBase->wid;
		$WholeCellModelID = $this->wholeCellModelID;
		$WID = $this->wid;

		$content .= "<center>\n";
		$content .= "<p class=\"modal\">Are you sure you want to delete $TableName <span style=\"font-style:italic;\">$WholeCellModelID</span>?</p>\n";
		$content .= "	 <form action=\"#\" method=\"POST\" onsubmit=\"deleteEntry($(this).serialize(),'$TableName','$WholeCellModelID'); return false;\">\n";
		$content .= "		 <input type=\"hidden\" name=\"KnowledgeBaseWID\" value=\"$KnowledgeBaseWID\"/>\n";
		$content .= "		 <input type=\"hidden\" name=\"TableID\" value=\"$TableID\"/>\n";
		$content .= "		 <input type=\"hidden\" name=\"WID\" value=\"$WID\"/>\n";
		$content .= "		 <input type=\"hidden\" name=\"Method\" value=\"$Method\"/>\n";
		$content .= "		 <input type=\"hidden\" name=\"Mode\" value=\"$Mode\"/>\n";
		$content .= "		 <input type=\"hidden\" name=\"Format\" value=\"$Format\"/>\n";
		$content .= "		 <input class=\"button\" style=\"width:60px;\" type=\"submit\" value=\"OK\">\n";
		$content .= "		 <input class=\"button\" style=\"width:60px;\" type=\"button\" value=\"Cancel\" onclick=\"modalWindow.hide();\"/>\n";
		$content .= " </form>\n";
		$content .= "</center>\n";

		return $content;
	}

	function navigation($Format, $TableID = null){
		if (!$TableID) $TableID = $this->tableID;
		if (!$TableID) $TableID = $this->tableID;

		$navigationContents = array();

		array_push($navigationContents, array(
			'url' => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d", $Format, $this->knowledgeBase->wid),
			"fontStyle" => "italic",
			"text" => $this->knowledgeBase->name));
		if ($TableID != 'summary')
			array_push($navigationContents, array(
				'url' => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&TableID=%s", $Format, $this->knowledgeBase->wid, $TableID),
				"text" => $this->knowledgeBase->schema[$TableID]['names']));
		if ($this->wid != $this->knowledgeBase->wid)
			array_push($navigationContents, array(
				'url' => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&WID=%d", $Format, $this->knowledgeBase->wid, $this->wid),
				"text" => $this->wholeCellModelID.($this->name ? ": ".$this->name : "")));

		return $navigationContents;
	}

	function sidebar($Format, $TableID = null){
		if (!$TableID) $TableID = $this->tableID;
		$TableName = $this->knowledgeBase->schema[$TableID]['name'];
		$TableNames = $this->knowledgeBase->schema[$TableID]['names'];
		$KnowledgeBaseWID = $this->knowledgeBase->wid;
		$KnowledgeBaseName = $this->knowledgeBase->name;

		$sidebarContents = array();
		$sidebarContents[0]["title"] = "$TableName Controls";
		$sidebarContents[0]["style"] = "icons";
		$sidebarContents[0]["content"] = array();
		if ($this->knowledgeBase->schema[$TableID]['writeAsColumn']){
			if (isset($_SESSION['UserName']))
				array_push($sidebarContents[0]["content"], array(
					"url" => "index.php?Mode=Ajax&Format=Table&Method=Edit&KnowledgeBaseWID=$KnowledgeBaseWID",
					"title" => "Edit $TableName",
					"text" => "Edit",
					"modalWindow"=>"width=700px,height=450px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=Edit,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName",
					"icon" => "../images/icons/pencil.png"));
		}else{
			if ($this->wid == $this->knowledgeBase->wid){
				if ($Format == 'List')
					array_push($sidebarContents[0]["content"], array(
						"url" => "index.php?KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID&Format=Table",
						"title" => "Table View",
						"text" => "Table View",
						"icon" => "../images/icons/table.png"));
				else
					array_push($sidebarContents[0]["content"], array(
						"url" => "index.php?KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID&Format=List",
						"title" => "List View",
						"text" => "List View",
						"icon" => "../images/icons/text_list_bullets.png"));
			}

			if (isset($_SESSION['UserName'])){
				if ($Format == 'List'){
					if ($this->wid != $this->knowledgeBase->wid){
						array_push($sidebarContents[0]["content"], array(
							"url" => "index.php?Format=$Format&Method=Edit&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid,
							"title" => "Edit ".$this->wholeCellModelID,
							"text" => "Edit",
							"icon" => "../images/icons/pencil.png"));
						array_push($sidebarContents[0]["content"], array(
							"modalWindow" => "width=400px,height=70px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=Table,Method=Delete,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,WID=".$this->wid.",WholeCellModelID=".$this->wholeCellModelID,
							"url" => "index.php?Mode=Ajax&Format=Table&Method=Delete&KnowledgeBaseWID=$KnowledgeBaseWID&WID=".$this->wid,
							"title" => "Delete ".$this->wholeCellModelID,
							"text" => "Delete",
							"icon" => "../images/icons/delete.png"));
					}
					array_push($sidebarContents[0]["content"], array(
						"url" => "index.php?Format=$Format&Method=Edit&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID",
						"title" => "Add $TableName",
						"text" => "Add",
						"icon" => "../images/icons/add.png"));
				}else{
					array_push($sidebarContents[0]["content"], array(
						"url" => "index.php?Mode=Ajax&Format=$Format&Method=Edit&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID",
						"title" => "Add $TableName",
						"text" => "Add",
						"modalWindow" => "width=700px,height=450px,center=1,resize=0,scrolling=1,closeable=1,LoggedIn=".(isset($_SESSION['UserName']) ? 1 : 0).",Format=$Format,Method=Edit,KnowledgeBaseWID=$KnowledgeBaseWID,TableName=$TableName,TableID=$TableID",
						"icon" => "../images/icons/add.png"));
				}
			}
		}

		if ($this->wid == $this->knowledgeBase->wid && $this->knowledgeBase->configuration['enableExport']){
			array_push($sidebarContents[0]["content"], array(
				"url" => "export.php?Format=Excel&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID",
				"title" => "Export",
				"text" => "Export",
				"icon" => "../images/icons/page_white_excel.png"));
			//array_push($sidebarContents[0]["content"], array(
			//  "url" => "export.php?Format=XML&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=$TableID",
			//  "title" => "Export",
			//  "text" => "Export",
			//  "icon" => "../images/icons/xhtml.png"));
			if (isset($_SESSION['UserName'])){
				array_push($sidebarContents[0]["content"], array(
					"url" => "import.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=summary",
					"title" => "Import",
					"text" => "Import",
					"icon" => "../images/icons/page_white_excel.png"));
			}
		}

		array_push($sidebarContents[0]["content"], array(
			"onclick" => "window.print()",
			"title" => "Print",
			"text" => "Print",
			"icon" => "../images/icons/printer.png"));

		if (!$this->knowledgeBase->schema[$TableID]['writeAsColumn'] && $Format == 'Table'){
			$sidebarContents[1]["title"] = "$TableName Properties";
			$sidebarContents[1]["style"] = "table";
			$sidebarContents[1]["content"] = array();
			$j = 0;
			foreach ($this->knowledgeBase->schema[$TableID]['columns'] as $column){
				if ($column['displayLevel']>1) continue;
				if ($column['propertyCategory']) continue;
				$j++;
				array_push($sidebarContents[1]["content"],
					"<th><input type=\"checkbox\"".($column['displayLevel'] == 0 ? " checked" : "")." onClick=\"toggleColumn('column$j',!this.checked)\"\"></th><td><span".($column['description'] ? " title=\"".$column['description']."\"" : "").">".$this->formatPropertyName($column)."</span></td>");
			}
		}
		return $sidebarContents;
	}

	function validateProperty($value, $data, $property){
		//null value
		if (!is_numeric($value) && $value == ""){
			if ($property['null'] == true) return array($data, true);
			return array($data, false);
		}

		//non-null value
		switch($property['format']){
			case 'date':
					return array($data, array($data, preg_match('/^\d{4,4}-\d{2,2}-\d{2,2} \d{2,2}:\d{2,2}:\d{2,2}$/', $value) != false));
			case 'string':
					return array($data, true);
			case 'enumerations':
					return array($data, array_search($value, array_keys($property['enumerations'])) !== false);
			case 'regexp':
					return array($data, preg_match($property['regexp'], $value) != false);
			case 'url':
					return array($data, true);
			case 'float':
					return array($data, is_numeric($value));
			case 'integer':
					return array($data, is_numeric($value) && (ceil(floatval($value)) == floatval($value)));
			case 'rateLaw':
					return array($data, $this->validRateLaw($value, $data[$property['vmaxField']], $data[$property['vmaxUnitField']], $data[$property['kmField']], $data[$property['stoichiometryField']], $property['forward']));
			case 'activationRule':
					$data['Regulators'] = $this->parseStimuliActivationEquation($value, $property);
					return array($data, $data['Regulators'] !== false && ($property['multipleObjectReferences'] == true || (count($data['Regulators']) <= 1)));
			case 'formula':
					return array($data, true);
			case 'empiricalFormula':
					return array($data, preg_match('/^([a-z]{1,2}[0-9]+)+$/i', $value));
			case 'reactionStoichiometry':
					$result = $this->parseReactionEquation($value, $property);
					return array($data, $result !== false && ($property['multipleObjectReferences'] == true || ((count($result[0]) + count($result[1])) <= 1)));
			case 'dna sequence':
					return array($data, preg_match('/^[acgt\n]+$/i', $value));
			case 'amino acid sequence':
					return array($data, preg_match('/^[ARNDCEQGHILKMFPSTWYV\n]+$/i', $value));
			case 'comments':
					return array($data, true);
			case 'list':
					return array($data, true);
			case 'pattern':
				if (false === preg_match_all('/<(.*?)>/', str_replace(array('(', ')'), '', $pattern), $keys))
					return array($data, false);
				if (false === preg_match_all('/^'.preg_replace('/<.*?>/', '(.*?)', str_replace(array('(',')'), '', $pattern)).'$/', $list, $matches))
					return array($data, false);

				if (false === preg_match_all('/\((.*?)\)/', str_replace(array('<', '>'), '', $pattern), $keys))
					return array($data, false);
				$pattern = str_replace(array('<', '>'), '', $pattern);
				foreach ($keys[1] as $key){
					$pattern=str_replace($key, preg_replace('/[^;]+/', '.*?', $key), $pattern);
				}
				if (false === preg_match('/^'.$pattern.'$/', $list, $matches))
					return array($data, false);

				return array($data, true);
				break;
			case 'objectReferences':
				if (!is_array($value)) $value = explode(';', $value);
				if ($property['multipleObjectReferences'] != true && count($value) > 1) return array($data, false);
				foreach ($value as $item){
					if ($property['objectReferenceType'] == 'composition'){
						if (false === preg_match('/^(\(-*[0-9]*\.*[0-9]*\) ){0,1}([a-z][a-z0-9_]*)\[([a-z][a-z0-9_]*)\]$/i',$item,$match))
							return array($data, false);
						if (!array_key_exists($match[2], $this->knowledgeBase->wholeCellModelIDs) ||
							array_search($this->knowledgeBase->wholeCellModelIDs[$match[2]]['TableID'], $property['objectReferences']) === false)
							return array($data, false);
						if (!array_key_exists($match[3], $this->knowledgeBase->wholeCellModelIDs) ||
							array_search($this->knowledgeBase->wholeCellModelIDs[$match[3]]['TableID'], array('compartments')) === false)
							return array($data, false);
					}else{
						if (!array_key_exists($item, $this->knowledgeBase->wholeCellModelIDs) ||
							array_search($this->knowledgeBase->wholeCellModelIDs[$item]['TableID'], $property['objectReferences']) === false){
							return array($data, false);
						}
					}
				}
				return array($data, true);
			case 'intramolecularBonds':
					return array($data, false !== preg_match('/^(([a-z][a-z0-9_]+): ([a-z])(\d+)-([a-z])(\d+);)*(([a-z][a-z0-9_]+): ([a-z])(\d+)-([a-z])(\d+))$/i', $bond));
			case 'fileReferences':
				foreach($property['fileReferences'] as $file){
					$file = str_replace('%s', $value, $file);
					if (file_exists($file))
						return array($data, true);
				}
				return array($data, false);
			case 'crossReference':
			case 'externalReference':
				return array($data, true);
		}
		return array(true, $data);
	}

	/*
	//test cases
	$this->parseReactionEquation('[c]: ATP + GLN + H2O + GLU ==> ADP + GLU + GLN + PI + H');
	$this->parseReactionEquation('[e]:  <==> SerSer');
	$this->parseReactionEquation('CYS[c] + PG160[m] ==> diacylglycerolCys[c] + SNGLYP[c] + H[c]');
	$this->parseReactionEquation('FUC1P[e] + (2) PI[c] ==> FUC1P[c] + (2) PI[e]');
	$this->parseReactionEquation('[c]: AMP + ATP <==> (2) ADP');
	$this->parseReactionEquation('[c]: GN + R1P <==> GSN + (2) H + PI');
	$this->parseReactionEquation('ADP[c] + (4) H[e] + H[c] + PI[c] <==> ATP[c] + (4) H[c] + H2O[c]');
	*/
	function parseReactionEquation($stoichiometry, $column = null){	
		$reactantsArr = $productsArr = array();
		$WholeCellModelIDs = $this->knowledgeBase->wholeCellModelIDs;
		if (preg_match('/^\[(.*?)\]: (((\((\d+)\) ){0,1}([a-z][a-z0-9_]*) \+ )*((\((\d+)\) ){0,1}([a-z][a-z0-9_]*)){0,1}) (<==|<==>|==>) (((\((\d+)\) ){0,1}([a-z][a-z0-9_]*) \+ )*((\((\d+)\) ){0,1}([a-z][a-z0-9_]*)){0,1})$/i', $stoichiometry, $match)){
			$compartment = $match[1];
			$reactants = $match[2];
			$direction = $match[11];
			$products = $match[12];

			if ($column && $WholeCellModelIDs[$compartment]['TableID'] != 'compartments'){
				return false;
			}

			if ($reactants){
				foreach (explode(" + ", $reactants) as $reactant){
					preg_match('/^(\((\d+)\) ){0,1}([a-z][a-z0-9_]*)$/i', $reactant, $match);

					if ($column && array_search($WholeCellModelIDs[$match[3]]['TableID'], $column['objectReferences']) === false){
						return false;
					}

					array_push($reactantsArr, array('WholeCellModelID' => $match[3], 'Compartment' => $compartment, 'Coefficient' => ($match[2] ? $match[2] : 1)));
				}
			}

			if ($products){
				foreach (explode(" + ", $products) as $product){
					preg_match('/^(\((\d+)\) ){0,1}([a-z][a-z0-9_]*)$/i', $product, $match);

					if ($column && array_search($WholeCellModelIDs[$match[3]]['TableID'], $column['objectReferences']) === false){
						return false;
					}

					array_push($productsArr, array('WholeCellModelID' => $match[3], 'Compartment' => $compartment, 'Coefficient' => ($match[2] ? $match[2] : 1)));
				}
			}
		}elseif (preg_match('/^(((\((\d+)\) ){0,1}([a-z][a-z0-9_]*)\[(.*?)\] \+ )*((\((\d+)\) ){0,1}([a-z][a-z0-9_]*)\[(.*?)\]){0,1}) (<==|<==>|==>) (((\((\d+)\) ){0,1}([a-z][a-z0-9_]*)\[(.*?)\] \+ )*((\((\d+)\) ){0,1}([a-z][a-z0-9_]*)\[(.*?)\]){0,1})$/i', $stoichiometry, $match)){
			$reactants = $match[1];
			$direction = $match[12];
			$products = $match[13];

			if ($reactants){
				foreach (explode(" + ", $reactants) as $reactant){
					preg_match('/^(\((\d+)\) ){0,1}([a-z][a-z0-9_]*)\[([a-z][a-z0-9_]*)\]$/i', $reactant, $match);

					if ($column && array_search($WholeCellModelIDs[$match[3]]['TableID'], $column['objectReferences']) === false){
						return false;
					}
					if ($column && $WholeCellModelIDs[$match[4]]['TableID'] != 'compartments'){
						return false;
					}

					array_push($reactantsArr, array('WholeCellModelID' => $match[3], 'Compartment' => $match[4], 'Coefficient' => ($match[2] ? $match[2] : 1)));
				}
			}

			if ($products){
				foreach (explode(" + ", $products) as $product){
					preg_match('/^(\((\d+)\) ){0,1}([a-z][a-z0-9_]*)\[([a-z][a-z0-9_]*)\]$/i', $product, $match);

					if ($column && array_search($WholeCellModelIDs[$match[3]]['TableID'], $column['objectReferences']) === false){
						return false;
					}
					if ($column && $WholeCellModelIDs[$match[4]]['TableID'] != 'compartments'){
						return false;
					}

					array_push($productsArr, array('WholeCellModelID' => $match[3], 'Compartment' => $match[4], 'Coefficient' => ($match[2] ? $match[2] : 1)));
				}
			}
		}else{
			return false;
		}

		return array($reactantsArr, $productsArr);
	}

	function parseStoichiometry($stoichiometry, $compartment){
		preg_match('/^\(*-*(\d*)\)* *([^\[\] \(\)]+)\[*(.*?)\]*$/', $stoichiometry, $match);
		if (!$match[2]) return false;
		if ($match[1]) $coefficient = $match[1];
		else $coefficient = 1;
		$metabolite = $match[2];
		if ($match[3]) $compartment = $match[3];

		return array($metabolite, $compartment, $coefficient);
	}

	function parseEmpiricalFormula($empiricalFormula){
		preg_match_all('/([A-Z]{1,2})(\d+)/i', $empiricalFormula, $matches);
		if (join($matches[0],"") != $empiricalFormula) return false;

		$parsedEmpiricalFormula = array();
		for($i = 0; $i < count($matches[0]); $i++){
			$parsedEmpiricalFormula[$matches[1][$i]] = $matches[2][$i];
		}

		return $parsedEmpiricalFormula;
	}

	function validReactionMassBalance($reactants, $products){
		$this->knowledgeBase->getMetaboliteEmpiricalFormulas();
		$metaboliteEmpiricalFormulas = $this->knowledgeBase->metaboliteEmpiricalFormulas;

		$deltaMass = array();

		foreach ($reactants as $reactant){
			if (!array_key_exists($reactant['WholeCellModelID'], $metaboliteEmpiricalFormulas)) continue;
			foreach ($metaboliteEmpiricalFormulas[$reactant['WholeCellModelID']] as $element => $coefficient){
				if (!array_key_exists($element,$deltaMass)) $deltaMass[$element] = 0;
				$deltaMass[$element] += $reactant['Coefficient'] * $coefficient;
			}
		}

		foreach ($products as $product){
			if (!array_key_exists($product['WholeCellModelID'], $metaboliteEmpiricalFormulas)) continue;
			foreach ($metaboliteEmpiricalFormulas[$product['WholeCellModelID']] as $element => $coefficient){
				if (!array_key_exists($element,$deltaMass)) $deltaMass[$element] = 0;
				$deltaMass[$element] -= $product['Coefficient'] * $coefficient;
			}
		}

		foreach ($deltaMass as $element => $coefficient){
			if ($coefficient != 0) return $deltaMass;
		}

		return true;
	}

	function validRateLaw($rateLaw, $vmax, $vmaxUnit, $km, $stoichiometry, $forward=true){
		if ($rateLaw == '') return true;

		//parse stoichiometry
		list($reactants, $products) = $this->parseReactionEquation($stoichiometry);
		if ($forward) $metabolites = $reactants;
		else $metabolites = $products;

		$metaboliteWholeCellModelIDs = array();
		foreach ($metabolites as $metabolite)
			array_push($metaboliteWholeCellModelIDs, $metabolite['WholeCellModelID']);

		//rate law
		$usedKmMax = 0;
		$usedVmax = 0;
		preg_match_all('/([a-z][a-z0-9_]*)/i', $rateLaw, $matches);
		$matches = $matches[1];
		foreach ($matches as $match){
			if ($match == 'Vmax'){
				$usedVmax = 1;
				continue;
			}
			if (substr($match, 0, 2) == 'Km'){
				if (strlen($match) == 2) $usedKmMax = max($usedKmMax, 1);
				elseif (is_numeric(substr($match, 2))) $usedKmMax = max($usedKmMax, substr($match, 2));
				else  return false;
				continue;
			}
			if(false === array_search($match, $metaboliteWholeCellModelIDs)){
				return false;
			}
		}

		//Vmax
		if ($usedVmax && $vmax == "") return false;
		if ($usedVmax && !($vmaxUnit == "1/min" || $vmaxUnit == "U/mg")) return false;

		//Km
		if ($usedKmMax < ($km == '' ? 0 : count(explode(";", $km)))) return false;
		if ($usedKmMax > ($km == '' ? 0 : count(explode(";", $km)))) return false;

		return true;
	}

	/*
	Test cases:

	$tests=array(
			"!(here)",
			"  (  here ) ",
			"our  (  here ) ",
			"our | (  here ) ",
			"our | (  here & !here & count ) ",
			"our | (  here & !here & count)( ) ",
			"our | (  here & !here & count ) | ()",
			"our | (  here & !here & count ) | (a)",
			"our | (  here & !here & count ) | (a) b",
			"!!our",
			"our | !!(  here & !here & count ) | (a)  & b",
			"our | !(  here & !here & count ) | (a)  & b",
			"our | !(  here & (!here | and) & count ) | (a)  & b");
	foreach($tests as $test){
			$temp=$this->parseStimuliActivationEquation($test);
			if($temp===false) echo "false\n";
			else print_r($temp);
	}
	*/
	function parseStimuliActivationEquation($equation, $column){
		$usedStimulis = array();
		$blocks = array();
		$begin = 0;
		$end = 0;
		$sense = 0;
				
		$equation = str_replace(" ", "", $equation);
		if (preg_match('/^[!\-]{0,1}\((.+)\)$/', $equation, $matches)) $equation = $matches[1];
		if (preg_match('/^[!\-]{0,1}(.+)$/', $equation, $matches)) $equation = $matches[1];
		if (!$equation) return false;						

		//split into blocks
		for ($i = 0; $i < strlen($equation); $i++){
			if (substr($equation, $i, 1) == '(') $sense++;
			if (substr($equation, $i, 1) == ')') $sense--;
			if ($sense<0) return false;

			if ($sense == 0){
				if (array_search(substr($equation, $i, 1), array("|", "&", "-", "+")) !== false){
					array_push($blocks, substr($equation, $begin, $i - 1 - $begin + 1));
					$begin = $i + 1;
				}elseif (array_search(substr($equation, $i, 2), array(">=", "<=", "==")) !== false){
					array_push($blocks, substr($equation, $begin, $i - 1 - $begin + 1));
					$begin = $i + 2;
				}elseif (array_search(substr($equation, $i, 1), array(">", "<")) !== false){
					array_push($blocks, substr($equation, $begin, $i - 1 - $begin + 1));
					$begin = $i + 1;
				}
			}
		}
		array_push($blocks, substr($equation, $begin, strlen($equation) - $begin));					

		//check parenthesis match
		if ($sense != 0) return false;			

		//if no further substructure
		if (count($blocks) == 1){	
			if (strpos($blocks[0], '(') !== false) return false;
			elseif (strpos($blocks[0], '!') !== false) return false;
			elseif (is_numeric($blocks[0]) || array_search($blocks[0], array("true", "false"))) return array();
			elseif (array_search($this->knowledgeBase->wholeCellModelIDs[$blocks[0]]['TableID'], $column['objectReferences']) !== false) return $blocks;
			return false;
		}		
		
		//recurse on blocks
		for ($i = 0; $i<count($blocks); $i++){		
			$temp = $this->parseStimuliActivationEquation($blocks[$i], $column);
			if ($temp === false) return false;
			else $usedStimulis = array_merge($usedStimulis, $temp);
		}
		
		return array_unique($usedStimulis);
	}

	function parseComments($text, $ReferenceWholeCellModelIDs){
		$usedReferenceWholeCellModelIDs = array();
		foreach ($ReferenceWholeCellModelIDs as $WholeCellModelID){
			if (strpos($text,$WholeCellModelID) !== false){
				array_push($usedReferenceWholeCellModelIDs, $WholeCellModelID);
			}
		}
		return $usedReferenceWholeCellModelIDs;
	}

	function serializeParameters($parameterIDs){
		$data = $this->loadToArray();
		$parameters = array();
		foreach ($parameterIDs as $columnID){
			if (is_null($data[$columnID]) || $data[$columnID] === ''){
				array_push($parameters, "null");
				continue;
			}
			switch ($this->knowledgeBase->schema[$this->tableID]['columns'][$columnID]['type']){
				case 'string':
					if (is_array($data[$columnID])) $data[$columnID] = join(";", $data[$columnID]);
					array_push($parameters, "'".mysql_escape_string($data[$columnID])."'");
					break;
				case 'numeric':
					array_push($parameters, $data[$columnID]);
					break;
			}
		}
		return join(",", $parameters);
	}


	function formatProperty($values, $column, $Format = 'List', $verbose = false){
		switch ($column['format']){
			case 'url':
				if($values) return $this->formatLink($values, $values, null, true);
				return;
			case 'interger':
			case 'float':
				return $this->parseFloat($values);
			case 'enumerations':
				return $column['enumerations'][$values];
			case 'rateLaw':
			case 'activationRule':
			case 'formula':
				return $this->parseFormula($values);
			case 'empiricalFormula':
				return $this->formatEmpiricalFormula($values);
			case 'reactionStoichiometry':
				return $this->parseReactionStoichiometry($values);
			case 'dna sequence':
				return $this->formatDNASequence($values, $Format);
			case 'amino acid sequence':
				return $this->formatAminoAcidSequence($values, $Format);
			case 'comments':
				return $this->formatComments($values, $Format != 'List');
			case 'list':
			case 'regexp':
				return str_replace(';', ', ', $values);
			case 'pattern':
				list($junk, $values) = $this->parsePattern($values, $column['pattern']);
				break;
			case 'intramolecularBonds':
				$bonds = explode(';', $values);
				foreach($bonds as $idx => $bond){
					if (preg_match('/^([a-z][a-z0-9_]+): ([a-z])(\d+)-([a-z])(\d+)$/i', $bond, $match))
						$bonds[$idx] = $this->formatObjectReference($match[1], $this->knowledgeBase->wholeCellModelIDs[$match[1]]).": ".$match[2].$match[3]."-".$match[4].$match[5];
				}
				return join(', ', $bonds);
				break;
			case 'objectReferences':
				return $this->parseObjectReference($values, $Format, $verbose);
			case 'fileReferences':
				foreach ($column['fileReferences'] as $file){
					$file = str_replace('%s', $values, $file);
					if (file_exists($file))
						return $this->formatLink($values, "viewCode.php?Language=matlab&File=".urlencode($file), $column['description'], false);
				}
			case 'crossReference':
			case 'externalReference':
				$arr = array();
				foreach (explode(';', $values) as $value){
					array_push($arr, $this->formatCrossReference($value, $column['url'], $column['linkDescription']));
				}
				return join(', ', $arr);
		}

		if (array_key_exists('url', $column)){
			if (!is_array($values)) $values = array($values);
			foreach ($values as $idx => $value){
				$values[$idx] = $this->formatCrossReference($value, $column['url'], $column['linkDescription']);
			}
			return join(", ", $values);
		}

		return $values;
	}

	function parseFloat($value){
		if (is_null($value)) return;
		if ($value && abs($value) < 0.01) $value = sprintf('%.3e', $value);
		else $value = sprintf('%.3f', $value);
		if (preg_match('/^(-*\d*\.*\d*)e([-+]\d*)$/i', $value, $match))
			return sprintf('%s &times; 10<span class="sup">%d</span>', $match[1], $match[2]);
		return $value;
	}

	function parseFormula($value){
		
		$value = str_replace(' ', '', $value);
		
		$value = preg_replace_callback('/([a-z0-9_]+)/i', array(&$this, 'parseFormulaCallback'), $value);
		
		while (preg_match('/(^|[\(\) \+\*\-\/])(K)(m[a-zA-Z0-9_]*?)([\(\) \+\*\-\/]|$)/i', $value))
			$value = preg_replace('/(^|[\(\) \+\*\-\/])(K)(m[a-zA-Z0-9_]*?)([\(\) \+\*\-\/]|$)/ie',"'\\1'.'\\2'.'<span class=\"sub\">'.'\\3'.'</span>'.'\\4'", $value);

		$value = str_replace(array('*','+','Vmax'), array('&middot;',' + ','V<span class="sub">max</span>'), $value);
		return preg_replace('/ +/', ' ', $value);
	}

	function parseFormulaCallback($match){
		if (array_key_exists($match[1], $this->knowledgeBase->wholeCellModelIDs))
			return $this->formatObjectReference($match[1], $this->knowledgeBase->wholeCellModelIDs[$match[1]]);
		if (is_numeric($match[1]) || array_search($match[1], array("true", "false")) !== false)
			return $this->formatNumber($match[1]);
		return $match[0];
	}

	function formatEmpiricalFormula($value){
		preg_match_all('/(([a-zA-z]+)([0-9]+))/', $value, $matches);
		$arr = array();
		foreach ($matches[2] as $idx => $element){
			array_push($arr, strtoupper(substr($element, 0, 1)).strtolower(substr($element, 1)).($matches[3][$idx] > 1 ? "<span class=\"sub\">".$matches[3][$idx]."</span>" : ""));
		}
		return join("", $arr);
	}

	function parseReactionStoichiometry($values){
		if (preg_match('/^\[(.*?)\]: (.*?) (<*==>*) (.*?)$/', $values, $matches)){
			$reactants = $products = array();
			foreach (explode(" + ", $matches[2]) as $match)
				array_push($reactants, $this->formatObjectStoichiometry($match));
			foreach (explode(" + ", $matches[4]) as $match)
				array_push($products, $this->formatObjectStoichiometry($match));
			switch ($matches[3]){
				case '<==':  $arrow = 8656; break;
				case '==>':  $arrow = 8658; break;
				case '<==>': $arrow = 8660; break;
			}
			return "[".$this->formatObjectReference($matches[1], $this->knowledgeBase->wholeCellModelIDs[$matches[1]])."]: ".join(" + ", $reactants)." &#$arrow; ".join(" + ", $products);
		}else{
			preg_match('/^(.*?) (<*==>*) (.*?)$/', $values, $matches);
			$reactants = $products = array();
			foreach (explode(" + ", $matches[1]) as $match)
				array_push($reactants,$this->formatObjectStoichiometry($match));
			foreach (explode(" + ", $matches[3]) as $match)
				array_push($products, $this->formatObjectStoichiometry($match));
			switch ($matches[2]){
				case '<==':  $arrow = 8656; break;
				case '==>':  $arrow = 8658; break;
				case '<==>': $arrow = 8660; break;
			}
			return join(" + ",$reactants)." &#$arrow; ".join(" + ",$products);
		}
	}

	function formatDNASequence($sequence, $Format = 'List'){
		$rowLength = ($Format == 'List' ? 60 : 40);
		$sequenceLength = strlen($sequence);
		$sequence .= str_repeat(' ', $rowLength - (strlen($sequence) % $rowLength));
		$html .= "<table cellpadding=\"0\" cellspacing=\"0\" class=\"sequence\">";
		for ($i = 0; $i < strlen($sequence); $i += $rowLength){
			$html .= "<tr>";
			$html .= "<th class=\"coordinate1\">".($i+1)."</th>";
			$html .= "<td class=\"sequence\">".substr($sequence, $i, $rowLength)."</td>";
			$html .= "<th class=\"coordinate2\">".min($sequenceLength, ($i + $rowLength))."</th>";
			$html .= "</tr>";
		}
		$html .= "</table>";
		return $html;
	}

	function formatAminoAcidSequence($sequence, $Format = 'List'){
		$rowLength = ($Format == 'List' ? 60 : 40);
		$sequenceLength = strlen($sequence);
		$sequence .= str_repeat(' ', $rowLength - (strlen($sequence) % $rowLength));
		$html .= "<table cellpadding=\"0\" cellspacing=\"0\" class=\"sequence\">";
		for ($i = 0; $i < strlen($sequence); $i += $rowLength){
			$html .= "<tr>";
			$html .= "<th class=\"coordinate1\">".($i+1)."</th>";
			$html .= "<td class=\"sequence\">".substr($sequence, $i, $rowLength)."</td>";
			$html .= "<th class=\"coordinate2\">".min($sequenceLength, ($i + $rowLength))."</th>";
			$html .= "</tr>";
		}
		$html .= "</table>";
		return $html;
	}

	function formatComments($text, $onlyReferences = false){
		if (!$text) return $text;
		
		$onlyReferences = true;
		if ($onlyReferences){
			foreach ($this->knowledgeBase->referenceWholeCellModelIDs as $WholeCellModelID => $WID){				
				$text = str_replace($WholeCellModelID, $this->formatObjectReference($WholeCellModelID,
					array('TableID' => 'references', 'WID' => $WID, 'WholeCellModelID' => $WholeCellModelID)), $text);
			}
		}else{
			foreach ($this->knowledgeBase->wholeCellModelIDs as $arr){
				$formattedText = $this->formatObjectReference($arr['WholeCellModelID'], array('TableID' => $arr['TableID'], 'WID' => $arr['WID'], 'WholeCellModelID' => $arr['WholeCellModelID']));
				$text = preg_replace('/(^|[^a-zA-Z0-9_])'.$arr['WholeCellModelID'].'([^a-zA-Z0-9_]|$)/e', "'\\1'.'$formattedText'.'\\2'", $text);
			}
		}
		
		return $text;
	}

	function parsePattern($list, $pattern){
		$values = array();
		preg_match_all('/<(.*?)>/', str_replace(array('(', ')'), '', $pattern), $keys);
		preg_match_all('/^'.preg_replace('/<.*?>/', '(.*?)', str_replace(array('(',')'),'',$pattern)).'$/', $list, $matches);
		foreach ($keys[1] as $idx => $key){
			$values[$key] = $matches[$idx+1][0];
		}

		$groupedValues = array();
		preg_match_all('/\((.*?)\)/',str_replace(array('<', '>'), '', $pattern), $keys);
		$pattern = str_replace(array('<', '>'), '', $pattern);
		foreach ($keys[1] as $key){
			$pattern = str_replace($key, preg_replace('/[^;]+/', '.*?', $key), $pattern);
		}

		preg_match('/^'.$pattern.'$/', $list, $matches);
		foreach ($keys[1] as $idx => $key){
			$groupedValues[str_replace(';', '_', $key)] = str_replace(';', ' ', $matches[$idx+1]);
		}

		return array($values, $groupedValues);
	}

	function parseObjectReference($list, $Format, $verbose = false){
		$arr = array();
		$maxLength = 0;
		foreach (explode(';', $list) as $item){
			if (!$item) continue;
			$maxLength = max($maxLength, strlen($item));
			array_push($arr, $this->formatObjectStoichiometry($item));
		}
		if ($verbose){
			if ($maxLength > 0){
				$table = "<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\"><tr>";
				$cols = ceil(min(count($arr) / 2, 2, 30 / $maxLength));
				if ($Format == 'Table') $cols = 1;
				for ($i = 0; $i < $cols; $i++){
					if(ceil($i * count($arr) / $cols) == count($arr))
						$table .= "<td>&nbsp;</td>";
					else
						$table .= "<td><ul><li>".
							join("</li><li>", array_slice($arr, ceil($i * count($arr) / $cols), ceil(count($arr) / $cols))).
							"</li></ul></td>";
				}
				$table .= "</tr></table>";
				return $table;
			}else{
				return;
			}
		}
		return join(', ', $arr);
	}

	function formatObjectStoichiometry($item){
		if (strpos($item, ' ') !== false){
			if(strpos($item, '[') !== false){
				preg_match('/^\((.*?)\) (.*?)\[(.*?)\]$/', $item, $matches);
				return
					"(".$matches[1].") ".
					$this->formatObjectReference($matches[2], $this->knowledgeBase->wholeCellModelIDs[$matches[2]]).
					"[".$this->formatObjectReference($matches[3], $this->knowledgeBase->wholeCellModelIDs[$matches[3]])."]";
			}else{
				preg_match('/^\((.*?)\) (.*?)$/', $item, $matches);
				return
					"(".$matches[1].") ".
					$this->formatObjectReference($matches[2], $this->knowledgeBase->wholeCellModelIDs[$matches[2]]);
			}
		}else{
			if(strpos($item, '[') !== false){
				preg_match('/^(.*?)\[(.*?)\]$/', $item, $matches);
				return
					$this->formatObjectReference($matches[1], $this->knowledgeBase->wholeCellModelIDs[$matches[1]]).
					"[".$this->formatObjectReference($matches[2], $this->knowledgeBase->wholeCellModelIDs[$matches[2]])."]";
			}else{
				return $this->formatObjectReference($item, $this->knowledgeBase->wholeCellModelIDs[$item]);
			}
		}
	}

	function formatObjectReference($XID, $object){
		if (!$XID) return;
		$KnowledgeBaseWID = $this->knowledgeBase->wid;
		return $this->formatLink($XID, "index.php?Format=List&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=".$object['TableID']."&WID=".$object['WID'], null, false);
	}

	function formatCrossReference($id, $link, $title){
		if (!$id) return;
		return $this->formatLink($id, sprintf($link, $id), $title);
	}

	function formatLink($text, $link, $title = null, $external = true){
		if ($external)
			return sprintf("%s <a href=\"%s\" target=\"_top\" class=\"crossReference\"><img style=\"position:relative; top:4px;\" src=\"../images/icons/link.png\"".($title ? " title=\"$title\"" : "")."/></a>",$text, $link);
		else
			return sprintf("<a href=\"%s\" target=\"_top\" class=\"objectReference\"".($title ? " title=\"$title\"" : "").">%s</a>",$link, $text);
	}
	
	function formatNumber($number){
		return "<span class=\"number\">$number</span>";
	}
	
	function formatPropertyName($property){
		return $property['name'].
			($property['usedInSimulation'] ? "<span class=\"symbol sup\" title=\"Property used in simulation\">".self::symbol_property_usedInSimulation."</span>" : "").
			($property['calculated'] == 1 ? "<span class=\"symbol sup\" title=\"Property calculated in simulation\">".self::symbol_property_calculcated_1."</span>" : "").
			($property['calculated'] == 2 ? "<span class=\"symbol sup\" title=\"Property trivially calculated in simulation\">".self::symbol_property_calculcated_2."</span>" : "").
			($property['calculated'] == 3 ? "<span class=\"symbol sup\" title=\"Property calculated by third-party\">".self::symbol_property_calculcated_3."</span>" : "");
	}

	function parseTableImageURLCallback($match){
		$propertyCategory = $this->knowledgeBase->schema[$this->tableID]['columns'][$match[1]]['propertyCategory'];
		$propertyID =$this->knowledgeBase->schema[$this->tableID]['columns'][$match[1]]['propertyID'];
		if($propertyCategory)
			return $this->$propertyCategory->$propertyID;
		return urlencode($this->$propertyID);
	}

	function formatPropertyInputBox($values, $columnID, $column){	
		switch($column['format']){
			case 'comments':
				return "<textarea name=\"$columnID\" class=\"textarea\">$values</textarea>";
			case 'objectReferences':
				return $this->formatObjectReferenceInputBox($values, $columnID, $column);
			case 'enumerations':
				return $this->formatEnumerationInputBox($values, $columnID, $column);
			default:
				return "<input name=\"$columnID\" type=\"text\" class=\"text\" value=\"".htmlspecialchars($values, ENT_COMPAT)."\" title=\"".htmlspecialchars($column['instructions'])."\"/>";
		}
	}

	function formatObjectReferenceInputBox($value, $columnID, $column){
		$html = '';
		if (array_key_exists('objectReferences', $column) && $column['objectReferenceType']!='composition'){
			$values = explode(';', $value);
			$html .= "<select name=\"$columnID".($column['multipleObjectReferences'] == true ? "[]" : "")."\" class=\"select\"".($column['multipleObjectReferences'] == true ? " MULTIPLE size=\"6\"" : "").">";
			$html .= "<option value=\"\">Select ".$column['name']."</option>";
			$html .= "<option value=\"\" disabled=\"disabled\">==========</option>";
			foreach ($column['objectReferences'] as $tableID){
				if ($this->knowledgeBase->schema[$this->tableID][$tableID]['displayLevel'] > 0) continue;
				if (count($column['objectReferences']) > 1){
					$html .= "<optgroup label=\"$tableID\">";
				}
				foreach ($this->knowledgeBase->wholeCellModelIDs as $XID => $object){
					if ($object['TableID'] == $tableID){
							$html .= "<option value=\"".$object['WholeCellModelID']."\"".(array_search($object['WholeCellModelID'], $values) !== false ? " SELECTED" : "").">".$object['WholeCellModelID'].": ".$object['Name']."</option>";
					}
				}
				if (count($column['objectReferences']) > 1){
					$html .= "</optgroup>";
				}
			}
			$html .= "</select>";
		}else{
			$html .= "<input name=\"$columnID\" type=\"text\" class=\"text\" value=\"".htmlspecialchars($value, ENT_COMPAT)."\"/>";
		}
		return $html;
	}

	function formatEnumerationInputBox($values, $columnID, $column){
		$html = '';
		$html .= "<select name=\"$columnID\" class=\"select\">";
		$html .= "<option value=\"\">Select ".$column['name']."</option>";
		$html .= "<option value=\"\" disabled=\"disabled\">==========</option>";
		foreach($column['enumerations'] as $itemValue => $itemText){
			if ($object['TableID'] == $tableID){
				$html .= "<option value=\"$itemValue\"".($itemValue == $values ? " SELECTED" : "").">$itemText</option>";
			}
		}
		$html .= "</select>";
		return $html;
	}

	function formatDescription($column){
		if ($column['description']) return "<img class=\"help\" src=\"../images/icons/help.png\" title=\"".htmlspecialchars($column['description'], ENT_COMPAT)."\"/>";
		return "&nbsp;";
	}

	function formatInstructions($column){
		if ($column['description'] && $column['instructions'])
			return "<img class=\"help\"  src=\"../images/icons/help.png\" title=\"".htmlspecialchars($column['description'].". ".$column['instructions'], ENT_COMPAT).".\"/>";
		elseif ($column['description'])
			return "<img class=\"help\"  src=\"../images/icons/help.png\" title=\"".htmlspecialchars($column['description'], ENT_COMPAT)."\"/>";
		elseif ($column['instructions'])
			return "<img class=\"help\"  src=\"../images/icons/help.png\" title=\"".htmlspecialchars($column['instructions'], ENT_COMPAT).".\"/>";
		return "&nbsp;";
	}

}
?>
