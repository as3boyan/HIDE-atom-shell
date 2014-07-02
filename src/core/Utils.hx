package core;
import js.node.Os;

/**
 * ...
 * @author AS3Boyan
 */
class Utils
{
	inline public static var WINDOWS:Int = 0;
	inline public static var LINUX:Int = 1;
	inline public static var MAC:Int = 2;
	inline public static var OTHER:Int = 3;
	
	public static var os:Int;
	
	public static function prepare():Void
	{	
		//https://github.com/Witcher42/os-cli/blob/master/bin/os.js
		
		var platform = Os.platform();
		
		os = OTHER;
		
		if (platform == 'linux') 
		{
			os = LINUX;
		}
		else if (platform == 'darwin') 
		{
			os = MAC;
		}
		else if (platform.indexOf('win') == 0) 
		{
			os = WINDOWS;
		}
			
		trace("platform is " + Std.string(platform));
	}
}