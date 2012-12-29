<?php
/**
 * Description of Reaction
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class Reaction extends KnowledgeBaseObject {

	public $type;
	public $spontaneous;
	public $stoichiometry;
	public $modificationPosition;
	public $direction;
	public $deltaGExp;
	public $deltaGCalc;
	public $deltaG;
	public $keq;
	public $optimalpH;
	public $optimalTemp;
	public $activators;
	public $inhibitors;
	public $lowerBound;
	public $upperBound;
	public $boundUnits;

	public $process;
	public $state;
	public $enzyme;
	public $enzymeCompartment;
	public $pathways;
	public $modificationReactant;
	public $modificationCompartment;
	public $coenzymes;

	public $forwardKinetics;
	public $backwardKinetics;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}

	function validate(){
		list($error, $warning) = parent::validate();
		if($error !== true)
			return array($error, $warning);		
			
		if ((!$this->process && !$this->state) || ($this->process && $this->state))
			return array('Reactions must be associated with a process or state',true);

		//validate chemical, transport, exchange reactons - no modification substrates
		if ($this->process == 'Process_Metabolism' &&
			array_search($this->type,array('chemical','transport','exchange')) &&
			$this->modificationReactant)
			return array('Metabolic reactions cannot have modification reactants', true);

		//validate exchange reactions -- no reactants
		if ($this->process == 'Process_Metabolism' &&
			array_search($this->type,array('exchange')) &&
			$this->modificationReactant){
			list($reactants, $products) = $this->parseReactionEquation($this->stoichiometry);
			if (count($reactants) > 0)
				return array('Metabolic exchange reactions cannot have reactants', true);
		}
		
		//check that reactions don't reference as enzymes monomer that belong to complexes
		if (array_key_exists($this->enzyme, $this->knowledgeBase->monomerComplexs) &&
		count($this->knowledgeBase->monomerComplexs[$this->enzyme]) > 0){		
			array_push($warning, 'Reaction reference enzyme which is a subunit of a macromolecular complex.');
		}
		
		//check that reactions don't reference wrong compartment of enzymes
		if (array_key_exists($this->enzyme, $this->knowledgeBase->moleculeCompartments) &&
		$this->knowledgeBase->moleculeCompartments[$this->enzyme] != $this->enzymeCompartment){
			array_push($warning, 'Reaction references a compartment in which the enzyme may not exist.');
		}
		
		//check that reactions don't reference wrong compartment of modification reactants
		if (array_key_exists($this->modificationReactant, $this->knowledgeBase->moleculeCompartments) &&
		$this->knowledgeBase->moleculeCompartments[$this->modificationReactant] != $this->modificationCompartment){
			array_push($warning, 'Reaction references a compartment in which the modification reactant may not exist.');
		}
		
		//check stoichiometry
		list($reactants, $products) = $this->parseReactionEquation($this->stoichiometry);
		
		foreach ($reactants as $reactant){
			//check that reactant doesn't belong to macromolecular complex
			if(array_key_exists($reactant['WholeCellModelID'], $this->knowledgeBase->monomerComplexs) &&
			count($this->knowledgeBase->monomerComplexs[$reactant['WholeCellModelID']]) > 0){		
				array_push($warning, 'Reactant is a subunit of a macromolecular complex.');
			}
				
			//check that reactant compartment matches the compartment of the molecule
			if (array_key_exists($reactant['WholeCellModelID'], $this->knowledgeBase->moleculeCompartments) &&
			$this->knowledgeBase->moleculeCompartments[$reactant['WholeCellModelID']] != $reactant['Compartment']){
				array_push($warning, 'Stoichiometry references a compartment in which a reactant may not exist.');
			}
		}
		
		foreach ($products as $product){
			//check that product doesn't belong to macromolecular complex
			if (array_key_exists($product['WholeCellModelID'], $this->knowledgeBase->monomerComplexs) &&
			count($this->knowledgeBase->monomerComplexs[$product['WholeCellModelID']]) > 0){		
				array_push($warning, 'Product is a subunit of a macromolecular complex.');
			}
				
			//check that product compartment matches the compartment of the molecule
			if (array_key_exists($product['WholeCellModelID'], $this->knowledgeBase->moleculeCompartments) &&
			$this->knowledgeBase->moleculeCompartments[$product['WholeCellModelID']] != $product['Compartment']){
				array_push($warning, 'Stoichiometry references a compartment in which a product may not exist.');
			}
		}
		
		return array(true, $warning);
	}
}
?>
