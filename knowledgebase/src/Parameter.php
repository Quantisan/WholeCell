<?php
/**
 * Description of Parameter
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class Parameter extends KnowledgeBaseObject {
	public $process;
	public $state;
	public $reactions;
	public $molecules;

	public $index;
	public $description;
	public $defaultValue;
	public $units;
	public $experimentallyConstrained;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
	
	function validate(){
		list($error, $warning) = parent::validate();
		if($error !== true)
			return array($error, $warning);	
			
		//check that protein doesn't belong to macromolecular complex
		$molecules = $this->molecules;
		if (!is_array($molecules)) $molecules = explode(';',$molecules);
		
		foreach ($molecules as $molecule){
			if (array_key_exists($molecule, $this->knowledgeBase->monomerComplexs) &&
			count($this->knowledgeBase->monomerComplexs[$molecule]) > 0){		
				array_push($warning, 'Molecule is a subunit of a macromolecular complex.');
			}
		}
		
		return array(true, $warning);
	}
}
?>
