package ;
import js.Node;
import js.atomshell.browser.App;
import js.atomshell.browser.BrowserWindow;
import js.Lib;

class AtomShellTestRunner
{
    static public function main()
    {
		var mainBrowserWindow = null;
		
		Node.process.chdir(Node.__dirname);
		
		App.commandLine.appendSwitch('js-flags', '--harmony');

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
				var windowOptions:BrowserWindowOptions = {};
				windowOptions.minWidth = 768;
				windowOptions.minHeight = 300;
				
				mainBrowserWindow = new BrowserWindow(windowOptions);
				
				mainBrowserWindow.loadUrl("file://" + js.Node.__dirname + "/run_tests.html");
				
				mainBrowserWindow.on(BrowserWindowEvent.CLOSED, function ()
					{
						mainBrowserWindow = null;
					}
				);
				
				mainBrowserWindow.toggleDevTools();
			}
		);

	}
}
