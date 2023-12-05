#!/usr/bin/php
<?php
/*
 * gmd.php AKA --= Git Merge Directories =-- (well, what ever its just a name)
 * ---------------------------------------------------------------------------
 * 1.) 4.12.23 - started.
 * -----------------------------------------
 * gmd.php - script to merge two repos. 
 * Useful if you use project with multiple submodules and all is used as one repository.
 * Then you have another repo that is used as installation or prepared for public and with separated submodules as it own repos.
 * So this script merge one directory with another and copy / replace what is missing or is different.
 * 
 * VERSION: v0.1
 * 
 * by w4d4f4k at gmail dot com
 * */

//
$opt_dir_master = null; //( isset($argv[1])?(preg_match("/.*\/$/i",$argv[1])?$argv[1]:$argv[1]."/"):null );
$opt_dir_slave  = null; //( isset($argv[2])?(preg_match("/.*\/$/i",$argv[2])?$argv[2]:$argv[2]."/"):null );
$opt_excludes   = null; //( isset($argv[3])?$argv[3]:null); // string of paths separated by comma
$opt_yestoall   = false; //( isset($argv[4])&&$argv[4]=="y"?true:false );
$opt_which      = "MISSING,UPDATE,EXISTS"; //( isset($argv[5])?$argv[5]:"MISSING,UPDATE,EXISTS" );
$opt_action     = "PREVIEW"; // PREVIEW | UPDATE

// PARSE ARGS
$argc=0;
for($i=0; $i<count($argv); $i++) {
	if( $i%2 ) {
		if( $argv[$i]=="-M" ) {
			$opt_dir_master = (preg_match("/.*\/$/i",$argv[$argc+1])?$argv[$argc+1]:$argv[$argc+1]."/");
		}
		else if( $argv[$i]=="-S" ) {
			$opt_dir_slave = (preg_match("/.*\/$/i",$argv[$argc+1])?$argv[$argc+1]:$argv[$argc+1]."/");
		}
		else if( $argv[$i]=="-E" ) {
			$opt_excludes = $argv[$argc+1];
		}
		else if( $argv[$i]=="-Y" ) {
			$opt_yestoall = true;
		}
		else if( $argv[$i]=="-W" ) {
			$opt_which = $argv[$argc+1];
		}
		else if( $argv[$i]=="-A" ) {
			$opt_action = $argv[$argc+1]; // PREVIEW or UPDATE
		}
	}
	$argc++;
}

// GLOBAL VARS
$afs       = [];
$tmpfs     = [];
$aexcludes = []; // exploded from $opt_excludes
$awhich    = [];

// PARSE/INIT VARS
if( $opt_which!="" ) {
	$awhich = explode(",",$opt_which);
}

//
if( $opt_excludes!=null ) {
	if( !preg_match("/\,/i",$opt_excludes) ) {
		$aexcludes[] = $opt_excludes;
	}
	else {
		$aexcludes = explode(",",$opt_excludes);
	}
}

// DISPLAY HELP MESSAGE
if( $opt_dir_master==null || $opt_dir_slave==null ) {
	die("Usage: ".$argv[0]." -M /home/user/your_master_project -S /home/user/your_slave_project\n".
	    "\n".
	    "Options: \n".
	    "-M /path/to/master/dir                     # master dir, dir to copy from\n".
	    "-S /path/to/slave/dir                      # slave dir, dir with submodules\n".
	    "-E /path/to/excludes1,/path/to/excludes2   # excludes \n".
	    "-Y                                         # yes to all\n".
	    "-W MISSING,UPDATE,EXISTS                   # which action should be executed\n".
	    "-A PREVIEW                                 # action that should be taken. ( PREVIEW or UPDATE )".
	    "".
	    "");
}

// DISPLAY ARGS or CONTINuE if yestoall
if( $opt_yestoall==false ) {
	//
	echo "DEBUG master     : ".$opt_dir_master."\n";
	echo "DEBUG slave      : ".$opt_dir_slave."\n";
	echo "DEBUG excludes(".count($aexcludes)."): ".$opt_excludes."\n";
	echo "DEBUG yestoall   : ".($opt_yestoall?"yes":"no")."\n";
	echo "DEBUG which      : ".$opt_which."                              # MISSING,UPDATE,EXISTS\n";
	echo "DEBUG action     : ".$opt_action."                             # PREVIEW or UPDATE\n";
	//
	$prm = readline("Is this correct? (Y/N): ");
	if(strtolower($prm)=="n") die("\n");
}

//-- Functions
//
function excluded($fp="") {
	global $aexcludes;
	for($i=0; $i<count($aexcludes); $i++) {
		$tmpfp = $aexcludes[$i];
		$rtmpfp = str_replace("/","\/",$tmpfp); // maybe we should generate string that preg_match can handle...
		if( preg_match("/".$rtmpfp.".*/i",$fp) ) {
			return true;
		}
	}
	return false;
}
// 
function find() {
	global $tmpfs, $afs, $aexcludes, $opt_dir_master, $opt_dir_slave, $awhich;
	//echo "run() Starting\n";
	//
	$cnta=0; $cntb=0; $cntc=0;
	while(count($tmpfs)) {
		$n = array_pop($tmpfs);
		$a = scandir( $n );
		while(count($a)) {
			$f     = array_pop($a);
			$fp    = $n.$f;
			$chkfp = str_replace($opt_dir_master,$opt_dir_slave,$fp);
			
			// skip .. or . or excludes
			if( $f=="." || $f==".." || in_array($fp,$aexcludes) || excluded($fp)) {
				continue;
			}
			
			//
			if( is_dir($fp) ) {
				$tmpfs[] = $fp."/";
			}
			else {
				// MISSING
				if( !file_exists($chkfp) ) {
					if( in_array("MISSING",$awhich) ) {
						$afs[] = [
							"name"       => $f,
							"full"       => $fp,
							"full_slave" => $chkfp,
							"status"     => "MISSING",
						];
						//
						echo $cnta."/".$cntb."/".$cntc.".) run() (MISSING) fp(".(is_file($fp)?"yes":"no")."|".(is_dir($fp)?"yes":"no")."): ".$fp." CHECK: ".$chkfp.", $h1 vs $h2\n";
					}
				}
				else {
					//
					$h1 = hash_file('sha256',$fp);
					$h2 = hash_file('sha256',$chkfp);
					// UPDATE
					if( $h1!=$h2 ) {
						if( in_array("UPDATE",$awhich) ) {
							$afs[] = [
								"name"       => $f,
								"full"       => $fp,
								"full_slave" => $chkfp,
								"status"     => "UPDATE",
							];
							//
							echo $cnta."/".$cntb."/".$cntc.".) run() (UPDATE) fp(".(is_file($fp)?"yes":"no")."|".(is_dir($fp)?"yes":"no")."): ".$fp." CHECK: ".$chkfp.", $h1 vs $h2\n";
						}
						$cntc++;
					}
					// EXISTS, ALL THE SAME.
					else {
						if( in_array("EXISTS",$awhich) ) {
							//
							echo $cnta."/".$cntb."/".$cntc.".) run() (EXISTS) fp(".(is_file($fp)?"yes":"no")."|".(is_dir($fp)?"yes":"no")."): ".$fp." CHECK: ".$chkfp.", $h1 vs $h2\n";
						}
					}
				}
			}
			
			$cnta++;
		}
		$cntb++;
	}
}

//-- Search for updates, missing etc..
//
$tmpfs[] = $opt_dir_master;
find();

//-- Handle action
//
for($i=0; $i<count($afs); $i++) {
	$f = $afs[$i];
	echo $i.".) => ".$f["full"];
	if( $opt_action=="UPDATE" ) {
		if( !copy($f["full"],$f["full_slave"]) ) {
			echo " = FAILED";
		}
		else {
			echo " = SUCCESS";
		}
	}
	echo "\n";
}

//--
//
die("done, afs.count: ".count($afs)."\n");
?>
