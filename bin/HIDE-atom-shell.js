(function () { "use strict";
var AtomShellMain = function() { };
AtomShellMain.main = function() {
	var mainBrowserWindow = null;
	App__1.on("window-all-closed",function() {
		if(js.Node.process.platform != "darwin") App__1.quit();
	});
	App__1.on("ready",function() {
		var windowOptions = new js.atomshell.browser.BrowserWindowOptions();
		mainBrowserWindow = new BrowserWindow__0(windowOptions);
		mainBrowserWindow.loadUrl("file://" + js.Node.__dirname + "/index.html");
		mainBrowserWindow.on("closed",function() {
			mainBrowserWindow = null;
		});
		mainBrowserWindow.toggleDevTools();
	});
};
var js = {};
js.Node = function() { };
js.atomshell = {};
js.atomshell.browser = {};
js.atomshell.browser.BrowserWindowOptions = function() {
};
var App__1 = require("app");
var EventEmitter__0 = require("events").EventEmitter;
var BrowserWindow__0 = require("browser-window");
var Readable__1 = require("stream").Readable;
var Writable__2 = require("stream").Writable;
js.Node.process = process;
js.Node.__dirname = __dirname;
AtomShellMain.main();
})();

//# sourceMappingURL=HIDE-atom-shell.js.map