#!/usr/bin/php
<?php
/*
 * gmd.php AKA --= Git Merge Directories =-- (well, what ever its just a name)
 * ---------------------------------------------------------------------------
 * gmd_commit.php - script to add & commit previously updated files with gmd.php.
 * User should set git directory of repo and commit text. Then program loop trough submodules, add & commit.
 * There is another option to automaticaly push every submodule to server.
 * 
 * VERSION: v0.1b
 * 
 * by w4d4f4k at gmail dot com
 * */
//
function strToHex($string){
    $hex = '';
    for ($i=0; $i<strlen($string); $i++){
        $ord = ord($string[$i]);
        $hexCode = dechex($ord);
        $hex .= substr('0'.$hexCode, -2);
    }
    return strToUpper($hex);
}
//
include "gmd_commit_languages/es.php";

var_dump( $alangs );
//
$opt_gitdir = "";
$opt_commit = "";

// PARSE ARGS
$argc=0;
for($i=0; $i<count($argv); $i++) {
	if( $i%2 ) {
		if( $argv[$i]=="-M" ) {
			$opt_gitdir = (preg_match("/.*\/$/i",$argv[$argc+1])?$argv[$argc+1]:$argv[$argc+1]."/");
		}
		else if( $argv[$i]=="-c" ) {
			$opt_commit = $argv[$argc+1];
		}
	}
	$argc++;
}

//
echo "\nDEBUG VARS: \n";
echo "opt_gitdir: ".$opt_gitdir."\n";
echo "opt_commit: ".$opt_commit."\n";
echo "DEBUG DONE! \n\n";

//
$prm = readline("Is this correct? (Y/N): ");
if(strtolower($prm)=="n") die("\n");

//
$a=[];
$tmp = file_get_contents( $opt_gitdir.".gitmodules" );
if( preg_match_all("/\[.*\x20\"(.*)\"\]/i",$tmp,$a) ) {
	$b = $a[1];
	for($i=0; $i<count($b); $i++) {
		$fp = $opt_gitdir.$b[$i];
		$c=[];
		exec("cd $fp && git status 2>&1",$c);
		//
		echo "submodule( ".count($c)." ): ".(count($c)==4?"NO CHANGES":"CHECKING")." ".$b[$i]." => $fp\n";
		if( count($c)==4 ) {
			continue;
		}
		// ADD
		$c1=[];
		exec("cd $fp && git add . 2>&1",$c1);
		var_dump( $c1 );
		
		// COMMIT
		$c2=[];
		exec("cd $fp && git commit -m \"$opt_commit\" 2>&1",$c2);
		var_dump( $c2 );
		
		// PUSH
		$c3=[];
		exec("cd $fp && git push 2>&1",$c3);
		var_dump( $c3 );
		/*for($j=0; $j<count($c); $j++) {
			//
			if( preg_match("/modificados/i",$c[$j]) ) {
				echo "line: ".$c[$j]."\n";
			}
		}*/
	}
}
?>
