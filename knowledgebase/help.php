<?php
/* Display help information.
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
require_once 'src/include.php';

//*********************
//session
//*********************
session_start();

//*********************
//navigation
//*********************
$knowledgeBase = new KnowledgeBase();
$KnowledgeBaseWID = $knowledgeBase->findWID($KnowledgeBaseWID, $KnowledgeBaseID);
if (false === $knowledgeBase->loadFromDatabase()) exit;
$KnowledgeBaseName = $knowledgeBase->name;

if (!$Format) $Format = 'List';
$navigationContents = $knowledgeBase->navigation($Format);
array_push($navigationContents, array(
	'url' => 'help.php',
	'text' => 'Help'));

$sidebarContents = $knowledgeBase->sidebar($Format);
array_unshift($sidebarContents, array('title'=>'Search controls', 'content'=>array()));
$sidebarContents[0]['title'] = '<i>Mycoplasma genitalium</i>';
$tableOrder = array(
	'summary',
	'simulations',	
	'processes', 
	'states',
	'genes', 
	'transcriptionUnits', 
	'transcriptionalRegulations', 
	'genomeFeatures', 
	'proteinMonomers', 
	'proteinComplexs', 
	'proteinActivations',
	'reactions', 
	'pathways', 
	'metabolites', 
	'mediaComponents', 
	'biomassCompositions', 
	'stimuli', 
	'stimuliValues', 	
	'parameters',
	'compartments', 	
	'metabolicMapMetabolites',
	'metabolicMapReactions', 
	'notes', 
	'references'); 
foreach ($tableOrder as $tableID){
	$table = $knowledgeBase->schema[$tableID];
	if ($table['displayLevel'] > 0) continue;
	array_push($sidebarContents[0]["content"], array(
		"url" => sprintf("index.php?Format=%s&KnowledgeBaseWID=%d&TableID=%s", $Format, $knowledgeBase->wid, $tableID),
		"text" => $table['names'],
		"symbol" => ($table['usedInSimulation'] ? "<span class=\"symbol sup\" title=\"Table used in simulation\">" . KnowledgeBaseObject::symbol_property_usedInSimulation . "</span>" : "")));
}

//*********************
//content
//*********************
$symbols = array(	
	array("symbol" => KnowledgeBaseObject::symbol_property_usedInSimulation, "description" => "Table / property used in model"),	
	array("symbol" => KnowledgeBaseObject::symbol_property_calculcated_1, "description" => "Property predicted by the model"),
	array("symbol" => KnowledgeBaseObject::symbol_property_calculcated_2, "description" => "Dependent property calculated by the model"),
	array("symbol" => KnowledgeBaseObject::symbol_property_calculcated_3, "description" => "Property predicted by third-party software"),
	);
if (isset($_SESSION['UserName']))
	array_push($symbols, array("symbol" => KnowledgeBaseObject::symbol_property_required, "description" => "Required property"));
	
foreach ($symbols as $symbol){
	$symbolsTable .= "				<tr>\n";	
	$symbolsTable .= "					<td>" . $symbol['symbol'] . "</td>\n";
	$symbolsTable .= "					<td>&nbsp;" . $symbol['description'] . "</td>\n";
	$symbolsTable .= "				</tr>\n";
}
$symbolsTable = ltrim($symbolsTable);

$content .= <<<HTML
<div id="Object" class="List">
	<div>
		<h1>Knowledge base content</h1>
		The <i>M. genitalium</i> knowledge base provides a comprehensive and quantitative description of <i>M. genitalium</i> including:
		<ul>
		<li>The <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=biomassCompositions">cellular composition</a> of <i>M. genitalium</i> and typical <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=mediaComponents">growth medium</a></li>
		<li>The location of <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=genes">gene</a></li>
		<li>The <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=transcriptionUnits">transcription unit organization</a> and <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=transcriptionalRegulations">transcriptional regulation</a> of the chromosome</li>
		<li>The composition and function of each <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=genes">RNA</a>, <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=genes">protein monomer</a>, and <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=macromolecularComplexs">macromolecular complex</a> gene product</li>
		<li>The stoichiometry, kinetics, and catalysis of each <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=reactions">reaction</a></li>
		<li>Links to all of the <a class="coloredLink" href="http://covertlab.stanford.edu/projects/WholeCell/knowledgebase/index.php?Format=$Format&KnowledgeBaseWID=$KnowledgeBaseWID&TableID=references">references</a> used to reconstruct <i>M. genitalium</i></li>
		</ul>
		Please use the menu bar at the left to search and navigate the knowledge base.
	</div>
</div>

<div id="Object" class="List" style="margin-top:40px;">
	<div>
		<h1><i>M. genitalium</i> reconstruction</h1>
		The knowledge base was developed from over 900 primary research articles, reviews, books, and databases. The <a class="coloredLink" href="http://simtk.org/project/xml/downloads.xml?group_id=714">supplementary information</a> to the manuscript titled "A Whole-Cell Computational Model Predicts Phenotype from Genotype" provides a detailed discussion of the construction of the knowledge base.
	</div>
</div>

<div id="Object" class="List" style="margin-top:40px;">
	<div>
		<h1>Implementation</h1>
		The <i>M. genitalium</i> knowledge base was stored using a modified version of the <a class="coloredLink" href="http://biowarehouse.ai.sri.com/">BioWarehouse schema</a> in a <a class="coloredLink" href="http://mysql.com">MySQL</a> relational database. Several tables and columns were added to the BioWarehouse schema primarily to represent additional functional genomic data. The knowledge base was viewed and edited using a web-interface implemented in <a class="coloredLink" href="http://php.net">PHP</a>.
	</div>
</div>

<div id="Object" class="List" style="margin-top:40px;">
	<div>
		<h1>Mathematical modeling</h1>
		The knowledge base was used as the basis for a comprehensive, quantitative <a class="coloredLink" href="../simulation">model</a> of <i>M. genitalium</i>. The symbols listed in the table below are used throughout this website to indicate which tables and properties were used in the computational model, as well as to indicate which properties which curated from the literature and which were either calculated by the model or by third-party software. Please see the <a class="coloredLink" href="../about.php">model documentation</a> for further discussion of these calculations.
		
		<center>
		<table cellpadding="0" cellspacing="0" style="margin-top:20px;">
		<thead>
			<tr>
				<th>Symbol</th>
				<th>Description</th>
			</tr>
		</thead>
		<tbody>
		$symbolsTable
		</tbody>
		</table>
		</center>
	</div>
</div>

<div id="Object" class="List" style="margin-top:40px;">
	<div>
		<h1>Download</h1>
		The <i>M. genitalium</i> knowledge base, including all of data and code, is freely available at <a class="coloredLink" href="http://simtk.org/project/xml/downloads.xml?group_id=714">SimTK</a>.
	</div>
</div>

<div id="Object" class="List" style="margin-top:40px;">
	<div>
		<h1>Citing the knowledge base</h1>
		<p>Please use the following reference to cite the <i>M. genitalium</i> knowledge base:</p>
		<p>Karr JR, Sanghvi JC, Macklin DN, Gutschow MV, Jacobs JM, Bolival B, Assad-Garcia N, Glass JI, Covert MW. A Whole-Cell Computational Model Predicts Phenotype from Genotype. <i>Cell</i> 150, 389-401 (2012).</p>
		Paper: <a class="coloredLink" href="http://www.cell.com/abstract/S0092-8674(12)00776-3">Cell</a> | 
		<a href="http://www.ncbi.nlm.nih.gov/pubmed/22817898">PubMed</a>
	</div>
</div>
HTML;

//*********************
//print page
//*********************
echo composePage($content, $navigationContents, $sidebarContents, 'knowledgebase');

?>
