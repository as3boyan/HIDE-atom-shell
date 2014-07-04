(function () { "use strict";
var AtomShellMain = function() { };
AtomShellMain.main = function() {
	var mainBrowserWindow = null;
	App__0.on("window-all-closed",function() {
		if(js.Node.process.platform != "darwin") App__0.quit();
	});
	App__0.on("ready",function() {
		var windowOptions;
		var val = { };
		var this1;
		this1 = { };
		this1["accept-first-mouse"] = val.acceptFirstMouse;
		this1["always-on-top"] = val.alwaysOnTop;
		this1.center = val.center;
		this1.frame = val.frame;
		this1.fullscreen = val.fullscreen;
		this1.height = val.height;
		this1.icon = val.icon;
		this1.kiosk = val.kiosk;
		this1["max-height"] = val.maxHeight;
		this1["max-width"] = val.maxWidth;
		this1["min-height"] = val.minHeight;
		this1["min-width"] = val.minWidth;
		this1["node-integration"] = val.nodeIntegration;
		this1.resizable = val.resizable;
		this1.show = val.show;
		this1["skip-taskbar"] = val.skipTaskbar;
		this1.title = val.title;
		this1["use-content-size"] = val.useContentSize;
		this1["web-preferences"] = val.webPreferences;
		this1.width = val.width;
		this1.x = val.x;
		this1.y = val.y;
		this1["zoom-factor"] = val.zoomFactor;
		windowOptions = this1;
		windowOptions["min-width"] = 768;
		mainBrowserWindow = new BrowserWindow__1(windowOptions);
		mainBrowserWindow.loadUrl("file://" + js.Node.__dirname + "/index.html");
		mainBrowserWindow.on("closed",function() {
			mainBrowserWindow = null;
		});
		mainBrowserWindow.toggleDevTools();
	});
};
var js = {};
js.Node = function() { };
var App__0 = require("app");
var EventEmitter__0 = require("events").EventEmitter;
var BrowserWindow__1 = require("browser-window");
var Readable__1 = require("stream").Readable;
var Writable__2 = require("stream").Writable;
js.Node.process = process;
js.Node.__dirname = __dirname;
AtomShellMain.main();
})();

//# sourceMappingURL=HIDE-atom-shell.js.map