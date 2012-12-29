<?php
/* 1. Displays login/out forms.
 * 2. Checks user name, password against database
 * 3. Starts/ends PHP session
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once '../pageTemplate.php';

//*********************
//configuration
//*********************
require('configuration.php');

//*********************
//session
//*********************
session_start();

//*********************
//login/out
//*********************
//extract arguments
extract($_POST);

if ($Command){
	if ($Command == 'login'){
		$link = databaseConnect($configuration);
		$result = mysql_query(sprintf("CALL loginuser('%s', '%s')", $UserName, $Password)) or die(mysql_error());
		if (!$result){
				$status = 0;
				$message = mysql_error();
		}else{
				if (mysql_num_rows($result) > 0){
						$user = mysql_fetch_array($result);
						$status = 1;
						$_SESSION['UserName'] = $UserName;
						$_SESSION['UserID'] = $user['ID'];
				}else{
						$status = 0;
						$message = "Incorrect user name and password.";
						unset($_SESSION['UserName']);
						unset($_SESSION['UserID']);
						session_unset();
				}
		}
		mysql_close($link);
	}else{
		unset($_SESSION['UserName']);
		unset($_SESSION['UserID']);
		session_unset();
		$status = 1;
	}

	echo "{\n";
	echo "	\"status\": $status, \n";
	echo "  \"message\": \"$message\"\n";
	echo "}\n";
	exit;
}

//*********************
//login/out forms
//*********************
if (isset($_SESSION['UserName'])){
$content = <<<HTML
<center>
	<p class="modal">Are you sure you want to logoff?</p>
	<form action="#" method="POST" onsubmit="logoff($(this).serialize()); return false;">
		<input type="hidden" name="Command" value="logoff"/>
		<input class="button" style="width:60px;" type="submit" value="OK">
		<input class="button" style="width:60px;" type="button" value="Cancel" onclick="modalWindow.hide();"/>
	</form>
</center>
HTML;
}else{
$content = <<<HTML
<form action="#" method="POST" onsubmit="login($(this).serialize()); return false;">
	<input type="hidden" name="Command" value="login"/>
	<table cellpadding="0" cellspacing="0" class="login">
		<tr>
			<th>User Name</th>
			<td><input type="text" name="UserName"/></td>
		</tr>
		<tr>
			<th>Password</th>
			<td><input type="password" name="Password"/></td>
		</tr>
		<tr>
			<th>&nbsp;</th>
			<td>
				<input class="button" style="width:64px;" type="submit" value="Login"/>
				<input class="button" style="width:65px;" type="button" value="Cancel" onclick="modalWindow.hide();"/>
			</td>
		</tr>
</table>
</form>
HTML;
}

//*********************
//print page
//*********************
echo $content;
?>
