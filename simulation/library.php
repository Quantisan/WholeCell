<?php

/**********************
* functions
**********************/
function buildSimulationMetaDataCache($baseDir, $kbConfig, $simulationMetaDataCache){
	getAllSimulationBatches($baseDir, $simulationMetaDataCache, true);
	getSimulationBatches($baseDir, $simulationMetaDataCache, true);
	getWildTypeSimulations($baseDir, $simulationMetaDataCache, true);
	getAllDeletionSimulations($baseDir, $kbConfig, $simulationMetaDataCache, true);
	getDeletionStrainSimulations($baseDir, $kbConfig, $simulationMetaDataCache, true);	
	
	copy('output/runSimulation/singleGeneDeletions.svg', '../images/singleGeneDeletionsSummaryGrid.svg');
	`cd ../images; inkscape -e singleGeneDeletionsSummaryGrid.png -D -w 600 singleGeneDeletionsSummaryGrid.svg`;
}

function getAllSimulationBatches($baseDir, $simulationMetaDataCache, $rebuildCache = false){
	if (!file_exists($simulationMetaDataCache['allBatches']) || $rebuildCache) {
		file_put_contents($simulationMetaDataCache['allBatches'], calcAllSimulationBatches($baseDir));
	}
	return file_get_contents($simulationMetaDataCache['allBatches']);
}

function getSimulationBatches($baseDir, $simulationMetaDataCache, $rebuildCache = false){
	if (!file_exists($simulationMetaDataCache['batches']) || $rebuildCache) {
		file_put_contents($simulationMetaDataCache['batches'], calcSimulationBatches($baseDir));
	}
	return file_get_contents($simulationMetaDataCache['batches']);
}

function getWildTypeSimulations($baseDir, $simulationMetaDataCache, $rebuildCache = false){
	if (!file_exists($simulationMetaDataCache['wildType']) || $rebuildCache) {
		file_put_contents($simulationMetaDataCache['wildType'], calcWildTypeSimulations($baseDir));
	}
	return file_get_contents($simulationMetaDataCache['wildType']);
}

function getAllDeletionSimulations($baseDir, $kbConfig, $simulationMetaDataCache, $rebuildCache = false){
	if (!file_exists($simulationMetaDataCache['allDeletions']) || $rebuildCache) {
		file_put_contents($simulationMetaDataCache['allDeletions'], calcAllDeletionSimulations($baseDir, $kbConfig));
	}
	return file_get_contents($simulationMetaDataCache['allDeletions']);
}

function getDeletionStrainSimulations($baseDir, $kbConfig, $simulationMetaDataCache, $rebuildCache = false){
	if (!file_exists($simulationMetaDataCache['deletionStrains']) || $rebuildCache) {
		file_put_contents($simulationMetaDataCache['deletionStrains'], calcDeletionStrainSimulations($baseDir, $kbConfig));
	}
	return file_get_contents($simulationMetaDataCache['deletionStrains']);
}

function calcAllSimulationBatches($baseDir){
	$dirId = opendir($baseDir);
	$data = array();
	while (false !== ($id = readdir($dirId))) {
		if (substr($id, 0, 1) == '.' || !is_numeric(substr($id, 1, 1)))
			continue;	
		$date = join("-", array_slice(explode('_', $id), 0, 3)).' '.join(":", array_slice(explode('_', $id), 3, 3));
		$pbsid = getPBSID($id, $baseDir);
		
		$firstName = $lastName = $affiliation = $email = $userName = $hostName = $ipAddress = $revision = $nConditions = $nSimulations = '';
		if (file_exists("$baseDir/$id/conditions.xml")){
			$conditions = parseConditionSet("$baseDir/$id/conditions.xml");
			extract($conditions);
		}
		
		$data[$id] = sprintf("{id:'%s', timestamp:'%s', pbsid:'%s', date:'%s', firstName:'%s', lastName:'%s', affiliation:'%s', email:'%s', userName:'%s', hostName:'%s', ipAddress:'%s', revision:'%d', nConditions:%d, nSimulations:%d}", 
			$id, $id, $pbsid, $date, $firstName, $lastName, $affiliation, $email, $userName, $hostName, $ipAddress, $revision, $nConditions, $nSimulations);
	}
	closedir($dirId);
	krsort($data);
	return "[\n\t".join(",\n\t", $data)."\n]";
}

function calcSimulationBatches($baseDir){
	$data = array();	
	$dirId = opendir($baseDir);	
	while (false !== ($id = readdir($dirId))) {
		if (!file_exists("$baseDir/$id/conditions.xml"))
			continue;
			
		$pbsid = getPBSID($id, $baseDir);
		$conditionSet = parseConditionSet("$baseDir/$id/conditions.xml");

		$simulationData = array();
		extract($conditionSet);
		$idx = 0;
		foreach ($conditions as $i => $condition){
			for ($j = 0; $j < $condition['replicates']; $j++){
				$idx++;
				list($status, $statusDetails, $time, $mass, $growth, $runtime, $run, $err, $currpbsid) = 
					getSimulationStatus($id, $pbsid, $idx, $conditionSet['nSimulations'], $baseDir);
				array_push($simulationData, array(
					'id' => $id,
					'timestamp' => $id,
					'conditionSet' => $i+1,
					'pbsid' => $pbsid,
					'idx' => $idx,
					'status' => $status,
					'statusDetails' => $statusDetails,
					'time' => $time,
					'mass' => sprintf('%e', $mass),
					'growth' => sprintf('%e', $growth),
					'runtime' => $runtime,
					'run' => $run,
					'err' => ($err ? "$err" : "null"),
					'currpbsid' => $currpbsid,
					));
			}
		}
		
		$data[$id] = array(
			'pbsid' => $pbsid,
			'conditionSet' => $conditionSet,
			'data' => $simulationData,
			);
	}
	closedir($dirId);
	
	return json_encode($data);
}

function calcWildTypeSimulations($baseDir){
	$data = '';
	$dirId = opendir($baseDir);	
	while (false !== ($id = readdir($dirId))) {
		if (!file_exists("$baseDir/$id/conditions.xml"))
			continue;
		
		$pbsid = getPBSID($id, $baseDir);
		$simGroupDate = join("-", array_slice(explode('_', $id), 0, 3)).' '.join(":", array_slice(explode('_', $id), 3, 3));
		$conditionSet = parseConditionSet("$baseDir/$id/conditions.xml");
		$conditionsHTML = formatConditions($conditionSet['conditions']);
		extract($conditionSet);
		
		$idx = 0;
		$running = false;
		foreach ($conditions as $i => $condition){
			for ($j = 0; $j < $condition['replicates']; $j++){
				if (count($condition['perturbations']) == 0 && !file_exists("$baseDir/$id/".($idx+$j+1)."/skipAnalysis")){
					list($status, $statusDetails, $time, $mass, $growth, $runtime, $run, $err, $currpbsid) = getSimulationStatus($id, $pbsid, $idx+$j+1, $conditionSet['nSimulations'], $baseDir);
					$data .= sprintf("{id:'%s', timestamp:'%s', conditionSet:%d, pbsid:%d, idx:%d, status:'%s', statusDetails:'%s', time:'%s', mass:%e, growth:%e, runtime:'%s', run:%d, err:%s, currpbsid:'%s'},\n",
						$id, $id, $i+1, $pbsid, $idx+$j+1, $status, $statusDetails, $time, $mass, $growth, $runtime, $run, ($err ? "$err" : "null"), $currpbsid);
					if ($currpbsid)
						$running = true;
				}
			}
			$idx += $condition['replicates'];
		}
	}
	closedir($dirId);
	return "[\n".substr($data, 0, -2)."\n]";
}

function calcAllDeletionSimulations($baseDir, $kbConfig){
	$result = runQuery("CALL get_latest_knowledgebase('WholeCell');", $kbConfig);
	$kbWID = $result['WID'];
	$link = databaseConnect($kbConfig);

	$singleGeneDeletions = array();
	$nWtSimulations = 0;
	$dirId = opendir($baseDir);	
	while (false !== ($id = readdir($dirId))) {
		if (substr($id, 0, 1) == '.')
			continue;		
		if (file_exists("$baseDir/$id/conditions.xml")){
			$conditions = parseConditionSet("$baseDir/$id/conditions.xml");
			$idx = 1;
			foreach($conditions['conditions'] as $condition){
				if (count($condition['perturbations']) == 1 && $condition['perturbations'][0]['type']=='geneticKnockout'){
					if (!array_key_exists($condition['perturbations'][0]['component'], $singleGeneDeletions))
						$singleGeneDeletions[$condition['perturbations'][0]['component']] = 0;
					for ($i = 0; $i < $condition['replicates']; $i++){
						if (!file_exists("$baseDir/$id/".($idx+$i)."/skipAnalysis"))
							$singleGeneDeletions[$condition['perturbations'][0]['component']]++;
					}
				}
				if (count($condition['perturbations']) == 0){
					for ($i = 0; $i < $condition['replicates']; $i++){
						if (!file_exists("$baseDir/$id/".($idx+$i)."/skipAnalysis"))
							$nWtSimulations ++;
					}
				}
				
				$idx += $condition['replicates'];
			}			
		}
	}
	closedir($dirId);

	$keys = $data = array();
	$result = mysql_query("CALL get_genes($kbWID, null)") or die(mysql_error());	
	$key = 0;
	while ($gene = mysql_fetch_array($result, MYSQL_ASSOC)){
		$geneID = $gene['WholeCellModelID'];
		$symbol = $gene['Symbol'] . ($gene['Symbol'] && $gene['Synonyms'] ? ", " : "") . str_replace(';', ', ', $gene['Synonyms']);
		$name = ($gene['Type']=='tRNA' ? "tRNA-".$gene['AminoAcid']." (".$gene['StartCodon'].str_replace(';', ', ', $gene['Codons']).")" : str_replace('"', '\"', $gene['Name']));
		$rxns = explode(';', $gene['Reactions']);
		foreach($rxns as $i=>$rxn){
			if ($rxn)
				$rxns[$i] = "<a href='../knowledgebase/index.php?KnowledgeBaseWID=$kbWID&WholeCellModelID=$rxn'>$rxn</a>";
		}
		$rxns = join(", ", $rxns);
		$nSimulations = $singleGeneDeletions[$geneID];
		
		$fileName = "output/runSimulation/singleGeneDeletions/$geneID.pdf";
		$summary = (file_exists($fileName) ? "<a href='$geneID.pdf'>pdf</a>" : "");
		$fileName = "output/runSimulation/singleGeneDeletions/$geneID.mat";
		$summary .= (file_exists($fileName) ? ($summary != "" ? " | " : ""). "<a href='$geneID.mat'>mat</a>" : "");		
		
		$fileName = "output/runSimulation/singleGeneDeletions/$geneID-analysis.pdf";
		$analysis = (file_exists($fileName) ? "<a href='$geneID-analysis.pdf'>pdf</a>" : "");
		$fileName = "output/runSimulation/singleGeneDeletions/$geneID-analysis.mat";
		$analysis .= (file_exists($fileName) ? ($analysis != "" ? " | " : ""). "<a href='$geneID-analysis.mat'>mat</a>" : "");		
		
		switch($_GET['sidx']) { 
			case 'locus':
				$key = $geneID;
				break;
			case 'symbol':
				$key = $symbol;
				break;
			case 'name':
				$key = $name;
				break;
			case 'essential':
				$key = $gene['Essential'];
			case 'nSimulations':
				$key = $nSimulations;
				break;
			case 'summary':
				$key = $summary != "";
				break;
			case 'analysis':
				$key = $analysis != "";
				break;
			default:
				$key++;
				break;
		}
		array_push($keys, $key);
			
		array_push($data, sprintf('{"id":"%s", "cell":["%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s"]}', 
			$geneID, $gene['WholeCellModelID'], $symbol, $name, $rxns, $gene['Essential'], $nSimulations, $summary, $analysis));
	}
	if ($_GET['sord'] == 'desc')
		array_multisort($keys, SORT_DESC, $data);
	else
		array_multisort($keys, SORT_ASC, $data);
		
	$fileName = "output/runSimulation/singleGeneDeletions/WT.pdf";
	$summary = ($nWtSimulations > 0 && file_exists($fileName) ? "<a href='WT.pdf'>pdf</a>" : "");
	$fileName = "output/runSimulation/singleGeneDeletions/WT.mat";
	$summary .= ($nWtSimulations > 0 && file_exists($fileName) ? ($summary != "" ? " | " : ""). "<a href='WT.mat'>mat</a>" : "");
	
	$fileName = "output/runSimulation/singleGeneDeletions/WT-analysis.pdf";
	$analysis = ($nWtSimulations > 0 && file_exists($fileName) ? "<a href='WT-analysis.pdf'>pdf</a>" : "");
	$fileName = "output/runSimulation/singleGeneDeletions/WT-analysis.mat";
	$analysis .= ($nWtSimulations > 0 && file_exists($fileName) ? ($analysis != "" ? " | " : ""). "<a href='WT-analysis.mat'>mat</a>" : "");
	
	array_unshift($data, sprintf('{"id":"%s", "cell":["%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s"]}', 
		'WT', 'WT', null, null, null, null, $nWtSimulations, $summary, $analysis));
	
	mysql_close($link);
	return
		"{\n".
		"  \"page\":\"1\",\n".
		"  \"total\":1,\n".
		"  \"records\":\"".count($data)."\",\n".
		"  \"rows\":[\n".
		"    ".join(",\n    ", $data)."\n".
		"  ],\n".
		"  \"userdata\":[]\n".
		"}\n";
}

function calcDeletionStrainSimulations($baseDir, $kbConfig){
	$result = runQuery("CALL get_latest_knowledgebase('WholeCell');", $kbConfig);
	$kbWID = $result['WID'];
	$link = databaseConnect($kbConfig);
	
	$dirId = opendir($baseDir);
	$data = array();
	while (false !== ($id = readdir($dirId))) {
		if (substr($id, 0, 1) == '.')
			continue;		
		if (file_exists("$baseDir/$id/conditions.xml")){
			$conditions = parseConditionSet("$baseDir/$id/conditions.xml");
			$revision = $conditions['revision'];
			$pbsid = getPBSID($id, $baseDir);
			$idx = 1;
			foreach($conditions['conditions'] as $condition){
				if (count($condition['perturbations']) == 1 &&
					$condition['perturbations'][0]['type']=='geneticKnockout' &&
					$condition['perturbations'][0]['component'] != '') {
					$geneID = $condition['perturbations'][0]['component'];
				}elseif (count($condition['perturbations']) == 0){
					$geneID = 'WT';
				}else{
					$idx += $condition['replicates'];
					continue;
				}
				
				for ($i = 0; $i < $condition['replicates']; $i++){						
					list($summary, $details, $time, $mass, $growth, $runtime, $run, $err, $currpbsid) = 
						getSimulationStatus($id, $pbsid, $idx+$i, $conditions['nSimulations'], $baseDir);
				
					if ($run == 2){
						$runLog = '<a href=\'viewSimulationLog.php?id='.$id.'&idx='.($idx+$i).'&job=simulation&log=out\'>log</a> | <a href=\'viewSimulationLog.php?id='.$id.'&idx='.($idx+$i).'&job=simulation&log=out&format=mat\'>mat</a>';
					}elseif ($run == 1){
						$runLog ='<a href=\'viewSimulationLog.php?id='.$id.'&idx='.($idx+$i).'&job=simulation&log=out\'>log</a>';
					}else{
						$runLog = '';
					}
					
					if ($err){							
						$errLog = '';
						$err = json_decode($err, true);
						foreach($err as $filetype => $type){
							$errLog .= '<a href=\'viewSimulationLog.php?id='.$id.'&idx='.($idx+$i).'&job='.$type.'&log=err\'>'.$filetype.'</a> | ';
						}
						$errLog = substr($errLog, 0, -3);
					}else{
						$errLog = '';
					}
					
					if ($currpbsid){
						$queue = "<a href='".$checkJobURL.$currpbsid."'>html</a>";
					}else{
						$queue = '';
					}				
				
					if (!file_exists("$baseDir/$id/".($idx + $i)."/skipAnalysis")){
						if (!array_key_exists($geneID, $data))
							$data[$geneID] = array();
						array_push($data[$geneID], array(
							'revision' => $revision,
							'batchId'  => $id,
							'batchIdx' => $idx+$i,
							'summary'  => $summary,
							'details'  => $details,
							'time'	   => $time,
							'mass'     => $mass,
							'growth'   => $growth,
							'runtime'  => $runtime,
							'runLog'   => $runLog,
							'errLog'   => $errLog,
							'queue'    => $queue,
							));
					}
				}
				$idx += $condition['replicates'];
			}
		}
	}
	closedir($dirId);

	return json_encode($data);
}

function getPBSID($id, $baseDir){
	if (file_exists("$baseDir/$id/pbsid"))
		return trim(file_get_contents("$baseDir/$id/pbsid"));
	return null;
}

function parseConditionSet($xmlFile){
	$xml = new DOMDocument();	
	$xml->load($xmlFile);
	
	//metadata
	$firstName = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('firstName')->item(0)->nodeValue;
	$lastName = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('lastName')->item(0)->nodeValue;
	$affiliation = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('affiliation')->item(0)->nodeValue;
	$email = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('email')->item(0)->nodeValue;
	$userName = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('userName')->item(0)->nodeValue;
	$hostName = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('hostName')->item(0)->nodeValue;
	$ipAddress = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('ipAddress')->item(0)->nodeValue;
	$revision = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('revision')->item(0)->nodeValue;
	$differencesFromRevision = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('differencesFromRevision')->item(0)->nodeValue;	
	
	//conditions
	$conditionsXML = $xml->getElementsByTagName('conditions')->item(0)->getElementsByTagName('condition');
	$conditions = array();
	for ($i = 0; $i < $conditionsXML->length; $i++)
		array_push($conditions, parseCondition($conditionsXML->item($i)));
	
	$nConditions = count($conditions);
	$nSimulations = 0;
	foreach ($conditions as $condition)
		$nSimulations += $condition['replicates'];
	
	return array(
		'firstName' => $firstName,
		'lastName' => $lastName,
		'affiliation' => $affiliation,
		'email' => $email,
		'userName' => $userName,
		'hostName' => $hostName,
		'ipAddress' => $ipAddress,
		'revision' => $revision,
		'differencesFromRevision' => $differencesFromRevision,
		'nConditions' => $nConditions,
		'nSimulations' => $nSimulations,
		'conditions' => $conditions
		);
}

function parseCondition($condition){
	$options = array();
	$parameters = array();
	$perturbations = array();
	
	$replicates = $condition->getElementsByTagName('replicates')->item(0)->nodeValue;
	$shortDescription = $condition->getElementsByTagName('shortDescription')->item(0)->nodeValue;
	$longDescription = $condition->getElementsByTagName('longDescription')->item(0)->nodeValue;
	
	$optionsXML = $condition->getElementsByTagName('option');
	$parametersXML = $condition->getElementsByTagName('parameter');
	$perturbationsXML = $condition->getElementsByTagName('perturbation');
	for ($i = 0; $i < $optionsXML->length; $i++)
		array_push($options, parseOption($optionsXML->item($i)));	
	for ($i = 0; $i < $parametersXML->length; $i++)
		array_push($parameters, parseParameter($parametersXML->item($i)));	
	for ($i = 0; $i < $perturbationsXML->length; $i++)
		array_push($perturbations, parsePerturbation($perturbationsXML->item($i)));
	
	return array(
		'replicates'=>$replicates,
		'shortDescription'=>$shortDescription,
		'longDescription'=>$longDescription,
		'options'=>$options,
		'parameters'=>$parameters,
		'perturbations'=>$perturbations
		);
}

function parseOption($option){
	return array(
		'state'=>$option->getAttribute('state'),
		'process'=>$option->getAttribute('process'),
		'name'=>$option->getAttribute('name'),	
		'value'=>$option->getAttribute('value')
		);		
}

function parseParameter($parameter){
	return array(
		'state'=>$parameter->getAttribute('state'),
		'process'=>$parameter->getAttribute('process'),
		'name'=>$parameter->getAttribute('name'),		
		'index'=>$parameter->getAttribute('index'),
		'value'=>$parameter->getAttribute('value')
		);
}

function parsePerturbation($perturbation){
	return array(
		'type'=>$perturbation->getAttribute('type'),
		'compartment'=>$perturbation->getAttribute('compartment'),
		'component'=>$perturbation->getAttribute('component'),
		'initialTime'=>$perturbation->getAttribute('initialTime'),
		'finalTime'=>$perturbation->getAttribute('finalTime'),
		'value'=>$perturbation->getAttribute('value')
		);
}

function formatConditions($conditions){	
	$html = '';
	foreach ($conditions as $i => $condition){		
		$idx = $i+1;
		extract($condition);
		$longDescriptionHTML = str_replace("\n", "<br/>", $longDescription);
		$html .= <<<HTML
			<tr><th colspan="2">Condition set #$idx</th>
			<tr><th style="padding-left:10px;">Name</th><td>$shortDescription</td></tr>
			<tr><th style="padding-left:10px;vertical-align:top;">Description</th><td>$longDescriptionHTML</td></tr>
			<tr><th style="padding-left:10px;">Replicates</th><td>$replicates</td></tr>
HTML;
		if (count($options) > 0){
			$optionsHTML = '';
			foreach($options as $option){
				$optionsHTML.="<tr>\n";
				$optionsHTML.="<td>".($option['state'] || $option['process'] ? $option['state'].$option['process'] : "&nbsp;")."</td>\n";
				$optionsHTML.="<td>".($option['name'] ? $option['name'] : "&nbsp;")."</td>\n";
				$optionsHTML.="<td>".($option['value'] ? $option['value'] : "&nbsp;")."</td>\n";
				$optionsHTML.="</tr>\n";
			}
			
			$html .= <<<HTML
				<tr><th style="padding-left:10px;">Options</th><td>&nbsp;</td></tr>
				<tr><td colspan="2" style="padding-left:20px;">
					<table cellspacing="0" cellpadding="0" style="border-top:none; border-bottom:none;">
					<thead>
						<tr>
							<th style="border-top:none; border-bottom:none;">State/Process</th>
							<th style="border-top:none; border-bottom:none;">Name</th>
							<th style="border-top:none; border-bottom:none;">Value</th>
						</tr>
					</thead>
					<tbody>$optionsHTML</tbody>
					</table></td></tr>
HTML;
		}
		
		if (count($parameters) > 0){
			$parametersHTML = '';
			foreach($parameters as $parameter){
				$parametersHTML .= "<tr>\n";
				$parametersHTML.="<td>".($parameter['state'] || $parameter['process'] ? $parameter['state'].$parameter['process'] : "&nbsp;")."</td>\n";
				$parametersHTML.="<td>".($parameter['name'] ? $parameter['name'] : "&nbsp;")."</td>\n";
				$parametersHTML.="<td>".($parameter['index'] ? $parameter['index'] : "&nbsp;")."</td>\n";
				$parametersHTML.="<td>".($parameter['value'] ? $parameter['value'] : "&nbsp;")."</td>\n";
				$parametersHTML.="</tr>\n";
			}
			
			$html .= <<<HTML
				<tr><th style="padding-left:10px;">Parameters</th><td>&nbsp;</td></tr>
				<tr><td colspan="2" style="padding-left:20px;">
					<table cellspacing="0" cellpadding="0" style="border-top:none; border-bottom:none;">
					<thead>
						<tr>
							<th style="border-top:none; border-bottom:none;">State/Process</th>
							<th style="border-top:none; border-bottom:none;">Name</th>				
							<th style="border-top:none; border-bottom:none;">Index</th>
							<th style="border-top:none; border-bottom:none;">Value</th>
						</tr>
					</thead>
					<tbody>$parametersHTML</tbody>
					</table></td></tr>
HTML;
		}
		if (count($perturbations) > 0){
			$perturbationsHTML = '';			
			foreach($perturbations as $perturbation){
				$perturbationsHTML.="<tr>\n";
				$perturbationsHTML.="<td>".($perturbation['type'] ? $perturbation['type'] : "&nbsp;")."</td>\n";
				$perturbationsHTML.="<td>".($perturbation['component'] ? $perturbation['component'] : "&nbsp;")."</td>\n";
				$perturbationsHTML.="<td>".($perturbation['compartment'] ? $perturbation['compartment'] : "&nbsp;")."</td>\n";
				$perturbationsHTML.="<td>".($perturbation['initialTime'] ? $perturbation['initialTime'] : "&nbsp;")."</td>\n";
				$perturbationsHTML.="<td>".($perturbation['finalTime'] ? $perturbation['finalTime'] : "&nbsp;")."</td>\n";
				$perturbationsHTML.="<td>".($perturbation['value'] ? $perturbation['value'] : "&nbsp;")."</td>\n";
				$perturbationsHTML.="</tr>\n";
			}
			
			$html .= <<<HTML
				<tr><th style="padding-left:10px;">Perturbations</th><td>&nbsp;</td></tr>
				<tr><td colspan="2" style="padding-left:20px;">
					<table cellspacing="0" cellpadding="0" style="border-top:none; border-bottom:none;">
					<thead>
						<tr>
							<th style="border-top:none; border-bottom:none;">Type</th>
							<th style="border-top:none; border-bottom:none;">Component</th>				
							<th style="border-top:none; border-bottom:none;">Compartment</th>
							<th style="border-top:none; border-bottom:none;">Initial time</th>
							<th style="border-top:none; border-bottom:none;">Final time</th>
							<th style="border-top:none; border-bottom:none;">Value</th>
						</tr>
					</thead>
					<tbody>$perturbationsHTML</tbody>
					</table></td></tr>
HTML;
		}
	}
	return $html;
}

function getSimulationStatus($id, $pbsid, $idx, $nSimulations, $baseDir){
	$simPbsId = $pbsid + $idx - 1;
	$reindexingPbsId = $pbsid + $nSimulations + $idx - 1;
	$analysisPbsId = $pbsid + 2 * $nSimulations;
	if (file_exists("$baseDir/$id/$idx/simulation.pbsid"))
		$simPbsId = trim(file_get_contents("$baseDir/$id/$idx/simulation.pbsid"));
	if (file_exists("$baseDir/$id/$idx/reindexing.pbsid"))
		$reindexingPbsId = trim(file_get_contents("$baseDir/$id/$idx/reindexing.pbsid"));
		
	$statuses = getJobStatuses();
	$time = null;
	$runtime = null;
	$run = 0;
	$err = null;
	$statusDetails = null;
	$currpbsid = null;
	if (array_key_exists($simPbsId, $statuses)){
		$currpbsid = $simPbsId;
		if ($statuses[$simPbsId]['job_state'] == 'R'){
			$run = 1;
			$err = false;
			list($time, $mass, $growth) = getCellState($id, $pbsid, $idx, $baseDir, true, $statuses);			
			$runtime = $statuses[$simPbsId]['resources_used.walltime'];
			$status = 'Running';
			$statusDetails = 'Running on node #'. getJobNode($statuses, $simPbsId, 10, 1);
		}elseif ($statuses[$simPbsId]['job_state'] == 'Q'){
			$run = 0;
			$err = false;
			$status = 'Queued';
		}else{
			$run = 0;
			$err = false;
			$status = 'Held';
		}
	}elseif (array_key_exists($reindexingPbsId, $statuses)){
		$currpbsid = $reindexingPbsId;
		$run = 2;
		list($state, $err) = getSimulationState($id, $idx, $baseDir);
		list($time, $mass, $growth) = getCellState($id, $pbsid, $idx, $baseDir, false, $statuses);
		$runtime = getSimulationRuntime($id, $idx, $baseDir);
		if ($statuses[$reindexingPbsId]['job_state'] == 'R'){
			$status = 'Reindexing';
			$statusDetails = sprintf('%s. Reindexing: %s on node %d', $state, $statuses[$reindexingPbsId]['resources_used.walltime'], getJobNode($statuses, $reindexingPbsId));
		}elseif ($statuses[$reindexingPbsId]['job_state'] == 'Q'){
			$status = 'Reindexing queued';
			$statusDetails = $state;
		}else{
			$status = 'Reindexing held';
			$statusDetails = $state;
		}
	}elseif (array_key_exists($analysisPbsId, $statuses)){
		$currpbsid = $analysisPbsId;
		$run = 2;
		list($state, $err) = getSimulationState($id, $idx, $baseDir);
		list($time, $mass, $growth) = getCellState($id, $pbsid, $idx, $baseDir, false, $statuses);
		$runtime = getSimulationRuntime($id, $idx, $baseDir);
		if ($statuses[$analysisPbsId]['job_state'] == 'R'){
			$status = 'Analyzing';
			$statusDetails = sprintf('%s. Analyzing: %s on node %d', $state, $statuses[$analysisPbsId]['runtime'], substr($statuses[$analysisPbsId]['exec_host'], 10, 1));
		}elseif ($statuses[$analysisPbsId]['job_state'] == 'Q'){
			$status = 'Analysis queued';
			$statusDetails = $state;
		}else{
			$status = 'Analysis held';
			$statusDetails = $state;
		}
	}else{
		$currpbsid = null;
		$run = 2;
		list($state, $err) = getSimulationState($id, $idx, $baseDir);
		list($time, $mass, $growth) = getCellState($id, $pbsid, $idx, $baseDir, false, $statuses);
		$runtime = getSimulationRuntime($id, $idx, $baseDir);
		$status = 'Finished';
		$statusDetails = $state;
	}
	
	return array($status, $statusDetails, $time, $mass, $growth, $runtime, $run, $err, $currpbsid);
}

function getJobStatuses(){
	$tmpArr = explode("\n\n", trim(`qstat -f @covertlab-cluster.stanford.edu`));
	$statuses = array();
	foreach ($tmpArr as $tmp){
		$tmp = explode("\n    ", str_replace("\n\t", "", $tmp));
		$id = array_shift(explode(".", str_replace("Job Id: ", "", array_shift($tmp))));
		$statuses[$id] = array();
		foreach ($tmp as $tmp2){
			list($prop, $val) = explode(' = ', $tmp2);
			$statuses[$id][$prop] = $val;
		}		
	}
	return $statuses;
}

function getJobNode($statuses, $pbsid){
	return substr($statuses[$pbsid]['exec_host'], 10, 1);
}

function getSimulationState($id, $idx, $baseDir){
	if (!file_exists("$baseDir/$id/$idx/out.log"))
		return array(null, "null");	
	if (file_exists("$baseDir/$id/$idx/err.mat") || (file_exists("$baseDir/$id/$idx/err.log") && filesize("$baseDir/$id/$idx/err.log") > 0)){
		$state = 'Terminated with error';
		$errs = array();
		if (file_exists("$baseDir/$id/$idx/err.log") && filesize("$baseDir/$id/$idx/err.log") > 0)
			array_push($errs, "\"log\":\"simulation\"");
		if (file_exists("$baseDir/$id/$idx/err.mat"))
			array_push($errs, "\"mat\":\"simulation\"");
		$err = "{".join(",", $errs)."}";
	}else{
		$err = null;
		$pinchedDiameter = floatval(array_pop(preg_split("/ +/", trim(`tail -n 500 $baseDir/$id/$idx/out.log | grep '^[ 0-9\.]\{15,\}' | tail -n 1`))));
		if ($pinchedDiameter == 0)
			$state = 'Terminated with division';
		else
			$state = 'Terminated without division';
			
		if (file_exists("$baseDir/$id/$idx/err.reindexing.log") && filesize("$baseDir/$id/$idx/err.reindexing.log") > 0){
			$state.= ', reindexing error';
			$err = "{\"log\":\"reindexing\"}";
		}elseif (
			(file_exists("$baseDir/$id/err.analysis-1.log") && filesize("$baseDir/$id/err.analysis-1.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-2.log") && filesize("$baseDir/$id/err.analysis-2.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-3.log") && filesize("$baseDir/$id/err.analysis-3.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-4.log") && filesize("$baseDir/$id/err.analysis-4.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-5.log") && filesize("$baseDir/$id/err.analysis-5.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-6.log") && filesize("$baseDir/$id/err.analysis-6.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-7.log") && filesize("$baseDir/$id/err.analysis-7.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-8.log") && filesize("$baseDir/$id/err.analysis-8.log") > 0) ||
			(file_exists("$baseDir/$id/err.analysis-9.log") && filesize("$baseDir/$id/err.analysis-9.log") > 0)
			){
			$state.= ', analysis error';
			$err = "{\"log\": \"analysis\"}";
		}
	}
	return array($state, $err);
}

function getCellState($id, $pbsid, $idx, $baseDir, $running, $statuses){
	if ($running){
		if (file_exists("$baseDir/$id/$idx/simulation.pbsid"))
			$pbsSimId = trim(file_get_contents("$baseDir/$id/$idx/simulation.pbsid"));
		else
			$pbsSimId = $pbsid + $idx - 1;
		$node = getJobNode($statuses, $pbsSimId);
		$tmp = `ssh -i /var/www/.ssh/cluster.key jkarr@covertlab-cluster.stanford.edu "ssh compute-0-$node tail -n 500 /opt/torque/spool/$pbsSimId.covertlab-cluster.stanford.edu.OU | grep '^[ 0-9\.]\{15,\}' | tail -n 1" 2>&1`;
	}else{
		if (!file_exists("$baseDir/$id/$idx/out.log"))
			return null;
		$tmp = `tail -n 500 $baseDir/$id/$idx/out.log | grep '^[ 0-9\.]\{15,\}' | tail -n 1`;
	}
	$tmp = preg_split("/ +/", trim($tmp));
	
	$time = $tmp[0];
	$timeH = floor($time / 3600);
	$timeM = floor(((($time-1) % 3600)+1)/60);
	$timeS = (($time-1) % 60)+1;
	
	$mass = $tmp[2];
	$growth = $tmp[3]*3600;
		
	return array(sprintf('%02d:%02d:%02d', $timeH, $timeM, $timeS), $mass, $growth);
}

function getSimulationRuntime($id, $idx, $baseDir){
	if (!file_exists("$baseDir/$id/$idx/out.log"))
		return null;
	$tmp = trim(`tail -n 500 $baseDir/$id/$idx/out.log | grep 'Total runtime'`);
	if (strlen($tmp) == 0)
		return null;
	$time = array_shift(array_slice(explode(" ", $tmp), 2, 1));	
	$timeH = floor($time / 3600);
	$timeM = floor(((($time-1) % 3600)+1)/60);
	$timeS = (round($time-1) % 60)+1;
	return sprintf('%02d:%02d:%02d', $timeH, $timeM, $timeS);
}

function getLogContent($statuses, $pbsJobId, $logFileName, $log){
	if (is_array($pbsJobId)){
		$logContent = '';
		$metaData = '';
		for($i = 0; $i < count($pbsJobId); $i++){
			list($tmpContent, $tmpMetaData) = getLogContent($statuses, $pbsJobId[$i], $logFileName[$i], $log);
			$logContent .= $logFileName[$i]."\n".$tmpContent."\n\n";
			if ($metaData == ''){
				$metaData = $tmpMetaData;
			}
		}
		return array($logContent, $metaData);
	}
	
	if (array_key_exists($pbsJobId, $statuses)){
		$node = getJobNode($statuses, $pbsJobId);
		if ($log == 'out')
			$logType = 'OU';
		else
			$logType = 'ER';
		$logContent = `ssh -i /var/www/.ssh/cluster.key jkarr@covertlab-cluster.stanford.edu "ssh compute-0-$node cat /opt/torque/spool/$pbsJobId.covertlab-cluster.stanford.edu.$logType" 2>&1`;
		$metaData = '<meta http-equiv="refresh" content="60">';
	}else{
		$logContent = file_get_contents($logFileName);
		$metaData = null;
	}
	
	return array($logContent, $metaData);
}

//from http://blog.cnizz.com/2008/04/08/convert-php-object-to-an-array/
function objectToArray($object)
{
	$array = array();
	foreach($object as $member => $data)
	{
		$array[$member] = (is_object($data) || is_array($data) ? objectToArray($data) : $data);
	}
	return $array;
}

?>