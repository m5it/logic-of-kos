function Fetch( opt ) {
	var href="";
	if( typeof(opt)!='undefined' && typeof(opt['href'])!='undefined' ) {
		href = opt.href;
	}
	else return;
	var opt_method  = (typeof(opt)=='object' && typeof(opt.method)!='undefined'?opt.method:"GET");
	var opt_body    = (typeof(opt)=='object' && typeof(opt.body)!='undefined'?opt.body:null);
	//headers:{"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"},
	var opt_headers = (typeof(opt)=='object' && typeof(opt.headers)!='undefined'?opt.headers:null);
	var opt_signal  = (typeof(opt)=='object' && typeof(opt.signal)!='undefined'?opt.signal:null);
	//
	var fetchOpts = {  
	    method :opt_method,
	    cache:'no-store',
	    //headers:new Headers({'content-type': 'application/json'}),
	    //body:{},
    };
    //
    if( opt_body!=null ) fetchOpts["body"] = opt_body;
    if( opt_headers!=null ) fetchOpts["headers"] = opt_headers;
    if( opt_signal!=null ) fetchOpts["signal"] = opt_signal; // controller.signal
	//
	return fetch(href, fetchOpts).then(function (data) {
		return data.json();
	}).then(function(json) {
		console.info("response",json);
		//
		if( typeof(opt)!='undefined' && typeof(opt["onDone"])=='function' ) {
			opt.onDone( json );
		}
		else {
			console.info("Fetch() opt.onDone() not defined!",json);
		}
	}).catch(function(E) {
		console.warn("Fetch() ERROR: ",E);
		//
		if( typeof(opt)!='undefined' && typeof(opt["onFail"])=='function' ) {
			opt.onFail( E );
		}
	});
}
