/**
  * 4.10.22 (pure JS)
  * ------------------------------------------------------------
  * https://github.com/m5it/html_js_4_fun_slid3r
  * ------------------------------------------------------------
  * Slid3r() thing by t3ch aka B.K. aka grandekos etc...
  --------------------------------------------------------
  * first time used to control remote car with mobile and ESP32 wroom
  --------------------------------------------------------------
  * Example usage:
  * (new Slid3r({
  *      doubleside:true,
  *      element   :document.querySelector(".slider.hor .field"),
  *      onscroll  :function(H) {
  *          document.querySelector(".slider.hor .info").innerText = H.getResult()+" speed.";
  *      },
  *  }));
  * 
  */
var Slid3r = function( opt ) {
	//
	var opt_elm        = ( typeof(opt)=='object' && typeof(opt['element'])!='undefined'?opt.element:null );
	var opt_onscroll   = ( typeof(opt)=='object' && typeof(opt['onscroll'])=='function'?opt.onscroll:null );
	var opt_onstart    = ( typeof(opt)=='object' && typeof(opt['onstart'])=='function'?opt.onstart:null );
	var opt_onend      = ( typeof(opt)=='object' && typeof(opt['onend'])=='function'?opt.onend:null );
	var opt_onended    = ( typeof(opt)=='object' && typeof(opt['onended'])=='function'?opt.onended:null );
	var opt_vertical   = ( typeof(opt)=='object' && typeof(opt['vertical'])!='undefined'?opt.vertical:false );     // default=false=horisontal OR vertical=true
	var opt_doubleside = ( typeof(opt)=='object' && typeof(opt['doubleside'])!='undefined'?opt.doubleside:false ); // doubleside=true then cursor is centered in middle=0, bottom=-255, top=255 or horizontal left,right,center..
	var opt_maxresult  = ( typeof(opt)=='object' && typeof(opt['maxresult'])!='undefined'?opt.maxresult:255 );
	var opt_mobile     = ( typeof(opt)=='object' && typeof(opt['mobile'])!='undefined'?opt.mobile:false );
	
	//
	if( opt_elm==null ) {
		console.warn("Error: you didn't define opt.element.",opt);
		return false;
	}
	//
	var _this      = this,
	    sWH        = null/*scrollWidth|scrollHeight -> depend on opt_vertical*/, 
	    oWH        = null/*offsetWidth|offsetHeight -> depend on opt_vertical*/, 
	    sTL        = null/*scrollLeft|scrollTop     -> depend on opt_vertical*/, 
	    pR         = null/*calculate percentage*/, 
	    valueOfOne = null, 
	    result     = 0,
	    scrollSize = null/*size of scroll space*/,
	    // events when fired scroll is centered. (opt_doubleside=true)
	    events     = (opt_mobile?["touchend","touchstart","touchmove",]:["mouseup","mousedown","mousemove",]),
	    check_ended=false,
	    tmp_elm    = opt_elm.querySelector(".cover");
	//
	this.scrollSpeed = (opt_vertical?(opt_elm.scrollHeight/100)-(opt_elm.offsetHeight/100):(opt_elm.scrollWidth/100)-(opt_elm.offsetWidth/100));
	//
	console.info("Slid3r() DEBUG scrollSpeed: "+_this.scrollSpeed+", tmp_elm",tmp_elm);
	//
	this.getResult = function() {
		return result;
	}
	//
	function calcResult() {
		scrollSize = sWH - oWH;
		//
		if( opt_doubleside ) {
			var tmp = 0;
			if( sTL<( scrollSize/2 ) ) {
				tmp =  (scrollSize/2)-sTL;
			}
			else {
				tmp =  sTL-(scrollSize/2);
			}
			pR = ((tmp*2)*100)/(sWH-oWH);
		}
		else {
			pR = (sTL*100)/(sWH-oWH);         // current percent depend on scrollWidth
		}
		result = Math.ceil(Math.round(pR)*valueOfOne);
		// Make value negative so we know what side scroll is dragged
		if( opt_doubleside && ((!opt_vertical && sTL<( scrollSize/2 )) || (opt_vertical && sTL>( scrollSize/2 ))) ) {
			result = result * (-1);
		}
	}
	//
	function centerScroll() {
		console.info("Slid3r()->centerScroll() start.");
		//
		if( opt_vertical ) opt_elm.scrollTop  = scrollSize/2;
		else               opt_elm.scrollLeft = scrollSize/2;
	}
	//
	function onEnd() {
		opt_elm.classList.remove("active");
		//
        if(opt_doubleside) {
            centerScroll();
        }
        touch = null;
        start = false;
        //
        if     (opt_onend!=null) {
            opt_onend(_this);
            check_ended = true;
        }
	}
	//
	sWH        = (opt_vertical?opt_elm.scrollHeight:opt_elm.scrollWidth);
	oWH        = (opt_vertical?opt_elm.offsetHeight:opt_elm.offsetWidth);
	sTL        = (opt_vertical?opt_elm.scrollTop:opt_elm.scrollLeft);
	valueOfOne = opt_maxresult/100;    // 255 = max analog value, 100 = percent
	calcResult();
	
	// on initialization, Center cursor if double side
	if( opt_doubleside ) {
		centerScroll();
	}
	
	var touches = null;
	var touchn  = 0;
	var X=0,Y=0;
	var start=false;
	
	// init events to center scroll when button is released
	for(var i=0; i<events.length;i++) {
		(function(i) {
			console.info("Slid3r() initializing event: ",events[i]);
			//
			tmp_elm.addEventListener(events[i],function(e) {
				if(e.type=="touchstart"||e.type=="mousedown") {
					//
					opt_elm.classList.add("active");
					check_ended = false;
					//
					X=0, Y=0;
					start=true;
					//
					if(e.type=="touchstart") {
					    touches = e.touches || e.changedTouches;
					    if     (touches.length>0) {
							touchn = touches.length-1;
						    //var touch   = e.touches[0] || e.changedTouches[0];
						    var touch   = e.touches[touchn] || e.changedTouches[touchn];
			                X = touch.pageX; 
			                Y = touch.pageY;
						}
						console.info("Slid3r() touchstart touches.length: "+touches.length+", touchn: "+touchn+", touch: ",touch);
					}
					else {
						X = e.pageX;
						Y = e.pageY;
						console.info("Slid3r() mousedown started. x: "+X+", y: "+Y);
					}
					//
					if(opt_onstart!=null) opt_onstart(_this);
				}
				else if( e.type=="touchend" || e.type=="mouseup" ) {
					if(!start) return false;
					//
					e.preventDefault();
					onEnd();
				}
				//
				else if( e.type=="touchmove" || e.type=="mousemove" ) {
					if(!start) return false;
					//
					e.preventDefault();
		
					//
					var x=0,y=0;
					
					if( e.type=="touchmove" ) {
						//
						var curtouches = e.touches || e.changedTouches;
						//var touch = e.touches[0] || e.changedTouches[0];
						var touch = e.touches[touchn] || e.changedTouches[touchn];
			            x = touch.pageX;
			            y = touch.pageY;
					}
					else {
						x = e.pageX;
						y = e.pageY;
					}
	                //-- calc moved distance in px from previous move or first mousedown/touch
	                var nx = x-X;
	                var ny = y-Y;
	                //
	                if( opt_vertical ) {
						opt_elm.scrollTop = (opt_elm.scrollTop + (ny*_this.scrollSpeed));
					}
					else {
						opt_elm.scrollLeft = (opt_elm.scrollLeft + (nx*_this.scrollSpeed));
					}
					//
					X=x;
	                Y=y;
				}
			});
		})(i);
	}
	
	//
	if(!opt_mobile) {
		document.addEventListener("mouseup",function(e) {
			//
			e.preventDefault();
			if( start ) onEnd();
		});
	}
	
	// init onscroll event.
	opt_elm.onscroll = function(e) {
		//
		sWH     = (opt_vertical?opt_elm.scrollHeight:opt_elm.scrollWidth);
		oWH     = (opt_vertical?opt_elm.offsetHeight:opt_elm.offsetWidth);
		sTL     = (opt_vertical?opt_elm.scrollTop:opt_elm.scrollLeft);
		//
		calcResult();
		
		//console.warn("Slid3r() sWH: "+sWH+", oWH: "+oWH+", sTL: "+sTL+", valueOfOne: "+valueOfOne+", pR: "+pR+", result: "+result);
		//
		if( check_ended && result==0 && opt_onended!=null ) opt_onended(_this);
		// Fire opt_onscroll() if defined.
		if(opt_onscroll!=null) opt_onscroll(_this);
	}
}
