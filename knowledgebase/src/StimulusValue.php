<?php
/**
 * Description of StimulusValue
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class StimulusValue extends KnowledgeBaseObject {

	public $stimulus;
	public $compartment;
	
	public $value;
	public $initialTime;
	public $finalTime;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
