//
function isDefined(o,v) {
    if(typeof(o)!='undefined' && o!=null) {
	    if(typeof(o[v])!='undefined' && o[v]!=null) {
		    return true;
		}
	}
	return false;
}
