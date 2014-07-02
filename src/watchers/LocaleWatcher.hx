package watchers;
import js.node.Fs;
import js.node.Path;
import js.atomshell.browser.BrowserWindow;
import haxe.ds.StringMap.StringMap;
import js.Browser;
import js.html.Element;
import js.Node;
import tjson.TJSON;

/**
 * ...
 * @author AS3Boyan
 */
class LocaleWatcher
{
	static var localeData:Dynamic;
	static var watcher:Dynamic;
	static var listenerAdded:Bool = false;
    static var pathToLocale:String;
	
	public static function load():Void 
	{        
		if (watcher != null) 
		{
			watcher.close();
		}
		
		parse();
		
		watcher = Watcher.watchFileForUpdates(pathToLocale, function ():Void 
		{
			parse();
			processHtmlElements();
		}, 1000);
		
		processHtmlElements();
		
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
	
	static function parse():Void 
	{
        pathToLocale = Path.join("core", "locale", SettingsWatcher.settings.locale);
        
// 		var options:NodeFsFileOptions = { };
// 		options.encoding = "utf8";
		
		var data:String = Fs.readFileSync(pathToLocale, "utf8");
		
		localeData = TJSON.parse(data);
	}
	
	public static function getStringSync(name:String):String
	{
		var value:String = name;
		
		if (Reflect.hasField(localeData, name)) 
		{
			value = Reflect.field(localeData, name);
		}
		else 
		{
			Reflect.setField(localeData, name, name);
			var data:String = TJSON.encode(localeData, 'fancy');
			Fs.writeFileSync(pathToLocale, data, "utf8");
		}
		
		return value;
	}
	
	static function processHtmlElements()
	{
		var element:Element;
		var value:String;
		
		for (node in Browser.document.getElementsByTagName("*")) 
		{
			element = cast(node, Element);
			
			value = element.getAttribute("localeString");
			
			if (value != null) 
			{
				element.textContent = getStringSync(value);
			}
		}
	}
}