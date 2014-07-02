package core;
import js.Node;

/**
 * ...
 * @author AS3Boyan
 */
class NekoToolsServer
{
	static var nekoToolsClient:ChildProcess;
	
	public static function start(path:String):Void
	{
		if (nekoToolsClient != null)
		{
			nekoToolsClient.kill();
			nekoToolsClient = null;
		}
		
		nekoToolsClient = ProcessHelper.runPersistentProcess("nekotools", ["server", "-p", "8000", "-d", path]);
	}
}