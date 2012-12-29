<?php
//$sidebarContentHTML
//$navigationContentHTML
/* Template for webpages:
 *   _____________Header______________
 *   ___________Navigation____________
 *   ---------|-----------------------
 *   ---------|-----------------------
 *   -Sidebar-|---------Main----------
 *   ---------|-----------------------
 *   ---------|-----------------------
 *   _____________Footer______________
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

function composePage($mainContentHTML = "", $navigationContents = array(), $sidebarContents = array(), $section = ''){
	if (!is_array($navigationContents)) $navigationContents = array();
	if (!is_array($sidebarContents)) $sidebarContents = array();

	$PageTitle = '<i>M. genitalium</i> Whole-Cell Model &amp; Knowledge Base';
	
	/******************
	 * Navigation content, Page Title
	 ******************/
	$fileparts = pathinfo($_SERVER['SCRIPT_FILENAME']);	
	
	$pageTitle = array();
	array_unshift($navigationContents, array(
		'url' => ($section=='' ? '' : '../').'index.php', 
		'text' => ($section=='' && $fileparts['filename']=='index' && $fileparts['extension']=='php' ? '<i>M. genitalium</i> Whole Cell Model &amp; Knowledge Base' : 'Home')));
	switch ($section){
		case 'knowledgebase':
			$navigationContents[1]['fontStyle'] = '';
			$navigationContents[1]['text'] = 'Knowledge Base';
			$navigationContents[1]['url'] = 'index.php';
			break;
		case 'simulation':
			$navigationContents[1]['fontStyle'] = '';
			$navigationContents[1]['text'] = 'Simulation';
			$navigationContents[1]['url'] = 'index.php';
			break;
	}	
	foreach ($navigationContents as $idx => $navigationContent){
		$navigationContents[$idx] = "<a href=\"" . $navigationContent['url'] . "\"" . ($navigationContent['fontStyle'] == 'italic' ? " style=\"font-style:italic;\"" : "") . ">" . $navigationContent['text'] . "</a>";
		array_push($pageTitle, $navigationContent['text']);
	}
	$navigationContentHTML = join(" &#8250; ", $navigationContents);
	$pageTitleHTML = join(" &#8250; ", $pageTitle);

	/******************
	 * Sidebar content
	 ******************/
	global $Format, $knowledgeBase;
	switch ($section){
		case '':
			array_splice($sidebarContents, 0, 0, array(array("title" => "<i>M. genitalium</i> whole-cell model &amp; KB", "style" => "icons", "content" => array())));
			array_push($sidebarContents[0]["content"], array(
				"url" => "index.php",
				"title" => "Home",
				"icon" => "images/icons/house.png",
				"text" => "Home"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "simulation",
				"title" => "Simulation",
				"icon" => "images/icons/chart_line.png",
				"text" => "Simulation"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "knowledgebase",
				"title" => "Knowledge base",
				"icon" => "images/icons/database.png",
				"text" => "Knowledge base"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "simulation/doc/doxygen/html",
				"title" => "Model",
				"icon" => "images/icons/page_white_code.png",
				"text" => "Model"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "http://simtk.org/project/xml/downloads.xml?group_id=714",
				"title" => "Download",
				"icon" => "images/icons/compress.png",
				"text" => "Download"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "about.php",
				"title" => "About",
				"icon" => "images/icons/information.png",
				"text" => "About"));
			break;
		case 'simulation':
			require('simulation/config.php');
			array_splice($sidebarContents, 0, 0, array(array("title" => "<i>M. genitalium</i> whole-cell simulations", "style" => "icons", "content" => array())));
			array_push($sidebarContents[0]["content"], array(
				"url" => "../index.php",
				"title" => "Home",
				"icon" => "../images/icons/house.png",
				"text" => "Home"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "index.php",
				"title" => "Simulations home",
				"icon" => "../images/icons/chart_line.png",
				"text" => "Simulations home"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "viewSimulationBatches.php",
				"title" => "Simulation batches",
				"icon" => "../images/icons/text_list_bullets.png",
				"text" => "Simulation batches"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "viewWTSimulations.php",
				"title" => "Wild type simulations",
				"icon" => "../images/icons/bug.png",
				"text" => "Wild type simulations"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "viewSingleGeneDeletions.php",
				"title" => "Gene disruption simulations",
				"icon" => "../images/icons/bug_error.png",
				"text" => "Gene disruption simulations"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "runSimulations.php",
				"title" => ($pageOptions['pageTemplate']['enableQueueSimulation'] ? "Queue simulation" : "Configure simulation"),
				"icon" => ($pageOptions['pageTemplate']['enableQueueSimulation'] ? "../images/icons/hourglass.png" : "../images/icons/cog.png"),
				"text" => ($pageOptions['pageTemplate']['enableQueueSimulation'] ? "Queue simulation" : "Configure simulation")));
			break;
		case 'knowledgebase':
			require('knowledgebase/configuration.php');
			array_splice($sidebarContents, 0, 0, array(array("title" => "<i>M. genitalium</i> knowledge base", "style" => "icons", "content" => array())));

			array_push($sidebarContents[0]["content"], array(
				"url" => "../index.php",
				"title" => "Home",
				"icon" => "../images/icons/house.png",
				"text" => "Home"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "index.php",
				"title" => "Knowledge base home",
				"icon" => "../images/icons/database.png",
				"text" => "Knowledge base home"));
			array_push($sidebarContents[0]["content"], array(
				"url" => "search.php?Format=$Format&KnowledgeBaseWID=" . $knowledgeBase->wid,
				"title" => "Search",
				"icon" => "../images/icons/find.png",
				"text" => "Search"));
			if (isset($_SESSION['UserName'])){
				array_push($sidebarContents[0]["content"], array(
					"url" => "login.php",
					"modalWindow" => "width=250px,height=50px,center=1,resize=0,scrolling=1,closeable=1",
					"title" => "Logoff",
					"icon" => "../images/icons/user.png",
					"text" => "Logoff"));
				array_push($sidebarContents[0]["content"], array(
					"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&Page=%s", $Format, $knowledgeBase->wid, 'ErrorsWarnings'),
					"title" => "Errors/warnings",
					"icon" => "../images/icons/cog.png",
					"text" => "Errors/warnings"));		
				array_push($sidebarContents[0]["content"], array(
					"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&Page=%s", $Format, $knowledgeBase->wid, 'RecentChanges'),
					"title" => "Recent changes",
					"icon" => "../images/icons/wrench.png",
					"text" => "Recent changes"));		
			}else{
				if (array_key_exists('enableLogin', $configuration) && $configuration['enableLogin']){
					array_push($sidebarContents[0]["content"], array(
						"url" => "login.php",
						"modalWindow" => "width=250px,height=91px,center=1,resize=0,scrolling=1,closeable=1",
						"title" => "Login",
						"icon" => "../images/icons/user.png",
						"text" => "Login"));
				}
			}

			array_push($sidebarContents[0]["content"], array(
				"url" => "help.php",
				"title" => "Help",
				"icon" => "../images/icons/help.png",
				"text" => "Help"));
			break;
	}

	$sidebarContentHTML = '';
	foreach ($sidebarContents as $sidebarContent){
		$sidebarContentHTML .= "			<div class=\"section\">\n";
		$sidebarContentHTML .= "				<div class=\"title\">" . $sidebarContent['title'] . "</div>\n";
		$sidebarContentHTML .= "				<div class=\"content\" style=\"" . $sidebarContent['style'] . "\">\n";

		if ($sidebarContent['style'] == 'table'){
			$sidebarContentHTML .= "								  <table class=\"columns\" cellspacing=0 cellpadding=0>\n";
			foreach ($sidebarContent['content'] as $item){
			$sidebarContentHTML .= "									  <tr>$item</tr>\n";
			}
			$sidebarContentHTML .= "								  </table>\n";
		}else{
			$sidebarContentHTML .= "								  <ul" . ($sidebarContent['style'] == 'icons' ? " class=\"buttons\"" : "") . ">\n";
			foreach($sidebarContent['content'] as $item){
				if($item['type'] == 'separator'){
					$sidebarContentHTML .= "								  </ul>\n";
					$sidebarContentHTML .= "								  <ul" . ($sidebarContent['style'] == 'icons' ? " class=\"buttons\"" : "") . ">\n";
					continue;
				}
				
				if ($sidebarContent['style'] == 'icons'){
					$sidebarContentHTML .= "									  <li style=\"list-style-image:none;\">";				
					if (array_key_exists('modalWindow', $item)){
						$sidebarContentHTML .= "<a href=\"javascript:void(0)\" onclick=\"modalWindow=dhtmlmodal.open('modalBox','ajax','" . $item['url'] . "','" . $item['title'] . "','" . $item['modalWindow'] . "'); return false;\"><img src=\"" . $item['icon']."\"/> " . $item['text'] . "</a>";
					}elseif (array_key_exists('onclick', $item)){
						$sidebarContentHTML .= "<a href=\"javascript:void(0)\" onclick=\"" . $item['onclick'] . "\"><img src=\"" . $item['icon'] . "\"/> " . $item['text'] . "</a>";
					}else{
						$sidebarContentHTML .= "<a href=\"" . $item['url'] . "\"><img src=\"" . $item['icon'] . "\"/> " . $item['text'] . "</a>";
					}
				}else{
					$sidebarContentHTML .= "									  <li style=\"margin-left:4px;\">";				
					$sidebarContentHTML .= "<a href=\"" . $item['url'] . "\">" . $item['text'] . "</a>" . $item['symbol'];
				}
				$sidebarContentHTML .= "</li>\n";
			}
			$sidebarContentHTML .= "								  </ul>\n";
		}


		$sidebarContentHTML .= "				</div>\n";
		$sidebarContentHTML .= "			</div>\n";
	}

	/******************
	 * last updated
	 ******************/
	$lastUpdated = date('M j, Y', filemtime($_SERVER['SCRIPT_FILENAME']));

	/******************
	 * Compose page
	 ******************/
if ($section == ''){
	$cssDir = 'css';
	$jsDir = 'js';
	$baseDir = '.';
} else {
	$cssDir = '../css';
	$jsDir = '../js';
	$baseDir = '..';
}

$pageTitleHTML = strip_tags($pageTitleHTML);
return <<<HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>$pageTitleHTML</title>
		<meta name="description" content="M. genitalium Whole-Cell Model &amp; Knowledge Base">
		<meta name="copyright" content="Copyright (c) 2012 Jonathan Karr, Jayodita Sanghvi, Derek Macklin, Jared Jacobs, and Markus Covert">
		<meta name="author" content="Markus Covert, Jonathan Karr, Jayodita Sanghvi, Jared Jacobs, and Derek Macklin">
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<link rel="icon" href="$baseDir/images/favicon.ico" type="image/x-icon"/> 
		<link rel="shortcut icon" href="$baseDir/images/favicon.ico" type="image/x-icon"/> 
		<link rel="stylesheet" type="text/css" href="$cssDir/jquery-ui-1.8.23.custom.css" media="all"/>
		<link rel="stylesheet" type="text/css" href="$cssDir/PTSans.min.css" media="all"/>
		<link rel="stylesheet" type="text/css" href="$cssDir/styles.css" media="all"/>
		<link rel="stylesheet" type="text/css" href="$cssDir/print.css" media="print"/>
		<link rel="stylesheet" type="text/css"href="$cssDir/dhtmlwindow.css" media="all"/>
		<link rel="stylesheet" type="text/css"href="$cssDir/modal.css" media="all"/>
		<script type="text/javascript" src="$jsDir/script.js"></script>
		<script type="text/javascript" src="$jsDir/prototype.js"></script>
		<script type="text/javascript" src="$jsDir/dhtmlwindow.js"></script>
		<script type="text/javascript" src="$jsDir/modal.js"></script>
		<script type="text/javascript" src="$jsDir/mapper.js"></script>
</head>
<body>
	<script type="text/javascript" src="$jsDir/wz_tooltip.js"></script>
	<!-- header -->
	<div id="header" class="ui-widget-header">
		<div class="title"></div>
		<div class="banner"><img src="$baseDir/images/banner.png" /></div>
		<ul class="menu menu_left">
			<li><a href="$baseDir">Home</a></li>
			<li class="spacer"></li>
			<li><a href="$baseDir/simulation/doc/doxygen/html">Model</a></li>
			<li class="spacer"></li>
			<li><a href="$baseDir/simulation">Simulations</a>
				<ul>
				<li><a href="$baseDir/simulation/viewSimulationBatches.php">Browse all</a></li>
				<li><a href="$baseDir/simulation/viewWTSimulations.php">Browse wild type</a></li>
				<li><a href="$baseDir/simulation/viewSingleGeneDeletions.php">Browse gene disruptions</a></li>	
				<li><a href="$baseDir/simulation/viewMultiGenerationSimulations.php">Browse multi-generation simulations</a></li>	
				<li><a href="$baseDir/simulation/runSimulations.php">Configure simulation</a></li>	
				</ul>
			</li>
			<li class="spacer"></li>
			<li><a href="http://wholecellkb.stanford.edu">Knowledge Base</a></li>
			<li class="spacer"></li>
			<li><a href="http://wholecellviz.stanford.edu">Visualization</a></li>
			<li class="spacer"></li>
			<li><a href="http://simtk.org/home/wholecell">Download</a></li>
			<li class="spacer"></li>
			<li><a>Help</a>
				<ul>
				<li><a href="$baseDir/about.php">About</a></li>
				<li><a href="http://covertlab.stanford.edu">Covert Lab</a></li>
				</ul>
			</li>
		</ul>
	</div>
	
	<!-- content -->
	<div id="container">
		$mainContentHTML
	</div>
	
	<div id="footer" class="ui-widget-header">
	Last updated $lastUpdated.
	Contact <a href="mailto:wholecell [at] lists.stanford.edu">wholecell@lists.stanford.edu</a>.
	<br/> &copy; Jonathan Karr, Jayodita Sanghvi, Derek Macklin, Jared Jacobs, and Markus Covert.
	</div>
</body>
</html>
HTML;
}
?>
