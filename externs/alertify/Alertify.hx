package ;

/**
 * ...
 * @author AS3Boyan
 */

typedef Labels = {
	@:optional var ok:String;
	@:optional var cancel:String;
}
 
typedef Options =
{
	@:optional var labels: Labels;
}
 
extern class Alertify
{
	public static function __init__():Void
	{
		var Alertify = untyped __js__("alertify");
	}
	
	// alert dialog
	static function alert(message:String):Void;	
	
	// confirm dialog
	static function confirm(message:String, onComplete:Bool->Void):Void;
	
	// prompt dialog
	static function prompt(message:String, onComplete:Bool->String->Void, ?defaultValue:String):Void;
	
	// standard notification
	// setting the wait property to 0 will
	// keep the log message until it's clicked
	static function log(notification:String, ?type:String, ?wait:Int):Void;
	
	// success notification
	// shorthand for alertify.log("Notification", "success");
	static function success(notification:String, ?wait:Int):Void;

	// error notification
	// shorthand for alertify.log("Notification", "error");
	static function error(notification:String, ?wait:Int):Void;
	
	static function set(options:Options):Void;
}