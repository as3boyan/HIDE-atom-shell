package openflproject;
import core.HaxeHelper;
import core.ProcessHelper;
import js.Browser;
import js.html.TextAreaElement;

/**
 * ...
 * @author AS3Boyan
 */
class OpenFLTools
{	
	public static function getParams(path:String, target:String, onLoaded:String->Void):Void
	{
		var processHelper = ProcessHelper.get();
		
		processHelper.runProcess(HaxeHelper.getPathToHaxelib(), ["run", "lime", "display", target, "-nocolor"], path, function (stdout:String, stderr:String):Void 
		{
			//onComplete
			
			if (onLoaded != null)
			{
				onLoaded(stdout);
			}
			
			printStderr(stderr);
			
		}, function (code:Int, stdout:String, stderr:String):Void 
		{
			//onFailed
			
			Alertify.error("OpenFL tools error. OpenFL may be not installed. Please update OpenFL.(haxelib upgrade)");
			Alertify.error("OpenFL tools process exit code " + code);
			
			printStderr(stdout);
			printStderr(stderr);
		}); 
	}
	
	static function printStderr(stderr:String)
	{
		if (stderr != "")
		{
			Alertify.error("OpenFL tools stderr: " + stderr, 15000);
		}
	}
}