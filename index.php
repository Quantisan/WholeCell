<?php
/* Displays about information
 * - development team
 * - third party sources, software
 * - license
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'pageTemplate.php';

//*********************
//session
//*********************
session_start();

//*********************
//content
//*********************
$content = <<<HTML
<style type="text/css">
div.player {
	clear:all;	
	height:600px;
	width:800px;
	border:1px solid rgb(0,20,115);	
	cursor:pointer;	
	text-align:center;
	margin:0px;
	padding:0px;
	background:url('images/animation.png') no-repeat;
}
div.player img {
	position:relative;
	margin-top:258px;
}
div.player div.info {
	height:26px;
	background:#000 url(lib/flowplayer/images/h80.png) repeat-x;
	opacity:1.0;
	color:#fff;
	font-weight:bold;
	margin-top:45px;
	text-align:left;
	padding:12px 15px;	
	font-size:12px;
	border-top:1px solid #ccc;
	margin-top:208px;
}
div.player div.info span {
	color:#ccc;
	display:block;
	font-weight:normal;
}
</style>

<div id="Object" class="List" style="margin-bottom:20px;">
<h1>Welcome!</h1>
<p>Welcome! The website provides an interactive interface to over 3,000 whole-cell simulations and comprehensive database of <i>M. genitalium</i> physiology. The animation below illustrates the predicted life cycle of a single cell. Please use the menu at the top left to:
<ul>
<li><a class="coloredLink" href="http://simtk.org/project/xml/downloads.xml?group_id=714">Download</a> the model code and user guide</li>
<li>Browse the model code <a class="coloredLink" href="simulation/doc/doxygen/html">documentation</a></li>
<li>Download wild type and single-gene disruption <a class="coloredLink" href="simulation">simulation</a></li>
<li>Interactively search and browse the <a class="coloredLink" href="knowledgebase">knowledge base</a>, a detailed database of <i>Mycoplasma</i> molecular biology and physiology</li>
</ul>
</p>
</div>

<script src="lib/flowplayer/flowplayer-3.2.6.min.js"></script>
<div class="player">
	<img src="lib/flowplayer/images/play_large.png" alt="Play this video"/> 
	<div class="info"> 
		<i>M. genitalium</i> whole-cell model
		<span>Duration: 2 minutes</span> 
	</div> 
</div>
<script language="JavaScript">
flowplayer("div.player", "lib/flowplayer/flowplayer-3.2.7.swf", {
	"clip":{
		"url":"images/animation.flv"}, 
	"plugins":{
		"controls":{
			"volume":false, 
			"mute":false
			}
		}
	});
</script>
HTML;

//*********************
//print page
//*********************

echo composePage($content, array(), array());

?>
