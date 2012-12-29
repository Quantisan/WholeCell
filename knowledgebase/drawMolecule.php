<?php

/* Webservice for drawing chemical structures from SMILES description.
 * Uses ChemAxon Marvin or dino-render (windows only) software.
 *
 * References
 * 1. ChemAxon Marvin
 *	http://www.chemaxon.com/marvin/
 * 2. Dingo Reference
 *	http://opensource.scitouch.net/indigo/dingo/command-line_reference
 * 3. SMILES - A Simplified Chemical Language
 *	http://www.daylight.com/dayhtml/doc/theory/theory.smiles.html
 *
 * Author: Jonathan Karr, jkarr@stanford.edu
 * Affiliation: Covert Lab, Department of Bioengineering, Stanford University
 * Last Updated: 3/23/2010
 */

//--------------------------
//process arguments
//--------------------------
//extract arguments
extract($_GET);

//$options
if (!$BGColor) $BGColor = "213 228 246";
if (!$Width) $Width = 646;
if (!$Height) $Height = 200;
if (!$Coloring) $Coloring = 'on';
if (!$BaseColor) $BaseColor = "0 0 0";
if (!$HLColor) $HLColor = "0 0 0";
if (!$AAMColor) $AAMColor = "0 0 0";
if (!$Renderer) $Renderer = 'Marvin';

//make temporary directory
if (!is_dir('tmp'))
	mkdir('tmp');

//--------------------------
//render
//--------------------------
switch($Renderer){
	case 'Dingo':
		exec("lib/indigo-depict/indigo-depict - $Smiles tmp/tmp.png -w $Width -h $Height -coloring $Coloring -bgcolor $BGColor -basecolor $BaseColor");
		break;
	case 'Marvin':
		$path = ".:lib/ChemAxon/MarvinBeans/lib/MarvinBeans.jar";
		`java -classpath $path DrawMolecule "$Smiles" $Width $Height $BGColor "png" "tmp/tmp.png"`;
		break;
}
header('Content-Type: image/png');
readfile('tmp/tmp.png');

?>
