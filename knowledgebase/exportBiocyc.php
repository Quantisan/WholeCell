<?php

/*
 * Exports knowledge in Pathway Tools flat-file format (http://bioinformatics.ai.sri.com/ptools/flatfile-format.html).
 *
 * Attribute-value files
 * - bindrxns.dat
 * - compounds.dat
 * - classes.dat
 * - dnabindsites.dat
 * - enzrxns.dat
 * - genes.dat
 * - pathways.dat
 * - promoters.dat
 * - protein-features.dat
 * - proteins.dat
 * - protligandcplxes.dat
 * - pubs.dat
 * - reactions.dat
 * - regulation.dat
 * - regulons.dat
 * - species.dat
 * - terminators.dat
 * - transunits.dat
 * - version.dat
 *
 * Tabular files
 * - enzymes.col
 * - genes.col
 * - func-associations.col
 * - pathways.col
 * - protcplxs.col
 * - transporters.col
 *
 * Link files
 * - compound-links.dat
 * - gene-links.dat
 * - pathway-links.dat
 * - protein-links.dat
 * - reaction-links.dat
 *
 * Sequence files
 * - chromosome.fsa
 * - dnaseq.fsa
 * - protseq.fsa
 *
 * Author: Jonathan Karr, jkarr@stanford.edu
 * Affiliation: Covert Lab, Department of Bioengineering, Stanford University
 * Last Updated: 3/26/2012
 */

ini_set('display_errors', 'on');
date_default_timezone_set('America/Los_Angeles');

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once 'src/include.php';

//*********************
//parameters
//*********************
$outDir = "data/biocyc";
$version = '16.0';

//*********************
//make out directory
//*********************
if (!is_dir($outDir))
	mkdir($outDir);

//*********************
//load latest knowledge base
//*********************
$knowledgeBase = new KnowledgeBase();
$knowledgeBase->findWID('', '');
if (false === $knowledgeBase->loadFromDatabase(array(
	'summary',
	'metabolites',
	'genes',
	'transcriptionalRegulations',
	'proteinMonomers',
	'proteinComplexs',
	'pathways',
	'reactions',
	'transcriptionUnits',
	'proteinActivations',
	'references')))
	exit;

//states
//processes
//parameters
//compartments/locations
//stimuli
//mediaComponents
//biomassCompositions
//genomeFeatures - non-protein-DNA-binding sites
//notes

//*********************
//export knowledge base
//*********************
$kbID = $knowledgeBase->wholeCellModelID;
$cycID = $kbID.'cyc';
$organismCommonName = join(" ", array_splice(explode(';', $knowledgeBase->taxonomy), -3, 2));
$strainName = array_pop(explode(';', $knowledgeBase->taxonomy));
$tier = 2;
$pgdbUID = 'C03';
$pgdbAuthor = 'jkarr';
$pgdbEmail = 'wholecell@lists.stanford.edu';
$pgdbCopyright = 'Copyright &copy; '.date('Y').', Stanford University. All rights reserved.';
$pgdbURL = 'http://wholecell.stanford.edu/knowledgebase';
$pgdbTimestamp = 3519494623;
$ncbiBioprojectID = 57707;
$geneticCode = 4;
$genomeID = 'CHROMOSOME-1';
$genomeLength = $knowledgeBase->genomeLength;
$ncbiTaxonomy = $knowledgeBase->crossReference->taxonomy;
$atccID = $knowledgeBase->crossReference->atcc;
$classes = array(
	array('id'=>'Chemicals', 'name'=>'Chemicals', 'type'=>array('FRAMES')),
	array('id'=>'Compounds-And-Elements', 'name'=>'Compound or element', 'type'=>array('Chemicals')),
	array('id'=>'Compounds', 'name'=>'Compounds', 'type'=>array('Compounds-And-Elements')),
	array('id'=>'Macromolecules', 'name'=>'Macromolecules', 'type'=>array('Chemicals')),
	array('id'=>'Polynucleotides', 'name'=>'Polynucleotides', 'type'=>array('Macromolecules')),
	array('id'=>'RNAs', 'name'=>'RNAs', 'type'=>array('Polynucleotides')),
	array('id'=>'mRNA', 'name'=>'mRNA', 'type'=>array('RNAs', 'Genes')),
	array('id'=>'rRNA', 'name'=>'rRNA', 'type'=>array('RNAs', 'Genes')),
	array('id'=>'sRNA', 'name'=>'sRNA', 'type'=>array('RNAs', 'Genes')),
	array('id'=>'tRNA', 'name'=>'tRNA', 'type'=>array('RNAs', 'Genes')),
	array('id'=>'Proteins', 'name'=>'Proteins', 'type'=>array('Macromolecules')),
	array('id'=>'Complexes', 'name'=>'Complexes', 'type'=>array('Macromolecules')),
	array('id'=>'Polypeptides', 'name'=>'Polypeptides', 'type'=>array('Proteins')),
	array('id'=>'Protein-Complexes', 'name'=>'Protein complexes', 'type'=>array('Complexes', 'Proteins')),
	array('id'=>'Protein-Small-Molecule-Complexes', 'name'=>'Protein-small molecule complexes', 'type'=>array('Complexes', 'Proteins')),
	array('id'=>'Regulation', 'name'=>'Regulation', 'type'=>array('FRAMES')),
	array('id'=>'Regulation-of-Transcription', 'name'=>'Regulation of transcription', 'type'=>array('Regulation')),
	array('id'=>'Regulation-of-Transcription-Initiation', 'name'=>'Regulation of transcription initiation', 'type'=>array('Regulation-of-Transcription')),
	array('id'=>'Regulation-of-Enzyme-Activity', 'name'=>'Regulation of enzyme activity', 'type'=>array('Regulation')),
	array('id'=>'Polymer-Segments', 'name'=>'Polymer segments', 'type'=>array('FRAMES')),
	array('id'=>'DNA-Segments', 'name'=>'DNA segments', 'type'=>array('Polymer-Segments')),
	array('id'=>'DNA-Binding-Sites', 'name'=>'DNA binding sites', 'type'=>array('DNA-Segments')),
	array('id'=>'Promoters', 'name'=>'Promoters', 'type'=>array('DNA-Segments')),
	array('id'=>'Transcription-Units', 'name'=>'Transcription units', 'type'=>array('DNA-Segments')),
	array('id'=>'DnaA-box', 'name'=>'DnaA box', 'type'=>array('DNA-Binding-Sites')),
	array('id'=>'DnaA-box-7mer', 'name'=>'7-mer', 'type'=>array('DnaA-box')),
	array('id'=>'DnaA-box-8mer', 'name'=>'8-mer', 'type'=>array('DnaA-box')),
	array('id'=>'DnaA-box-9mer', 'name'=>'9-mer', 'type'=>array('DnaA-box')),
	array('id'=>'Publications', 'name'=>'Publications', 'type'=>array('FRAMES')),
	array('id'=>'article', 'name'=>'article', 'type'=>array('Publications')),
	array('id'=>'book', 'name'=>'book', 'type'=>array('Publications')),
	array('id'=>'misc', 'name'=>'misc', 'type'=>array('Publications')),
	array('id'=>'thesis', 'name'=>'thesis', 'type'=>array('Publications')),
	array('id'=>'Generalized-Reactions', 'name'=>'Generalized reactions', 'type'=>array('FRAMES')),
	array('id'=>'Reactions', 'name'=>'Reactions', 'type'=>array('Generalized-Reactions')),
	array('id'=>'Reactions-Classified-By-Substrate', 'name'=>'Reactions classified by substrate', 'type'=>array('Reactions')),
	array('id'=>'Reactions-Classified-By-Conversion-Type', 'name'=>'Reactions classified by conversion type', 'type'=>array('Reactions')),
	array('id'=>'Unclassified-Reactions', 'name'=>'Unclassified reactions', 'type'=>array('Reactions')),
	array('id'=>'Small-Molecule-Reactions', 'name'=>'Small molecule reactions', 'type'=>array('Reactions-Classified-By-Substrate')),
	array('id'=>'Macromolecule-Reactions', 'name'=>'Macromolecule reactions', 'type'=>array('Reactions-Classified-By-Substrate')),
	array('id'=>'Protein-Reactions', 'name'=>'Protein reactions', 'type'=>array('Macromolecule-Reactions')),
	array('id'=>'Polynucleotide-Reactions', 'name'=>'Polynucleotide reactions', 'type'=>array('Macromolecule-Reactions')),
	array('id'=>'Polysaccharide-Reactions', 'name'=>'Polysaccharide reactions', 'type'=>array('Macromolecule-Reactions')),
	array('id'=>'Protein-Modification-Reactions', 'name'=>'Protein modification reactions', 'type'=>array('Protein-Reactions', 'Chemical-Reactions')),
	array('id'=>'Simple-Reactions', 'name'=>'Simple reactions', 'type'=>array('Reactions-Classified-By-Conversion-Type')),
	array('id'=>'Chemical-Reactions', 'name'=>'Chemical reactions', 'type'=>array('Simple-Reactions')),
	array('id'=>'Pathways', 'name'=>'Pathways', 'type'=>array('Generalized-Reactions')),
	array('id'=>'Enzymatic-Reactions', 'name'=>'Enzymatic reactions', 'type'=>array('FRAMES')),
	array('id'=>'All-Genes', 'name'=>'All genes', 'type'=>array('DNA-Segments')),
	array('id'=>'Genes', 'name'=>'Genes', 'type'=>array('All-Genes')),
	array('id'=>'MultiFun', 'name'=>'MultiFun', 'type'=>array('Genes'))
	);

//version
$organismArr = array_splice(explode(';', $knowledgeBase->taxonomy), -3);
$organismArr[0] = substr($organismArr[0], 0, 1).'.';
$organismStr = join(" ", $organismArr);
$dateStr = date('D M j, Y');

$str = <<<FILE
ORGID	$kbID
ORGANISM	$organismStr
VERSION	$version
RELEASE-DATE	$dateStr
FILE;
writeDatFile($outDir, 'version.dat', $str, $knowledgeBase, $version);

//species
$dateTimeStr = date('d-M-Y H:i:s');

$str = <<<FILE
UNIQUE-ID - $kbID
TYPES - TAX-$ncbiTaxonomy
COMMON-NAME - $organismCommonName
COMMENT - This Pathway/Genome Database was generated on $dateTimeStr from the annotated genome of <i>$organismCommonName</i> $strainName.
CONTACT-EMAIL - $pgdbEmail
DBLINKS - (NCBI-BIOPROJECT "$ncbiBioprojectID)
DBLINKS - (NCBI-TAXONOMY-DB "$ncbiTaxonomy")
GENETIC-CODE - $geneticCode
GENOME - $genomeID
MITOCHONDRIAL-GENETIC-CODE - 0
PGDB-AUTHORS - |$pgdbAuthor|
PGDB-COPYRIGHT - $pgdbCopyright
PGDB-HOME-PAGE - $pgdbURL
PGDB-LAST-CONSISTENCY-CHECK - $pgdbTimestamp
PGDB-NAME - $cycID
PGDB-TIER - $tier
PGDB-UNIQUE-ID - $pgdbUID
RANK - |strain|
STRAIN-NAME - $strainName
SYNONYMS - $organismCommonName ATCC $atccID
SYNONYMS - $organismCommonName str. $strainName
SYNONYMS - $organismCommonName strain $strainName
SYNONYMS - $organismCommonName $strainName
NCBI-TAXONOMY-ID - $ncbiBioprojectID
FILE;
writeDatFile($outDir, 'species.dat', $str, $knowledgeBase, $version);

//compounds
$attrValContent = '';
$linkContent = '';
foreach($knowledgeBase->metabolites as $metabolite){
	$attrValContent .= "UNIQUE-ID - ".$metabolite->wholeCellModelID."\n";
	if ($metabolite->subcategory)
		$attrValContent .= "TYPES - ".$metabolite->category."-".$metabolite->subcategory."\n";
	elseif ($metabolite->category)
		$attrValContent .= "TYPES - ".$metabolite->category."\n";
	else
		$attrValContent .= "TYPES - Compounds\n";
	if ($metabolite->category)
		array_push($classes, array('id'=>$metabolite->category, 'name'=>$metabolite->category, 'type'=>array('Compounds')));
	if ($metabolite->subcategory)
		array_push($classes, array('id'=>$metabolite->category."-".$metabolite->subcategory, 'name'=>$metabolite->subcategory, 'type'=>array($metabolite->category)));

	$attrValContent .= "COMMON-NAME - ".$metabolite->name."\n";
	if ($metabolite->iupacName)
		$attrValContent .= "SYSTEMATIC-NAME - ".$metabolite->iupacName."\n";
	if ($metabolite->traditionalName)
		$attrValContent .= "SYNONYMS - ".$metabolite->traditionalName."\n";
	$attrValContent .= "CHARGE - ".($metabolite->charge + 0)."\n";
	$empiricalFormula = $metabolite->parseEmpiricalFormula($metabolite->empiricalFormula);
	foreach ($empiricalFormula as $atom => $count){
		$attrValContent .= "CHEMICAL-FORMULA - ($atom $count)\n";
	}
	if ($metabolite->smiles)
		$attrValContent .= "SMILES - ".$metabolite->smiles."\n";
	$attrValContent .= "MOLECULAR-WEIGHT - ".$metabolite->molecularWeight."\n";
	if ($metabolite->pI)
		$attrValContent .= "PI - ".$metabolite->pI."\n";
	if ($metabolite->pKa1)
		$attrValContent .= "PKA1 - ".$metabolite->pKa1."\n";
	if ($metabolite->pKa2)
		$attrValContent .= "PKA2 - ".$metabolite->pKa2."\n";
	if ($metabolite->pKa3)
		$attrValContent .= "PKA3 - ".$metabolite->pKa3."\n";
	if ($metabolite->hydrophobic)
		$attrValContent .= "HYDROPHOBIC - ".$metabolite->hydrophobic."\n"; //extended representation
	if ($metabolite->logD)
		$attrValContent .= "LOGD - ".$metabolite->logD."\n"; //extended representation
	if ($metabolite->logP)
		$attrValContent .= "LOGP - ".$metabolite->logP."\n"; //extended representation
	if ($metabolite->volume)
		$attrValContent .= "VOLUME - ".$metabolite->volume."\n"; //extended representation
	if ($metabolite->exchangeUpperBound)
		$attrValContent .= "EXCHANGE-UB - ".$metabolite->exchangeUpperBound."\n"; //extended representation
	if ($metabolite->exchangeLowerBound)
		$attrValContent .= "EXCHANGE-LB - ".$metabolite->exchangeLowerBound."\n"; //extended representation
	if ($metabolite->comments)
		$attrValContent .= "COMMENT - ".formatMultiline($metabolite->comments)."\n";

	foreach ($metabolite->crossReference as $db => $id){
		$db = strtoupper($db);
		$attrValContent .= "DBLINKS - ($db \"$id\")\n";
	}

	$attrValContent .= "//\n";

	$tmp = array($metabolite->wholeCellModelID, null, $metabolite->smiles, $metabolite->name);
	if ($metabolite->iupacName)
		array_push($tmp, $metabolite->iupacName);
	if ($metabolite->traditionalName)
		array_push($tmp, $metabolite->traditionalName);
	$linkContent .= join("\t", $tmp)."\n";
}
writeDatFile($outDir, 'compounds.dat', $attrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'compound-links.dat', $linkContent, $knowledgeBase, $version);

//reactions
$rxnAttrValContent = '';
$enzRxnAttrValContent = '';
$linkContent = '';
$colContent = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	'UNIQUE-ID', 'NAME', 'REACTION-EQUATION',
	'PATHWAYS', 'PATHWAYS', 'PATHWAYS', 'PATHWAYS',
	'COFACTORS', 'COFACTORS', 'COFACTORS', 'COFACTORS',
	'ACTIVATORS', 'ACTIVATORS', 'ACTIVATORS', 'ACTIVATORS',
	'INHIBITORS', 'INHIBITORS', 'INHIBITORS', 'INHIBITORS',
	'SUBUNIT-COMPOSITION');
$transColContent = sprintf("%s\t%s\t%s\t%s\n",
	'UNIQUE-ID', 'NAME', 'REACTION-EQUATION', 'SUBUNIT-COMPOSITION');
foreach($knowledgeBase->reactions as $rxn){
	$rxnAttrValContent .= "UNIQUE-ID - ".$rxn->wholeCellModelID."\n";
	if ($rxn->type){
		$rxnAttrValContent .= "TYPES - ".$rxn->type."\n";
		array_push($classes, array('id'=>$rxn->type, 'name'=>$rxn->type, 'type'=>array('Reactions')));
	}else{
		$rxnAttrValContent .= "TYPES - Reactions\n";
	}
	if ($rxn->name)
		$rxnAttrValContent .= "COMMON-NAME - ".$rxn->name."\n";
	if ($rxn->crossReference->ecNumber)
		$rxnAttrValContent .= "EC-NUMBER - ".$rxn->crossReference->ecNumber."\n";
	$rxnAttrValContent .= "REACTION-DIRECTION - ".($rxn->direction == 'F' ? 'LEFT-TO-RIGHT' : 'REVERSIBLE')."\n";
	list($reactants, $products) = $rxn->parseReactionEquation($rxn->stoichiometry);
	foreach($reactants as $reactant){
		$rxnAttrValContent .= "LEFT - ".$reactant['WholeCellModelID']."\n";
		$rxnAttrValContent .= "^COEFFICIENT - ".$reactant['Coefficient']."\n";
		$rxnAttrValContent .= "^COMPARTMENT - ".$reactant['Compartment']."\n";
	}
	foreach($products as $product){
		$rxnAttrValContent .= "RIGHT - ".$product['WholeCellModelID']."\n";
		$rxnAttrValContent .= "^COEFFICIENT - ".$product['Coefficient']."\n";
		$rxnAttrValContent .= "^COMPARTMENT - ".$product['Compartment']."\n";
	}
	if ($rxn->modificationReactant)
		$rxnAttrValContent .= sprintf("MODIFICATION - (%s %s %s)\n", $rxn->modificationReactant, $rxn->modificationPosition, $rxn->modificationCompartment);
	if ($rxn->spontaneous)
		$rxnAttrValContent .= "SPONTANEOUS? - ".$rxn->spontaneous."\n";
	if ($rxn->deltaGExp)
		$rxnAttrValContent .= "DELTAG0-EXP - ".$rxn->deltaGExp."\n"; //extended representation
	if ($rxn->deltaGCalc)
		$rxnAttrValContent .= "DELTAG0-CALC - ".$rxn->deltaGCalc."\n"; //extended representation
	if ($rxn->keq)
		$rxnAttrValContent .= "EQUILIBRIUM-CONSTANT - ".$rxn->keq."\n";
	if ($rxn->lowerBound)
		$rxnAttrValContent .= sprintf("BOUNDS - (%s %s %s)\n", $rxn->lowerBound, $rxn->upperBound, $rxn->boundUnits); //extended representation
	if ($rxn->activators)
		$rxnAttrValContent .= "ACTIVATORS - ".$rxn->activators."\n"; //extended representation
	if ($rxn->inhibitors)
		$rxnAttrValContent .= "INHIBITORS - ".$rxn->inhibitors."\n"; //extended representation
	if ($rxn->pathways)
		$pathways = explode(';', $rxn->pathways);
	else
		$pathways = array();
	foreach($pathways as $pathway)
		$rxnAttrValContent .= "IN-PATHWAY - $pathway\n";
	foreach($rxn->crossReference as $db=>$id)
		$rxnAttrValContent .= "DBLINKS - (".strtoupper($db)." $id)\n";
	if (trim($rxn->comments))
		$rxnAttrValContent .= "COMMENT - ".formatMultiline($rxn->comments)."\n";
	if ($rxn->coenzymes)
		$tmp = explode(';', $rxn->coenzymes);
	else
		$tmp = array();
	$cofactors = array();
	foreach($tmp as $cofactor){
		list($cofactor, $coefficient, $compartment) = $rxn->parseStoichiometry($cofactor, '');
		array_push($cofactors, $cofactor);
	}
	if ($rxn->enzyme){
		$enzID = $rxn->enzyme;
		foreach($knowledgeBase->proteinMonomers as $pm){
			if ($pm->wholeCellModelID == $enzID){
				$enzName = $pm->name;
				$enzComp = "1*$enzID";
				break;
			}
		}
		foreach($knowledgeBase->proteinComplexs as $pc){
			if ($pc->wholeCellModelID == $enzID){
				list($reactants, $products) = $pc->parseReactionEquation($pc->biosynthesis);
				$genes = array();
				$subunitComp = array();
				foreach ($reactants as $subunit){
					array_push($subunitComp, $subunit['Coefficient']."*".$subunit['WholeCellModelID']);
				}

				$enzName = $pc->name;
				$enzComp = join(",", $subunitComp);
				break;
			}
		}

		$rxnAttrValContent .= "ENZYMATIC-REACTION - ENZRXN-FOR-".$rxn->wholeCellModelID."\n";
		$enzRxnAttrValContent .= "UNIQUE-ID - ENZRXN-FOR-".$rxn->wholeCellModelID."\n";
		$enzRxnAttrValContent .= "TYPES - Enzymatic-Reactions\n";
		$enzRxnAttrValContent .= "COMMON-NAME - ".$rxn->name."\n";
		$enzRxnAttrValContent .= "ENZYME - ".$rxn->enzyme."\n";
		$enzRxnAttrValContent .= "REACTION - ".$rxn->wholeCellModelID."\n";
		$enzRxnAttrValContent .= "REACTION-DIRECTION - LEFT-TO-RIGHT\n";
		foreach($cofactors as $cofactor){
			$enzRxnAttrValContent .= "COFACTORS - ".$cofactor."\n";
		}
		if ($rxn->forwardKinetics->kmForward)
			$enzRxnAttrValContent .= "KM - ".$rxn->forwardKinetics->kmForward."\n";
		if ($rxn->forwardKinetics->vmaxExpForward && $rxn->forwardKinetics->vmaxExpUnitForward == '1/min')
			$enzRxnAttrValContent .= "KCAT - ".$rxn->forwardKinetics->vmaxExpForward."\n";
		if ($rxn->forwardKinetics->vmaxExpForward && $rxn->forwardKinetics->vmaxExpUnitForward == 'U/mg')
			$enzRxnAttrValContent .= "VMAX - ".$rxn->forwardKinetics->vmaxExpForward."\n";
		if ($rxn->optimalpH)
			$enzRxnAttrValContent .= "PH-OPT - ".$rxn->optimalpH."\n";
		if ($rxn->optimalTemp)
			$enzRxnAttrValContent .= "TEMPERATURE-OPT - ".$rxn->optimalTemp."\n";
		$enzRxnAttrValContent .= "//\n";

		$colContent .= sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
			"ENZRXN-FOR-".$rxn->wholeCellModelID, $rxn->name, $rxn->stoichiometry,
			$pathways[0], $pathways[1], $pathways[2], $pathways[3],
			$cofactors[0], $cofactors[1], $cofactors[2], $cofactors[3],
			$rxn->activators, null, null, null,
			$rxn->inhibitors, null, null, null,
			$enzComp);
		
		$transColContent .= sprintf("%s\t%s\t%s\t%s\n",
			$enzID, $enzName, $rxn->stoichiometry, $enzComp);
	}
	if ($rxn->enzyme && $rxn->direction != 'F'){
		$rxnAttrValContent .= "ENZYMATIC-REACTION - ENZRXN-REV-".$rxn->wholeCellModelID."\n";
		$enzRxnAttrValContent .= "UNIQUE-ID - ENZRXN-REV-".$rxn->wholeCellModelID."\n";
		$enzRxnAttrValContent .= "TYPES - Enzymatic-Reactions\n";
		$enzRxnAttrValContent .= "COMMON-NAME - ".$rxn->name."\n";
		$enzRxnAttrValContent .= "ENZYME - ".$rxn->enzyme."\n";
		$enzRxnAttrValContent .= "REACTION - ".$rxn->wholeCellModelID."\n";
		$enzRxnAttrValContent .= "REACTION-DIRECTION - RIGHT-TO-LEFT\n";
		foreach($cofactors as $cofactor){
			$enzRxnAttrValContent .= "COFACTORS - ".$cofactor."\n";
		}
		if ($rxn->backwardKinetics->kmBackward)
			$enzRxnAttrValContent .= "KM - ".$rxn->backwardKinetics->kmBackward."\n";
		if ($rxn->backwardKinetics->vmaxExpBackward && $rxn->backwardKinetics->vmaxExpUnitBackward == '1/min')
			$enzRxnAttrValContent .= "KCAT - ".$rxn->backwardKinetics->vmaxExpBackward."\n";
		if ($rxn->backwardKinetics->vmaxExpBackward && $rxn->backwardKinetics->vmaxExpUnitBackward == 'U/mg')
			$enzRxnAttrValContent .= "VMAX - ".$rxn->backwardKinetics->vmaxExpBackward."\n";
		if ($rxn->optimalpH)
			$enzRxnAttrValContent .= "PH-OPT - ".$rxn->optimalpH."\n";
		if ($rxn->optimalTemp)
			$enzRxnAttrValContent .= "TEMPERATURE-OPT - ".$rxn->optimalTemp."\n";
		$enzRxnAttrValContent .= "//\n";
		
		$colContent .= sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
			"ENZRXN-REV-".$rxn->wholeCellModelID, $rxn->name, $rxn->stoichiometry,
			$pathways[0], $pathways[1], $pathways[2], $pathways[3],
			$cofactors[0], $cofactors[1], $cofactors[2], $cofactors[3],
			$rxn->activators, null, null, null,
			$rxn->inhibitors, null, null, null,
			$enzComp);

		$transColContent .= sprintf("%s\t%s\t%s\t%s\n",
			$enzID, $enzName, $rxn->stoichiometry, $enzComp);
	}

	$rxnAttrValContent .= "//\n";

	$linkContent .= sprintf("%s\t%s\n", $rxn->wholeCellModelID, $rxn->crossReference->ecNumber);
}
writeDatFile($outDir, 'reactions.dat', $rxnAttrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'enzrxns.dat', $enzRxnAttrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'bindrxns.dat', '', $knowledgeBase, $version);
writeDatFile($outDir, 'enzymes.col', $colContent, $knowledgeBase, $version);
writeDatFile($outDir, 'transporters.col', $transColContent, $knowledgeBase, $version);
writeDatFile($outDir, 'reaction-links.dat', $linkContent, $knowledgeBase, $version);

//chromosome
$chSeq = $knowledgeBase->readGenomeSequence($knowledgeBase->configuration['genomeSequence']);
$str = sprintf(">%s_uid%s|%s|%s|%s\n",
	str_replace(" ", "_", "$organismCommonName $strainName"),
	$ncbiBioprojectID,
	$genomeID,
	$organismCommonName,
	strtolower($kbID));
$str .= fastaFormat($chSeq);
file_put_contents("$outDir/".strtolower($kbID)."-$genomeID.fsa", utf8_decode($str));

//transcription units, promoters
$regulations = array();
foreach($knowledgeBase->transcriptionalRegulations as $tr){
	if (!array_key_exists($tr->transcriptionUnit, $regulations))
		$regulations[$tr->transcriptionUnit] = array();
	array_push($regulations[$tr->transcriptionUnit], $tr->wholeCellModelID);
}

$tuAttrValContent = '';
$pmAttrValContent = '';
foreach($knowledgeBase->transcriptionUnits as $tu){
	$tuAttrValContent .= "UNIQUE-ID - ".$tu->wholeCellModelID."\n";
	$tuAttrValContent .= "TYPES - Transcription-Units\n";
	$tuAttrValContent .= "COMMON-NAME - ".$tu->name."\n";
	$genes = explode(";", $tu->genes);
	foreach($genes as $gene){
		$gene = array_shift(explode("[", $gene));
		$tuAttrValContent .= "COMPONENTS - ".$gene."\n";
	}
	if (array_key_exists($tu->wholeCellModelID, $regulations)){
		foreach($regulations[$tu->wholeCellModelID] as $tr)
			$tuAttrValContent .= "COMPONENTS - BS0-$tr\n";
	}
	$tuAttrValContent .= "LEFT-END-POSITION - ".$tu->coordinate."\n";
	$tuAttrValContent .= "RIGHT-END-POSITION - ".($tu->coordinate + $tu->length - 1)."\n";
	$tuAttrValContent .= "TRANSCRIPTION-DIRECTION - ".($tu->direction == 'forward' ? '+' : '-')."\n"; //extended representation
	if ($tu->comments)
		$tuAttrValContent .= "COMMENT - ".formatMultiline($tu->comments)."\n";

	if ($tu->promoter35Coordinate){
		$tuAttrValContent .= "COMPONENTS - PM-".$tu->wholeCellModelID."\n";
		$pmAttrValContent .= "UNIQUE-ID - PM-".$tu->wholeCellModelID."\n";
		$pmAttrValContent .= "TYPES - Promoters\n";
		$pmAttrValContent .= "COMMON-NAME - ".$tu->name."\n";
		$pmAttrValContent .= "ABSOLUTE-PLUS-1-POS - ".($tu->direction == 'forward' ? $tu->coordinate + $tu->tSSCoordinate : $tu->coordinate + $tu->length - 1 - $tu->tSSCoordinate)."\n";
		$pmAttrValContent .= "MINUS-10-".($tu->direction == 'forward' ? 'LEFT' : 'RIGHT')." - (".$tu->promoter10Coordinate." ".$tu->promoter10Length.")\n"; //extended representation
		$pmAttrValContent .= "MINUS-35-".($tu->direction == 'forward' ? 'LEFT' : 'RIGHT')." - (".$tu->promoter35Coordinate." ".$tu->promoter35Length.")\n"; //extended representation
		$pmAttrValContent .= "COMPONENT-OF - ".$tu->wholeCellModelID."\n";
		if (array_key_exists($tu->wholeCellModelID, $regulations)){
			foreach($regulations[$tu->wholeCellModelID] as $tr)
				$pmAttrValContent .= "REGULATED-BY - $tr\n";
		}
		$pmAttrValContent .= "//\n";
	}

	$tuAttrValContent .= "//\n";
}
writeDatFile($outDir, 'transunits.dat', $tuAttrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'promoters.dat', $pmAttrValContent, $knowledgeBase, $version);

//terminators
writeDatFile($outDir, 'terminators.dat', '', $knowledgeBase, $version);

//regulons, regulation
$regAttrValContent = '';
foreach($knowledgeBase->transcriptionalRegulations as $tr){
	$regAttrValContent .= "UNIQUE-ID - ".$tr->wholeCellModelID."\n";
	$regAttrValContent .= "TYPES - Regulation-of-Transcription-Initiation\n";
	$regAttrValContent .= "ASSOCIATED-BINDING-SITE - BS0-".$tr->wholeCellModelID."\n";
	$regAttrValContent .= "REGULATED-ENTITY - ".$tr->transcriptionUnit."\n";
	$regAttrValContent .= "REGULATOR - ".$tr->transcriptionFactor."\n";
	$regAttrValContent .= sprintf("MODE - (\"%s\" \"%s\" \"%s\")\n", $tr->affinity, $tr->activity, $tr->element); //extended representation
	if ($tr->condition)
		$regAttrValContent .= "GROWTH-CONDITIONS - ".$tr->condition."\n";
	$regAttrValContent .= "COMMENT - ".formatMultiline($tr->comments)."\n";
	$regAttrValContent .= "//\n";
}
foreach($knowledgeBase->proteinActivations as $reg){
	$regAttrValContent .= "UNIQUE-ID - ".$reg->wholeCellModelID."\n";
	$regAttrValContent .= "TYPES - Regulation-of-Enzyme-Activity\n";
	$regAttrValContent .= "REGULATED-ENTITY - ".$reg->protein."\n";
	$regAttrValContent .= "MECHANISM - ".$reg->activationRule."\n"; //extended representation
	$regAttrValContent .= "COMMENT - ".formatMultiline($reg->comments)."\n";
	$regAttrValContent .= "//\n";
}
writeDatFile($outDir, 'regulation.dat', $regAttrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'regulons.dat', '', $knowledgeBase, $version);

//genes
$attrValContent = '';
$colContent = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	"UNIQUE-ID", "NAME", "PRODUCT-NAME", "SWISS-PROT-ID", "REPLICON",
	"START-BASE", "END-BASE",
	"SYNONYMS", "SYNONYMS", "SYNONYMS", "SYNONYMS",
	"GENE-CLASS", "GENE-CLASS", "GENE-CLASS", "GENE-CLASS");
$linkContent = '';
$seqContent = '';
foreach($knowledgeBase->genes as $gene){
	$attrValContent .= "UNIQUE-ID - ".$gene->wholeCellModelID."\n";
	$attrValContent .= "TYPES - ".$gene->type."\n";
	if ($gene->name)
		$attrValContent .= "COMMON-NAME - ".$gene->name."\n";
	if ($gene->symbol)
		$attrValContent .= "SYNONYMS - ".$gene->symbol."\n";
	if ($gene->synonyms)
		$synonyms = explode(';', $gene->synonyms);
	else
		$synonyms = array();
	foreach($synonyms as $synonym)
		$attrValContent .= "SYNONYMS - ".$synonym."\n";
	foreach($gene->crossReference as $db => $id){
		$db = strtoupper($db);
		$attrValContent .= "DBLINKS	- ($db $id)\n";
	}
	foreach($gene->homolog as $org=>$id){
		$org = strtoupper($org);
		$attrValContent .= "DBLINKS	- ($org $id |Ortholog|)\n";
	}
	$attrValContent .= "CENTISOME-POSITION - ".($gene->coordinate / $genomeLength * 100)."\n";
	$attrValContent .= "LEFT-END-POSITION - ".$gene->coordinate."\n";
	$attrValContent .= "RIGHT-END-POSITION - ".($gene->coordinate + $gene->length - 1)."\n";
	$attrValContent .= "TRANSCRIPTION-DIRECTION - ".($gene->direction == 'forward' ? '+' : '-')."\n";
	$attrValContent .= "COMPONENT-OF - ".$gene->transcriptionUnit."\n";
	$attrValContent .= "COMPONENT-OF - ".$genomeID."\n";
	if ($gene->type == 'mRNA')
		$attrValContent .= "PRODUCT - ".$gene->wholeCellModelID."_MONOMER\n";
	else
		$attrValContent .= "PRODUCT - |".$gene->wholeCellModelID."_".$gene->type."|\n";
	if ($gene->expression)
		$attrValContent .= "EXPRESSION - ".$gene->expression."\n"; //extended representation
	if ($gene->halfLifeExp)
		$attrValContent .= "HALF-LIFE - ".$gene->halfLifeExp."\n";  //extended representation
	if ($gene->essential)
		$attrValContent .= "ESSENTIAL - ".$gene->essential."\n"; //extended representation
	if ($gene->startCodon)
		$attrValContent .= "START-CODON - ".$gene->startCodon."\n"; //extended representation
	if ($gene->codons)
		$codons = explode(';', $gene->codons);
	else
		$codons = array();
	foreach($codons as $codon)
		$attrValContent .= "CODON - ".$codon."\n"; //extended representation
	if ($gene->aminoAcid)
		$attrValContent .= "AMINO-ACID - ".$gene->aminoAcid."\n"; //extended representation
	if ($gene->comments)
		$attrValContent .= "COMMENT - ".formatMultiline($gene->comments)."\n";

	$attrValContent .= "//\n";

	$colContent .= sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
		$gene->wholeCellModelID,
		($gene->symbol ? $gene->symbol : $gene->wholeCellModelID),
		$gene->name,
		$gene->crossReference->swissProt,
		$gene->transcriptionUnit,
		($gene->direction == 'forward' ? $gene->coordinate : $gene->coordinate + $gene->length - 1),
		($gene->direction == 'forward' ? $gene->coordinate + $gene->length - 1 : $gene->coordinate),
		$gene->symbol, $synonyms[0], $synonyms[1], $synonyms[2],
		$gene->type, '', '', '');

	$linkContent .= sprintf("%s\t%s\t%s\t%s\n",
		$gene->wholeCellModelID,
		null,
		($gene->symbol ? $gene->symbol : $gene->wholeCellModelID),
		null);

	$seqContent .= sprintf(">%s %s \"%s\" %s %s %s\n",
		$gene->wholeCellModelID,
		($gene->symbol ? $gene->symbol : $gene->wholeCellModelID),
		$gene->wholeCellModelID."_".($gene->type == 'mRNA' ? "MONOMER" : $gene->type),
		($gene->direction == 'forward'
			? $gene->coordinate."..".($gene->coordinate + $gene->length - 1)
			: "(complement(".($gene->coordinate + $gene->length - 1)."..".$gene->coordinate."))"),
		$organismCommonName,
		$strainName);
	$geneSeq = substr($chSeq, $gene->coordinate-1, $gene->length);
	if ($gene->direction != 'forward'){
		$geneSeq = strrev($geneSeq);
		$geneSeq = str_replace(array('w', 'x', 'y', 'z'), array('T', 'G', 'C', 'A'), str_replace(array('A', 'C', 'G', 'T'), array('w', 'x', 'y', 'z'), $geneSeq));
	}
	$geneSeq = strtolower(substr($geneSeq, 0, 3)).substr($geneSeq, 3, -3).strtolower(substr($geneSeq, -3));
	$seqContent .= fastaFormat($geneSeq, 60);
}
writeDatFile($outDir, 'genes.dat', $attrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'genes.col', $colContent, $knowledgeBase, $version);
writeDatFile($outDir, 'gene-links.dat', $linkContent, $knowledgeBase, $version);
file_put_contents("$outDir/dnaseq.fsa", utf8_decode($seqContent));

//DNA-binding sites
$attrValContent = '';
foreach($knowledgeBase->genomeFeatures as $gf){
	if ($gf->type != 'DnaA box')
		continue;
	$attrValContent .= "UNIQUE-ID - ".$gf->wholeCellModelID."\n";
	$attrValContent .= "TYPES - DnaA-box-".$gf->subtype."\n";
	$attrValContent .= "LEFT-END-POSITION - ".$gf->coordinate."\n";
	$attrValContent .= "RIGHT-END-POSITION - ".($gf->coordinate + $gf->length - 1)."\n";
	$attrValContent .= "SITE-LENGTH - ".$gf->length."\n";
	$attrValContent .= "COMPONENT-OF - $genomeID\n";
	$attrValContent .= "//\n";
}
foreach($knowledgeBase->transcriptionalRegulations as $tr){
	$attrValContent .= "UNIQUE-ID - BS0-".$tr->wholeCellModelID."\n";
	$attrValContent .= "TYPES - DNA-Binding-Sites\n";
	if ($tr->bindingSiteCoordinate){
		$attrValContent .= "LEFT-END-POSITION - ".$tr->bindingSiteCoordinate."\n";
		$attrValContent .= "RIGHT-END-POSITION - ".($tr->bindingSiteCoordinate + $tr->bindingSiteLength - 1)."\n";
		$attrValContent .= "SITE-LENGTH - ".$tr->bindingSiteLength."\n";
	}
	$attrValContent .= "COMPONENT-OF - ".$tr->transcriptionUnit."\n";
	$attrValContent .= "COMPONENT-OF - $genomeID\n";
	$attrValContent .= "INVOLVED-IN-REGULATION - ".$tr->wholeCellModelID."\n";
	$attrValContent .= "//\n";
}
writeDatFile($outDir, 'dnabindsites.dat', $attrValContent, $knowledgeBase, $version);

//proteins
$attrValContent = '';
$colContent = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	'UNIQUE-ID', 'NAME',
	'GENE-NAME', 'GENE-NAME', 'GENE-NAME', 'GENE-NAME',
	'GENE-ID', 'GENE-ID', 'GENE-ID', 'GENE-ID',
	'SUBUNIT-COMPOSITION');
$linkContent = '';
$seqContent = '';
foreach($knowledgeBase->proteinMonomers as $pm){
	$geneID = array_shift(explode("[", $pm->gene));
	foreach($knowledgeBase->genes as $gene){
		if ($gene->wholeCellModelID == $geneID)
			break;
	}

	$attrValContent .= "UNIQUE-ID - ".$pm->wholeCellModelID."\n";
	$attrValContent .= "TYPES - Polypeptides\n";
	if ($pm->name)
		$attrValContent .= "COMMON-NAME - ".$pm->name."\n";
	if ($pm->symbol)
		$attrValContent .= "SYNONYMS - ".$pm->symbol."\n";
	foreach($pm->crossReference as $db=>$id)
		$attrValContent .= "DBLINKS - (".strtoupper($db)." $id)\n";
	$attrValContent .= "GENE - $geneID\n";
	if ($pm->complex)
		$complexes = explode(';', $pm->complex);
	else
		$complexs = array();
	foreach($complexes as $complex)
		$attrValContent .= "COMPONENT-OF - ".$complex."\n";
	if ($pm->molecularWeight)
		$attrValContent .= "MOLECULAR-WEIGHT - ".$pm->molecularWeight."\n";
	$empiricalFormula = $metabolite->parseEmpiricalFormula($metabolite->empiricalFormula);
	foreach($empiricalFormula as $el=>$count)
		$attrValContent .= "CHEMICAL-FORMULA - ($el $count)\n";
	if ($pm->pI)
		$attrValContent .= "PI - ".$pm->pI."\n"; //extended representation
	if ($pm->instability)
		$attrValContent .= "INSTABILITY - ".$pm->instability."\n"; //extended representation
	if ($pm->stability)
		$attrValContent .= "STABILITY - ".$pm->stability."\n"; //extended representation
	if ($pm->aliphatic)
		$attrValContent .= "ALIPHATIC - ".$pm->aliphatic."\n"; //extended representation
	if ($pm->gravy)
		$attrValContent .= "GRAVY - ".$pm->gravy."\n"; //extended representation
	if ($pm->extinctionCoefficient)
		$attrValContent .= "EXTINCTION-COEFFICIENT - ".$pm->extinctionCoefficient."\n"; //extended representation
	if ($pm->absorption)
		$attrValContent .= "ABSORPTION - ".$pm->absorption."\n"; //extended representation
	if ($pm->topology)
		$attrValContent .= "TOPOLOGY - ".$pm->topology."\n"; //extended representation
	if ($pm->activeSite)
		$attrValContent .= "ACTIVE-SITE - ".$pm->activeSite."\n"; //extended representation
	if ($pm->metalBindingSite)
		$attrValContent .= "METAL-BINDING-SITE - ".$pm->metalBindingSite."\n"; //extended representation
	if ($pm->dnaFootprint)
		$attrValContent .= "DNA-FOOTPRINT-SIZE - ".$pm->dnaFootprint."\n";
	if ($pm->molecularInteraction)
		$attrValContent .= "MOLECULAR-INTERACTION - ".$pm->molecularInteraction."\n"; //extended representation
	if ($pm->chemicalRegulation)
		$attrValContent .= "CHEMICAL-REGULATION - ".$pm->chemicalRegulation."\n"; //extended representation
	if ($pm->nTerminalMethionineCleavage)
		$attrValContent .= "N-TERMINAL-METHIONINE-CLEAVAGE - ".$pm->nTerminalMethionineCleavage."\n"; //extended representation
	if ($pm->signalSequenceType)
		$attrValContent .= "SIGNAL-SEQUENCE-TYPE - ".$pm->signalSequenceType."\n"; //extended representation
	if ($pm->signalSequenceLength)
		$attrValContent .= "SIGNAL-SEQUENCE-LENGTH - ".$pm->signalSequenceLength."\n"; //extended representation
	if ($pm->signalSequenceLocation)
		$attrValContent .= "SIGNAL-SEQUENCE-LOCATION - ".$pm->signalSequenceLocation."\n";	 //extended representation
	$attrValContent .= "LOCATIONS - ".$pm->compartment."\n";
	if ($pm->reactions)
		$reactions = explode(';', $pm->reactions);
	else
		$reactions = array();
	foreach($reactions as $reaction)
		$attrValContent .= "CATALYZES - ".$reaction."\n";

	if ($pm->chaperone)
		$tmp = explode(';', $pm->chaperone);
	else
		$tmp = array();
	foreach($tmp as $chaperone){
		list($chaperone, $coefficient, $compartment) = $rxn->parseStoichiometry($chaperone, 'c');
		$attrValContent .= "CHAPERONES - $chaperone\n"; //extended representation
	}

	if ($pm->prostheticGroups)
		$tmp = explode(';', $pm->prostheticGroups);
	else
		$tmp = array();
	foreach($tmp as $cofactor){
		list($cofactor, $coefficient, $compartment) = $rxn->parseStoichiometry($cofactor, 'c');
		$attrValContent .= "PROSTHETIC-GROUPS - $cofactor\n";
		$attrValContent .= "^COEFFICIENT - $coefficient\n"; //extended representation
	}

	if ($pm->subsystem)
		$attrValContent .= "SUBSYSTEM - ".$pm->subsystem."\n";
	if ($pm->generalClassification)
		$attrValContent .= "GENERAL-CLASSIFICATION - ".$pm->generalClassification."\n";
	if ($pm->proteaseClassification)
		$attrValContent .= "PROTEASE-CLASSIFICATION - ".$pm->proteaseClassification."\n";
	if ($pm->transporterClassification)
		$attrValContent .= "TRANSPORTER-CLASSIFICATION - ".$pm->transporterClassification."\n";
	if ($pm->comments)
		$attrValContent .= "COMMENT - ".formatMultiline($pm->comments)."\n";

	$attrValContent .= "//\n";

	$linkContent .= sprintf("%s\t%s\t%s\t%s\n", $pm->wholeCellModelID, $geneID, null, $pm->name);

	$seqContent .= sprintf(">%s %s %s %s %s\n",
		$pm->wholeCellModelID, $pm->name,
		($gene->direction == 'forward'
			? $gene->coordinate."..".($gene->coordinate + $gene->length - 1)
			: "(complement(".($gene->coordinate + $gene->length - 1)."..".$gene->coordinate."))"),
		$organismCommonName, $strainName);
	$seqContent .= fastaFormat($pm->sequence, 60);
}
foreach($knowledgeBase->proteinComplexs as $pc){
	$attrValContent .= "UNIQUE-ID - ".$pc->wholeCellModelID."\n";
	$attrValContent .= "TYPES - Protein-Complexes\n";
	$attrValContent .= "SPECIES - $cycID\n";
	if ($pc->name)
		$attrValContent .= "COMMON-NAME - ".$pc->name."\n";
	foreach($pc->crossReference as $db=>$id)
		$attrValContent .= "DBLINKS - (".strtoupper($db)." $id)\n";
	if ($pc->dnaFootprint)
		$attrValContent .= "DNA-FOOTPRINT-SIZE - ".$pc->dnaFootprint."\n";
	$attrValContent .= "LOCATIONS - ".$pc->compartment."\n";

	if ($pc->reactions)
		$reactions = explode(';', $pc->reactions);
	else
		$reactions = array();
	foreach($reactions as $reaction)
		$attrValContent .= "CATALYZES - ".$reaction."\n";

	if ($pc->disulfideBonds)
		$dsBonds = explode(';', $pc->disulfideBonds);
	else
		$dsBonds = array();
	foreach($dsBonds as $dsBond){
		list($subunit, $residues) = explode(': ', $dsBond);
		list($residue1, $residue2) = explode('-', $residues);
		$residue1 = substr($residue1, 1);
		$residue2 = substr($residue2, 1);
		$attrValContent .= "DISULFIDE-BONDS - ($subunit $residue1 $residue2)\n";
	}

	if ($pc->molecularInteraction)
		$attrValContent .= "MOLECULAR-INTERACTION - ".$pc->molecularInteraction."\n"; //extended representation
	if ($pc->chemicalRegulation)
		$attrValContent .= "CHEMICAL-REGULATION - ".$pc->chemicalRegulation."\n"; //extended representation
	if ($pc->subsystem)
		$attrValContent .= "SUBSYSTEM - ".$pc->subsystem."\n";
	if ($pc->generalClassification)
		$attrValContent .= "GENERAL-CLASSIFICATION - ".$pc->generalClassification."\n";
	if ($pc->proteaseClassification)
		$attrValContent .= "PROTEASE-CLASSIFICATION - ".$pc->proteaseClassification."\n";
	if ($pc->transporterClassification)
		$attrValContent .= "TRANSPORTER-CLASSIFICATION - ".$pc->transporterClassification."\n";
	if ($pc->comments)
		$attrValContent .= "COMMENT - ".formatMultiline($pc->comments)."\n";

	$linkContent .= sprintf("%s\t%s\t%s\t%s\n", $pc->wholeCellModelID, null, null, $pc->name);

	list($reactants, $products) = $pc->parseReactionEquation($pc->biosynthesis);
	$subunitComp = array();
	foreach ($reactants as $subunit){
		array_push($subunitComp, $subunit['Coefficient']."*".$subunit['WholeCellModelID']);
		$attrValContent .= "COMPONENTS - ".$subunit['WholeCellModelID']."\n";
		$attrValContent .= "^COEFFICIENT - ".$subunit['Coefficient']."\n";
	}
	$genes = proteinsToGenes($pc->wholeCellModelID, $knowledgeBase);
	$geneIDs = array_merge(array_keys($genes), array(null, null, null));
	$geneNames = array_merge(array_values($genes), array(null, null, null));

	if ($pc->prostheticGroups)
		$tmp = explode(';', $pc->prostheticGroups);
	else
		$tmp = array();
	foreach($tmp as $cofactor){
		list($cofactor, $coefficient, $compartment) = $rxn->parseStoichiometry($cofactor, 'c');
		$attrValContent .= "PROSTHETIC-GROUPS - $cofactor\n";
		$attrValContent .= "^COEFFICIENT - $coefficient\n"; //extended representation
	}

	if ($pc->chaperone)
		$tmp = explode(';', $pc->chaperone);
	else
		$tmp = array();
	foreach($tmp as $chaperone){
		list($chaperone, $coefficient, $compartment) = $rxn->parseStoichiometry($chaperone, 'c');
		$attrValContent .= "CHAPERONES - $chaperone\n"; //extended representation
	}

	$colContent .= sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
		$pc->wholeCellModelID, $pc->name,
		$geneIDs[0], $geneIDs[1], $geneIDs[2], $geneIDs[3],
		$geneNames[0], $geneNames[1], $geneNames[2], $geneNames[3], 
		join(",", $subunitComp));

	$attrValContent .= "//\n";
}
writeDatFile($outDir, 'proteins.dat', $attrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'protligandcplxes.dat', '', $knowledgeBase, $version);
writeDatFile($outDir, 'protein-features.dat', '', $knowledgeBase, $version);
writeDatFile($outDir, 'protein-links.dat', $linkContent, $knowledgeBase, $version);
writeDatFile($outDir, 'protcplxs.col', $colContent, $knowledgeBase, $version);
file_put_contents("$outDir/protseq.fsa", utf8_decode($seqContent));

//pathways
$attrValContent = '';
$linkContent = '';
$colContent = "";
$funcAssocColContent = "UNIQUE-ID\tNAME\tGENES\n";
$maxNGenes = 0;
foreach($knowledgeBase->pathways as $pathway){
	$attrValContent .= "UNIQUE-ID - ".$pathway->wholeCellModelID."\n";
	$attrValContent .= "TYPES - Pathway\n";
	$attrValContent .= "COMMON-NAME - ".$pathway->name."\n";
	$enzymes = array();
	if ($pathway->reactions){
		$reactions = explode(';', $pathway->reactions);
		foreach($reactions as $reaction){
			$attrValContent .= "REACTION-LIST - $reaction\n";
			foreach($knowledgeBase->reactions as $rxn){
				if ($rxn->wholeCellModelID == $reaction && $rxn->enzyme)
					array_push($enzymes, $rxn->enzyme);
			}
		}
	}
	if ($pathway->comments)
		$attrValContent .= "COMMENT - ".formatMultiline($pathway->comments)."\n";
	$attrValContent .= "//\n";

	$linkContent .= $pathway->wholeCellModelID."\t".$pathway->name."\t\n";
	$genes = array_keys(proteinsToGenes($enzymes, $knowledgeBase));
	
	$maxNGenes = max($maxNGenes, count($genes));

	$colContent .= $pathway->wholeCellModelID."\t".$pathway->name.(empty($genes) ? "" : "\t".join("\t", $genes))."\n";
	$funcAssocColContent .= sprintf("%s\t%s%s\n",
		$pathway->wholeCellModelID,
		$pathway->name,
		(empty($genes) ? "" : "\t".join("\t", $genes)));
}
$colContent = "UNIQUE-ID\tNAME".str_repeat("\tGENE-NAME", $maxNGenes)."\n".$colContent;

writeDatFile($outDir, 'pathways.dat', $attrValContent, $knowledgeBase, $version);
writeDatFile($outDir, 'pathway-links.dat', $linkContent, $knowledgeBase, $version);
writeDatFile($outDir, 'pathways.col', $colContent, $knowledgeBase, $version);
writeDatFile($outDir, 'func-associations.col', $funcAssocColContent, $knowledgeBase, $version);

//references
$attrValContent = '';
foreach ($knowledgeBase->references as $ref) {
$ref->knowledgeBase = null;
	$attrValContent .= "UNIQUE-ID - ".$ref->wholeCellModelID."\n";
	$attrValContent .= "TYPES - ".$ref->type."\n";
	$authors = $editors = array();
	if ($ref->authors)
		$authors = explode(", ", $ref->authors);
	if ($ref->editors)
		$editors = explode(", ", $ref->editors);
	foreach($authors as $author)
		$attrValContent .= "AUTHORS - $author\n";
	foreach($editors as $editor)
		$attrValContent .= "EDITORS - $editor\n"; //extended representation
	if ($ref->type == 'article' && $ref->publication)
		$attrValContent .= "SOURCE - ".$ref->publication.($ref->volume ? " ".$ref->volume : "").($ref->issue ? " (".$ref->issue.")" : "").($ref->pages ? ": ".$ref->pages : "")."\n";
	elseif ($ref->publisher)
		$attrValContent .= "SOURCE - ".$ref->publisher."\n";
	if ($ref->title)
		$attrValContent .= "TITLE - ".$ref->title."\n";
	if ($ref->year)
		$attrValContent .= "YEAR - ".$ref->year."\n";
	if ($ref->crossReference->pmid)
		$attrValContent .= "PUBMED-ID - ".$ref->crossReference->pmid."\n";
	if ($ref->crossReference->isbn)
		$attrValContent .= "DBLINKS - (ISBN ".$ref->crossReference->isbn.")\n";
	if ($ref->url)
		$attrValContent .= "URL - ".$ref->url."\n";
	if ($ref->comments)
		$attrValContent .= "COMMENT - ".formatMultiline($ref->comments)."\n";

	$attrValContent .= "//\n";
}
writeDatFile($outDir, 'pubs.dat', $attrValContent, $knowledgeBase, $version);

//classes
$attrValContent = '';
$tmp = $classes;
$classes = array();
foreach($tmp as $tmp2){
	if (!array_key_exists($tmp2['id'], $classes))
		$classes[$tmp2['id']] = $tmp2;
	elseif (!($classes[$tmp2['id']] == $tmp2)){
		echo "ERROR: class ".$tmp2['id']." multiply defined\n";
		exit;
	}
}
foreach($classes as $class){
	$attrValContent .= "UNIQUE-ID - ".$class['id']."\n";
	$attrValContent .= "COMMON-NAME - ".$class['name']."\n";
	if (array_key_exists('synonym', $class)){
		foreach($class['synonym'] as $synonym)
			$attrValContent .= "SYNONYMS - ".$synonym."\n";
	}
	if (!array_key_exists('type', $class)){
		echo "ERROR: undefined type of class ".$tmp2['id']."\n";
		exit;
	}
	foreach($class['type'] as $type)
		$attrValContent .= "TYPES - ".$type."\n";
	if ($class['comment'])
		$attrValContent .= "COMMENT - ".$class['comment']."\n";

	$attrValContent .= "//\n";
}
writeDatFile($outDir, 'classes.dat', $attrValContent, $knowledgeBase, $version);

//*********************
//helper functions
//*********************
function writeDatFile($outDir, $fileName, $content, $knowledgeBase, $version){
	$organismStr = join(" ", array_splice(explode(';', $knowledgeBase->taxonomy), -3));
	$cycID = $knowledgeBase->wholeCellModelID.'cyc';
	$dateStr = date('F j, Y, H:i:s');
	$year = date('Y');
	$header = <<<HEADER
# Copyright © $year, Stanford University. All rights reserved.
#
# Authors:
#    Jonathan R Karr, jkarr@stanford.edu
#    Jayodita C Sanghvi, jayodita@stanford.edu
#    Derek N Macklin, macklin@stanford.edu
#    Jared M Jacobs, jmjacobs@stanford.edu
#    Markus W Covert, mcovert@stanford.edu
#
# Affiliation:
#    Covert Lab
#    Department of Bioengineering
#    Stanford University
#    http://covertlab.stanford.edu
#
# The format of this file is defined at http://bioinformatics.ai.sri.com/ptools/flatfile-format.html.
#
# Species: $organismStr
# Database: $cycID
# Version: $version
# File Name: $fileName
# Date and time generated: $dateStr
#
HEADER;

file_put_contents("$outDir/$fileName", utf8_decode($header."\n".$content));
}

function fastaFormat($seq, $lineLength = 80){
	$str = '';
	for ($i = 0; $i < strlen($seq); $i += $lineLength)
		$str .= substr($seq, $i, $lineLength)."\n";
	return $str;
}

function formatMultiline($str){
	return str_replace("\n", "\n/", trim($str));
}

function proteinsToGenes($enzymes, $knowledgeBase){
	if (!is_array($enzymes))
		$enzymes = array($enzymes);
	$enzymes = array_unique($enzymes);
	$monomers = array();
	$geneIDs = array();
	while (!empty($enzymes)){

		$isMon = false;
		foreach($knowledgeBase->proteinMonomers as $pm){
			if ($pm->wholeCellModelID == $enzymes[0]){
				array_push($monomers, $enzymes[0]);
				array_shift($enzymes);
				$isMon = true;
				break;
			}
		}
		if ($isMon)
			continue;

		$isCpx = false;
		foreach($knowledgeBase->proteinComplexs as $pc){
			if ($pc->wholeCellModelID == $enzymes[0]){
				array_shift($enzymes);
				list($reactants, $products) = $pc->parseReactionEquation($pc->biosynthesis);
				foreach($reactants as $reactant)
					array_push($enzymes, $reactant['WholeCellModelID']);
				$enzymes = array_unique($enzymes);
				$isCpx = true;
				break;
			}
		}
		if ($isCpx)
			continue;

		$isRna = false;
		foreach($knowledgeBase->genes as $gene){
			if ($gene->wholeCellModelID == $enzymes[0]){
				array_push($geneIDs, $enzymes[0]);
				array_shift($enzymes);
				$isRna = true;
				break;
			}
		}
		if ($isRna)
			continue;

		array_shift($enzymes);
	}

	foreach($monomers as $monomer){
		foreach($knowledgeBase->proteinMonomers as $pm){
			if($pm->wholeCellModelID == $monomer){
				array_push($geneIDs, array_shift(explode("[", $pm->gene)));
				break;
			}
		}
	}
	$geneIDs = array_unique($geneIDs);
	
	$genes = array();
	foreach($geneIDs as $geneID){
		foreach($knowledgeBase->genes as $gene){
			if ($gene->wholeCellModelID == $geneID){
				$genes[$geneID] = $gene->name;
				break;
			}
		}
	}
	return $genes;
}

?>