package dialogs;
import bootstrap.ButtonManager;
import bootstrap.InputGroupButton;
import bootstrap.ListGroup;
import core.HaxeHelper;
import core.ProcessHelper;
import js.Browser;
import js.html.Event;

/**
 * ...
 * @author AS3Boyan
 */
class HaxelibManagerDialog extends ModalDialog
{
	var listGroup:ListGroup;

	public function new() 
	{
		super("haxelib manager");
		
		var inputGroupButton:InputGroupButton = new InputGroupButton("Search");
		
		getBody().appendChild(inputGroupButton.getElement());
		
		listGroup = new ListGroup();
		listGroup.getElement().id = "haxelibsList";
		
		HaxeHelper.getInstalledHaxelibList(function (data:Array<String>):Void 
		{
			for (item in data)
			{
				listGroup.addItem(item, "");
			}
		}
		);
		
		getBody().appendChild(listGroup.getElement());
		
		Browser.window.addEventListener("resize", function (e:Event):Void 
		{
			updateSize();
		}
		);
		
		var buttonManager = ButtonManager.get();
		
		getFooter().appendChild(buttonManager.createButton("OK", false, true, true));
		
		updateSize();
	}
	
	function updateSize():Void 
	{
		listGroup.getElement().style.height = Browser.window.innerHeight / 2 + "px";
	}
	
}