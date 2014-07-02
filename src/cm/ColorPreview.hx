package cm;
import core.Completion;
import jQuery.JQuery;
import js.Browser;
import js.html.DivElement;
import js.html.KeyboardEvent;
import js.html.TextAreaElement;
import js.Node;
import tabmanager.TabManager;

/**
 * ...
 * @author AS3Boyan
 */
class ColorPreview
{
	static var preview:DivElement;
	static var startScroll:Dynamic;
	static var top:Int = 0;
	static var left:Int = 0;
	static var wordStart:CodeMirror.Pos;
	static var wordEnd:CodeMirror.Pos;
	static var startingFormat:String;
	static var isColorPickerShown:Bool;
	static var applyChanges:Bool;
	static var startingColor:String;

	public static function create(cm:CodeMirror):Void 
	{
		preview = cast(Browser.document.getElementsByClassName("colorPreview")[0], DivElement);
		startScroll = cm.getScrollInfo();
		
		untyped new JQuery(".colorPreview").spectrum( 
		{ 
			showButtons: false,
			
			show: function ():Void 
			{
				isColorPickerShown = true;
				applyChanges = true;
				untyped new JQuery(".colorPreview").spectrum("set", preview.style.backgroundColor);
			},
			
			hide: function ():Void 
			{
				isColorPickerShown = false;
			},
			
			change: function (color):Void 
			{
				if (applyChanges) 
				{
					var colorString = color.toHex();
					cm.replaceRange(startingFormat + colorString, wordStart, wordEnd);
				}
				else 
				{
					preview.style.backgroundColor = startingColor;
				}
			},
			
			move: function (color):Void 
			{
				var colorString = color.toHex();
				preview.style.backgroundColor = "#" + colorString;
			}
		} 
		);
		
		Browser.window.onkeyup = function (e:KeyboardEvent):Void 
		{
			applyChanges = false;
			
			if (e.keyCode == 27 && preview.style.display != "none") 
			{
				untyped new JQuery(".colorPreview").spectrum("hide");
			}
		}
		
		new JQuery(Browser.document).click(function (e):Void 
		{
			if (!Std.is(Browser.document.activeElement, TextAreaElement))
			{
				applyChanges = false;
				new JQuery(preview).fadeOut(250);
				untyped new JQuery(".colorPreview").spectrum("hide");
			}
		}
		);
	}
	
	public static function update(cm:CodeMirror):Void 
	{
		var completionInstance = Completion.get();
		
		var wordData = completionInstance.getCurrentWord(cm, { word:~/[A-Fx0-9#]+$/i }, cm.getCursor());
		
		var word = wordData.word;
		var color:String = null;
		
		if (word != null && word.length > 2) 
		{
			if (!isColorPickerShown) 
			{
				wordStart = wordData.from;
				wordEnd = wordData.to;
				
				if (StringTools.startsWith(word, "0x")) 
				{
					color = word.substr(2);
					startingFormat = "0x";
				}
				else if (StringTools.startsWith(word, "#"))
				{
					color = word.substr(1);
					startingFormat = "#";
				}
				
				if (color != null) 
				{
					startScroll = cm.getScrollInfo();
					var pos = cm.cursorCoords(null);
					top = pos.bottom;
					left = pos.left;
					startingColor = "#" + color;
					preview.style.backgroundColor = startingColor;
					new JQuery(preview).animate( { left: Std.string(pos.left) + "px", top: Std.string(pos.bottom) + "px" } );
					
					if (preview.style.display == "none")
					{
						new JQuery(preview).fadeIn(250);
					}
				}
				else 
				{
					new JQuery(preview).fadeOut(250);
				}
			}
		}
		else 
		{
			new JQuery(preview).fadeOut(250);
			untyped new JQuery(".colorPreview").spectrum("hide");
		}
	}
	
	public static function scroll(cm:CodeMirror):Void 
	{
		if (preview.style.display != "none") 
		{			
			var curScroll = cm.getScrollInfo();
			var editor = cm.getWrapperElement().getBoundingClientRect();
			var newTop = top + startScroll.top - curScroll.top;
			
			var point = newTop - new JQuery().scrollTop();
			if (point <= editor.top || point >= editor.bottom)
			{
				new JQuery(preview).fadeOut(250);
				return;
			}
			
			preview.style.top = newTop + "px";
			preview.style.left = (left + startScroll.left - curScroll.left) + "px";
		}
	}
	
}