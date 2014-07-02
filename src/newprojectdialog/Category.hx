package newprojectdialog;
import haxe.ds.StringMap.StringMap;
import js.html.AnchorElement;
import js.html.LIElement;
import jQuery.JQuery;

/**
 * ...
 * @author AS3Boyan
 */
class Category
{
	public var element:LIElement;
	public var items:Array<Item>;
	public var subcategories:StringMap<Category>;
	public var position:Int;
	public var name:String;
	public var parent:Category;
	
	public function new(_name:String, _element:LIElement) 
	{
		element = _element;
		subcategories = new StringMap();
		items  = new Array();
		name = _name;
	}
	
	public function getCategory(name:String):Category
	{
		if (!subcategories.exists(name))
		{
			NewProjectDialog.createSubcategory(name, this);
		}
		
		return subcategories.get(name);
	}
	
	public function addItem(name:String, ?createProjectFunction:Dynamic, ?showCreateDirectoryOption:Bool = true, ?nameLocked:Bool = false):Void
	{
		items.push(new Item(name, createProjectFunction, showCreateDirectoryOption, nameLocked));
		NewProjectDialog.loadProjectCategory();
	}
	
	public function getItems():Array<String>
	{
		var itemNames:Array<String> = new Array();
				
		for (item in items)
		{
			itemNames.push(item.name);
		}
		
		return itemNames;
	}
	
	public function select(?item:String):Void
	{
		NewProjectDialog.updateListItems(this, item);
	}
	
	public function getItem(name:String):Item
	{
		var currentItem:Item = null;
		
		for (item in items)
		{
			if (name == item.name)
			{
				currentItem = item;
			}
		}
		
		return currentItem;
	}
	
	public function setPosition(_position:Int):Void
	{
		position = _position;
	}
	
	public function getElement():LIElement
	{
		return element;
	}
}