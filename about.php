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

$license = "<p>".str_replace("\n", "</p>\n<p>", str_replace("\r\n", "\n", trim(file_get_contents('license.txt'))))."</p>";

$content = <<<HTML
<div id="Object" class="List">
	<h1>About the <i>M. genitalium</i> whole-cell model &amp; knowledge base</h1>
	<p>Please see the following manuscript and its accompanying supplementary information for detailed discussion of the construction of the whole-cell model.</p>
	<p>Karr JR, Sanghvi JC, Macklin DN, Gutschow MV, Jacobs JM, Bolival B, Assad-Garcia N, Glass JI, Covert MW. A Whole-Cell Computational Model Predicts Phenotype from Genotype. <i>Cell</i> 150, 389-401 (2012).
	<a class="coloredLink" href="http://www.cell.com/abstract/S0092-8674(12)00776-3">Cell</a> |
	<a href="http://www.ncbi.nlm.nih.gov/pubmed/22817898">PubMed</a></p>
</div>

<div id="Object" class="List" style="margin-top:20px;">
	<h1>Source code &amp; user instructions</h1>
	All source code and detailed user instructions for the <i>M. genitalium</i> model and knowledge base are available at <a href="http://simtk.org/project/xml/downloads.xml?group_id=714" class="coloredLink">SimTK</a>.
</div>

<div id="Object" class="List" style="margin-top:20px;">
	<h1>Simulations</h1>
	All simulations are available from the <a href="simulation" class="coloredLink">simulation</a> page.
</div>

<div id="Object" class="List" style="margin-top:20px;">
	<h1>MIT license</h1>
	$license
</div>

<div id="Object" class="List" style="margin-top:20px;">
	<h1>Citing the model &amp; knowledge base</h1>
	<p>Please use the following reference to cite the <i>M. genitalium</i> model and knowledge base:</p>
	<p>Karr JR, Sanghvi JC, Macklin DN, Gutschow MV, Jacobs JM, Bolival B, Assad-Garcia N, Glass JI, Covert MW. A Whole-Cell Computational Model Predicts Phenotype from Genotype. <i>Cell</i> 150, 389-401 (2012).
	<a class="coloredLink" href="http://www.cell.com/abstract/S0092-8674(12)00776-3">Cell</a> | 
	<a href="http://www.ncbi.nlm.nih.gov/pubmed/22817898">PubMed</a></p>
	<p>Karr JR, Sanghvi JC, Macklin DN, Arora A, Covert MW. WholeCellKB: Model Organism Databases for Comprehensive Whole-Cell Models. <i>Nucleic Acids Res</i> 41 (2013).
	<a class="coloredLink" href="http://nar.oxfordjournals.org/content/early/2012/11/21/nar.gks1108.long">Nucleic Acids Res</a> | 
	<a href="http://www.ncbi.nlm.nih.gov/pubmed/23175606">PubMed</a></p>
</div>

<div id="Object" class="List" style="margin-top:20px;">
	<h1>Development team</h1>
	The <i>M. genitalium</i> whole cell model and knowledge base were developed at Stanford University by
	<ul style="margin-top:0px">		
		<li><a class="coloredLink" href="http://www.stanford.edu/~jkarr">Jonathan Karr</a>, Graduate Student in Biophysics</li>
		<li><a class="coloredLink" href="http://stanfordwho.stanford.edu/SWApp/lookup?search=Jayodita%20Sanghvi">Jayodita Sanghvi</a>, Graduate Student in Bioengineering</li>
		<li><a class="coloredLink" href="http://stanfordwho.stanford.edu/SWApp/lookup?search=Derek%20Macklin">Derek Macklin</a>, Graduate Student in Bioengineering</li>
		<li>Jared Jacobs, Software Engineer</li>
		<li><a class="coloredLink" href="http://stanfordwho.stanford.edu/SWApp/lookup?search=Miriam%20Gutschow">Miriam Gutschow</a>, Graduate student in Bioengineering</li>
		<li><a class="coloredLink" href="http://stanfordwho.stanford.edu/SWApp/lookup?search=Ben%20Bolival">Ben Bolival</a>, Staff Scientist</li>
		<li><a class="coloredLink" href="http://www.jcvi.org/cms/about/bios/nassad-garcia/">Nacyra Assad-Garcia</a>, Staff Scientist, JCVI</li>
		<li><a class="coloredLink" href="http://www.jcvi.org/cms/about/bios/jglass/">John Glass</a>, Professorm JCVI</li>
		<li><a class="coloredLink" href="http://covertlab.stanford.edu/">Markus Covert</a>, Assistant Professor of Bioengineering</li>
	</ul>
</div>
HTML;

//*********************
//print page
//*********************
$navigationContents = array(
	array('url' => 'about.php', 'text' => 'About'));

echo composePage($content, $navigationContents, array());

?>
