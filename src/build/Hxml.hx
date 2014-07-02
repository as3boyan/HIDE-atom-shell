package build;
import core.HaxeHelper;
import js.Node;
import parser.ClasspathWalker;
import projectaccess.ProjectAccess;
import core.ProcessHelper;
import core.Utils;

/**
 * ...
 * @author AS3Boyan
 */
class Hxml
{
	public static function checkHxml(dirname:String, filename:String, hxmlData:String, ?onComplete:Dynamic)
	{
		var useCompilationServer:Bool = true;
		var startCommandLine:Bool = false;
		
		if (hxmlData != null) 
		{
			if (hxmlData.indexOf("-cmd") != -1) 
			{
				startCommandLine = true;
			}
			
			if (hxmlData.indexOf("-cpp") != -1) 
			{
				useCompilationServer = false;
			}
		}
		
		buildHxml(dirname, filename, useCompilationServer, startCommandLine, onComplete);
	}
	
	public static function buildHxml(dirname:String, filename:String, ?useCompilationServer:Bool = true, ?startCommandLine:Bool = false, ?onComplete:Dynamic)
	{
		var params:Array<String> = [];
		
		if (startCommandLine) 
		{
			switch (Utils.os) 
			{
				case Utils.WINDOWS:
					params.push("start");
				default:
			}
		}
		
		var pathToHaxe = HaxeHelper.getPathToHaxe();
			
		params = params.concat([pathToHaxe, "--cwd", dirname]);
		
		if (useCompilationServer)
		{
			params = params.concat(["--connect", "5000"]);
		}
		
		params.push(filename);
		
		var process:String = params.shift();
		
		var cwd = ProjectAccess.path;
		
		var processHelper = ProcessHelper.get();
		
		processHelper.runProcessAndPrintOutputToConsole(process, params, cwd, onComplete);
	}
}