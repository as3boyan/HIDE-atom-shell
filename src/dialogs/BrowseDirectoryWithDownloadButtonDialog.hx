package dialogs;
import js.atomshell.browserandwebpage.Shell;
import bootstrap.ButtonManager;
import js.html.ButtonElement;

/**
 * ...
 * @author AS3Boyan
 */
class BrowseDirectoryWithDownloadButtonDialog extends BrowseDirectoryDialog
{
	var downloadButton:ButtonElement;

	public function new(?title:String) 
	{
		super(title);
		
		var buttonManager = ButtonManager.get();
		
		downloadButton = buttonManager.createButton("Download");
		
		inputGroupButton.getSpan().appendChild(downloadButton);
	}
	
	public function setDownloadButtonOptions(text:String, url:String)
	{
		downloadButton.textContent = text;
		
		downloadButton.onclick = function (e):Void 
		{
			Shell.openExternal(url);
		};
	}
	
}