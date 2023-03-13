//
chrome.action.onClicked.addListener((tab) => {
  chrome.scripting.executeScript({
    target: {tabId: tab.id},
    files: ['panel.js']
  });
});
//
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
	console.info("SelectAndRemove => sw.js onMessage()",request);
});
/*console.warn("EXTENSION sw.js STARTED!");
//
chrome.tabs.query({}, function(tabs) {
  tabs.forEach(function (tab) {
    // do whatever you want with the tab
    console.info("EXTENSION sw.js tab",tab);
    //
    //if( tab.url=="chrome://extensions/" ) {
    //if( tab.url=="https://dev.lokkal.com/1,mexico,san_miguel_de_allende/search-for/" ) {
    if( tab.url=="chrome://inspect/#devices" ) {
		//
	    chrome.scripting.executeScript({
		    target: {tabId: tab.id, allFrames: true},
		    files: ['test1.js'],
		}, () => chrome.runtime.lastError);
	    //
        console.warn("GOT EXTENSION!");
	}
  });
});
//
chrome.scripting.executeScript({
    target: {tabId: 1, allFrames: true},
    files: ['test1.js'],
});
//
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
	console.info("EXTENSION sw.js onMessage()",request);
});
*/
