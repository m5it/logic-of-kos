'use strict';
//
window.onload = function() {
	console.warn("SelectAndRemove => load.js STARTED!",chrome.runtime.getURL("main.js"));
	selectandremove_start();
	setTimeout(function() {
		chrome.runtime.sendMessage(null,"text...",{});
	},1000);
	console.warn("SelectAndRemove => load.js DONE!");
}
