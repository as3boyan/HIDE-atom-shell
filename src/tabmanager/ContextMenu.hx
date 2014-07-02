package tabmanager;
import js.atomshell.browserandwebpage.Shell;
import cm.CMDoc;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.LIElement;
import js.html.MouseEvent;
import js.html.UListElement;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */
class ContextMenu
{	
	static var contextMenu:DivElement;
	
	public static function createContextMenu():Void
	{
		contextMenu = Browser.document.createDivElement();
		contextMenu.className = "dropdown";
		contextMenu.style.position = "absolute";
		contextMenu.style.display = "none";
		
		Browser.document.addEventListener("click", function (e:MouseEvent)
		{
			contextMenu.style.display = "none";
		}
		);
		
		var tabManager = TabManager.get();
		
		var ul:UListElement = Browser.document.createUListElement();
		ul.className = "dropdown-menu";
		ul.style.display = "block";
		
		ul.appendChild(createContextMenuItem("New File...", tabManager.createFileInNewTab));
		
		ul.appendChild(createDivider());
		
		ul.appendChild(createContextMenuItem("Close", function ()
		{
			tabManager.closeTab(contextMenu.getAttribute("path"));
		}
		));
		ul.appendChild(createContextMenuItem("Close All", function ()
		{
			tabManager.closeAll();
		}
		));
		
		ul.appendChild(createContextMenuItem("Close Other", function ()
		{
			var path = contextMenu.getAttribute("path");
			tabManager.closeOthers(path);
		}
		));
		
		ul.appendChild(createDivider());
		
		ul.appendChild(createContextMenuItem("Show Item In Folder", function ()
		{
			var path = contextMenu.getAttribute("path");
			Shell.showItemInFolder(path);
		}
		));
		
		contextMenu.appendChild(ul);
		
		Browser.document.body.appendChild(contextMenu);
	}
	
	public static function showMenu(path:String, e:MouseEvent):Void 
	{
		contextMenu.setAttribute("path", path);
		
		contextMenu.style.display = "block";
		contextMenu.style.left = Std.string(e.pageX) + "px";
		contextMenu.style.top = Std.string(e.pageY) + "px";
	}
	
	public static function createContextMenuItem(text:String, onClick:Dynamic):LIElement
	{
		var li:LIElement = Browser.document.createLIElement();
		li.onclick = function (e:MouseEvent):Void
		{
			onClick();
		};
		
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.href = "#";
		a.textContent = LocaleWatcher.getStringSync(text);
		li.appendChild(a);
		
		return li;
	}
	
	static function createDivider():LIElement
	{
		var li:LIElement = Browser.document.createLIElement();
		li.className = "divider";
		return li;
	}
}