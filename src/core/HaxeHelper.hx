package core;
import js.node.Path;
import parser.ClasspathWalker;
import haxe.xml.Fast;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
class HaxeHelper
{
	static var haxeArguments:Array<String>;
	static var haxeDefines:Array<String>;
	static var haxelibHaxelibs:Array<String>;
	static var installedHaxelibs:Array<String>;
	static var pathToHaxe:String;
	static var pathToHaxelib:String;
	
	public static function getArguments(onComplete:Array<String>->Void):Void
	{
		if (haxeArguments != null) 
		{
			onComplete(haxeArguments);
		}
		else 
		{
			var data:Array<String> = [];
		
			var processHelper = ProcessHelper.get();
			
			processHelper.runProcess(getPathToHaxe(), ["--help"], null, function (stdout:String, stderr:String):Void 
			{
				var regex:EReg = ~/-+[A-Z-]+ /gim;
				regex.map(stderr, function (ereg:EReg):String
				{
					var str = ereg.matched(0);
					data.push(str.substr(0, str.length - 1));
					return str;
				}
				);
				haxeArguments = data;
				onComplete(haxeArguments);
			}
			);
		}
	}
	
	public static function getDefines(onComplete:Array<String>->Void):Void
	{
		if (haxeDefines != null) 
		{
			onComplete(haxeDefines);
		}
		else 
		{
			var processHelper = ProcessHelper.get();
			
			var data:Array<String> = [];
		
			processHelper.runProcess(getPathToHaxe(), ["--help-defines"], null, function (stdout:String, stderr:String):Void 
			{
				var regex:EReg = ~/[A-Z-]+ +:/gim;
				regex.map(stdout, function (ereg:EReg):String
				{
					var str = ereg.matched(0);
					data.push(StringTools.trim(str.substr(0, str.length - 1)));
					return ereg.matched(0);
				}
				);
				haxeDefines = data;
				onComplete(haxeDefines);
			}
			);
		}
	}
	
	public static function getInstalledHaxelibList(onComplete:Array<String>->Void):Void
	{
		if (installedHaxelibs != null) 
		{
			onComplete(installedHaxelibs);
		}
		else 
		{
			var processHelper = ProcessHelper.get();
			
			var data:Array<String> = [];
		
			processHelper.runProcess(getPathToHaxelib(), ["list"], null, function (stdout:String, stderr:String):Void 
			{
				var regex:EReg = ~/^[A-Z-]+:/gim;
				regex.map(stdout, function (ereg:EReg):String
				{
					var str = ereg.matched(0);
					data.push(str.substr(0, str.length - 1));
					return str;
				}
				);
				installedHaxelibs = data;
				onComplete(installedHaxelibs);
			}
			);
		}
	}
	
	public static function getHaxelibList(onComplete:Array<String>->Void):Void 
	{
		if (haxelibHaxelibs != null) 
		{
			onComplete(haxelibHaxelibs);
		}
		else 
		{
			var processHelper = ProcessHelper.get();
			
			var data:Array<String> = [];
		
			processHelper.runProcess(getPathToHaxelib(), ["search", '""'], null, function (stdout:String, stderr:String):Void 
			{				
				var lines:Array<String> = stdout.split("\n");
				
				for (line in lines) 
				{
					line = StringTools.trim(line);
					
					if (line.length > 0 && line.indexOf(" ") == -1) 
					{
						data.push(line);
					}
				}
				
				haxelibHaxelibs = data;
				onComplete(haxelibHaxelibs);
			}
			);
		}
	}

	public static function getVersion(onComplete:String->Void):Void
	{
		var processHelper = ProcessHelper.get();
		
		processHelper.runProcess(getPathToHaxe(), ["-version"], null, function (stdout:String, stderr:String):Void 
		{
			onComplete(stdout);
		}
		);
	}

	public static function getPathToHaxe()
	{
		return pathToHaxe;
	}

	public static function getPathToHaxelib()
	{
		return pathToHaxelib;
	}

	public static function updatePathToHaxe()
	{
		pathToHaxe = "haxe";
		pathToHaxelib = "haxelib";
		
		var classpathWalker = ClasspathWalker.get();
		
		var pathToHaxeDirectory = classpathWalker.pathToHaxe;
		
		if (pathToHaxeDirectory != null)
		{
			pathToHaxe = Path.join(pathToHaxeDirectory, pathToHaxe);
			pathToHaxelib = Path.join(pathToHaxeDirectory, pathToHaxelib);
		}
	}
}