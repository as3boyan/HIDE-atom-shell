package core;
import haxe.Json;
import js.atomshell.browser.BrowserWindow;
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
	static var window:BrowserWindow;
	
	public static function init():Void
	{
		window = BrowserWindow.getAllWindows()[0];
		
		initBrowserWindowState();

		window.on('maximize', function ():Void
		{
				isMaximizationEvent = true;
				currWinMode = 'maximized';
		});

		window.on('unmaximize', function ():Void
		{
				currWinMode = 'normal';
				restoreBrowserWindowState();
		});

		window.on('minimize', function ():Void
		{
				currWinMode = 'minimized';
		});

		window.on('restore', function ():Void
		{
				currWinMode = 'normal';
		});
		
		Browser.window.addEventListener('resize', function (e) 
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
				if (isMaximizationEvent) 
				{
					// first resize after maximization event should be ignored
					isMaximizationEvent = false;
				} 
				else 
				{
					if (currWinMode == 'maximized') 
					{
						currWinMode = 'normal';
					}
				}
				
				resizeTimeout.stop();
				
				dumpBrowserWindowState();   
			};
				
		}, false);
		
		window.on("close", function (e)
		{
			saveBrowserWindowState();
			window.close();//true
		}
		);
	}
	
	static function initBrowserWindowState():Void
	{
		var windowState = Browser.getLocalStorage().getItem("windowState");
				
		if (windowState != null)
		{
			winState = Json.parse(windowState);
		}
				
		if (winState != null) 
		{
			currWinMode = winState.mode;
			if (currWinMode == 'maximized') 
			{
				window.maximize();
			} 
			else 
			{
				restoreBrowserWindowState();
			}
		} 
		else 
		{
			currWinMode = 'normal';
			dumpBrowserWindowState();
		}
	}

	static function dumpBrowserWindowState():Void
	{
		if (winState == null) 
		{
			winState = {};
		}
		
		// we don't want to save minimized state, only maximized or normal
		if (currWinMode == 'maximized') 
		{
			winState.mode = 'maximized';
		}
		else 
		{
			winState.mode = 'normal';
		}
		
		// when window is maximized you want to preserve normal
		// window dimensions to restore them later (even between sessions)
		if (currWinMode == 'normal') 
		{
			var pos = window.getPosition();
			trace(pos);
// 			winState.x = window.x;
// 			winState.y = window.y;
			var size = window.getSize();
			trace(size);
// 			winState.width = window.width;
// 			winState.height = window.height;
		}
	}

	static function restoreBrowserWindowState():Void
	{
		window.setSize(winState.width, winState.height);
		window.setPosition(winState.x, winState.y);
	}

	static function saveBrowserWindowState():Void
	{
		dumpBrowserWindowState();
		Browser.getLocalStorage().setItem("windowState", Json.stringify(winState));
	}
        
}

