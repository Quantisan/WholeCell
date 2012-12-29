<?php

//display errors
ini_set('display_errors', 1);

//load methods
require('config.php');
require_once '../knowledgebase/library.php';
require_once 'library.php';

#get KB WID
$result = runQuery("CALL get_latest_knowledgebase('WholeCell');", $kbConfig); $kbWID = $result['WID'];

//initialize data
$data = '';

#default values of options
$nodes = array();
list($nodes, $data) = createRow($nodes, $data, 'options', 'Options', null, null, 0, false, false, true, null, null);
$options = json_decode(file_get_contents('data/options.json'), true);

foreach($options as $name => $defaultValue){
	if ($name == 'states' || $name == 'processes')
		continue;
	$readonly = is_array($defaultValue);
	list($nodes, $data) = createRow($nodes, $data, "options_global_$name", $name, $defaultValue, "options", 1, true, !$readonly, false, null, null);
}

list($nodes, $data) = createRow($nodes, $data, 'options_states', 'States', null, 'options', 1, false, false, false, null, null);
foreach($options['states'] as $state => $stateOptions){
	if (count($stateOptions) >= 1)
		list($nodes, $data) = createRow($nodes, $data, "options_states_$state", $state, null, "options_states", 2, false, false, false, null, null);
	foreach($stateOptions as $name => $defaultValue){
		$readonly = is_array($defaultValue);
		list($nodes, $data) = createRow($nodes, $data, "options_states_".$state."_".$name, $name, $defaultValue, "options_states_$state", 3, true, !$readonly, false, null, null);
	}
}

list($nodes, $data) = createRow($nodes, $data, 'options_processes', 'Processes', null, 'options', 1, false, false, false, null, null);
foreach($options['processes'] as $process => $processOptions){
	if (count($processOptions) >= 1)
		list($nodes, $data) = createRow($nodes, $data, "options_processes_$process", $process, null, "options_processes", 2, false, false, false, null, null);
	foreach($processOptions as $name => $defaultValue){
		$readonly = is_array($defaultValue);
		list($nodes, $data) = createRow($nodes, $data, "options_processes_".$process."_".$name, $name, $defaultValue, "options_processes_$process", 3, true, !$readonly, false, null, null);
	}
}

#default values of parameter
$parameters = json_decode(file_get_contents('data/parameters.json'), true);
$link = databaseConnect($kbConfig);
list($nodes, $data) = createRow($nodes, $data, 'parameters', 'Parameters', null, null, 0, false, false, true, null, null);

list($nodes, $data) = createRow($nodes, $data, 'parameters_states', 'States', null, 'parameters', 1, false, false, true, null, null);
$stateResult = mysql_query("
  SELECT * 
  FROM State 
  join DBID on DBID.otherwid=State.wid
  WHERE DataSetWID=$kbWID;") or die(mysql_error());
while ($state = mysql_fetch_array($stateResult, MYSQL_ASSOC)){  
	$parameterResult = mysql_query("
	select
		Parameter.Name, 
		Parameter.Identifier `Index`,
		Parameter.Description, 
		CommentTable.Comm Comment,
		Parameter.DefaultValue, 
		Parameter.ExperimentallyConstrained, 
		Term.Name Units
	from ParameterWIDOtherWID 
	join Parameter on Parameter.wid=ParameterWIDOtherWID.Parameterwid 
	join Term on Term.wid=Parameter.UnitsWID
	join CommentTable on CommentTable.otherwid=Parameter.wid
	where ParameterWIDOtherWID.otherwid=".$state['WID'].";") or die(mysql_error());
	if (mysql_num_rows($parameterResult) > 0)
		list($nodes, $data) = createRow($nodes, $data, "parameters_states_".substr($state['XID'], 6), $state['Name'], null, "parameters_states", 2, false, false, false, null, null);
	$tmp = array();
	while ($parameter = mysql_fetch_array($parameterResult, MYSQL_ASSOC)){
		if ($parameter['Index']) {			
			if (!array_key_exists($parameter['Name'], $tmp))
				list($nodes, $data) = createRow($nodes, $data,
					"parameters_states_".substr($state['XID'], 6)."_".$parameter['Name'], 
					$parameter['Name'], null, 
					"parameters_states_".substr($state['XID'], 6), 
					3, false, false, false, null, null);
			$defaultValue = $parameter['DefaultValue'];			
			list($nodes, $data) = createRow($nodes, $data,
				"parameters_states_".substr($state['XID'], 6)."_".$parameter['Name']."_".$parameter['Index'], 
				$parameter['Index'], $defaultValue, 
				"parameters_states_".substr($state['XID'], 6)."_".$parameter['Name'], 
				4, true, true, false, $parameter['Units'], utf8_decode($parameter['Comment']));
			$tmp[$parameter['Name']] = true;
		} else{
			//$defaultValue = $parameter['DefaultValue'];
			$defaultValue = $parameters['states'][substr($state['XID'], 6)][$parameter['Name']];
			list($nodes, $data) = createRow($nodes, $data,
				"parameters_states_".substr($state['XID'], 6)."_".$parameter['Name'], 
				$parameter['Name'], $defaultValue, 
				"parameters_states_".substr($state['XID'], 6), 
				3, true, true, false, $parameter['Units'], utf8_decode($parameter['Comment']));
		}
	}
}

list($nodes, $data) = createRow($nodes, $data, 'parameters_processes', 'Processes', null, 'parameters', 1, false, false, true, null, null);
$processResult = mysql_query("
  SELECT * 
  FROM Process 
  join DBID on DBID.otherwid=Process.wid
  WHERE DataSetWID=$kbWID;") or die(mysql_error());
while ($process = mysql_fetch_array($processResult, MYSQL_ASSOC)){  
	$parameterResult = mysql_query("
	select
		Parameter.Name, 
		Parameter.Identifier `Index`,
		Parameter.Description, 
		CommentTable.Comm Comment,
		Parameter.DefaultValue, 
		Parameter.ExperimentallyConstrained, 
		Term.Name Units
	from ParameterWIDOtherWID
	join Parameter on Parameter.wid=ParameterWIDOtherWID.parameterwid 
	join Term on Term.wid=Parameter.UnitsWID
	join CommentTable on CommentTable.otherwid=Parameter.wid
	where ParameterWIDOtherWID.otherwid=".$process['WID'].";") or die(mysql_error());
	if (mysql_num_rows($parameterResult) > 0)
		list($nodes, $data) = createRow($nodes, $data, "parameters_processes_".substr($process['XID'], 8), $process['Name'], null, "parameters_processes", 2, false, false, false, null, null);
	$tmp = array();
	while ($parameter = mysql_fetch_array($parameterResult, MYSQL_ASSOC)){
		if ($parameter['Index']) {			
			if (!array_key_exists($parameter['Name'], $tmp))
				list($nodes, $data) = createRow($nodes, $data,
					"parameters_processes_".substr($process['XID'], 8)."_".$parameter['Name'], 
					$parameter['Name'], null, 
					"parameters_processes_".substr($process['XID'], 8), 
					3, false, false, false, null, null);
			$defaultValue = $parameter['DefaultValue'];
			list($nodes, $data) = createRow($nodes, $data,
				"parameters_processes_".substr($process['XID'], 8)."_".$parameter['Name']."_".$parameter['Index'], 
				$parameter['Index'], $defaultValue, 
				"parameters_processes_".substr($process['XID'], 8)."_".$parameter['Name'], 
				4, true, true, false, $parameter['Units'], utf8_decode($parameter['Comment']));
			$tmp[$parameter['Name']] = true;
		} else{
			//$defaultValue = $parameter['DefaultValue'];
			$defaultValue = $parameters['processes'][substr($process['XID'],8)][$parameter['Name']];
			list($nodes, $data) = createRow($nodes, $data,
				"parameters_processes_".substr($process['XID'], 8)."_".$parameter['Name'], 
				$parameter['Name'], $defaultValue, 
				"parameters_processes_".substr($process['XID'], 8), 
				3, true, true, false, $parameter['Units'], utf8_decode($parameter['Comment']));
		}
	}
}
mysql_close($link);

#fixed constants
list($nodes, $data) = createRow($nodes, $data, 'fixedConstants', 'Fitted Constants', null, null, 0, false, false, false, null, null);
$fixedConstants = json_decode(file_get_contents('data/fixedConstants.json'), true);

list($nodes, $data) = createRow($nodes, $data, 'fixedConstants_states', 'States', null, 'fixedConstants', 1, false, false, false, null, null);
foreach($fixedConstants['states'] as $state => $statefixedConstants){
	if (count($statefixedConstants) >= 1)
		list($nodes, $data) = createRow($nodes, $data, "fixedConstants_states_".$state, $state, null, 'fixedConstants_states', 2, false, false, false, null, null);
	foreach($statefixedConstants as $name=>$defaultValue){
		list($nodes, $data) = createRow($nodes, $data, "fixedConstants_states_".$state."_".$name, $name, null, "fixedConstants_states_".$state, 3, true, false, false, null, null);
	}
}

list($nodes, $data) = createRow($nodes, $data, 'fixedConstants_processes', 'Processes', null, 'fixedConstants', 1, false, false, false, null, null);
foreach($fixedConstants['processes'] as $process=>$processfixedConstants){
	if (count($processfixedConstants) >= 1)
		list($nodes, $data) = createRow($nodes, $data, "fixedConstants_processes_".$process, $process, null, 'fixedConstants_processes', 2, false, false, false, null, null);
	foreach($processfixedConstants as $name=>$defaultValue){
		list($nodes, $data) = createRow($nodes, $data, "fixedConstants_processes_".$process."_".$name, $name, null, "fixedConstants_processes_".$process, 3, true, false, false, null, null);
	}
}

#fitted constants
list($nodes, $data) = createRow($nodes, $data, 'fittedConstants', 'Fitted Constants', null, null, 0, false, false, false, null, null);
$fittedConstants = json_decode(file_get_contents('data/fittedConstants.json'), true);

list($nodes, $data) = createRow($nodes, $data, 'fittedConstants_states', 'States', null, 'fittedConstants', 1, false, false, false, null, null);
foreach($fittedConstants['states'] as $state => $statefittedConstants){
	if (count($statefittedConstants) >= 1)
		list($nodes, $data) = createRow($nodes, $data, "fittedConstants_states_".$state, $state, null, 'fittedConstants_states', 2, false, false, false, null, null);
	foreach($statefittedConstants as $name=>$defaultValue){
		list($nodes, $data) = createRow($nodes, $data, "fittedConstants_states_".$state."_".$name, $name, null, "fittedConstants_states_".$state, 3, true, false, false, null, null);
	}
}

list($nodes, $data) = createRow($nodes, $data, 'fittedConstants_processes', 'Processes', null, 'fittedConstants', 1, false, false, false, null, null);
foreach($fittedConstants['processes'] as $process=>$processfittedConstants){
	if (count($processfittedConstants) >= 1)
		list($nodes, $data) = createRow($nodes, $data, "fittedConstants_processes_".$process, $process, null, 'fittedConstants_processes', 2, false, false, false, null, null);
	foreach($processfittedConstants as $name=>$defaultValue){
		list($nodes, $data) = createRow($nodes, $data, "fittedConstants_processes_".$process."_".$name, $name, null, "fittedConstants_processes_".$process, 3, true, false, false, null, null);
	}
}

//print JSON
$data = substr($data, 0, -2);
$total = count($nodes);
echo <<<JSON
{
	"userdata":[],
	"total":$total,
	"page":1,
	"rows":[
$data
	]
}
JSON;

//helper functions
function createRow($nodes, $data, $id, $name, $value, $parent, $level, $isLeaf, $editable, $expanded, $units, $description){
	$nodes[$id] = count($nodes)+1;
	
	if (is_array($value))
		$value = null;
	$units = str_replace('"', '\"', $units);		
	$description = str_replace('"', '\"', $description);
	
	$description = "";
	
	$indent = str_repeat("\t", $level+1);
	return array($nodes, $data.$indent."{".
		"\"id\":\"".$nodes[$id]."\", ".
		"\"wholeCellModelID\":\"".$id."\", ".
		"\"name\":\"$name\", ".
		"\"value\":\"$value\", ".
		"\"parent\":".($parent ? "\"".$nodes[$parent]."\"" : "null").", ".
		"\"level\":\"$level\", ".
		"\"isLeaf\":\"".($isLeaf ? 'true' : 'false')."\", ".
		"\"loaded\":\"true\", ".
		"\"editable\":\"".($editable ? 'true' : 'false')."\", ".
		"\"expanded\":\"".($expanded ? 'true' : 'false')."\", ".
		"\"modified\":\"false\", ".
		"\"units\":\"$units\", ".
		"\"description\":\"$description\"".
		"},\n");
}

?>