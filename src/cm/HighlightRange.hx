package cm;
import CodeMirror.Pos;
import haxe.Timer;

/**
* @author 
 */
class HighlightRange
{
	static var instance:HighlightRange;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new HighlightRange();
		}
			
		return instance;
	}
	
	public function highlight(cm:CodeMirror, from:Pos, to:Pos)
	{
		var marker = cm.markText(from, to, {className: "showDeclaration"});
				
		Timer.delay(function ()
					{
						marker.clear();
					}
					, 1000);
	}

}