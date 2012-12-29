<?php
/**
 * Description of GenomeFeature
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class GenomeFeature extends KnowledgeBaseObject {

	public $type;
	public $subtype;
	public $coordinate;
	public $length;
	public $direction;
	public $sequence;

	public $genes;
	public $transcriptionUnits;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
