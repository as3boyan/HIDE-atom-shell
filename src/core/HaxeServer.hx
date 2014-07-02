package core;
import js.node.Net;
import js.node.ChildProcess;

/**
 * ...
 * @author AS3Boyan
 */
class HaxeServer
{
	static var haxeServer:ChildProcess;

	public static function check():Void
	{
		var socket = Net.connect(5000, "localhost");
		//socket.on("data", function (e)
		//{
			//trace(e.toString("utf8"));
			//socket.destroy();
		//}
		//);
		socket.on("error", function (e)
		{
			trace("Haxe server is not found at localhost:5000");
		}
		);
		socket.on("close", function (e)
		{
			if (e) 
			{
				start();
			}
		}
		);
	}
	
	public static function start():Void
	{
		trace("Starting new Haxe server at localhost:5000");
		
		var processHelper = ProcessHelper.get();
		
		haxeServer = processHelper.runPersistentProcess(HaxeHelper.getPathToHaxe(), ["--wait", "5000"], null, function (code:Int, stdout:String, stderr:String):Void 
		{
			trace(stdout);
			trace(stderr);
		}
		);

// 		var window:BrowserWindow = BrowserWindow.getAllWindows()[0];
		
// 		window.on("close", function (e)
// 		{
// 			terminate();
// 			window.close();
// 		}
// 		);
	}
	
	public static function terminate():Void
	{
		if (haxeServer != null) 
		{
			haxeServer.kill();
		}
	}
}