<?php

//load methods
require('config.php');
require_once('library.php');
require_once('../pageTemplate.php');

//content
$data = getAllSimulationBatches($baseDir, $simulationMetaDataCache);

$pbsIDHidden = ($pageOptions['index']['displayPBSIDs'] ? 'false' : 'true');
$revisionHidden = ($pageOptions['index']['displayRevision'] ? 'false' : 'true');
$emailHidden = ($pageOptions['index']['displayEmail'] ? 'false' : 'true');
$userNameHidden = ($pageOptions['index']['displayUserName'] ? 'false' : 'true');
$hostNameHidden = ($pageOptions['index']['displayHostName'] ? 'false' : 'true');
$ipAddressHidden = ($pageOptions['index']['displayIpAddress'] ? 'false' : 'true');

$content = <<<HTML
<div id="Object" class="List" style="margin-bottom:20px;">
	<h1>Welcome</h1>
	<p>This website provides access to the over 3,000 wild type and single-gene disruption simulations reported in the manuscript titled "<a class="coloredLink" href="http://simtk.org/frs/download.php?file_id=3122">A Whole-Cell Computational Model Predicts Phenotype from Genotype</a>". Please use the menu at the left to browse and download simulations. Simulations are organized in two ways: 
	<ul>
	<li>Simulations are organized by the date, or <a class="coloredLink" href="viewSimulationBatches.php">batch</a>, they were executed</li>
	<li>Simulations are organized by type: <a class="coloredLink" href="viewWTSimulations.php">wild type</a> or <a class="coloredLink" href="viewSingleGeneDeletions.php">single-gene disruption</a></li>
	</ul>
	</p>
	
	<p>All of the whole-cell model source code and training data is freely available. Please use the links below to download the model.</p>
	
	<p>Additionally, this website provides an interactive interface to <a class="coloredLink" href="runSimulations.php">configure a whole-cell simulation</a> to run on your own machine. This page displays all of the default parameter values of whole-cell model, allows you to modify the values of those parameters, and generates and XML file describing the specified modifications to the default parameter values which can be used with the whole-cell model software to simulate <i>M. genitalium</i>. See the <a class="coloredLink" href="http://simtk.org/project/xml/downloads.xml?group_id=714">whole-cell model user guide</a> for detailed instructions how to install and run whole-cell simulations.</p>
</div>

<div id="Object" class="List" style="margin-bottom:20px;">
	<h1>Model construction</h1>
	The <i>M. genitalium</i> whole-cell model was developed from over 900 primary research articles, reviews, books, and databases. The <a class="coloredLink" href="https://simtk.org/project/xml/downloads.xml?group_id=714">supplementary information</a> to the manuscript titled "<a class="coloredLink" href="http://www.cell.com/abstract/S0092-8674(12)00776-3">A Whole-Cell Computational Model Predicts Phenotype from Genotype</a>" provides a detailed discussion of the construction of the model.
</div>

<div id="Object" class="List" style="margin-bottom:20px;">
	<h1>Source code &amp; user instructions</h1>
	All source code and detailed user instructions for the <i>M. genitalium</i> model are available at <a href="http://simtk.org/project/xml/downloads.xml?group_id=714" class="coloredLink">SimTK</a>.
</div>

<div id="Object" class="List" style="margin-bottom:20px;">
	<h1>Citing the model</h1>
	<p>Please use the following reference to cite the <i>M. genitalium</i> model:</p>
	<p>Karr JR, Sanghvi JC, Macklin DN, Gutschow MV, Jacobs JM, Bolival B, Assad-Garcia N, Glass JI, Covert MW. A Whole-Cell Computational Model Predicts Phenotype from Genotype. <i>Cell</i> 150, 389-401 (2012).
	<a class="coloredLink" href="http://www.cell.com/abstract/S0092-8674(12)00776-3">Cell</a> | 
	<a href="http://www.ncbi.nlm.nih.gov/pubmed/22817898">PubMed</a></p>
</div>
HTML;

echo composePage($content, array(), array(), 'simulation');

?>
