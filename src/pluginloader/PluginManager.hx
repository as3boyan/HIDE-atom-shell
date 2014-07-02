package pluginloader;
import js.node.ChildProcess;
import js.node.fs.Stats;
import js.node.Fs;
import js.node.Path;
import haxe.Template;
import haxe.ds.StringMap;
import haxe.Serializer;
import haxe.Timer;
import haxe.Unserializer;
import js.Browser;
import js.html.Element;
import js.html.TextAreaElement;

/**
 * ...
 * @author 
 */

typedef PluginDependenciesData =
{
	var name:String;
	var plugins:Array<String>;
	var onLoaded:Void->Void;
	var callOnLoadWhenAtLeastOnePluginLoaded:Bool;
}
 
class PluginManager
{
	public var plugins:Array<String> = new Array();
	public var pathToPlugins:StringMap<String> = new StringMap();
	public var inactivePlugins:Array<String> = [];
	
	public var requestedPluginsData:Array<PluginDependenciesData> = new Array();
	
	public var pluginsMTime:StringMap<Int> = new StringMap();
	
	public var firstRun:Bool = false;
	
	public var pluginsTestingData:String = "  - cd plugins";
	
	static var instance:PluginManager = null;
	
	public function new()
	{
			
	}
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new PluginManager();
		}
		
		return instance;
	}
	
	public function loadPlugins(?compile:Bool = true):Void
	{
		var pathToPluginsFolder:String = "plugins";
		
		if (!Fs.existsSync(pathToPluginsFolder)) 
		{
			Fs.mkdirSync(pathToPluginsFolder);
		}
		
		var pathToPluginsMTime:String = "pluginsMTime.dat";
		
		var args:Array<String>;
		
		if (Fs.existsSync(pathToPluginsMTime))
		{
// 			var options:NodeFsFileOptions = { };
// 			options.encoding = "utf8";
			var data:String = Fs.readFileSync(pathToPluginsMTime, "utf8");
			if (data != "") 
			{
				pluginsMTime = Unserializer.run(data);
			}
		}
		else 
		{
			firstRun = true;
		}
		
		readDir(pathToPluginsFolder, "", function (path:String, pathToPlugin:String):Void
		{
			var pluginName:String = StringTools.replace(pathToPlugin, Path.sep, ".");
			
			var relativePathToPlugin:String = Path.join(path, pathToPlugin);
			
			//Store path to plugin, so we can load JS and CSS scripts by specifying path relative to plugin's directory
			pathToPlugins.set(pluginName, relativePathToPlugin);
			
			var absolutePathToPlugin:String = Path.resolve(relativePathToPlugin);
			
			if (firstRun)
			{
				pluginsMTime.set(pluginName, Std.parseInt(Std.string(Date.now().getTime())));
			}
			
			if (compile && (!pluginsMTime.exists(pluginName) || pluginsMTime.get(pluginName) < walk(absolutePathToPlugin)))
			{				
				//Compile each plugin and load
				compilePlugin(pluginName, absolutePathToPlugin, loadPlugin);
			}
			else 
			{
				//Load plugin
				loadPlugin(absolutePathToPlugin);
			}
		});
		
		Timer.delay(function ():Void
		{
			if (requestedPluginsData.length > 0)
			{
				trace("still not loaded plugins: ");
			
				for (pluginData in requestedPluginsData)
				{
					trace(pluginData.name + ": can't load plugin, required plugins are not found");
					trace(pluginData.plugins);
				}
				
				savePluginsMTime();
			}
		}
		, 10000);
	}
	
	function walk(pathToPlugin:String):Int
	{
		var pathToItem:String;
		var time:Int = -1;
		var mtime:Int;
		var extension:String;
		
		for (item in Fs.readdirSync(pathToPlugin))
		{
			pathToItem = Path.join(pathToPlugin, item);
			
			var stat = Fs.statSync(pathToItem);
			
			extension = Path.extname(pathToItem);
			
			if (stat.isFile() && (extension == ".hx" || extension == ".hxml"))
			{
				mtime = stat.mtime.getTime();
				
				if (time < mtime)
				{
					time = mtime;
				}
			}
			else if (stat.isDirectory()) 
			{
				mtime = walk(pathToItem);
				
				if (time < mtime)
				{
					time = mtime;
				}
			}
		}
		
		return time;
	}
	
	function readDir(path:String, pathToPlugin:String, onLoad:Dynamic):Void
	{
		var pathToFolder:String;
		
		Fs.readdir(Path.join(path, pathToPlugin), function (error, folders:Array<String>):Void
		{
			if (error != null)
			{
				trace(error);
			}
			else 
			{
				for (item in folders)
				{
					if (item != "inactive")
					{
						pathToFolder = Path.join(path, pathToPlugin, item);
					
						Fs.stat(pathToFolder, function (error, stat:Stats)
						{
							if (error != null)
							{
								//trace(error);
							}
							else 
							{						
								var pluginName:String = StringTools.replace(pathToPlugin, Path.sep, ".");
								
								if (stat.isDirectory())
								{
									readDir(path, Path.join(pathToPlugin,item), onLoad);
								}
								else if (item == "plugin.hxml" && !Lambda.has(inactivePlugins, pluginName))
								{	
									var levels:String = "";
									for (i in 0...pathToPlugin.split("\\").length)
									{
										levels += "../";
									}
									
									pluginsTestingData += "\n  - cd " + StringTools.replace(pathToPlugin, "\\", "/") + "\n  - haxe plugin.hxml\n  - cd " + levels;
									
									onLoad(path, pathToPlugin);
									return;
								}
							}
						}
						);
					}
				}
			}
		}
		);
	}
	
	function loadPlugin(pathToPlugin:String):Void
	{		
		var pathToMain:String = Path.join(pathToPlugin, "bin", "Main.js");
		
		Fs.exists(pathToMain, function (exists:Bool)
		{
			if (exists)
			{
				HIDE.loadJS(null, [pathToMain]);
			}
			else 
			{
				trace(pathToMain + " is not found/nPlease compile " + pathToPlugin + " plugin");
			}
		}
		);
	}
	
	public function compilePlugin(name:String, pathToPlugin:String, onSuccess:Dynamic, ?onFailed:String->Void):Void
	{
		var pathToBin:String =  Path.join(pathToPlugin, "bin");
		
		Fs.exists(pathToBin, function (exists:Bool)
		{
			if (exists)
			{
				startPluginCompilation(name, pathToPlugin, onSuccess, onFailed);
			}
			else 
			{
				Fs.mkdir(pathToBin, function (error)
				{
					startPluginCompilation(name, pathToPlugin, onSuccess, onFailed);
				}
				);
			}
		}
		);
	}
	
	function startPluginCompilation(name:String, pathToPlugin:String, onSuccess:Dynamic, ?onFailed:String->Void):Void
	{
		var startTime:Float = Date.now().getTime();
		var delta:Float;
		
		var command:String = ["haxe", "--cwd", HIDE.surroundWithQuotes(pathToPlugin), "plugin.hxml"].join(" ");
		
		trace(command);
		
		var haxeCompilerProcess:ChildProcess = ChildProcess.exec(command, { }, function (err, stdout, stderr)
		{			
			if (err == null)
			{
				delta = Date.now().getTime() - startTime;
				
				trace(name + " compilation took " + Std.string(delta)) + " ms";
				
				onSuccess(pathToPlugin);
				pluginsMTime.set(name, Std.parseInt(Std.string(Date.now().getTime())));
			}
			else 
			{
				var element:Element = Browser.document.getElementById("plugin-compilation-console");

				var textarea:TextAreaElement;
				
				if (element == null)
				{
					textarea = Browser.document.createTextAreaElement();
					textarea.id = "plugin-compilation-console";
					textarea.value = "Plugins compile-time errors:\n";
					Browser.document.body.appendChild(textarea);
				}
				else  
				{
					textarea = cast(element, TextAreaElement);
				}
				
				trace(pathToPlugin + ' stderr: ' + stderr);
				
				textarea.value += name + "\n" + stderr + "\n";
				trace("can't load " + name + " plugin, compilation failed");
				
				var regex:EReg = new EReg("haxelib install (.+) ", "gim");
				regex.map(stderr, function (ereg:EReg)
				{
					trace(ereg);
					return "";
				}
				);
				
				if (onFailed != null)
				{
					onFailed(stderr);
				}
			}
		}
		);
	}
	
	function checkRequiredPluginsData():Void
	{		
		if (requestedPluginsData.length > 0)
		{
			var pluginData:PluginDependenciesData;
		
			var j:Int = 0;
			while (j < requestedPluginsData.length)
			{
				pluginData = requestedPluginsData[j];
				
				var pluginsLoaded:Bool;
				
				if (pluginData.callOnLoadWhenAtLeastOnePluginLoaded == false)
				{
					pluginsLoaded = Lambda.foreach(pluginData.plugins, function (plugin:String):Bool
					{
						return Lambda.has(plugins, plugin);
					}
					);
				}
				else 
				{
					pluginsLoaded = !Lambda.foreach(pluginData.plugins, function (plugin:String):Bool
					{
						return !Lambda.has(plugins, plugin);
					}
					);
				}
				
				if (pluginsLoaded)
				{
					requestedPluginsData.splice(j, 1);
					trace(pluginData.name);
					pluginData.onLoaded();
				}
				else 
				{
					j++;
				}
			}
		}
		
		if (Lambda.count(pathToPlugins) == plugins.length)
		{			
			trace("all plugins loaded");
			
			var delta:Float = Date.now().getTime() - Main.currentTime;
			
			trace("Loading took: " + Std.string(delta) + " ms");
			
			var options = { encoding: null };
			options.encoding = "utf8";
			Fs.readFile("../.travis.yml.template", options, function(error, data:String):Void
			{
				if (data != null)
				{
					// var updatedData:String = Mustache.render(data, {plugins: pluginsTestingData});
					var updatedData:String = new Template(data).execute({plugins: pluginsTestingData});

					Fs.writeFile("../.travis.yml", updatedData, "utf8", function(error):Void
					{
						trace(".travis.yml was updated according to active plugins list");
					}
					);
					
				}
				else
				{
					trace(error);
				}
			}
			);
			
			savePluginsMTime();
		}
	}
	
	public function savePluginsMTime() 
	{
		var pathToPluginsMTime:String = Path.join("..", "pluginsMTime.dat");
			
		var data:String = Serializer.run(pluginsMTime);
		
		Fs.writeFile(pathToPluginsMTime, data, "utf8", function (error)
		{
			
		}
		);
	}
	
	public function waitForDependentPluginsToBeLoaded(name:String, plugins:Array<String>, onLoaded:Void->Void, ?callOnLoadWhenAtLeastOnePluginLoaded:Bool = false):Void
	{	
		var data:PluginDependenciesData = { name:name, plugins:plugins, onLoaded:onLoaded, callOnLoadWhenAtLeastOnePluginLoaded:callOnLoadWhenAtLeastOnePluginLoaded };
		requestedPluginsData.push(data);
		checkRequiredPluginsData();
	}
	
	public function notifyLoadingComplete(name:String):Void
	{
		plugins.push(name);
		checkRequiredPluginsData();
	}
	
	public function compilePlugins(?onComplete:Dynamic, ?onFailed:Dynamic):Void
	{
		var pluginCount:Int = Lambda.count(pathToPlugins);
		var compiledPluginCount:Int = 0;

		var relativePathToPlugin:String;
		var absolutePathToPlugin:String;

		if (pluginCount > 0) 
		{
			for (name in pathToPlugins.keys())
			{
				relativePathToPlugin = pathToPlugins.get(name);
				absolutePathToPlugin = Path.resolve(relativePathToPlugin);

				compilePlugin(name, absolutePathToPlugin, function ():Void
				{
					compiledPluginCount++;

					if (compiledPluginCount == pluginCount)
					{
						onComplete();
					}
				}
				, onFailed);
			}
		}
		else 
		{
			onComplete();
		}
	}
}