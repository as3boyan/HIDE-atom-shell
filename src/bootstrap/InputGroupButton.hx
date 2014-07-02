package bootstrap;
import js.Browser;
import js.html.ButtonElement;
import js.html.SpanElement;

/**
 * ...
 * @author AS3Boyan
 */
class InputGroupButton extends InputGroup
{
	var span:SpanElement;
	var button:ButtonElement;
	
	public function new(text:String) 
	{
		super();
		
		span = Browser.document.createSpanElement();
		span.className = "input-group-btn";
		
		var buttonManager = ButtonManager.get();
		
		button = buttonManager.createButton(text);
		span.appendChild(button);
		
		inputGroup.appendChild(span);
	}
	
	public function getSpan():SpanElement
	{
		return span;
	}
	
	public function getButton():ButtonElement
	{
		return button;
	}
	
}