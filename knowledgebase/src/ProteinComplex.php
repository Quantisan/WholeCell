<?php
/**
 * Description of ProteinComplex
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class ProteinComplex extends KnowledgeBaseObject {

	public $biosynthesis;
	public $compartment;
	public $disulfideBonds;
	public $prostheticGroups;
	public $chaperones;

	public $halfLifeCalc;
	public $molecularWeight;
	public $dnaFootprint;
	public $dnaFootprintBindingStrandedness;
	public $dnaFootprintRegionStrandedness;
	public $molecularInteraction;
	public $chemicalRegulation;
	public $subsystem;
	public $generalClassification;
	public $proteaseClassification;
	public $transporterClassification;
	public $complexFormationProcess;

	public $reactions;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
	
	function validate(){
		list($error, $warning) = parent::validate();
		if ($error !== true)
			return array($error, $warning);
			
		//array of chaperones
		$chaperones = $this->chaperones;
		if (!is_array($chaperones)) $chaperones = explode(';', $chaperones);			
		foreach ($chaperones as $chaperone){
			preg_match('/^(\(-*[0-9]*\.*[0-9]*\) ){0,1}([a-z][a-z0-9_]*)\[([a-z][a-z0-9_]*)\]$/i', $chaperone, $match);
			
			$wholeCellModelID = $match[2];
			$compartment = $match[3];
			
			//check that chaperone doesn't belong to macromolecular complex
			if (array_key_exists($wholeCellModelID, $this->knowledgeBase->monomerComplexs) &&
			count($this->knowledgeBase->monomerComplexs[$wholeCellModelID]) > 0){		
				array_push($warning, 'Chaperone is a subunit of a macromolecular complex.');
			}
				
			//check that chaperone compartment matches the compartment of the protein
			if (array_key_exists($wholeCellModelID, $this->knowledgeBase->moleculeCompartments) &&
			$this->knowledgeBase->moleculeCompartments[$wholeCellModelID] != $compartment){
				array_push($warning, 'Chaperone references a compartment in which the protein may not exist.');
			}
		}
		
		//check biosynthesis
		list($reactants, $products) = $this->parseReactionEquation($this->biosynthesis);
		
		foreach ($reactants as $reactant){
			//check that reactant doesn't belong to macromolecular complex
			if (array_key_exists($reactant['WholeCellModelID'], $this->knowledgeBase->monomerComplexs) &&
				count($this->knowledgeBase->monomerComplexs[$reactant['WholeCellModelID']]) > 1){		
				array_push($warning, 'Reactant is a subunit of a macromolecular complex.');
			}
				
			//check that reactant compartment matches the compartment of the molecule
			if (array_key_exists($reactant['WholeCellModelID'], $this->knowledgeBase->moleculeCompartments) &&
				$this->knowledgeBase->moleculeCompartments[$reactant['WholeCellModelID']] != $reactant['Compartment']){
				array_push($warning, 'Biosynthesis references a compartment in which a reactant may not exist.');
			}
		}
		
		foreach ($products as $product){
			//check that product doesn't belong to macromolecular complex
			if (array_key_exists($product['WholeCellModelID'], $this->knowledgeBase->monomerComplexs) &&
				count($this->knowledgeBase->monomerComplexs[$product['WholeCellModelID']]) > 1){		
				array_push($warning, 'Product is a subunit of a macromolecular complex.');
			}
				
			//check that product compartment matches the compartment of the molecule
			if (array_key_exists($product['WholeCellModelID'], $this->knowledgeBase->moleculeCompartments) &&
				$this->knowledgeBase->moleculeCompartments[$product['WholeCellModelID']] != $product['Compartment']){
				array_push($warning, 'Biosynthesis references a compartment in which a product may not exist.');
			}
		}
		
		return array(true, $warning);
	}
}
?>
