<?php

//load methods
require('config.php');
require_once('library.php');

//configuration
extract($_GET);
if (!$job) $job = 'simulation';
if (!$log) $log = 'out';
if (!$format) $format = 'log';
$simGroupDate = join("-", array_slice(explode('_', $id), 0, 3)).' '.join(":", array_slice(explode('_', $id), 3, 3));

//redirect
if ($pageOptions['viewSimulationLog']['redirect']){
	if ($format == 'mat' && $log == 'out') 
		$logFile = "$simulationResultsURL/$id/$idx/summary.$format";
	else
		$logFile = "$simulationResultsURL/$id/$idx/$log.$format";	
	header("Location: $logFile");
	exit;
}

//get status
$pbsid = getPBSID($id, $baseDir);
$statuses = getJobStatuses();
switch ($job){
	case 'simulation':
		if (file_exists("$baseDir/$id/$idx/simulation.pbsid"))
			$pbsJobId = trim(file_get_contents("$baseDir/$id/$idx/simulation.pbsid"));
		else		
			$pbsJobId = $pbsid + $idx - 1;
		if ($format == 'mat' && $log == 'out') 
			$logFile = "$baseDir/$id/$idx/summary.$format";
		else
			$logFile = "$baseDir/$id/$idx/$log.$format";
		break;
	case 'reindexing':
		if (file_exists("$baseDir/$id/$idx/reindexing.pbsid"))
			$pbsJobId = trim(file_get_contents("$baseDir/$id/$idx/reindexing.pbsid"));
		else{
			$conditionSet = parseConditionSet("$baseDir/$id/conditions.xml");
			$pbsJobId = $pbsid + $conditionSet['nSimulations'] + $idx - 1;		
		}
		$logFile = "$baseDir/$id/$idx/$log.reindexing.$format";
		break;
	case 'analysis':
		if (file_exists("$baseDir/$id/analysis.pbsid")){
			$pbsJobId = file("$baseDir/$id/analysis.pbsid", FILE_IGNORE_NEW_LINES);
		}else{
			$conditionSet = parseConditionSet("$baseDir/$id/conditions.xml");
			$pbsJobId = array(
				$pbsid + 2 * $conditionSet['nSimulations'],
				$pbsid + 2 * $conditionSet['nSimulations'] + 1,
				$pbsid + 2 * $conditionSet['nSimulations'] + 2,
				$pbsid + 2 * $conditionSet['nSimulations'] + 3,
				$pbsid + 2 * $conditionSet['nSimulations'] + 4,
				$pbsid + 2 * $conditionSet['nSimulations'] + 5,
				$pbsid + 2 * $conditionSet['nSimulations'] + 6,
				$pbsid + 2 * $conditionSet['nSimulations'] + 7,
				$pbsid + 2 * $conditionSet['nSimulations'] + 8);		
			if ($conditionSet['conditions'][0]['perturbations'][0]['type'] == 'geneticKnockout'){
				$pbsJobId = array_slice($pbsJobId, 0, 2);
			}
		}
		$logFile = array();
		for ($i = 1; $i <= count($pbsJobId); $i++)
			array_push($logFile, "$baseDir/$id/$log.analysis-$i.$format");
		break;
	default:
		die("Unsupported job type '$job'");
}

if ($format == 'mat'){
	header('Content-type: application/octet-stream');
	header("Content-Disposition: attachment; filename=\"$log.mat\"");

	if (is_array($logFile)){
		foreach($logFile as $tmp){
			readfile($logFile);
		}
	}else{
		readfile($logFile);
	}
	exit;
}

//content
$Job = strtoupper(substr($job, 0, 1)).substr($job, 1);
list($logContent, $metadata) = getLogContent($statuses, $pbsJobId, $logFile, $log);
$content = <<<HTML
<pre>
$logContent
</pre>
HTML;

// layout page
require('../pageTemplate.php');
$navigationContents = array(
	array(
		'url' => 'index.php', 
		'text' => 'Simulation'), 
	array(
		'url' => "viewSimulationLog.php?id=$id&idx=$idx&job=$job&log=$log&format=$format", 
		'text' => "$Job Log #$pbsJobId $simGroupDate".($job!='analysis' ? " - $idx" : "")));
echo composePage($content, $navigationContents, array(), 'simulation');

?>