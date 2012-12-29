<?php
/**
 * Description of BiomassComposition
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class BiomassComposition extends KnowledgeBaseObject {

	public $metabolite;
	public $compartment;

	public $biomassCompositionCoefficient;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
