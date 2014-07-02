package watchers;
import js.npm.Watchr;

/**
 * ...
 * @author AS3Boyan
 */
class Watcher
{
	public static function watchFileForUpdates(_path:String, onUpdate:Dynamic, ?_interval:Int):Dynamic
	{
		var config:WatchrConfig = {
			path: _path,
			listener:
				function (changeType, filePath, fileCurrentStat, filePreviousStat):Void 
				{
					if (changeType == "update") 
					{
						onUpdate();
					}
				}
		};
		
		if (_interval != null) 
		{
			config.interval = _interval;
		}
		
		var watcher = Watchr.watch(config);
		
		return watcher;
	}
	
}