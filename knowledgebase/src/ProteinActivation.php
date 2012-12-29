<?php
/**
 * Description of ProteinActivation
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class ProteinActivation extends KnowledgeBaseObject {

	public $protein;
	public $regulators;

	public $activationRule;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
	
	function validate(){
		list($error, $warning) = parent::validate();
		if($error !== true)
			return array($error, $warning);
			
		//check that protein doesn't belong to macromolecular complex
		if (array_key_exists($protein, $this->knowledgeBase->monomerComplexs) &&
		count($this->knowledgeBase->monomerComplexs[$protein]) > 0){		
			array_push($warning, 'Protein is a subunit of a macromolecular complex.');
		}
			
		//check that regulator doesn't belong to macromolecular complex
		$regulators = $this->regulators;
		if (!is_array($regulators)) $regulators = explode(';', $regulators);			
		foreach ($regulators as $regulator){		
			if (array_key_exists($regulator, $this->knowledgeBase->monomerComplexs) &&
			count($this->knowledgeBase->monomerComplexs[$regulator]) > 0){		
				array_push($warning, 'Regulator is a subunit of a macromolecular complex.');
			}
		}
					
		return array(true, $warning);
	}
}
?>
