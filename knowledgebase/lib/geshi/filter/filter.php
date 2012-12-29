<?php //$Id: filter.php,v 1.8 2005/05/19 17:32:30 defacer Exp $


/**************************************************************
 *  This program is a part of Moodle - Modular Object-Oriented Dynamic 
 *  Learning Environment - http://moodle.org                             
 *
 *  GeSHi syntax highlight filter for Moodle
 *  By Grigory Rubtsov <rgbeast@onlineuniversity.ru>, 2005
 *
 *  Uses GeSHi syntax highlighter 1.0.7 
 *  http://qbnz.com/highlighter/
 *  @author    Nigel McNie <nigel@geshi.org>
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  http://www.gnu.org/copyleft/gpl.html
**************************************************************/

// set to true if you with to use your own style (see README.txt for details)
$CFG->geshifilterexternalcss=false;

require_once("php/filter/geshi/geshi.php");

// Highlight code enclosed by <span syntax='langname'> </span>

function geshi_filter($courseid, $text) {
  $search = '/<span syntax="([a-zA-Z_-]*)".*?>(.+?)<\/span>\s*/is';
  return preg_replace_callback($search, 'geshi_filter_callback', $text);
}


function geshi_filter_callback($subtext) {
    global $CFG;

    if(isset($subtext[2])) {
      $lang = $subtext[1];
      if($lang[0]=="_") {
	$linenumbers=true;
	$lang=substr($lang,1,strlen($lang)-1);      
      }
      else {
        $linenumbers=false;
      }
      if($lang=="html") $lang="html4strict";
      $code = $subtext[2];
      $code = geshi_filter_decode_special_chars(geshi_filter_br2nl($code));

      $path = $CFG->dirroot.'/filter/geshi/geshi/geshi';
      $geshi = new GeSHi($code, $lang, $path);
      $geshi->enable_classes($CFG->geshifilterexternalcss);
      if($linenumbers) {
        $geshi->enable_line_numbers(GESHI_NORMAL_LINE_NUMBERS);  
      }
      
      return $geshi->parse_code();
    }
}

function geshi_filter_br2nl($str) {
  return preg_replace("'<br\s*\/?>\r?\n?'","\n",$str);
}

function geshi_filter_decode_special_chars($str) {
  // analog of htmlspecialchars_decode in PHP 5
  $search = array("&amp;","&quot;", "&lt;", "&gt;","&#92;","&#39;");
  $replace = array("&","\"", "<", ">","\\","\'");
  return str_replace($search, $replace, $str);
}



?>