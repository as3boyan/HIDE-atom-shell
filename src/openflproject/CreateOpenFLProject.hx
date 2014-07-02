package openflproject;
import core.HaxeHelper;
import core.ProcessHelper;

/**
 * ...
 * @author AS3Boyan
 */
class CreateOpenFLProject
{
	public static function createOpenFLProject(params:Array<String>, path:String, ?onComplete:Dynamic):Void
	{	
		var processParams = ["run", "lime", "create"].concat(params);
		
		var processHelper = ProcessHelper.get();
		
		var pathToHaxelib = HaxeHelper.getPathToHaxelib();
		
		processHelper.runProcess(pathToHaxelib, processParams, path, function (stdout, stderr)
								 {
									 	if (stdout != "") 
										{
											Alertify.log("stdout:\n" + stdout);
										}

										if (stderr != "") 
										{
											Alertify.log("stderr:\n" + stderr);
										}
											
										onComplete();
											
								 }, function (code, stdout, stderr):Void 
		{
			Alertify.error([pathToHaxelib].concat(processParams).join(" ") + " " + Std.string(code));
			
			if (stdout != "") 
			{
				Alertify.error("stdout:\n" + stdout);
			}
			
			if (stderr != "") 
			{
				Alertify.error("stderr:\n" + stderr);
			}
		});
	}
}