<?php

ini_set('display_errors', 1);
ini_set('max_execution_time', 10 * 60);
set_time_limit(10 * 60);

require('config.php');
require_once '../knowledgebase/library.php';

#database configuration
require('../knowledgebase/configuration.php');
$result = runQuery("CALL get_latest_knowledgebase('WholeCell');", $configuration); $kbWID = $result['WID'];
$link = databaseConnect($configuration);

#server information
$serverIpAddress = $_SERVER['SERVER_ADDR'];
$scriptFileName = $_SERVER['HTTP_REFERER'];
$scriptBaseDir = substr($scriptFileName, 0, strlen($scriptFileName) - strpos(strrev($scriptFileName), '/') - 1);
$serverUser = exec('whoami');

#user information
$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];
$email = $_POST['email'];
$affiliation = $_POST['affiliation'];
$revision = trim(`svn info | grep 'Revision:' | cut "-d:" -f2`);

#simulation information
$shortDescription = $_POST['shortDescription'];
$longDescription = $_POST['longDescription'];
$userName = $_POST['userName'];
$hostName = $_POST['hostName'];
$ipAddress = $_POST['ipAddress'];
$replicates = $_POST['replicates'];

if ($pageOptions['runSimulations']['enableQueueSimulation']){
	$differencesFromRevision = htmlentities(`svn diff`);
}else{
	$differencesFromRevision = '';
}

#validate data
$invalid = '';

if ($firstName == '')
	$invalid.="Invalid first name.<br/>";
if ($lastName == '')
	$invalid.="Invalid last name.<br/>";
if ($email == '')
	$invalid.="Invalid email.<br/>";
if ($affiliation == '')
	$invalid.="Invalid affilation.<br/>";

if ($shortDescription == '')
	$invalid.="Invalid simulation name.<br/>";
if ($longDescription == '')
	$invalid.="Invalid simulation description.<br/>";
	
if ($userName == '')
	$invalid.="Invalid user name.<br/>";
if ($hostName == '')
	$invalid.="Invalid host name.<br/>";
if ($ipAddress == '')
	$invalid.="Invalid IP address.<br/>";
	
if (!is_numeric($replicates) || ceil($replicates)!=$replicates || $replicates < 1)
	$invalid.="Invalid replicates.<br/>";

#options
$tmpArr = json_decode(substr(str_replace(array("\\\\\\\"", "\\\""), array("\"", "\""), $_POST['options']), 1, -1), true);
if (!$tmpArr)
	$tmpArr = array();
$selectedOptions = array();
foreach ($tmpArr as $tmp){
	$selectedOptions[$tmp['id']] = $tmp['value'];
}

$options = json_decode(file_get_contents('data/options.json'), true);
$optionValues = '';

foreach($options as $name => $defaultValue){
	if ($name=='states' || $name=='processes')
		continue;
	$value = $selectedOptions["options_global_$name"];
	if (is_null($value))
		continue;
	if (!is_numeric($value) && is_numeric($defaultValue))
		$invalid.="Invalid option $name.<br/>";
	if (is_array($defaultValue))
		continue;
	if ($value != $defaultValue)
		$optionValues .= "\t\t<option name=\"$name\" value=\"$value\"/>\n";
}

foreach($options['states'] as $state => $stateOptions){
	foreach($stateOptions as $name=>$defaultValue){
		$value = $selectedOptions["options_states_".$state."_".$name];
		if (is_null($value))
			continue;
		if (!is_numeric($value) && is_numeric($defaultValue))
			$invalid.="Invalid option $state:$name.<br/>";
		if (is_array($defaultValue))
			continue;
		if ($value != $defaultValue)
			$optionValues .= "\t\t<option state=\"$state\" name=\"$name\" value=\"$value\"/>\n";
	}
}
foreach($options['processes'] as $process=>$processOptions){
	foreach($processOptions as $name=>$defaultValue){
		$value = $selectedOptions["options_processes_".$process."_".$name];
		if (is_null($value))
			continue;
		if (!is_numeric($value) && is_numeric($defaultValue))
			$invalid.="Invalid option $process:$name.<br/>";
		if (is_array($defaultValue))
			continue;
		if ($value != $defaultValue)
			$optionValues .= "\t\t<option process=\"$process\" name=\"$name\" value=\"$value\"/>\n";
	}
}
if ($optionValues)
	$optionValues = "<options>\n\t\t".$optionValues."\n\t\t</options>";

#parameters
$parameterValues = '';
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
	join Parameter on Parameter.wid=ParameterWIDOtherWID.parameterwid
	join Term on Term.wid=Parameter.UnitsWID
	join CommentTable on CommentTable.otherwid=Parameter.wid
	where ParameterWIDOtherWID.otherwid=".$state['WID'].";") or die(mysql_error());
	while ($parameter = mysql_fetch_array($parameterResult, MYSQL_ASSOC)){
		$stateID = substr($state['XID'],6);
		$name = $parameter['Name'];
		$index = $parameter['Index'];

		$value = $selectedOptions["parameters_states_".$stateID."_".$name.($index ? "_".$index : "")];
		if (is_null($value))
			continue;

		if (!is_numeric($value) && is_numeric($parameter['DefaultValue']))
			$invalid.="Invalid parameter $stateID:$name.<br/>";
		$parameterValues .= "\t\t<parameter state=\"$stateID\" name=\"$name\" value=\"$value\"".($parameter['Index'] ? " index=\"".$parameter['Index']."\"" : "")."/>\n";
	}
}
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
	while ($parameter = mysql_fetch_array($parameterResult, MYSQL_ASSOC)){
		$processID = substr($process['XID'],8);
		$name = $parameter['Name'];
		$index = $parameter['Index'];

		$value = $selectedOptions["parameters_processes_".$processID."_".$name.($index ? "_".$index : "")];
		if (is_null($value))
			continue;

		if (!is_numeric($value) && is_numeric($parameter['DefaultValue']))
			$invalid.="Invalid parameter $processID:$name.<br/>";
		$parameterValues .= "\t\t<parameter process=\"$processID\" name=\"$name\" value=\"$value\"".($parameter['Index'] ? " index=\"".$parameter['Index']."\"" : "")."/>\n";
	}
}
if ($parameterValues)
	$parameterValues = "<parameters>\n\t\t".$parameterValues."\n\t\t</parameters>";

#if data valid, build xml file and queue simulation
if ($invalid && !$_FILES['conditionsXMLFile']['name']){
	$title = 'Error';
	$content = $invalid;
} else {
	#build xml file
	$optionValues = trim($optionValues);
	$parameterValues = trim($parameterValues);
	if ($optionValues)
		$optionValues = "\n\t\t".$optionValues;
	if ($parameterValues)
		$parameterValues = "\n\t\t".$parameterValues;

	$time = date('Y_m_d_H_i_s');
	$currTime = gmdate("D, d M Y H:i:s") . " GMT";
	$xmlFileName = "tmp/$time.xml";

	$xml=<<<XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
Condition set autogenerated by $scriptFileName at $currTime.
-->
<conditions
	xmlns="http://covertlab.stanford.edu"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://covertlab.stanford.edu runSimulations.xsd">
	<firstName>$firstName</firstName>
	<lastName>$lastName</lastName>
	<userName>$userName</userName>
	<email>$email</email>
	<affiliation>$affiliation</affiliation>
    <hostName>$hostName</hostName>
    <ipAddress>$ipAddress</ipAddress>
	<revision>$revision</revision>
	<differencesFromRevision><![CDATA[$differencesFromRevision]]></differencesFromRevision>
	<condition>
		<shortDescription><![CDATA[$shortDescription]]></shortDescription>
		<longDescription><![CDATA[$longDescription]]></longDescription>
		<replicates>$replicates</replicates>$optionValues$parameterValues
	</condition>
</conditions>
XML;

	#write xml file to disk
	if ($_FILES['conditionsXMLFile']['name']){
		$xml = new DOMDocument();
		$xml->load($_FILES['conditionsXMLFile']['tmp_name']);

		//metadata
		$firstNameXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('firstName');
		$lastNameXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('lastName');
		$affiliationXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('affiliation');
		$emailXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('email');
		$userNameXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('userName');
		$hostNameXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('hostName');
		$ipAddressXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('ipAddress');
		$revisionXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('revision');
		$differencesFromRevisionXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('differencesFromRevision');

		if ($firstNameXML->length > 0) $firstNameXML->item(0)->nodeValue = $firstName;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("firstName", $firstName));

		if ($lastNameXML->length > 0) $lastNameXML->item(0)->nodeValue = $lastName;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("lastName", $lastName));

		if ($affiliationXML->length > 0) $affiliationXML->item(0)->nodeValue = $affiliation;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("affiliation", $affiliation));

		if ($emailXML->length > 0) $emailXML->item(0)->nodeValue = $email;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("email", $email));

		if ($userNameXML->length > 0) $userNameXML->item(0)->nodeValue = $userName;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("userName", $userName));

		if ($hostNameXML->length > 0) $hostNameXML->item(0)->nodeValue = $hostName;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("hostName", $hostName));

		if ($ipAddressXML->length > 0) $ipAddressXML->item(0)->nodeValue = $ipAddress;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("ipAddress", $ipAddress));

		if ($revisionXML->length > 0) $revisionXML->item(0)->nodeValue = $revision;
		else $xml->getElementsByTagName('conditions')->item(0)->appendChild($xml->createElement("revision", $revision));

		if ($differencesFromRevisionXML->length > 0) $differencesFromRevisionXML->item(0)->nodeValue = $differencesFromRevision;
		else{
			$differencesFromRevisionXML = $xml->createElement("differencesFromRevision");
			$differencesFromRevisionXML->appendChild($xml->createCDATASection($differencesFromRevision));
			$xml->getElementsByTagName('conditions')->item(0)->appendChild($differencesFromRevisionXML);
		}

		$xml->save($xmlFileName);
	}else{
		if ($pageOptions['runSimulations']['enableQueueSimulation']){
			file_put_contents($xmlFileName, $xml);
		}else{
			header('Content-type: text/xml');
			header('Content-Disposition: attachment; filename="conditions.xml"');
			header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
			echo str_replace("\n\n", "\n", $xml);
			exit;
		}
	}
	exit;

	#queue simulation
	$result = `ssh -i /var/www/.ssh/cluster.key jkarr@covertlab-cluster.stanford.edu "cd $scriptBaseDir; ./runSimulations.pl $xmlFileName" 2>&1`;
	if (preg_match('/Simulation set #(\d+) queued with (\d+) simulations/', $result, $matches)) {
		$simulationIdx = $matches[1];
		$title = 'Simulation queued';
		$content = "Simulation #$simulationIdx succesfully queued!";
	}else{
		$title = 'Error';
		$content = "Failed to queue simulation: $result.";
	}
}

#close database connection
mysql_close($link);

#format content
require('../pageTemplate.php');

$navigationContents = array(
	array('url' => 'index.php', 'text' => 'Simulations'),
	array('url' => 'runSimulations.php', 'text' => 'Queue Simulations: '.$title));

$content = <<<HTML
<div id="Object" class="List"><div>
$content
</div></div>
HTML;

echo composePage($content, $navigationContents, array(), 'simulation');

?>
