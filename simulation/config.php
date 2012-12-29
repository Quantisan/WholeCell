<?php

//options
$fullOptions = true;
$pageOptions = array(
	'index' => array(
		'displayPBSIDs'         => $fullOptions,
		'displayRevision'       => $fullOptions,
		'displayEmail'          => $fullOptions,
		'displayUserName'       => $fullOptions,
		'displayHostName'       => $fullOptions,
		'displayIpAddress'      => $fullOptions,
	),
	'viewWTSimulations' => array(
		'displayDownload'       => !$fullOptions,
		'displayErrorLog'       => $fullOptions,
		'displayStatusSummary'  => $fullOptions,
		'displayRunTime'        => $fullOptions,
		'displayQueue'          => $fullOptions,		
	),
	'viewSingleGeneDeletions' => array(
		'displayPlots'          => $fullOptions,
		'displayReactions'      => $fullOptions,
		'displayEssential'      => $fullOptions,
		'displayAnalysis'       => $fullOptions,
		'displayRevision'       => $fullOptions,
		'displayStatusSummary'  => $fullOptions,
		'displayRunTime'        => $fullOptions,
		'displayDownload'       => !$fullOptions,
		'displayError'          => $fullOptions,
		'displayQueue'          => $fullOptions,
	),
	'viewSimulationSet' => array(
		'enableRefresh'         => $fullOptions,
		'displaySummary'        => $fullOptions,
		'displayStatusSummary'  => $fullOptions,
		'displayRunTime'        => $fullOptions,
		'displayDownload'       => !$fullOptions,
		'displayErrorLog'       => $fullOptions,
		'displayQueue'          => $fullOptions,
		'displayPBSID'          => $fullOptions,		
		'displayEmail'          => $fullOptions,
		'displayHostName'       => $fullOptions,
		'displayRevision'       => $fullOptions,
	),
	'viewSimulationLog' => array(
		'redirect'              => !$fullOptions,
	),
	'runSimulations' => array(
		'enableQueueSimulation' => $fullOptions,
	),
	'pageTemplate' => array(
		'enableQueueSimulation' => $fullOptions,
	),
);

//paths
$baseDir = '/home/projects/WholeCell/simulation/output/runSimulation';
$baseURL = 'http://covertlab.stanford.edu/projects/WholeCell/simulation';
$simulationResultsURL = 'http://covertlab.stanford.edu/projects/WholeCell/simulation/output/runSimulation';
$webSVNURL = 'http://covertlab.stanford.edu/websvn/wsvn/WholeCell?op=revision&rev=%d';
$gangliaJobURL = 'http://covertlab-cluster.stanford.edu/ganglia/addons/rocks/job.php?c=covertlab-cluster&id=';
$gangliaQueueURL = 'http://covertlab-cluster.stanford.edu/ganglia/addons/rocks/queue.php?c=covertlab-cluster';
$checkJobURL = 'http://covertlab-cluster.stanford.edu/cgi-bin/checkjob.cgi?jobid=';

//cache paths
$simulationMetaDataCache = array(
	'allBatches' => 'data/allSimulationBatches.json', 
	'batches' => 'data/simulationBatches.json', 
	'wildType' => 'data/wildTypeSimulations.json',
	'allDeletions' => 'data/allDeletionSimulations.json',
	'deletionStrains' => 'data/deletionStrainSimulations.json',
	);

//knowledge base configuration
require('../knowledgebase/configuration.php');
$kbConfig = $configuration;

//user database configuration
$dbConfig['hostName'] = 'covertlab.stanford.edu';
$dbConfig['userName'] = 'covertlab';
$dbConfig['password'] = 'covertlab';
$dbConfig['schema'] = 'covertlab';

?>
