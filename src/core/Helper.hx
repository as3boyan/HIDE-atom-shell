package core;
import haxe.ds.StringMap.StringMap;
import haxe.Timer;

/**
 * ...
 * @author AS3Boyan
 */
class Helper
{
	static var timers:StringMap<Timer> = new StringMap();
	
	public static function debounce(type:String, onComplete:Dynamic, time_ms:Int)
	{
		var timer = timers.get(type); 
		
		if (timer != null) 
		{
			timer.stop();
		}
		
		timer = new Timer(time_ms);
		timer.run = function ():Void 
		{
			timer.stop();
			onComplete();
		};
		
		timers.set(type, timer);
	}
}