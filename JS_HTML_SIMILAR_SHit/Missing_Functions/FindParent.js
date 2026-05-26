function findParent(element,opt) {
	var opt_classname = (typeof(opt)=='object' && typeof(opt.classname)!='undefined'?opt.classname:null);
	var opt_maxtries  = (typeof(opt)=='object' && typeof(opt.maxtries)!='undefined'?opt.maxtries:10);
	var cnt=0;
	while(cnt<opt_maxtries) {
		if( element.getAttribute("class").match( opt_classname ) ) {
			console.info("findParent() got element!",element);
			return element;
		}
		element = element.parentNode;
		cnt++;
	}
	return null;
}
