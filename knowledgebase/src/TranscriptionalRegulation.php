<?php
/**
 * Description of TranscriptionalRegulation
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class TranscriptionalRegulation extends KnowledgeBaseObject {

	public $transcriptionUnit;
	public $transcriptionFactor;
	public $transcriptionFactorCompartment;

	public $bindingSiteCoordinate;
	public $bindingSiteLength;
	public $bindingSiteDirection;
	public $bindingSiteSequence;
	public $affinity;
	public $activity;
	public $element;
	public $condition;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
	
	function validate(){
		list($error, $warning) = parent::validate();
		if ($error !== true)
			return array($error, $warning);
			
		//check that transcriptional regulations don't reference as transcription factors monomers that belong to complexes
		if (array_key_exists($this->transcriptionFactor, $this->knowledgeBase->monomerComplexs) &&
		count($this->knowledgeBase->monomerComplexs[$this->transcriptionFactor]) > 0){		
			array_push($warning, 'Transcription factor is a subunit of a macromolecular complex.');
		}
			
		//check that transcriptional regulations don't reference wrong compartment of transcription factors
		if (array_key_exists($this->transcriptionFactor, $this->knowledgeBase->moleculeCompartments) &&
		$this->knowledgeBase->moleculeCompartments[$this->transcriptionFactor] != $this->transcriptionFactorCompartment){
			array_push($warning, 'Transcriptional regulation references a compartment in which the transcription factor may not exist.');
		}
		
		return array(true, $warning);
	}
}
?>
