package bootstrap;
import js.Browser;
import js.html.ButtonElement;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */
class ButtonManager
{
	static var instance:ButtonManager = null;
	
	public function new()
	{
			
	}
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new ButtonManager();
		}
		
		return instance;
	}
	
	public function createButton(text:String, ?disabled:Bool = false, ?hide:Bool = false, ?primary:Bool = false):ButtonElement
	{
		var button = Browser.document.createButtonElement();
		button.type = "button";
		
		if (primary) 
		{
			button.className = "btn btn-primary";
		}
		else 
		{
			button.className = "btn btn-default";
		}
		
		button.setAttribute("localeString", text);
		button.textContent = LocaleWatcher.getStringSync(text);
		
		if (disabled) 
		{
			button.classList.add("disabled");
		}
		
		if (hide) 
		{
			button.setAttribute("data-dismiss", "modal");
		}
		
		return button;
	}
}