// Update server time
qS("#tm_submit").addEventListener("click",function(e) {
	e.preventDefault();
	loadingStart();
	console.info("#tm_submit clicked.");
	
	//-- SENDING Javascript Fetch() GET/POST Request
	//
	/*var q = document.location.origin+"/time/?settm=1"+
	    "&tm_hour="+qS("#tm input[name='tm_hour']").value+
	    "&tm_min="+qS("#tm input[name='tm_min']").value+
	    "&tm_sec="+qS("#tm input[name='tm_sec']").value+
	    //
	    "&tm_year="+qS("#tm input[name='tm_year']").value+
	    "&tm_mday="+qS("#tm input[name='tm_mday']").value+
	    "&tm_mon="+qS("#tm input[name='tm_mon']").value;
	//
	Fetch({href:q,onDone:function(json){
		console.info("timetm response",json);
		loadingStop();
	},});*/
	
	//-- SENDING WebSockets Request With WSC Client.
	//
    wsc.sendMessage(
	    //
	    {"action":"time_set","hash":e.detail,
			//
			"data":{
				'tm_hour':qS("#tm input[name='tm_hour']").value,
				'tm_min':qS("#tm input[name='tm_min']").value,
				'tm_sec':qS("#tm input[name='tm_sec']").value,
				'tm_year':qS("#tm input[name='tm_year']").value,
				'tm_mday':qS("#tm input[name='tm_mday']").value,
				'tm_mon':qS("#tm input[name='tm_mon']").value,
			},
		},
		//
		{"uid":"time_set","function":function(json) {
		//
		console.warn("done time_set, data",json);
		//
		
		return true; // if return true then function is removed and message/response can be received only once.
	},});
	return false;
});
