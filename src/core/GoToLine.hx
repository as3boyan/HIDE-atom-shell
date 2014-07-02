package core;
import cm.Editor;
import tabmanager.TabManager;

/**
 * ...
 * @author AS3Boyan
 */
class GoToLine
{
	static var instance:GoToLine;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new GoToLine();
		}
			
		return instance;
	}
	
	public function show()
	{
		var tabManagerInstance = TabManager.get();
		
		if (tabManagerInstance.selectedPath != null) 
		{
			Alertify.prompt("Go to Line", function (e:Bool, str:String):Void 
			{
				var cm2 = Editor.editor;
				var lineNumber = Std.parseInt(str);
				cm2.centerOnLine(lineNumber);
				var highlightRange = cm.HighlightRange.get();
				
				var from = {line: lineNumber, ch: 0};
				var to = {line: lineNumber, ch: cm2.getLine(lineNumber).length};
				highlightRange.highlight(cm2, from, to);
			}
			);
		}
	}
}