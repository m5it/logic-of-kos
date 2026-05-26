/**
 * Don't If Drunk is script that try to prevent to use X page if you are drunk and maybe you think too fast... :)
 * */

//--
//
//
function random(min,max) {
    return Math.round((Math.random(min,max)*max)+min);
}
//--
//
var debug = false; // CTRL+d
//
var stats = {
	"num_dt_click":0, // cursor clicked drinktest! ole! :)
	"num_dt_near":0, // cursor was near drinktest
	"num_dt_in":0, // cursor was inside of drinktest
};
//
var domains = [ // execute on these domains only...
	/https\:\/\/.*facebook\.*/i,
	/https\:\/\/.*grandekos\.*/i,
];
//
var logs_max = 10;
var logs = [/*
{ts:00000000, x:0, y:0, ...}
*/];
//
var dontifdrunk   = false;
var div_cover     = null, cvw=0/*cover width*/, cvh=0/*cover height*/;
var div_drunktest = null;
var div_info = null;
var mx=null, my=null, dtx=document.body.offsetWidth/2, dty=document.body.offsetHeight/2, ang=null, ndtx=null, ndty=null;
var dtw=30, dth=30; // drunktest object width & height
var dtn=30; // drunktest near size
//var dtt=(window.offsetHeight/2), dtl=(window.offsetWidth/2);
//var dtt=0, dtl=0;
var dts = 0.5, dtmoving=false, dist=150;
//--
//
for(var i=0; i<domains.length; i++) {
	if( document.location.origin.match( domains[i] ) ) {
		dontifdrunk = true;
		break;
	}
}

//--
//
function add_logs( opts ) {
	var opt_info = (typeof(opts)=='object'&&typeof(opts.info)!='undefined'?opts.info:"");
	var tmp = {
		"info":opt_info,
		"mx":mx,
		"my":my,
		"ts":(new Date().getTime()),
		"dtx":dtx,
		"dty":dty,
	};
	if( logs.length>=logs_max ) {
		for(var i=(logs.length<logs_max?logs.length:logs_max); i>=0; i--) {
			if(i>0) logs[i] = logs[i-1];
			else logs[i] = tmp;
		}
	}
	else {
		logs.push(tmp);
	}
}
//
function set_style() {
	//body
	document.body.style.margin="0px";
	//div_drunktest
	div_drunktest.style.transition = "all "+dts+"s";
	//
	cvw = document.body.offsetWidth;
	cvh = document.body.offsetHeight;
	//
	//dty = (cvh/2);
	//dtx = (cvw/2);
}
//
function set_info() {
	div_info = document.createElement("div");
	div_info.setAttribute("style","position:fixed;top:0px;max-width:300px;max-height:250px;overflow:auto;background:white;z-index:10000;");
	document.body.appendChild(div_info);
}
//
function set_cover() {
	div_cover = document.createElement("div");
	div_cover.setAttribute("style","position:fixed;top:0px;left:0px;right:0px;bottom:0px;background:black;opacity:0.9;z-index:9999;");
	document.body.appendChild(div_cover);
	cvw = div_cover.offsetWidth;
	cvh = div_cover.offsetHeight;
}
//
function set_drunktest() {
	div_drunktest = document.createElement("div");
	div_drunktest.setAttribute("style","position:absolute;background:red;z-index:10000;width:"+dtw+"px;height:"+dth+"px;border-radius:66px;left:"+dtx+"px;top:"+dty+"px;"); // +"px;transition:all "+dts+"s
	div_drunktest.setAttribute("id","drunktest");
	document.body.appendChild(div_drunktest);
	// Handle click on drunktest
	div_drunktest.addEventListener("click",function(e) {
		e.preventDefault();
		console.info("set_drunktest() CLICK occured! At mx: "+mx+", my: "+my+", event as e: ",e);
		add_logs({"info":"click",});
		stats.num_dt_click++;
		return false;
	});
}
//
function upd_drunktest() {
	if( dtmoving ) {
		console.warn("upd_drunktest() Failed, still moving...");
		return false;
	}
	dtmoving = true;
	console.warn("upd_drunktest() STARTING with dtx: "+dtx+", dty: "+dty);
	//
	div_drunktest.style.left = dtx+"px";
	div_drunktest.style.top  = dty+"px";
	//
	setTimeout(function() { dtmoving = false; },dts*1000);
}
//
function mov_drunktest_random() {
	//
	var isNewPositionReady = false;
	var cnt=0;
	while( !isNewPositionReady && cnt<=100 ) {
		//
		var side_size   = random(30,200); /**
		(WARNING) side_size should be calculated depend on where we move and how far we can go. 
		**/
		var choose_side = random(0,3); // 0=up,1=down,2=left,3=right
		console.warn("mov_drunktest_random() at "+cnt+" looks cursor near of drunktest, side_size: "+side_size+", choose_side",choose_side);
		// cvw=max width, cvh=max height
		var tmpdtx = 0, tmpdty = 0;
		if     ( choose_side==0 ) { // go up
			tmpdty = dty-side_size;
			tmpdtx = dtx;
		}
		else if( choose_side==1 ) { // go down
			tmpdty = dty+side_size;
			tmpdtx = dtx;
		}
		else if( choose_side==2 ) { // go left
			tmpdtx = dtx-side_size;
			tmpdty = dty;
		}
		else if( choose_side==3 ) { // go right
			tmpdtx = dtx+side_size;
			tmpdty = dty;
		}
		//
		if( tmpdtx>=0 && tmpdtx<=cvh && tmpdty>=0 && tmpdty<=cvw ) {
			console.warn("mov_drunktest_random() at "+cnt+" got new pos.. tmpdty: "+tmpdty+", tmpdtx: "+tmpdtx);
			break;
		}
		else {
			console.warn("mov_drunktest_random() at "+cnt+" repeating, new pos failed... tmpdty: "+tmpdty+", tmpdtx: "+tmpdtx);
		}
		cnt++;
	}
	/*dty = tmpdty;
	dtx = tmpdtx;
	var tmps = 0;
	if( random(0,1) == 0 ) {
		tmps = random(10,50);
		console.warn("chk_drunktest() using random tmps",tmps);
	}
	setTimeout(function() { upd_drunktest(); },tmps);*/
	mov_drunktest(tmpdty, tmpdtx);
}
//
function mov_drunktest(tmpdty, tmpdtx) {
	//console.warn("mov_drunktest() using tmpdty: "+tmpdty+", tmpdtx: "+tmpdtx);
	if( dtmoving ) {
		console.warn("mov_drunktest() Failed, still moving...");
		return false;
	}
	dty = tmpdty;
	dtx = tmpdtx;
	var tmps = 0;
	/*if( random(0,1) == 0 ) {
		tmps = random(10,50);
		//console.warn("mov_drunktest() using random tmps",tmps);
	}*/
	setTimeout(function() { upd_drunktest(); },tmps);
	return true;
}
//
function chk_drunktest() {
	//console.warn("chk_drunktest() mx: "+mx+" / dtx("+dth+"): "+dtx+", my: "+my+" / dty("+dtw+"): "+dty);
	// Check if cursor is inside of drunktest
	if(mx>=dtx && (mx<=(dtx+dtw)) && (my>=dty && (my<=(dty+dth))) ) {
		//console.warn("chk_drunktest() looks cursor is inside of drunktest...!");
		add_logs({"info":"cursor is inside",});
		stats.num_dt_in++;
		//
		//mov_drunktest_random();
	}
	// Check if cursor is near of drunktest ( experimental )
	else if(mx>=(dtx-dtn) && (mx<=(dtx+dtw+dtn)) && (my>=(dty-dtn) && (my<=(dty+dth+dtn))) ) {
		//console.warn("chk_drunktest() looks cursor near of drunktest...!");
		//
		add_logs({"info":"cursor is near",});
		stats.num_dt_near++;
		//
		//mov_drunktest_random();
		if( !dtmoving ) {
			mov_drunktest(ndty, ndtx);
		} else {
			console.warn("chk_drunktest() still moving!");
		}
	}
}
//--
//
if( dontifdrunk ) {
	console.warn("DON'TIFDRUNK => DO THE JOB!");
	//
	set_cover();
	set_drunktest();
	set_info();
	set_style();
	upd_drunktest();
	//
	div_drunktest.onresize = function(e) {
		console.info("DID on resize...");
	}
	//
	document.onmousemove = function(e) {
		// mouse cursor X and Y
		mx = e.clientX, my = e.clientY;
		// dontdrunk point X and Y
		dty = div_drunktest.offsetTop, dtx = div_drunktest.offsetLeft;
		// angle from mouse cursor to dontdrunk point
		ang = Math.atan2(my-dty, mx-dtx) * (180/Math.PI);
		// new dontdrunk points depend on angle and distance
		// tempolary distance=xdist
		//dist = 150;
		ndty = my - dist * Math.sin( ang * (Math.PI/180) );
		ndtx = mx - dist * Math.cos( ang * (Math.PI/180) );
		
		//
		chk_drunktest();
		//
		if( debug ) {
			var tmphtml="<div>"+JSON.stringify(stats)+"</div>";
			for(var i=0; i<logs.length; i++) { tmphtml += "<div>"+JSON.stringify(logs[i])+"</div>"; }
			//
			div_info.innerHTML = '<div>\
				<div>ang: '+ang+'</div>\
				<div>mx: '+mx+'</div>\
				<div>my: '+my+'</div>\
				<div>drunktest dtx (left): '+dtx+'</div>\
				<div>drunktest dty (top): '+dty+'</div>\
				<div>ndtx: '+ndtx+'</div>\
				<div>ndty: '+ndty+'</div>\
				<div>DEBUG LOGS('+logs.length+') cvw: '+cvw+', cvh: '+cvh+':</div>\
				'+tmphtml+'\
			</div>';
		}
		//
		add_logs();
	}
	
	//
	document.onkeydown = function(e) {
		console.info("DON'TIFDRUNK => onkeydown STARTED",e);
		// CTRL + d = display debug window and stop the job for moment, until X or continue is pressed.
		if( e.ctrlKey && e.key=="d" ) {
			console.info("DON'TIFDRUNK => onkeydown setting debug...");
			if( debug ) {
				div_info.innerHTML = "";
				debug = false;
			}
			else        debug = true;
		}
	}
}
