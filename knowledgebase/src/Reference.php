<?php
/**
 * Description of Reference
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering Stanford University
 * @lastupdated 3/23/2010
 */
class Reference extends KnowledgeBaseObject {

	public $type;
	public $authors;
	public $editors;
	public $year;
	public $title;
	public $publication;
	public $volume;
	public $issue;
	public $pages;
	public $publisher;
	public $url;

	public $citations;

	function  __construct($idx, $tableID, $knowledgeBase) {
		parent::__construct($idx, $tableID, $knowledgeBase);
	}
}
?>
