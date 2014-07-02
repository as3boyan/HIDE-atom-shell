package core;
import js.atomshell.browser.BrowserWindow;
import js.atomshell.browser.Dialog;
import js.Browser;
import js.html.InputElement;

/**
 * ...
 * @author AS3Boyan
 */
class FileDialog
{
	static var input:InputElement;
	static var onClick:String->Void;
	
	public static function create():Void
	{
// 		input = Browser.document.createInputElement();
// 		input.type = "file";
// 		input.style.display = "none";
// 		input.addEventListener("change", function(e) 
// 		{
// 			var value:String = input.value;
// 			if (value != "") 
// 			{
// 				onClick(value);
// 			}
// 		});
		
// 		Browser.document.body.appendChild(input);
	}
	
	public static function openFile(_onClick:String->Void, ?extensions:String):Void
	{
// 		input.value = "";
		
// 		onClick = _onClick;
		
// 		if (input.hasAttribute("nwsaveas"))
// 		{
// 			input.removeAttribute("nwsaveas");
// 		}
		
// 		if (input.hasAttribute("nwdirectory"))
// 		{
// 			input.removeAttribute("nwdirectory");
// 		}
		
// 		if (extensions != null) 
// 		{
// 			input.setAttribute("accept", extensions);
// 		}
// 		else 
// 		{
// 			input.removeAttribute("accept");
// 		}
		
// 		input.click();
		
		var options:DialogOpenOptions = {};
		options.title = "Open File";
		options.properties = [];
		options.properties.push(DialogOptionsProperty.OPEN_FILE);
		
		Dialog.showOpenDialog(BrowserWindow.getAllWindows()[0], options, function (filenames)
		{
			if (filenames != null)
			{
				trace(filenames);
				_onClick(filenames[0]);
			}

		});
	}
	
	public static function saveFile(_onClick:String->Void, ?_name:String):Void
	{
// 		input.value = "";
		
// 		onClick = _onClick;
		
// 		if (_name == null)
// 		{
// 			_name = "";
// 		}
		
// 		if (input.hasAttribute("nwdirectory"))
// 		{
// 			input.removeAttribute("nwdirectory");
// 		}
		
// 		input.setAttribute("nwsaveas", _name);
// 		input.click();
		
		var options:DialogSaveOptions = {};
		options.title = "Save As";
		
		Dialog.showSaveDialog(BrowserWindow.getAllWindows()[0], options, function (filename)
		{
			if (filename != null)
			{
				_onClick(filename);
			}

		}); 
	}
	
	public static function openFolder(_onClick:String->Void):Void
	{
// 		input.value = "";
		
// 		onClick = _onClick;
		
// 		if (input.hasAttribute("nwsaveas"))
// 		{
// 			input.removeAttribute("nwsaveas");
// 		}
		
// 		input.setAttribute("nwdirectory", "");
// 		input.click();
		
		var options:DialogOpenOptions = {};
		options.title = "Open Folder";
		options.properties = [];
		options.properties.push(DialogOptionsProperty.OPEN_DIRECTORY);
		
		Dialog.showOpenDialog(BrowserWindow.getAllWindows()[0], options, function (filenames)
		{
			if (filenames != null)
			{
				trace(filenames);
				_onClick(filenames[0]);
			}

		});
	}
	
}