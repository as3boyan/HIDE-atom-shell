package menu;
import jQuery.JQuery;
import haxe.ds.StringMap.StringMap;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.UListElement;
import js.html.Element;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */

//@:expose makes this class available in global scope
//@:keepSub prevents -dce full from deleting unused functions, so they still can be used in other plugins
//more info about meta tags can be obtained at Haxe website: 
//http://haxe.org/manual/tips_and_tricks
class BootstrapMenu
{
	static var menus:StringMap<Menu> = new StringMap();
	static var menuArray:Array<Menu> = new Array();
		
	public static function createMenuBar():Void
	{
		//We use overflow: hidden; to hide window scrollbars
		Browser.document.body.style.overflow = "hidden";
			
		var navbar:DivElement = Browser.document.createDivElement();
		navbar.className = "navbar navbar-default navbar-inverse navbar-fixed-top";
		
		var navbarHeader:DivElement = Browser.document.createDivElement();
		navbarHeader.className = "navbar-header";
		navbar.appendChild(navbarHeader);
		
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.className = "navbar-brand";
		a.href = "#";
		a.innerText = LocaleWatcher.getStringSync("HIDE");
		a.setAttribute("localeString", "HIDE");
		
		navbarHeader.appendChild(a);
			
		var div:DivElement = Browser.document.createDivElement();
		div.className = "navbar-collapse collapse";
		
		var ul:UListElement = Browser.document.createUListElement();
		ul.id = "position-navbar";
		ul.className = "nav navbar-nav";
			
		div.appendChild(ul);
				
		navbar.appendChild(div);
		
		Browser.document.body.appendChild(navbar);
	}
	
	public static function getMenu(name:String, ?position:Int):Menu
	{
		var menu:Menu;

		if (!menus.exists(name))
		{
			menu = new Menu(name);

			menu.setPosition(position);

			addMenuToDocument(menu);

			menus.set(name, menu);
			
			new JQuery(Browser.window.document).on("mouseenter", "#position-navbar .dropdown", function (e)
												   {
													   var self = untyped __js__("this");
													   
													    var open = new JQuery(self).siblings(".open");
														if (open.length > 0) {
															open.removeClass("open");
															new JQuery(self).addClass("open");
														}
												   }
												  );
		}
		else
		{
			menu = menus.get(name);

			if (position != null && menu.position != position)	
			{
				menu.removeFromDocument();
				menus.remove(name);

				menu.setPosition(position);

				addMenuToDocument(menu);

				menus.set(name, menu);
			}
		}
		
		return menu;
	}

	public static function addMenuToDocument(menu:Menu):Void
	{
		var div:Element = cast(Browser.document.getElementById("position-navbar"), Element);

		if (menu.position != null && menuArray.length > 0 && div.childNodes.length > 0)
		{
			var currentMenu:Menu;

			var added:Bool = false;

			for (i in 0...menuArray.length)
			{
				currentMenu = menuArray[i];

				if (currentMenu != menu && currentMenu.position == null || menu.position < currentMenu.position)
				{
					div.insertBefore(menu.getElement(), currentMenu.getElement());
					menuArray.insert(i, menu);
					added = true;
					break;
				}
			}

			if (!added)
			{
				menu.addToDocument();
				menuArray.push(menu);
			}
		}
		else
		{
			menu.addToDocument();
			menuArray.push(menu);
		}
	}
}