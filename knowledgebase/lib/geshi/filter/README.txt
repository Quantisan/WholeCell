Syntax highlight filter based on GeSHi

It can highlight c,asm,bash,cpp,css,lisp,matlab,html4strict,php,pascal,xml
and many other languages (see list in geshi/geshi/)


To Install it:
    - Enable if from "Administration/Filters".
  
To Use it:
    - Enclose your code in <span syntax="langname"> </span>
    - If you wish lines of code to be numbered use underscore before
    languange name <span syntax="_langname"> </span>
    
To modify colors:
    First way (with brute force)
     	- Go to file geshi/geshi/language_name.php, find there 'STYLES' array.
	- Make changes you wish.
    Second way (supporting not all features yet)
	- Open /filter/geshi/geshi/contrib/cssgen.php with a web browser
	- Select languages and colors you wish
	- Generate stylesheet
        - Save stylesheet in you theme directory as geshi.css
	- In theme config.php add 'geshi' element to $THEME->sheets array
	- In the beginning of filter.php set
	    $CFG->geshifilterexternalcss=true;

RGBeast, rgbeast@onlineuniversity.ru
