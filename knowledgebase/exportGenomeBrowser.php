<?php

/*
 * exportGenomeBrowser.php
 *
 * @author: Jonathan Karr
 * @affiliation: Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated: 3/29/2010
 */

//*********************
//include classes
//*********************
set_include_path(get_include_path() . PATH_SEPARATOR . 'lib');

require_once 'library.php';
require_once 'src/include.php';

$knowledgeBase = new KnowledgeBase();
$knowledgeBase->selectWID();
$knowledgeBase->loadFromDatabase(array('genes', 'transcriptionUnits'));
$knowledgeBase->exportGenomeBrowserSVG('genes');
$knowledgeBase->exportGenomeBrowserSVG('transcriptionUnits');