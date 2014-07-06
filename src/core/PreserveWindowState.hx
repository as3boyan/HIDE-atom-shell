package core;
import tjson.TJSON;
import js.atomshell.browserandwebpage.Screen;
import js.atomshell.browser.BrowserWindow;
import js.node.JSON;
import haxe.Timer;
import js.Browser;

//Ported to Haxe from https://github.com/rogerwang/node-webkit/wiki/Preserve-window-state-between-sessions

// Cross-platform window state preservation.
// Yes this code is quite complicated, but this is the best I came up with for 
// current state of node-webkit BrowserWindow API (v0.7.3).
// Known issues:
// - unmaximization not always sets the window (x, y) in the lastly used coordinates
// - unmaximization animation sometimes looks wierd

class PreserveWindowState
{
	static var winState:Dynamic;
	static var currWinMode:String;
	static var resizeTimeout:Timer;
	static var isMaximizationEvent:Bool = false;
	static var browserWindow:BrowserWindow;
	
	public static function init():Void
	{
		browserWindow = BrowserWindow.getAllWindows()[0];
		
		initWindowState();

// 		window.on('maximize', function ():Void
// 		{
// 				isMaximizationEvent = true;
// 				currWinMode = 'maximized';
// 		});

// 		window.on('unmaximize', function ():Void
// 		{
// 				currWinMode = 'normal';
// 				restoreBrowserWindowState();
// 		});

// 		window.on('minimize', function ():Void
// 		{
// 				currWinMode = 'minimized';
// 		});

// 		window.on('restore', function ():Void
// 		{
// 				currWinMode = 'normal';
// 		});
		
		Browser.window.addEventListener('resize', onResize, false);
		
		Browser.window.addEventListener("beforeunload", saveWindowState);
	}
	
	static function onResize(_)
	{
		// resize event is fired many times on one resize action,
		// this hack with setTiemout forces it to fire only once

		if (resizeTimeout != null)
		{
			resizeTimeout.stop();
		}

		resizeTimeout = new Timer(500);
		resizeTimeout.run = 
		function () 
		{
			// on MacOS you can resize maximized window, so it's no longer maximized
// 				if (isMaximizationEvent) 
// 				{
// 					// first resize after maximization event should be ignored
// 					isMaximizationEvent = false;
// 				} 
// 				else 
// 				{
// 					if (currWinMode == 'maximized') 
// 					{
// 						currWinMode = 'normal';
// 					}
// 				}

			resizeTimeout.stop();

			dumpWindowState();   
		};
	}
	
	static function initWindowState():Void
	{
		var windowState = Browser.getLocalStorage().getItem("windowState");
				
		if (windowState != null)
		{
			winState = TJSON.parse(windowState);
		}
				
		if (winState != null) 
		{
// 			currWinMode = winState.mode;
// 			if (currWinMode == 'maximized') 
// 			{
// 				window.maximize();
// 			} 
// 			else 
// 			{
				restoreWindowState();
// 			}
		} 
		else 
		{
// 			currWinMode = 'normal';
			dumpWindowState();
		}
	}

	static function dumpWindowState():Void
	{
		if (winState == null) 
		{
			winState = {};
		}
		
		// we don't want to save minimized state, only maximized or normal
// 		if (currWinMode == 'maximized') 
// 		{
// 			winState.mode = 'maximized';
// 		}
// 		else 
// 		{
// 			winState.mode = 'normal';
// 		}
		
		// when window is maximized you want to preserve normal
		// window dimensions to restore them later (even between sessions)
// 		if (currWinMode == 'normal') 
// 		{
			var pos = browserWindow.getPosition();
			if (pos != null)
			{
				winState.x = pos[0];
				winState.y = pos[1];
			}
		
			var size = browserWindow.getSize();
			if (size != null)
			{
				winState.width = size[0];
				winState.height = size[1];
			}

// 		}
	}

	static function restoreWindowState():Void
	{
		var workArea = Screen.getPrimaryDisplay().workArea;
		
		var x = winState.x;
		var y = winState.y;
		
		var width = winState.width;
		var height = winState.height;
		
		if (x < 0)
		{
			x = workArea.x;
		}

		if (y < 0)
		{
			y = workArea.y;
		}
			
		if (width > workArea.width)
		{
			width = workArea.width;
		}

		if (height > workArea.height)
		{
			height = workArea.height;
		}
		
		browserWindow.setSize(width, height);
		browserWindow.setPosition(x, y);
	}

	static function saveWindowState(_):Void
	{
		resizeTimeout.stop();
		Browser.window.removeEventListener("resize", onResize, false);
		
// 		dumpWindowState();
		Browser.getLocalStorage().setItem("windowState", TJSON.encode(winState));
	}       
}
