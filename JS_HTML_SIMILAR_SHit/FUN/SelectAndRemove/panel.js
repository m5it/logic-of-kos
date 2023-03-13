console.warn("SelectAndRemove => panel.js STARTED!");
//-- DISPLAY & INITIALIZE PANEL
if( selectandremove_panel_visible==false ) {
	selectandremove_panel_visible = true;
	//-- STYLE
	if( selectandremove_panel_initialized==false ) {
		selectandremove_panel_initialized = true;
		//
		qS("body").insertAdjacentHTML("afterbegin",'<style>#selectandremove {\
			position:fixed;\
			right:3px;\
			top:3px;\
			z-index:2000;\
		}\
		#selectandremove > div {\
			padding:3px;\
		}\
		#selectandremove button {\
			border-radius:13px;\
		}\
		body.selectandremove_active #btn_selectandremove {\
			border:solid 1px red;\
		}\
		#selectandremove_preview {\
			position:relative;\
			top:30px;\
			left: 3px;\
		    max-width: 100%;\
			right: 3px;\
			background: lightblue;\
		    padding: 13px;\
		    border-radius: 9px;\
		    box-shadow: 0px 0px 3px 1px grey;\
		}\
		#selectandremove_preview > div {}\
		</style>');
	}
	
	//-- HTML
	qS("body").insertAdjacentHTML("afterbegin",'<div id="selectandremove">\
		<div>\
			<button id="btn_selectandremove_clear">x</button>\
			<button id="btn_selectandremove_list">0</button>\
			<button id="btn_selectandremove">Select & Remove</button>\
		</div>\
	</div>');
	
	//
	qS("#btn_selectandremove_list").innerText = aremoved.length;
	
	//-- BUTTON CLICKS
	//
	qS("#btn_selectandremove_clear").addEventListener("click",function(e) {
		e.preventDefault();
		console.warn("btn_selectandremove_clear() STARTED");
		localStorage.removeItem("selectandremove");
		document.location.href=document.location.href;
		return false;
	});
	//
	qS("#btn_selectandremove").addEventListener("click",function(e) {
		e.preventDefault();
		console.warn("clicked selectandremove");
		var elm = findParent(e.target,{any:[{attr:'id',text:'selectandremove'},],});
		if( elm!=null ) {
			console.warn("selectandremove got parent elm!");
			qS("body").classList.add("selectandremove_active");
			//
			setTimeout(function() {
				console.warn("selectandremove ready to remove when you are ready!");
				//
				document.querySelector("*").addEventListener("click",function(e1) {
					e1.preventDefault();
					//
					elm = findParent(e1.target,{any:[{attr:'id',text:'selectandremove'}]});
					if( elm!=null ) {
						console.warn("can not remove ourself!");
						return false;
					}
					console.warn("selectandremove got element to remove!",e1.target);
					//
					//document.dispatchEvent( new CustomEvent("somexxx", { detail: e1 }) );
					//
					setTimeout(function() {
						selectandremove_gen( e1.target );
						qS("#btn_selectandremove_list").innerText = aremoved.length
					},500);
					e1.stopPropagation();
					return false;
				});
			},100);
		}
		return false;
	});
	//
	// preview_close &  preview_del are inside of block
	qS("#btn_selectandremove_list").addEventListener("click",function(e) {
		e.preventDefault();
		console.warn("btn_selectandremove_list CLICKED!");
		//
		if( qS("body").classList.contains("selectandremove_preview") ) return false;
		qS("body").classList.add("selectandremove_preview");
		var html="<button id='btn_selectandremove_preview_close'>X</button>";
		for(var i=0; i<aremoved.length; i++) {
			html += '<div>\
				<button class="btn_selectandremove_preview_del" attrId="'+i+'">x</button> \
				'+aremoved[i]+'\
			</div>';
		}
		qS("#btn_selectandremove_list").insertAdjacentHTML("afterend",'<div id="selectandremove_preview">\
			'+html+'\
		</div>');
		//
		setTimeout(function() {
			//--
			document.querySelectorAll(".btn_selectandremove_preview_del").forEach(function(elm) {
				elm.addEventListener("click",function(e1) {
					e1.preventDefault();
					var attrId = this.getAttribute("attrId");
					console.info("btn_selectandremove_preview_del attrId",attrId);
					return false;
				});
			});
			//--
			qS("#btn_selectandremove_preview_close").addEventListener("click",function(e1){
				e1.target.parentNode.remove();
				qS("body").classList.remove("selectandremove_preview");
			});
		},100);
		return false;
	});
}
//-- OR HIDE/REMOVE PANEL
else {
	if( qS("#selectandremove")!=null ) {
		qS("#selectandremove").remove();
	}
	else {
		console.warn("SelectAndRemove => panel.js Field dont exists!");
	}
	selectandremove_panel_visible = false;
}
