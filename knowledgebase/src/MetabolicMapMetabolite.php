<?php
/**
 * Description of MetabolicMapMetabolite
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class MetabolicMapMetabolite extends KnowledgeBaseObject {

	public $metabolite;
	public $compartment;

	public $x;
	public $y;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
