package watchers;
import js.npm.Pathwatcher;

/**
 * ...
 * @author AS3Boyan
 */
class Watcher
{
	public static function watchFileForUpdates(_path:String, onUpdate:Dynamic, ?_interval:Int):Dynamic
	{
// 		var config:WatchrConfig = {
// 			path: _path,
// 			listeners: {
// 				change: function (changeType, filePath, fileCurrentStat, filePreviousStat):Void 
// 				{
// 					if (changeType == "update") 
// 					{
// 						onUpdate();
// 					}
// 				},
// // 				log: function (logLevel, args)
// // 				{
// // 					trace(logLevel);
// // 					trace(args);
// // 				},
// // 				watching: function (err, isWatching)
// // 				{
// // 					trace(err);
// // 					trace(isWatching);
// // 				},
// // 				error: function (err)
// // 				{
// // 					trace(err);
// // 				}
// 			},
// // 			next: function (err, watchers)
// // 			{
// // 				trace(err);
// // 				trace(watchers);
// // 			}
// 		};
		
// 		if (_interval != null) 
// 		{
// 			config.interval = _interval;
// 		}
			
// 		config.persistent = true;
			
// 		var watcher = Watchr.watch(config);
		
		var watcher = Pathwatcher.watch(_path, function (event, path)
									   {
										   if (event == PathwatcherEvent.CHANGE)
										   {
											   onUpdate();
										   }

									   });
		
		return watcher;
	}
	
}
