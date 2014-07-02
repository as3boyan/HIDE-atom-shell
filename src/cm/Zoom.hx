package cm;
import js.Browser;
import js.html.KeyboardEvent;
import js.html.WheelEvent;
import jQuery.JQuery;
import menu.BootstrapMenu;

/**
 * ...
 * @author AS3Boyan
 */
class Zoom
{	
	static var instance:Zoom;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new Zoom();
		}
			
		return instance;
	}
	
	public function load():Void
	{
		Browser.document.addEventListener("mousewheel", function(e:WheelEvent)
		{
			if (e.altKey || e.ctrlKey || e.metaKey)
			{
				if (e.wheelDeltaY < 0)
				{
					var fontSize:Int = Std.parseInt(new JQuery(".CodeMirror").css("font-size"));
					fontSize--;
					setFontSize(fontSize);
					e.preventDefault(); 
					e.stopPropagation(); 
				}
				else if (e.wheelDeltaY > 0)
				{
					var fontSize:Int = Std.parseInt(new JQuery(".CodeMirror").css("font-size"));
					fontSize++;
					setFontSize(fontSize);
					e.preventDefault(); 
					e.stopPropagation(); 
				}
			}
		}
		);
		
		BootstrapMenu.getMenu("View").addMenuItem("Increase Font Size", 10001, function ()
		{
			var fontSize:Int = Std.parseInt(new JQuery(".CodeMirror").css("font-size"));
			fontSize++;
			setFontSize(fontSize);
		}
		, "Ctrl-+");
		
		BootstrapMenu.getMenu("View").addMenuItem("Decrease Font Size", 10002, function ()
		{
			var fontSize:Int = Std.parseInt(new JQuery(".CodeMirror").css("font-size"));
			fontSize--;
			setFontSize(fontSize);
		}
		, "Ctrl--");
	}
	
	public function setFontSize(fontSize:Int):Void
	{
		new JQuery(".CodeMirror").css("font-size", Std.string(fontSize) + "px");
		new JQuery(".CodeMirror-hint").css("font-size", Std.string(fontSize - 2) + "px");
		new JQuery(".CodeMirror-hints").css("font-size", Std.string(fontSize - 2) + "px");
		Editor.editor.refresh();
	}
	
}