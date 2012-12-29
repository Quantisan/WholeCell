<?php
/**
 * Description of MetabolicMapReaction
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class MetabolicMapReaction extends KnowledgeBaseObject {

	public $reaction;

	public $path;
	public $labelX;
	public $labelY;
	public $valueX;
	public $valueY;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
