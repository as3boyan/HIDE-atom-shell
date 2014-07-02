package watchers;
import js.atomshell.browser.BrowserWindow;
import js.node.Path;
import completion.SnippetsCompletion;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
class SnippetsWatcher
{
	var watcher:Dynamic;
	
	static var instance:ThemeWatcher;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new ThemeWatcher();
		}
			
		return instance;
	}
	
	public function load():Void 
	{
		var pathToFile = Path.join(SettingsWatcher.pathToFolder, "snippets.json");
		
		watcher = Watcher.watchFileForUpdates(pathToFile, function ():Void 
		{
			var snippetsCompletion = SnippetsCompletion.get();
			snippetsCompletion.load();
		}, 1000);
		
		BrowserWindow.getAllWindows()[0].on("close", function (e) 
		{
			if (watcher != null) 
			{
				watcher.close();
			}
		}
		);
	}
}