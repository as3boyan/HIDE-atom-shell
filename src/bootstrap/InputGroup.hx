package bootstrap;
import js.Browser;
import js.html.DivElement;
import js.html.InputElement;

/**
 * ...
 * @author AS3Boyan
 */
class InputGroup
{
	var inputGroup:DivElement;
	var input:InputElement;

	public function new() 
	{
		inputGroup = Browser.document.createDivElement();
		inputGroup.className = "input-group";
		
		input = Browser.document.createInputElement();
		input.type = "text";
		input.className = "form-control";
		inputGroup.appendChild(input);
	}
	
	public function getInput():InputElement 
	{
		return input;
	}
	
	public function getElement():DivElement
	{
		return inputGroup;
	}
	
	
}