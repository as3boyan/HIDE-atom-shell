package completion;
import cm.HighlightRange;
import tabmanager.TabManager;
import CodeMirror.Pos;
import cm.Editor;
import core.Completion;

/**
* @author 
 */
class GoToDeclaration
{
	static var instance:GoToDeclaration = null;
	
	public function new()
	{
			
	}
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new GoToDeclaration();
		}
		
		return instance;
	}
	
	public function start()
	{
		var ereg = ~/([^:\n\r]+):([0-9]+): (lines|characters) ([0-9]+)-([0-9]+)/g;
		
		var cm = Editor.editor;
		
		var completionInstance = Completion.get();
		
		completionInstance.getCompletion(function ()
								 {
									 if (completionInstance.declarationPositions.length > 0)
									 {
										 var posData = completionInstance.declarationPositions[0];
										 
										 if (ereg.match(posData))
										 {
											 var path = ereg.matched(1);
											 var line = Std.parseInt(ereg.matched(2)) - 1;
											 var posType = ereg.matched(3);
											 var from = Std.parseInt(ereg.matched(4));
											 var to = Std.parseInt(ereg.matched(5));
											 
											 var from2:Pos = null;
											 var to2:Pos = null;
											 
											 if (posType == "lines")
											 {
												 from2 = {line: from - 1, ch: 0};
												 to2 = {line: to, ch: 0};
											 }
											 else if (posType == "characters")
											 {
												 from2 = {line: line, ch: from};
												 to2 = {line: line, ch: to};
											 }
												 
											 if (from2 != null && to2 != null)
											 {
												 var tabManagerInstance = TabManager.get();

												 tabManagerInstance.openFileInNewTab(path, true, function ():Void 
												 {
													 var cm = Editor.editor;
													 cm.centerOnLine(from2.line);
													 cm.focus();
													 cm.setCursor(to2);
													 
													 var highlightRange = HighlightRange.get();
													 highlightRange.highlight(cm, from2, to2);
												 });
											 }
											 else
											 {
												 Alertify.error("Go To Declaration data parsing failed.");
											 }

										 }
									 }
								 }
								, cm.getCursor(), "position", false);
	}


}
