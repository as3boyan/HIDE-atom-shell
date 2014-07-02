package dialogs;
import jQuery.JQuery;
import js.Browser;
import js.html.DivElement;
import js.html.HeadingElement;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */
class ModalDialog
{
	var modal:DivElement;
	var header:DivElement;
	var body:DivElement;
	var footer:DivElement;
	var h4:HeadingElement;

	public function new(?title:String) 
	{
		modal = Browser.document.createDivElement();
		modal.className = "modal fade";
		
		var dialog:DivElement = Browser.document.createDivElement();
		dialog.className = "modal-dialog";
		modal.appendChild(dialog);
		
		var content:DivElement = Browser.document.createDivElement();
		content.className = "modal-content";
		dialog.appendChild(content);
		
		header = Browser.document.createDivElement();
		header.className = "modal-header";
		content.appendChild(header);
		
		h4 = cast(Browser.document.createElement("h4"), HeadingElement);
		h4.className = "modal-title";
		
		if (title != null) 
		{
			setTitle(title);
		}
		
		header.appendChild(h4);
		
		body = Browser.document.createDivElement();
		body.className = "modal-body";
		body.style.overflow = "hidden";
		content.appendChild(body);
		
		footer = Browser.document.createDivElement();
		footer.className = "modal-footer";
		content.appendChild(footer);
		
		Browser.window.addEventListener("keyup", function (e)
		{
			if (e.keyCode == 27)
			{
				hide();
			}
		}
		);
		
		Browser.document.body.appendChild(modal);
	}
	
	public function setTitle(title:String):Void
	{
		//h4.setAttribute("localeString", title);
		//h4.textContent = LocaleWatcher.getStringSync(title);
		h4.textContent = title;
	}
	
	public function getHeader() 
	{
		return header;
	}
	
	public function getBody() 
	{
		return body;
	}
	
	public function getFooter() 
	{
		return footer;
	}
	
	public function getModal()
	{
		return modal;
	}
	
	public function show():Void
	{
		untyped new JQuery(modal).modal("show");
	}
	
	public function hide():Void
	{
		untyped new JQuery(modal).modal("hide");
	}
	
}