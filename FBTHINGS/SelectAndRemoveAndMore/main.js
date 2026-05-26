'use strict';
console.warn("SelectAndRemove => main.js STARTED!");
//
function qS(q) { return document.querySelector(q); }
//
function findParent(element,opt) {
	var opt_classname = (typeof(opt)=='object' && typeof(opt.classname)!='undefined'?opt.classname:null);
	var opt_any       = (typeof(opt)=='object' && typeof(opt.any)=='object'?opt.any:null); // [{attr:'id',text:'someid'},{attr:'class','someclass'}]
	var opt_maxtries  = (typeof(opt)=='object' && typeof(opt.maxtries)!='undefined'?opt.maxtries:10);
	var cnt=0;
	while(cnt<opt_maxtries) {
		//
		if( element.nodeName=='HTML' ) return null;
		//
		if( opt_classname!=null && element.getAttribute("class").match( opt_classname ) ) {
			console.info("findParent() got element!",element);
			return element;
		}
		//
		else if( opt_any!=null ) {
			console.warn("findParent() DEBUG typeof(element): "+typeof(element)+", ",element);
			for(var i=0; i<opt_any.length; i++) {
				if( typeof(element)=='object' &&
				  element.getAttribute( opt_any[i].attr )!=null &&
				  element.getAttribute( opt_any[i].attr ).match( opt_any[i].text ) ) return element;
			}
		}
		element = element.parentNode;
		cnt++;
	}
	return null;
}
//
function isDefined(o,v) {
    if(typeof(o)!='undefined' && o!=null) {
	    if(typeof(o[v])!='undefined' && o[v]!=null) {
		    return true;
		}
	}
	return false;
}

//--
//
var selectandremove_panel_visible     = false;
var selectandremove_panel_initialized = false;
var aremoved        = [];//localStorage.getItem("selectandremove"); // null or array of objects
var aremoved_counts = {};
//
//function aremoved_find(target) {
function aremoved_find( opt ) {
	var opt_bycss = ( isDefined(opt,"bycss")?opt.bycss:null );
	var opt_byat  = ( isDefined(opt,"byat")?opt.byat:null );
	if( aremoved!=null) {
		if( opt_bycss!=null || opt_byat!=null ) {
			console.info("SelectAndRemove => main.js aremoved_find() D1");
			for(var i=0; i<aremoved.length; i++) {
				console.info("SelectAndRemove => main.js aremoved_find() D1 at",i);
				if( opt_byat!=null && opt_byat==i ) {
					console.info("SelectAndRemove => main.js aremoved_find() D1/0");
					return aremoved[i];
				}
				else if( isDefined(aremoved[i],"css") && aremoved[i].css==opt_bycss ) {
					console.info("SelectAndRemove => main.js aremoved_find() D1/1");
					return aremoved[i];
				}
			}
		}
		else {
			console.info("SelectAndRemove => main.js aremoved_find() D2");
			if( aremoved.indexOf( opt )>=0 ) {
				console.info("SelectAndRemove => main.js aremoved_find() D2/1");
				return aremoved.indexOf( opt );
			}
		}
	}
	return -1;
}
function selectandremove_gen_classlist(target) {
	var a = target.classList, ret="";
	// remove some classes that can make problems when searching for correct element
	if(a.contains("active")) {
		a.remove("active");
	}
	//
	for(var i=0; i<a.length; i++) {ret+="."+a[i];}
	return ret;
}
function selectandremove_gen_css(target) {
	//
	var css="";
	var cnt=0;
	while(true&&cnt<50) {
		if( target.tagName=="HTML" ) break;
		css    = target.tagName+
			(target.getAttribute("id")!=null?"#"+target.getAttribute("id"):"")+
			(target.getAttribute("class")!=null?selectandremove_gen_classlist(target):"")+
		(css==""?"":" > "+css);
		target = target.parentNode;
		cnt++;
	}
	return css;
}
function selectandremove_gen(target) {
	// remove this class before generating css path of element that will/should be removed
	qS("body").classList.remove("selectandremove_active");
	//
	var css = selectandremove_gen_css( target );
	console.warn("selectandremove css",css);
	
	var tmp = aremoved_find( {"bycss":css} );
	if( tmp>=0 ) {
		console.warn("target already exists in aremoved!");
	}else {
		if( aremoved==null ) aremoved = [];
		aremoved.push( {
			"css":css,
			"outer":target.outerHTML,
		} );
	}
	target.remove();
	localStorage.setItem("selectandremove",JSON.stringify(aremoved));
}
function selectandremove_start() {
	console.warn("selectandremove_remove() STARTING");
	//
	aremoved = localStorage.getItem("selectandremove");
	//
	if( typeof(aremoved)!='object' ) aremoved = JSON.parse( aremoved );
	if( aremoved==null ) aremoved = [];
	console.warn("selectandremove, starting to remove saved elements...",aremoved);
	//
	for(var i=0; i<aremoved.length; i++) {
		var css = aremoved[i].css;
		console.warn("aremoved at: "+i+", aremoved css: ",css);
		aremoved_counts[i] = 0;
		selectandremove_try_remove( css, i );
	}
	//
	if( aremoved!=null && qS("#btn_selectandremove_list")!=null ) {
		qS("#btn_selectandremove_list").innerText = aremoved.length;
	}
	return true;
}
function selectandremove_try_remove(css,pos) {
	console.warn("selectandremove_try_remove() Starting on pos: "+pos+", css: ",css);
	if( qS( css )!=null ) {
		qS( css ).remove();
		return true;
	}
	else {
		if( aremoved_counts[pos]>10 ) {
			console.warn("selectandremove_try_remove() Failed on pos: "+pos+", css: ",css);
			return false;
		}
		setTimeout(function(){selectandremove_try_remove(css,pos);},100);
		aremoved_counts[pos]++;
	}
}

//
function selectandremove_preview() {
	var html='<button id="btn_selectandremove_preview_close">C</button>\
	<select name="btn_selectandremove_preview_action">\
	    <option value="">-- actions --</option>\
	    <option value="1">Diff attrs & blocks</option>\
	</select>\
	';
	//
	for(var i=0; i<aremoved.length; i++) {
		html += '<div>\
			<input type="checkbox" name="btn_selectandremove_preview_diff" value="'+i+'">\
			<button class="btn_selectandremove_preview_del" attrId="'+i+'">x</button> \
			<button class="btn_selectandremove_preview_info" attrId="'+i+'">i</button> \
			'+aremoved[i].css+'\
		</div>';
	}
	//
	qS("#btn_selectandremove_list").insertAdjacentHTML("afterend",'<div id="selectandremove_preview">\
		'+html+'\
	</div>');
	// INIT BUTTONS
	setTimeout(function() {
		//-- DELETE
		document.querySelectorAll(".btn_selectandremove_preview_del").forEach(function(elm) {
			elm.addEventListener("click",function(e1) {
				e1.preventDefault();
				var attrId = this.getAttribute("attrId");
				console.info("btn_selectandremove_preview_del attrId",attrId);
				console.info("btn_selectandremove_preview_del aremoved d1",aremoved);
				aremoved.splice(attrId,1);
				console.info("btn_selectandremove_preview_del aremoved d2",aremoved);
				localStorage.setItem("selectandremove",JSON.stringify(aremoved));
				qS("#btn_selectandremove_list").innerText = aremoved.length;
				//qS("#selectandremove_preview").remove();
				//selectandremove_preview();
				document.location.href=document.location.href;
				return false;
			});
		});
		//-- INFO
		document.querySelectorAll(".btn_selectandremove_preview_info").forEach(function(elm) {
			elm.addEventListener("click",function(e1) {
				e1.preventDefault();
				var attrId = this.getAttribute("attrId");
				console.info("btn_selectandremove_preview_info attrId",attrId);
				var tmp = aremoved_find({'byat':attrId,});
				console.info("btn_selectandremove_preview_info tmp",tmp);
				var div = document.createElement("div");
				div.setAttribute("class","selectandremove_preview_more");
				div.appendChild( document.createTextNode(tmp.outer) );
				e1.target.insertAdjacentElement("afterend",div);
				return false;
			});
		});
		//--
		qS("#btn_selectandremove_preview_close").addEventListener("click",function(e1){
			e1.target.parentNode.remove();
			qS("body").classList.remove("selectandremove_preview");
		});
	},100);
}

console.warn("SelectAndRemove => main.js INITIALIZED!");
//}
