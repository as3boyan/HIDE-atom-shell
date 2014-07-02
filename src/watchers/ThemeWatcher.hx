package watchers;
import js.node.Fs.FsReadFileOpt;
import js.atomshell.browser.BrowserWindow;
import js.node.Fs;
import js.node.Path;
import cm.Editor;
import js.html.LinkElement;
import js.Browser;
import js.Node;
import haxe.Timer;
import jQuery.JQuery;

/**
 * ...
 * @author AS3Boyan
 */
class ThemeWatcher
{
	var watcher:Dynamic;
	var listenerAdded:Bool = false;
    var pathToTheme:String;
	var currentTheme:String;
	
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
	
	public function load() 
	{		
        pathToTheme = Path.join("core", SettingsWatcher.settings.theme);
        
        Fs.exists(pathToTheme, function (exists:Bool)
                         {
                             if (exists)
                             {
                                 continueLoading();
                             }
                             else
                             {
                                 Alertify.log("File " + pathToTheme + " for theme " + SettingsWatcher.settings.theme + " was not found. CSS files in core folder: [" + getListOfCSSFiles().join(",") + "]", "", 10000);
                             }
                         });
	}
    
    function continueLoading()
    {
        updateTheme();
		
		if (watcher != null) 
		{
			watcher.close();
		}
		
		watcher = Watcher.watchFileForUpdates(pathToTheme, function ():Void 
		{
			updateTheme();
		}, 1000);
		
		if (!listenerAdded) 
		{
			BrowserWindow.getAllWindows()[0].on("close", function (e) 
			{
				if (watcher != null) 
				{
					watcher.close();
				}
			}
			);
			
			listenerAdded = true;
		}
    }
	
    function getListOfCSSFiles()
    {
        var files:Array<String> = [];
        
        for (item in Fs.readdirSync("core"))
        {
            if (Path.extname(item) == ".css")
            {
                files.push(Path.basename(item));
            }
        }
        
        return files;
    }
    
	function updateTheme(?type:String) 
	{		
		var theme = SettingsWatcher.settings.theme;
		
		var relativePath = Path.join("core", theme);
		
		new JQuery("#theme").attr("href", relativePath);
		
		if (currentTheme != null && currentTheme != theme)
		{
			var ereg = ~/\/\* *codeEditorTheme *= *([^ \*]*) *\*\//g;
		
// 			var options:FsReadFileOpt = {};
// 			options.encoding = "utf8";

			var data = Fs.readFileSync(relativePath, "utf8");

			if (ereg.match(data))
			{
				var codeEditorTheme = ereg.matched(1);
				Editor.setTheme(codeEditorTheme);
			}
		}
			
		currentTheme = theme;
	}
}