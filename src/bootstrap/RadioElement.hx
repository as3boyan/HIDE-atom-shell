package bootstrap;
import js.Browser;
import js.html.DivElement;
import js.html.InputElement;
import js.html.LabelElement;

/**
 * ...
 * @author AS3Boyan
 */
class RadioElement
{
	var element:DivElement;
	var input:InputElement;

	public function new(_name:String, _value:String, _text:String, ?_onChange:Dynamic) 
	{
		element = Browser.document.createDivElement();
		element.className = "radio";
		
		var label:LabelElement = Browser.document.createLabelElement();
		element.appendChild(label);
		
		input = Browser.document.createInputElement();
		input.type = "radio";
		input.name = _name;
		input.value = _value;
		
		input.onchange = function (e):Void 
		{
			if (_onChange != null) 
			{
				_onChange();
			}
		};
		
		label.appendChild(input);
		
		label.appendChild(Browser.document.createTextNode(_text));
		
		element.appendChild(label);
	}
	
	public function getInput():InputElement
	{
		return input;
	}
	
	public function getElement():DivElement
	{
		return element;
	}
	
}