<?php
/* Helper functions
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

define('CLIENT_MULTI_RESULTS', 131072);
define('CLIENT_MULTI_STATEMENTS', 65536);

function databaseConnect($options, $verbose = false){
	extract($options);

	while(1){
		$link = @mysql_connect($hostName, $userName, $password, 0, CLIENT_MULTI_STATEMENTS);
		if ($link) break;
		if ($verbose) echo "Connecting to database ...\n";
		sleep(3);
	}

	mysql_select_db($schema, $link) or die (mysql_error());
	return $link;
}

function runQuery($sql, $options){
	$link = databaseConnect($options);
	$result = mysql_query($sql) or die(mysql_error());
	if ($result !== false) $result = mysql_fetch_array($result);
	mysql_close($link);
	return $result;
}

function filter_by_value($array, $threshold){
	$newarray = array();
	foreach ($array as $key => $value){
		if ($value > $threshold){
			array_push($newarray, $key);
		}
	}
	return $newarray;
}

function array2object($array) {
	if (is_array($array)) {
		$obj = new StdClass();

		foreach ($array as $key => $val){
			$obj->$key = $val;
		}
	}
	else { $obj = $array; }

	return $obj;
}

function object2array($object) {
	if (is_object($object)) {
		foreach ($object as $key => $value) {
			$array[$key] = $value;
		}
	}
	else {
		$array = $object;
	}
	return $array;
}

?>