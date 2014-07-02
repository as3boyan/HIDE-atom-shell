package watchers;
import js.atomshell.browser.App;
import js.atomshell.browser.BrowserWindow;
import js.node.Fs.FsReadFileOpt;
import js.node.Fs;
import js.node.Path;
import core.Utils;
import filetree.FileTree;
import haxe.Timer;
import js.Node;
import projectaccess.ProjectAccess;
import tjson.TJSON;

typedef Settings = {
	var theme:String;
	var locale:String;
	var ignore:Array<String>;
	var indentWithTabs:Bool;
	var indentSize:Int;
}

/**
 * ...
 * @author 
 */
class SettingsWatcher
{
	public static var settings:Settings;
	public static var watcher:Dynamic;
    
    static var pathToSettings:String;
	public static var pathToFolder:String;
	
	public static function load():Void 
	{		
		var pathToConfigFolder:String = Path.join("core", "config");
		
// 		switch (Utils.os)
// 		{
// 			case Utils.WINDOWS:
// 				pathToFolder = Node.process.env.APPDATA;
// 			default:
// 				pathToFolder = Node.process.env.HOME;
// 		}
		//App.dataPath
// 		pathToFolder = "/home/as3boyan/.config";
		pathToFolder = untyped App.getHomeDir();
		
		if (pathToFolder != null)
		{
			pathToFolder = Path.join(pathToFolder, ".HIDE");
			if (!Fs.existsSync(pathToFolder))
			{
				Fs.mkdirSync(pathToFolder);
			}
			
			var configFiles = Fs.readdirSync(pathToConfigFolder);
			var files = Fs.readdirSync(pathToFolder);
			
// 			var options:FsReadFileOpt = {};
// 			options.encoding = "utf8";
			
			var content:String;
			
			var pathToFile:String = null;
			
			for (file in configFiles)
			{
				if (files.indexOf(file) == -1)
				{
					pathToFile = Path.join(pathToConfigFolder, file);
					content = Fs.readFileSync(pathToFile, "utf8");
					pathToFile = Path.join(pathToFolder, file);
					Fs.writeFileSync(pathToFile, content, "utf8");
				}
			}
		}
		else
		{
			pathToFolder = pathToConfigFolder;
		}
		
        pathToSettings = Path.join(pathToFolder, "settings.json");
        
		watcher = Watcher.watchFileForUpdates(pathToSettings, parse, 3000);
		
		parse();
		
		BrowserWindow.getAllWindows()[0].on("close", function (e) 
		{
			if (watcher != null) 
			{
				watcher.close();
			}
		}
		);
	}
	
	static function parse():Void 
	{		
// 		var options:FsReadFileOpt = { encoding: "utf8" };
		
		var data:String = Fs.readFileSync(pathToSettings, "utf8");
		
		if (data != "")
		{
			settings = TJSON.parse(data);
			
			var themeWatcher = ThemeWatcher.get();
			themeWatcher.load();
			LocaleWatcher.load();

			if (ProjectAccess.path != null) 
			{
				var fileTree = FileTree.get();
				fileTree.load();
			}
		}
		else
		{
			Alertify.error(pathToSettings + " is empty! Please remove this file and restart HIDE.", 0);
		}

	}
	
	public static function isItemInIgnoreList(path:String):Bool
	{
		var ignored:Bool = false;
		
		var ereg:EReg;
		
		for (item in SettingsWatcher.settings.ignore) 
		{
			ereg = new EReg(item, "");
			
			if (ereg.match(path)) 
			{
				ignored = true;
				break;
			}
		}
		
		return ignored;
	}
}