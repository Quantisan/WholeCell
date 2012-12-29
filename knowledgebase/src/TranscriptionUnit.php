<?php
/**
 * Description of TranscriptionUnit
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class TranscriptionUnit extends KnowledgeBaseObject {

	public $genes;

	public $type;
	public $coordinate;
	public $length;
	public $direction;
	public $promoter35Coordinate;
	public $promoter35Length;
	public $promoter10Coordinate;
	public $promoter10Length;
	public $tSSCoordinate;
	public $sequence;
	public $synthesisRate;
	public $probRNAPolBinding;
	
	public $compartment;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
