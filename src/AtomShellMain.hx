package ;
import js.atomshell.browser.App;
import js.atomshell.browser.BrowserWindow;
import js.Lib;

class AtomShellMain
{
    static public function main()
    {
		var mainBrowserWindow = null;
		
		App.on(AppEvent.WINDOW_ALL_CLOSED, function ()
			   {
				   if (js.Node.process.platform != "darwin")
				   {
					   App.quit();
				   }
			   }
			  );
		
		App.on(AppEvent.READY, function ()
			{				
// 				var size = Screen.getPrimaryDisplay().workAreaSize;
				
				var windowOptions:BrowserWindowOptions = new BrowserWindowOptions({});
// 				windowOptions.skipTaskbar = true;
// 				windowOptions.center = true;
// 				windowOptions.width = size.width;
// 				windowOptions.height = size.height;
				
				mainBrowserWindow = new BrowserWindow(windowOptions);
				
				mainBrowserWindow.loadUrl("file://" + js.Node.__dirname + "/index.html");
				
				mainBrowserWindow.on(BrowserWindowEvent.CLOSED, function ()
					{
						mainBrowserWindow = null;
					}
				);
				
// 				mainBrowserWindow.webContents.on(BrowserWindow.WebContentsEvent.DID_FINISH_LOAD, function ()
// 					{
						
// 					});
				
// 				Main.load();
				
				mainBrowserWindow.toggleDevTools();
			}
		);

	}
}