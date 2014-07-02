package menu;
import core.Hotkeys;
import haxe.ds.StringMap.StringMap;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.Element;
import js.html.LIElement;
import js.html.LinkElement;
import js.html.MouseEvent;
import js.html.NodeList;
import js.html.SpanElement;
import js.html.UListElement;
import js.Node;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */

interface MenuItem
{
	public function getElement():Element;
}

//@:keepSub prevents -dce full from deleting unused functions, so they still can be used in other plugins
//alternatively you can just remove -dce full flag from plugin.hxml
//more info about meta tags can be obtained at Haxe website: 
//http://haxe.org/manual/tips_and_tricks
class MenuButtonItem implements MenuItem
{	
	var li:LIElement;
	public var position:Int;
	
	public function new(_menu:String, _text:String, _onClickFunction:Dynamic, ?_hotkey:String = "", ?_submenu:Bool = false)
	{		
		var hotkeyText:String = _hotkey;
		
		var menuItem:String = _menu + "->" + _text;
		
		var span:SpanElement = Browser.document.createSpanElement();
        span.className = "hotkey";
		
		if (!_submenu) 
		{
			Hotkeys.add(menuItem, hotkeyText, span, _onClickFunction);
		}
		
		li = Browser.document.createLIElement();	
		li.classList.add("menu-item");
		
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.style.left = "0";
		
		//Do not translate submenu items
		if (!_submenu)
		{
			a.textContent = LocaleWatcher.getStringSync(_text);
			a.setAttribute("localeString", _text);
		}
		else 
		{
			a.textContent = _text;
		}
		
		if (_onClickFunction != null) 
		{
			a.onclick = function (e:js.html.MouseEvent)
			{                
				if (li.className != "disabled")
				{                    
					_onClickFunction();
				}
			};
		}
		
		a.innerText = _text;

		a.appendChild(span);
		
		li.appendChild(a);
	}
	
	public function getElement():LIElement
	{
		return li;
	}
}

//@:keepSub prevents -dce full from deleting unused functions, so they still can be used in other plugins
class Separator implements MenuItem
{
	var li:LIElement;
	
	public function new()
	{
		li = Browser.document.createLIElement();
		li.className = "divider";
	}
	
	public function getElement():Element
	{
		return li;
	}
}

class Submenu
{
	var ul:UListElement;
	var li:LIElement;
	var name:String;
	var parentMenu:String;
	
	public function new(_parentMenu:String, _name:String)
	{
		name = _name;
		parentMenu = _parentMenu;
		
		//http://stackoverflow.com/questions/18023493/bootstrap-3-dropdown-sub-menu-missing
		
		var li2:LIElement = Browser.document.createLIElement();
		li2.classList.add("menu-item");
		li2.classList.add("dropdown");
		li2.classList.add("dropdown-submenu");
		
		li = li2;
		
		ul = Browser.document.createUListElement();
		
		var a2:AnchorElement = Browser.document.createAnchorElement();
		a2.href = "#";
		a2.classList.add("dropdown-toggle");
		a2.setAttribute("data-toggle", "dropdown");
		a2.setAttribute("localeString", name);
		a2.textContent = name;
		a2.onclick = function (event:MouseEvent)
		{
            new jQuery.JQuery("li.menu-item.dropdown.dropdown-submenu.open").removeClass("open");
            
			// Avoid following the href location when clicking
			event.preventDefault(); 
			// Avoid having the menu to close when clicking
			event.stopPropagation(); 
			// If a menu is already open we close it
			//$('ul.dropdown-menu [data-toggle=dropdown]').parent().removeClass('open');
			// opening the one you clicked on
				
			if (ul.childElementCount > 0) 
			{
				li2.classList.add('open');

				var menu:UListElement = ul;
				var newpos:Int;
				
				if ((menu.offsetLeft + menu.clientWidth) + 30 > Browser.window.innerWidth) 
				{
					newpos = -menu.clientWidth;
				}
				else 
				{
					newpos = li2.clientWidth;
				}
				
				menu.style.left = Std.string(newpos) + "px";
			}
		}
		
		li2.appendChild(a2);
		
		ul.classList.add("dropdown-menu");
		li2.appendChild(ul);
	}
	
	public function addMenuItem(_text:String, _position:Int, _onClickFunction:Dynamic, ?_hotkey:String):Void
	{
		var menuButtonItem:MenuButtonItem = new MenuButtonItem(parentMenu + "->" + name, _text, _onClickFunction, _hotkey, true);
		ul.appendChild(menuButtonItem.getElement());
	}
	
	public function clear():Void 
	{
		while (ul.firstChild != null) 
		{
			ul.removeChild(ul.firstChild);
		}
	}
	
	public function getElement():Element
	{
		return li;
	}
}
 
//@:expose makes this class available in global scope
//@:keepSub prevents -dce full from deleting unused functions, so they still can be used in other plugins
class Menu
{
	var li:LIElement;
	var ul:UListElement;
	var items:Array<MenuButtonItem>;
	var name:String;
	var submenus:StringMap<Submenu>;
	public var position:Int;
	
	public function new(_text:String, ?_headerText:String) 
	{
		name = _text;
		
		li = Browser.document.createLIElement();
		li.className = "dropdown";
		
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.href = "#";
		a.className = "dropdown-toggle";
		a.setAttribute("data-toggle", "dropdown");
		a.innerText = LocaleWatcher.getStringSync(_text);
		a.setAttribute("localeString", _text);
		li.appendChild(a);
		
		ul = Browser.document.createUListElement();
		ul.className = "dropdown-menu";
		ul.classList.add("dropdown-menu-form");
		
		if (_headerText != null)
		{
			var li_header:LIElement = Browser.document.createLIElement();
			li_header.className = "dropdown-header";
			li_header.innerText = _headerText;
			ul.appendChild(li_header);
		}
		
		li.appendChild(ul);
		
		items = new Array();
		submenus = new StringMap();
	}
	
	public function addMenuItem(_text:String, _position:Int, _onClickFunction:Dynamic, ?_hotkey:String):Void
	{
		var menuButtonItem:MenuButtonItem = new MenuButtonItem(name, _text, _onClickFunction, _hotkey);
				
		menuButtonItem.position = _position;
		
		if (menuButtonItem.position != null && items.length > 0 && ul.childNodes.length > 0)
		{
			var currentMenuButtonItem:MenuButtonItem;

			var added:Bool = false;

			for (i in 0...items.length)
			{
				currentMenuButtonItem = items[i];

				if (currentMenuButtonItem != menuButtonItem && currentMenuButtonItem.position == null || menuButtonItem.position < currentMenuButtonItem.position)
				{
					ul.insertBefore(menuButtonItem.getElement(), currentMenuButtonItem.getElement());
					items.insert(i, menuButtonItem);
					added = true;
					break;
				}
			}

			if (!added)
			{
				ul.appendChild(menuButtonItem.getElement());
				items.push(menuButtonItem);
			}
		}
		else
		{
			ul.appendChild(menuButtonItem.getElement());
			items.push(menuButtonItem);
		}
	}
	
	public function addSeparator():Void
	{
		ul.appendChild(new Separator().getElement());
	}
	
	public function addSubmenu(_text:String):Submenu
	{
		var submenu = new Submenu(name, _text);
		ul.appendChild(submenu.getElement());
		submenus.set(_text, submenu);
		return submenu;
	}
	
	public function addToDocument():Void
	{	
		var div:Element = cast(Browser.document.getElementById("position-navbar"), Element);
		div.appendChild(li);
	}

	public function removeFromDocument():Void
	{
		li.remove();
	}

	public function setPosition(_position:Int):Void
	{
		position = _position;
	}
	
	public function setDisabled(menuItemNames:Array<String>):Void
	{
		var childNodes:NodeList = ul.childNodes;
		
		for (i in 0...childNodes.length)
		{
			var child:Element = cast(childNodes[i], Element);
			
			if (child.className != "divider")
			{				
				var a:AnchorElement = cast(child.firstChild, AnchorElement);
								
				if (Lambda.indexOf(menuItemNames, a.getAttribute("text")) == -1)
				{
					child.className = "";
				}
				else
				{
					child.className = "disabled";
				}
			}
		}
	}
	
	public function setMenuEnabled(enabled:Bool):Void
	{
		var childNodes:NodeList = ul.childNodes;
		
		for (i in 0...childNodes.length)
		{
			var child:Element = cast(childNodes[i], Element);
			
			if (child.className != "divider")
			{
				if (enabled)
				{
					child.className = "";
				}
				else
				{
					child.className = "disabled";
				}
			}
			
		}
	}
	
	public function getSubmenu(name:String):Submenu
	{
		if (!submenus.exists(name)) 
		{
			submenus.set(name, addSubmenu(name));
		}
		
		return submenus.get(name);
	}
	
	public function getElement():Element
	{
		return li;
	}
}