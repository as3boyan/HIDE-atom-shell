(function () { "use strict";
var AtomShellTestRunner = function() { };
AtomShellTestRunner.main = function() {
	var mainBrowserWindow = null;
	js.Node.process.chdir(js.Node.__dirname);
	App__1.commandLine.appendSwitch("js-flags","--harmony");
	App__1.on("window-all-closed",function() {
		if(js.Node.process.platform != "darwin") App__1.quit();
	});
	App__1.on("ready",function() {
		var windowOptions;
		var val = { };
		var _this = { };
		_this["accept-first-mouse"] = val.acceptFirstMouse;
		_this["always-on-top"] = val.alwaysOnTop;
		_this.center = val.center;
		_this.frame = val.frame;
		_this.fullscreen = val.fullscreen;
		_this.height = val.height;
		_this.icon = val.icon;
		_this.kiosk = val.kiosk;
		_this["max-height"] = val.maxHeight;
		_this["max-width"] = val.maxWidth;
		_this["min-height"] = val.minHeight;
		_this["min-width"] = val.minWidth;
		_this["node-integration"] = val.nodeIntegration;
		_this.resizable = val.resizable;
		_this.show = val.show;
		_this["skip-taskbar"] = val.skipTaskbar;
		_this.title = val.title;
		_this["use-content-size"] = val.useContentSize;
		_this["web-preferences"] = val.webPreferences;
		_this.width = val.width;
		_this.x = val.x;
		_this.y = val.y;
		_this["zoom-factor"] = val.zoomFactor;
		windowOptions = _this;
		windowOptions["min-width"] = 768;
		windowOptions["min-height"] = 300;
		mainBrowserWindow = new BrowserWindow__0(windowOptions);
		mainBrowserWindow.loadUrl("file://" + js.Node.__dirname + "/run_tests.html");
		mainBrowserWindow.on("closed",function() {
			mainBrowserWindow = null;
		});
		mainBrowserWindow.toggleDevTools();
	});
};
var js = {};
js.Node = function() { };
var App__1 = require("app");
var EventEmitter__0 = require("events").EventEmitter;
var BrowserWindow__0 = require("browser-window");
var Readable__1 = require("stream").Readable;
var Writable__2 = require("stream").Writable;
js.Node.process = process;
js.Node.__dirname = __dirname;
AtomShellTestRunner.main();
})();

//# sourceMappingURL=run_tests.js.map