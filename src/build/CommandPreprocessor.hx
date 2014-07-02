package build;
import js.node.Path;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
class CommandPreprocessor
{
	public static function preprocess(command:String, path:String):String
	{
		var processedCommand:String = command;
		
		processedCommand = StringTools.replace(processedCommand, "%path%", path);
		
		var ereg:EReg = ~/%join%[(](.+)[)]/;
		
		if (ereg.match(processedCommand))
		{
			var matchedString:String = ereg.matched(1);
			var args = matchedString.split(",");
			
			processedCommand = StringTools.replace(processedCommand, ereg.matched(0), Path.join(args[0], args[1]));
		}
		
		return processedCommand;
	}	
}