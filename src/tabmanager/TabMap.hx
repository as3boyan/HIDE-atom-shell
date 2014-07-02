package tabmanager;

/**
 * ...
 * @author AS3Boyan
 */
class TabMap
{
	var tabArray:Array<Tab>;

	public function new() 
	{
		tabArray = [];
	}
	
	public function get(path:String):Tab
	{
		var tab = null;
		
		for (t in tabArray) 
		{
			if (t.path == path) 
			{
				tab = t;
				break;
			}
		}
		
		return tab;
	}
	
	public function exists(path:String):Bool
	{
		var exists:Bool = false;
		
		for (t in tabArray) 
		{
			if (t.path == path) 
			{
				exists = true;
				break;
			}
		}
		
		return exists;
	}
	
	function getIndex(path:String):Int
	{
		var index:Int = -1;
		
		for (i in 0...tabArray.length) 
		{
			if (tabArray[i].path == path) 
			{
				index = i;
				break;
			}
		}
		
		return index;
	}
	
	public function getPrevious(path:String):Tab
	{
		var index = getIndex(path);
		index--;
		
		if (index < 0) 
		{
			index = tabArray.length - 1;
		}
		
		return tabArray[index];
	}
	
	public function getNext(path:String):Tab
	{
		var index = getIndex(path);
		index++;
		
		if (index > tabArray.length - 1) 
		{
			index = 0;
		}
		
		return tabArray[index];
	}
	
	public function add(tab:Tab):Void
	{
		tabArray.push(tab);
	}
	
	public function remove(path:String):Void 
	{
		tabArray.splice(getIndex(path), 1);
	}
	
	public function keys():Array<String>
	{
		var keys:Array<String> = [];
		
		for (t in tabArray) 
		{
			keys.push(t.path);
		}
		
		return keys;
	}
	
	public function getTabs():Array<Tab>
	{
		return tabArray;
	}
	
}