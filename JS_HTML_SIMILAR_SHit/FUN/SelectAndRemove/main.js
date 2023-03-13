'use strict';
console.warn("SelectAndRemove => main.js STARTED!");
//
function qS(q) { return document.querySelector(q); }
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
//--
//
var selectandremove_panel_visible     = false;
var selectandremove_panel_initialized = false;
var aremoved        = [];//localStorage.getItem("selectandremove"); // null or array of objects
var aremoved_counts = {};
//
function aremoved_find(target) {
	if( aremoved!=null && aremoved.indexOf(target)>=0 ) {
		return aremoved.indexOf(target);
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
	
	var tmp = aremoved_find( css );
	if( tmp>=0 ) {
		console.warn("target already exists in aremoved!");
	}else {
		if( aremoved==null ) aremoved = [];
		aremoved.push( css );
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
		var css = aremoved[i];
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
console.warn("SelectAndRemove => main.js INITIALIZED!");
//}
