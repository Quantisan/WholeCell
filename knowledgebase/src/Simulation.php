<?php
/**
 * Description of Simulation
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class Simulation extends KnowledgeBaseObject {

	public $label;
	public $investigator;
	public $date;
	public $description;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
