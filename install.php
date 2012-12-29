<?php

/*
This script installs both the whole-cell knowledge base and model, 
including configuring the whole-cell model code to run on a Linux 
cluster using the MATLAB MCR.

Detailed notes on the third-party software packages required to run
the whole-cell knowledge base and model are listed below.

Please contact the authors at for help installing and/or using this
software. See wholecell.stanford.edu for contact information.


Whole Cell Instructions
===================================================
A. Knowledgebase
	1. Install MySQL, Apache, PHP		
		- http://www.mysql.com/downloads/
		- http://www.apache.org/dyn/closer.cgi
		- http://www.php.net/downloads.php	

	2. Install php packages
		- DOMDocument

	3. Add apache alias for web-based whole cell knowledge base viewer/editor. Add these lines your apache configuration file
		Alias /WholeCell <repos>
		<Directory <repos>
			Options none
			AllowOverride All

			Order allow,deny
			Allow from all
		</Directory>

	4. Run this script to install MySQL schema, knowledge base content, create new MySQL users, and setup configuration files. Follow on screen instructions.
		>> php install.php
	5. To view/edit knowledge base, visit http://<hostname>/WholeCell/knowledgebase
B. Model
	1. Install MATLAB
		- http://www.mathworks.com/products/matlab/
	2. Install toolbooxes
		- bioinformatics
		- curve fitting
		- image processing
		- optimization
		- signal processing
		- statistics
	3. To run model
		>> cd <repos>/simulation/; matlab -r "runSimulation();"
	4. To synchronize model with knowledge base
		>> cd <repos>/simulation/; matlab -r "generateTestFixtures();"
C. Cluster, analysis, animation
	1. Install MATLAB Component Runtime (MCR)
	2. Install Perl with packages
		- XML::DOM
		- XML::RegExp
		- LWP
		- LWP::UserAgent
		- LWP::UserAgent::Determined
		- Date::Format
		- MIME::Lite
		- HTML::Template
		- Mysql
		- DBI::DBD
	3. Install graphics/video software:
		- latex
		- inkscape
		- GraphicsMagick
		- ffmpeg
		- meconder
		- pdftk
	4. Install Torque/Maui
	5. Add apache alias to enable web-based simulation submission and tracking (see A.3)	
	6. Run this script to configure your cluster. See simulation/config.php and simulation/library.pl for further information.
	7. To run and view simulations, visit http://<hostname>/WholeCell/simulation
	8. To compile animations
		>> cd <repos>/simulation/; runAnimation.pl <simulation group ID>	

Author: Jonathan Karr, jkarr@stanford.edu
Affiliation: Covert Lab, Department of Bioengineering, Stanford University
Last Updated: 11/25/2011
*/

if (is_dir('knowledgebase') && !is_dir('knowledgebase/tmp'))
	mkdir('knowledgebase/tmp');

// gather configuration
echo "MySQL host name: ";
$hostName = rtrim(fgets(STDIN));

echo "MySQL schema name (eg. wholecell): ";
$schema = rtrim(fgets(STDIN));

echo "MySQL user name (eg. wholecell): ";
$dbNewUserName = rtrim(fgets(STDIN));

echo "MySQL password: ";
$dbNewPassword = rtrim(fgets(STDIN));

echo "Do you need to create this schema? [Y/N]: ";
$createSchema = rtrim(fgets(STDIN));
if ($createSchema == 'y' || $createSchema == 'Y') {
	echo "MySQL root user name: ";
	$dbUserName = rtrim(fgets(STDIN));

	echo "MySQL root password: ";
	$dbPassword = rtrim(fgets(STDIN));
}

echo "Desired knowledge base user name (eg. jkarr): ";
$kbUserName = rtrim(fgets(STDIN));

echo "Desired knowledge base password: ";
$kbPassword = rtrim(fgets(STDIN));

echo "Desired knowledge first name: ";
$kbFirstName = rtrim(fgets(STDIN));

echo "Desired knowledge middle name: ";
$kbMiddleName = rtrim(fgets(STDIN));

echo "Desired knowledge last name: ";
$kbLastName = rtrim(fgets(STDIN));

echo "Desired knowledge affiliation: ";
$kbAffiliation = rtrim(fgets(STDIN));

echo "Desired knowledge email: ";
$kbEmail = rtrim(fgets(STDIN));

echo "Desired file absolute path to store simulation results: ";
$resultsFilePath = rtrim(fgets(STDIN));

echo "Would you like to setup a cluster? [Y/N]: ";
$setupCluster = rtrim(fgets(STDIN));
if ($setupCluster == 'y' || $setupCluster == 'Y') {
	echo "Enter system user name: ";
	$linuxUserName = rtrim(fgets(STDIN));
	
	echo "Enter front-end hostname: ";
	$simulationHostName = rtrim(fgets(STDIN));
	
	echo "Enter simulation code path: ";
	$simulationPath = rtrim(fgets(STDIN));

	echo "Enter node MCR path: ";
	$mcrPath = rtrim(fgets(STDIN));
	
	echo "Enter node tmp directory path: ";
	$tmpDirectoryPath = rtrim(fgets(STDIN));
	
	echo "Enter user database host name: ";
	$userDBHostName = rtrim(fgets(STDIN));
	
	echo "Enter user database schema: ";
	$userDBSchema = rtrim(fgets(STDIN));
	
	echo "Enter user database user name: ";
	$userDBUserName = rtrim(fgets(STDIN));
	
	echo "Enter user database password: ";
	$userDBPassword = rtrim(fgets(STDIN));

	echo "Enter whole-cell base URL: ";
	$baseURL = rtrim(fgets(STDIN));
	
	echo "Enter simulation results URL: ";
	$simulationResultsURL = rtrim(fgets(STDIN));
	
	echo "Enter websvn URL: ";
	$webSVNURL = rtrim(fgets(STDIN));
	
	echo "Enter ganglia job URL: ";
	$gangliaJobURL = rtrim(fgets(STDIN));
	
	echo "Enter ganglia queue URL: ";
	$gangliaQueueURL = rtrim(fgets(STDIN));
	
	echo "Enter checkjob URL: ";
	$checkJobURL = rtrim(fgets(STDIN));
}

//Create new mysql database and new mysql user with priviledges on new database
if (is_dir('knowledgebase') && $createSchema=='y' || $createSchema=='Y'){
	echo "Creating MySQL database and new user.\n";
	file_put_contents("knowledgebase/tmp/tmp.sql", "
		CREATE DATABASE `$schema`;
		CREATE USER '$dbNewUserName'@'%' IDENTIFIED BY '$dbNewPassword';
		GRANT ALL PRIVILEGES
			ON `$schema`.*
			TO '$dbNewUserName'@'%'
			WITH GRANT OPTION
			MAX_QUERIES_PER_HOUR 0
			MAX_CONNECTIONS_PER_HOUR 0
			MAX_UPDATES_PER_HOUR 0
			MAX_USER_CONNECTIONS 0;");
	$result = system("mysql \"--host=$hostName\" \"--user=$dbUserName\" \"--password=$dbPassword\" mysql < knowledgebase/tmp/tmp.sql");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";
}

//Edit hostname, username, password, and schema in <repos>/knowledgebase/configuration.php, <repos>/simulation/config.m
echo "Editing configuration files.\n";

if (is_dir('knowledgebase')){
	$result = file_put_contents('knowledgebase/configuration.php',
	"<?php
	\$configuration = array(
		'hostName' => '$hostName',
		'userName' => '$dbNewUserName',
		'password' => '$dbNewPassword',
		'schema'   => '$schema',
		'enableLogin' => 1,
		'enableExport' => 1,
		);
	?>
	");
	if ($result === false)
		echo "Error editing configuration file.\n";
}

if (is_dir('simulation')){
	$result = file_put_contents('simulation/config.m',
	"function dbConnectionParameters = config()
	%CONFIG Returns configuration values.

	dbConnectionParameters.hostName = '$hostName';
	dbConnectionParameters.schema   = '$schema';
	dbConnectionParameters.userName = '$dbNewUserName';
	dbConnectionParameters.password = '$dbNewPassword';
	");
	if ($result === false)
		echo "Error editing configuration file.\n";

	$str = file_get_contents('simulation/src/+edu/+stanford/+covert/+cell/+sim/+util/SimulationDiskUtil.m');
	$str = str_replace("% value = '/absolute_path/to/output/directory';", $resultsFilePath, $str);
	$result = file_put_contents('simulation/src/+edu/+stanford/+covert/+cell/+sim/+util/SimulationDiskUtil.m', $str);
	if ($result === false)
		echo "Error editing configuration file.\n";

	$str = file_get_contents('simulation/config.php');
	$str = preg_replace('/\$baseDir = \'.*?\';/', '$baseDir = \''.$resultsFilePath.'\';', $str);
	$str = preg_replace('/\$baseURL = \'.*?\';/', '$baseURL = \''.$baseURL.'/simulation\';', $str);
	$str = preg_replace('/\$simulationResultsURL = \'.*?\';/', '$simulationResultsURL = \''.$simulationResultsURL.'\';', $str);
	$str = preg_replace('/\$webSVNURL = \'.*?\';/', '$webSVNURL = \''.$webSVNURL.'\';', $str);
	$str = preg_replace('/\$gangliaJobURL = \'.*?\';/', '$gangliaJobURL = \''.$gangliaJobURL.'\';', $str);
	$str = preg_replace('/\$gangliaQueueURL = \'.*?\';/', '$gangliaQueueURL = \''.$gangliaQueueURL.'\';', $str);
	$str = preg_replace('/\$checkJobURL = \'.*?\';/', '$checkJobURL = \''.$checkJobURL.'\';', $str);
	$str = preg_replace('/\$dbConfig\[\'hostName\'\] = \'.*?\';/', '$dbConfig[\'hostName\'] = \''.$userDBHostName.'\';', $str);
	$str = preg_replace('/\$dbConfig\[\'userName\'\] = \'.*?\';/', '$dbConfig[\'userName\'] = \''.$userDBUserName.'\';', $str);
	$str = preg_replace('/\$dbConfig\[\'password\'\] = \'.*?\';/', '$dbConfig[\'password\'] = \''.$userDBPassword.'\';', $str);
	$str = preg_replace('/\$dbConfig\[\'schema\'\] = \'.*?\';/', '$dbConfig[\'schema\'] = \''.$userDBSchema.'\';', $str);
	$result = file_put_contents('simulation/config.php', $str);
	if ($result === false)
		echo "Error editing configuration file.\n";

	$str = file_get_contents('simulation/library.pl');
	$str = preg_replace('/\'hostName\' => \'.*?\',/',  "'hostName' => '$hostName',", $str);
	$str = preg_replace('/\'URL\' => \'.*?\',/',  "'URL' => '".str_replace("http://", "", $baseURL)."',", $str);
	$str = preg_replace('/\'schema\' => \'.*?\',/',  "'schema' => '$schema',", $str);
	$str = preg_replace('/\'dbUserName\' => \'.*?\',/',  "'dbUserName' => '$dbNewUserName',", $str);
	$str = preg_replace('/\'dbPassword\' => \'.*?\',/',  "'dbPassword' => '$dbNewPassword',", $str);
	$str = preg_replace('/\'email\' => \'.*?\',/',  "'email' => '$kbEmail',", $str);
	$str = preg_replace('/\'simulationHostName\' => \'.*?\',/',  "'simulationHostName' => '$simulationHostName',", $str);
	$str = preg_replace('/\'simulationPath\' => \'.*?\',/',  "'simulationPath' => '$simulationPath',", $str);
	$str = preg_replace('/\'execUserName\' => \'.*?\',/',  "'execUserName' => '$linuxUserName',", $str);
	$str = preg_replace('/\'fileUserName\' => \'.*?\',/',  "'fileUserName' => '$linuxUserName',", $str);
	$str = preg_replace('/\'mcrPath\' => \'.*?\',/',  "'mcrPath' => '$mcrPath',", $str);
	$str = preg_replace('/\'nodeTmpDir\' => \'.*?\',/',  "'nodeTmpDir' => '$tmpDirectoryPath',", $str);
	$str = preg_replace('/\'webSVNURL\' => \'.*?\',/',  "'webSVNURL' => '$webSVNURL',", $str);
	$str = preg_replace('/\'gangliaJobURL\' => \'.*?\',/',  "'gangliaJobURL' => '$gangliaJobURL',", $str);
	$str = preg_replace('/\'gangliaQueueURL\' => \'.*?\',/',  "'gangliaQueueURL' => '$gangliaQueueURL',", $str);
	$str = preg_replace('/\'checkJobURL\' => \'.*?\',/',  "'checkJobURL' => '$checkJobURL',", $str);
	$result = file_put_contents('simulation/library.pl', $str);
	if ($result === false)
		echo "Error editing configuration file.\n";
}

if (is_dir('knowledgebase')){
	//Load database schema based on BioWarehouse v4.1 (http://biowarehouse.ai.sri.com/releases/previous-releases/4.1/)
	echo "Loading schema\n";
	$result = system("mysql \"--host=$hostName\" \"--user=$dbNewUserName\" \"--password=$dbNewPassword\" \"$schema\" < knowledgebase/lib/biowarehouse/warehouse-mysql-create.sql");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";	
	$result = system("mysql \"--host=$hostName\" \"--user=$dbNewUserName\" \"--password=$dbNewPassword\" \"$schema\" < knowledgebase/lib/biowarehouse/warehouse-mysql-index.sql");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";
		
	echo "Loading stored procedures\n";
	$result = system("mysql \"--host=$hostName\" \"--user=$dbNewUserName\" \"--password=$dbNewPassword\" \"$schema\" < knowledgebase/src/procedures.sql");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";
		
	echo "Editing schema\n";
	file_put_contents("knowledgebase/tmp/tmp.sql", "CALL update_schema();");
	$result = system("mysql \"--host=$hostName\" \"--user=$dbNewUserName\" \"--password=$dbNewPassword\" \"$schema\" < knowledgebase/tmp/tmp.sql");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";
		
	//Create knowledge base user
	echo "Creating knowledge base user.\n";
	file_put_contents("knowledgebase/tmp/tmp.sql", "CALL set_user('$kbUserName', '$kbPassword', '$kbFirstName', '$kbMiddleName', '$kbLastName', '$kbAffiliation', '$kbEmail');");
	$result = system("mysql \"--host=$hostName\" \"--user=$dbNewUserName\" \"--password=$dbNewPassword\" \"$schema\" < knowledgebase/tmp/tmp.sql");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";

	//Load knowledge base content
	echo "Loading knowledge base content.\n";
	$result = system("cd knowledgebase; php uploadKnowledgeBase.php \"$kbUserName\" \"$kbPassword\" false false");
	if ($result === false)
		echo "Error creating MySQL databse and adding new user.\n";
}

// Print success message(s)
if (is_dir('knowledgebase'))
	echo "Knowledge successfully installed.\n";
if (is_dir('simulation'))
	echo "Model successfully installed.\n";

?>