<?php
/**
 * Description of ProteinMonomer
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class ProteinMonomer extends KnowledgeBaseObject {

	public $gene;
	public $symbol;
	public $length;
	public $negAA;
	public $posAA;
	public $sequence;
	public $molecularWeight;
	public $atoms;
	public $formula;
	public $nTerminalAA;
	public $pI;
	public $halfLifeCalc;
	public $instability;
	public $stability;
	public $aliphatic;
	public $gravy;
	public $extinctionCoefficient;
	public $absorption;
	public $complex;
	public $topology;
	public $activeSite;
	public $metalBindingSite;
	public $dnaFootprint;
	public $dnaFootprintBindingStrandedness;
	public $dnaFootprintRegionStrandedness;
	public $molecularInteraction;
	public $chemicalRegulation;
	public $subsystem;
	public $generalClassification;
	public $proteaseClassification;
	public $transporterClassification;
	public $compartment;
	public $nTerminalMethionineCleavage;
	public $signalSequenceType;
	public $signalSequenceLocation;
	public $signalSequenceLength;
	public $prostheticGroups;
	public $chaperones;

	public $reactions;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
	
	function validate(){
		list($error, $warning) = parent::validate();
		if($error !== true)
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
			
		return array(true, $warning);
	}
}
?>
