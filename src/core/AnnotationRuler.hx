package core;
import cm.Editor;
import jQuery.JQuery;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import tabmanager.TabManager;

/**
 * ...
 * @author AS3Boyan
 */
class AnnotationRuler
{
    var positions:Array<Float> = [];
    
	static var instance:AnnotationRuler = null;
	
	public function new()
	{
			
	}
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new AnnotationRuler();
		}
		
		return instance;
	}
	
	public function addErrorMarker(pathToFile:String, line:Int, ch:Int, message:String):Void 
	{
		var tabManagerInstance = TabManager.get();
		
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.href = "#";
		a.onclick = function (e):Void 
		{
			tabManagerInstance.openFileInNewTab(pathToFile, true, function ():Void 
			{
				var cm:Dynamic = Editor.editor;
				cm.centerOnLine(line);
			});
		};
		
		var div:DivElement = Browser.document.createDivElement();
		div.className = "errorMarker";
		
		var lineCount = tabManagerInstance.getCurrentDocument().lineCount();
		
        var targetLine:Float = line / lineCount * 100;
        
        while (positions.indexOf(targetLine) != -1)
        {
            targetLine++;
        }
        
		div.style.top = Std.string(targetLine) + "%";
		
        positions.push(targetLine);
        
		div.setAttribute("data-toggle", "tooltip");
		div.setAttribute("data-placement", "left");
		div.title = "Line: " + Std.string(line) + ":" + message;
		
		untyped new JQuery(div).tooltip({});
		
		a.appendChild(div);
		
		new JQuery("#annotationRuler").append(a);
	}
	
	public function clearErrorMarkers():Void 
	{
		new JQuery("#annotationRuler").children().remove();
        positions = [];
	}
}