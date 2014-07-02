package ;
import js.node.Fs;
import js.node.Fs.FsReadFileOpt;
import js.node.Path;
import js.atomshell.browser.BrowserWindow;
import haxe.ds.StringMap.StringMap;
import haxe.Serializer;
import js.Browser;
import js.html.LinkElement;
import js.html.ScriptElement;
import js.Node;
import pluginloader.PluginManager;

/**
 * ...
 * @author AS3Boyan
 */

 //This class is a global HIDE API for plugins
 //Using this API plugins can load JS and CSS scripts in specified order 
 //To use it in plugins you may need to add path to externs for this class, they are located at externs/plugins/hide

class HIDE
{
	public static var windows:Array<BrowserWindow> = [];
	
	//Loads JS scripts in specified order and calls onLoad function when last item of urls array was loaded
	public static function loadJS(name:String, urls:Array<String>, ?onLoad:Dynamic):Void
	{		
		if (name != null)
		{
			for (i in 0...urls.length)
			{
				urls[i] = Path.join(getPluginPath(name), urls[i]);
			}
		}
		
		loadJSAsync(name, urls, onLoad);
	}
	
	//Asynchronously loads multiple CSS scripts
	public static function loadCSS(name:String, urls:Array<String>, ?onLoad:Dynamic):Void
	{
		if (name != null)
		{
			for (i in 0...urls.length)
			{
				urls[i] = Path.join(getPluginPath(name), urls[i]);
			}
		}

		loadCSSAsync(name, urls, onLoad);
	}
	
	static function loadCSSAsync(name:String, urls:Array<String>, ?onLoad:Dynamic):Void
	{
		var link:LinkElement = Browser.document.createLinkElement();
		link.href = urls.splice(0, 1)[0];
		link.type = "text/css";
		link.rel = "stylesheet";
		link.onload = function (e)
		{
			traceScriptLoadingInfo(name, link.href);
			
			if (urls.length > 0)
			{
				loadCSSAsync(name, urls, onLoad);
			}
			else if (onLoad != null)
			{
				onLoad();
			}
		};
		
		Browser.document.head.appendChild(link);
	}	
	
	static function traceScriptLoadingInfo(name:String, url:String):Void
	{
		var str:String;
				
		if (name != null)
		{
			str = "\n" + name + ":\n" + url + "\n";
		}
		else 
		{
			str = url + " loaded";
		}
		
		//trace(str);
	}
	
	public static function getPluginPath(name:String):String
	{
		var pluginManager = PluginManager.get();
		
		var pathToPlugin:String = pluginManager.pathToPlugins.get(name);
				
		if (pathToPlugin == null)
		{
			trace("HIDE can't find path for plugin: " + name + "\nPlease check folder structure of plugin, make sure that it corresponds to it's 'name'");
		}
		
		return pathToPlugin;
	}
	
	public static function waitForDependentPluginsToBeLoaded(name:String, plugins:Array<String>, onLoaded:Void->Void, ?callOnLoadWhenAtLeastOnePluginLoaded:Bool = false):Void
	{	
		var pluginManager = PluginManager.get();
		
		pluginManager.waitForDependentPluginsToBeLoaded(name, plugins, onLoaded, callOnLoadWhenAtLeastOnePluginLoaded);
	}
	
	public static function notifyLoadingComplete(name:String):Void
	{
		var pluginManager = PluginManager.get();
		
		pluginManager.notifyLoadingComplete(name);
	}
	
	public static function openPageInNewBrowserWindow(name:String, url:String, ?params:Dynamic):Dynamic
	{	
		var window = null;
		
// 		var fullPath:String = url;
		
// 		if (!StringTools.startsWith(url, "http") && name != null)
// 		{
// 			fullPath = Path.join(getPluginPath(name), url);
// 		}
		
// 		var window = BrowserWindow.open(fullPath, params);
// 		windows.push(window);
		
// 		window.on("close", function (e)
// 		{
// 			windows.remove(window);
// 			window.close(true);
// 		}
// 		);
		
		return window;
	}

	public static function compilePlugins(?onComplete:Dynamic, ?onFailed:Dynamic):Void
	{
		var pluginManager = PluginManager.get();
		
		pluginManager.compilePlugins(onComplete, onFailed);
	}
	
	public static function readFile(name:String, path:String, onComplete:Dynamic):Void
	{
		var options:FsReadFileOpt = { };
		options.encoding = "utf8";
		
		var pluginManager = PluginManager.get();
		
		var fullPath:String = path;
		
		if (name != null) 
		{
			fullPath = Path.join(pluginManager.pathToPlugins.get(name), path);
		}
		
		Fs.readFile(fullPath, options, function (error, data:String):Void
		{
			if (error != null)
			{
				trace(error);
			}
			else 
			{
				onComplete(data);
			}
		}
		);
	}
	
	public static function writeFile(name:String, path:String, contents:String, ?onComplete:Dynamic):Void
	{
		var pluginManager = PluginManager.get();
		
		Fs.writeFile(Path.join(pluginManager.pathToPlugins.get(name), path), contents, "utf8", function (error)
		{
			if (onComplete != null && error == null)
			{
				onComplete();
			}
		}
		);
	}
	
	public static function surroundWithQuotes(path:String):String
	{
		return '"' + path + '"';
	}
	
	//Private function which loads JS scripts in strict order
	static function loadJSAsync(name:String, urls:Array<String>, ?onLoad:Dynamic):Void
	{
		var script:ScriptElement = Browser.document.createScriptElement();
		script.src = urls.splice(0, 1)[0];
		script.onload = function (e)
		{			
			traceScriptLoadingInfo(name, script.src);
			
			if (urls.length > 0)
			{
				loadJSAsync(name, urls, onLoad);
			}
			else if (onLoad != null)
			{
				onLoad();
			}
		};
		
		Browser.document.body.appendChild(script);
	}
}