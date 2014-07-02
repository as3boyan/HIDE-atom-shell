package core;
import js.Browser;
import js.html.TextAreaElement;

/**
 * ...
 * @author AS3Boyan
 */
class CompilationOutput
{
	public static function load():Void
	{		
		var output:TextAreaElement = Browser.document.createTextAreaElement();
		output.id = "outputTextArea";
		output.readOnly = true;
		
		new jQuery.JQuery("#output").append(output);
	}
	
}