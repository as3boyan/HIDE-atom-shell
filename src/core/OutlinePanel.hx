package core;
import cm.HighlightRange;
import haxe.Timer;
import parser.OutlineHelper;
import cm.Editor;
import jQuery.JQuery;

/**
 * ...
 * @author AS3Boyan
 */

typedef TreeItem = {
	var label:String;
    @:optional var icon:String;
	@:optional var items:Array<TreeItem>;
	@:optional var expanded:Bool;
	@:optional var value:Dynamic;
}
 
class OutlinePanel
{
	static var instance:OutlinePanel;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new OutlinePanel();
		}
			
		return instance;
	}
	
	var source:Array<TreeItem> = [];
	
	public function update():Void
	{
		untyped new JQuery("#outline").jqxTree( { source: source } );
		
		new JQuery('#outline').dblclick(function (event):Void 
		{
			var item = untyped new JQuery('#outline').jqxTree('getSelectedItem');
			
			var value:DeclarationPos = item.value;
			
			var cm2 = Editor.editor;
			
			if (value != null) 
			{
				var pos = cm2.posFromIndex(value.min);
				var pos2 = cm2.posFromIndex(value.max);
				var line = pos.line;
				
				cm2.centerOnLine(line);
				cm2.focus();
				cm2.setCursor(pos2);
				
				var highlightRange = HighlightRange.get();
				highlightRange.highlight(cm2, pos, pos2);
			}
		}
		);
	}
	
	public function addField(item:TreeItem):Void
	{
		source.push(item);
	}
	
	public function clearFields():Void 
	{
		source = [];
	}
}