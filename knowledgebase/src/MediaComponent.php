<?php
/**
 * Description of MediaComponent
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class MediaComponent extends KnowledgeBaseObject {

	public $metabolite;
	public $compartment;

	public $concentration;
	public $initialTime;
	public $finalTime;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
