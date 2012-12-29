<?php
/**
 * Description of Gene
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class Gene extends KnowledgeBaseObject {

	public $symbol;
	public $synonyms;
	public $type;
	public $startCodon;
	public $codons;
	public $aminoAcid;
	public $coordinate;
	public $length;
	public $direction;
	public $sequence;
	public $molecularWeight;
	public $gcContent;
	public $essential;
	public $expression;
	public $expressionColdShock;
	public $expressionHeatShock;
	public $halfLifeExp;
	public $halfLifeCalc;
	public $halfLifeTimeConstant;
	public $synthesisRate;
	public $probRNAPolBinding;
	public $pI;

	public $transcriptionUnit;
	public $reactions;
	public $compartment;
	
	public $homolog;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
		$this->homolog = new stdClass();
	}
}
?>
