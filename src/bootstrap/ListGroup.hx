package bootstrap;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.HeadingElement;
import js.html.ParagraphElement;

/**
 * ...
 * @author AS3Boyan
 */
class ListGroup
{
	var listGroup:DivElement;
	var items:Array<AnchorElement> = [];

	public function new() 
	{
		listGroup = Browser.document.createDivElement();
		listGroup.className = "list-group";
	}

	public function addItem(text:String, description:String, ?onClick:Dynamic)
	{
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.href = "#";
		a.className = "list-group-item";
		
		if (onClick != null) 
		{
			a.onclick = onClick;
		}
		
		var h4:HeadingElement = cast(Browser.document.createElement("h4"), HeadingElement);
		h4.className = "list-group-item-heading";
		h4.textContent = text;
		a.appendChild(h4);
		
		var p:ParagraphElement = Browser.document.createParagraphElement();
		p.className = "list-group-item-text";
		p.textContent = description;
		a.appendChild(p);
		
        items.push(a);
		listGroup.appendChild(a);
	}
	
    public function clear():Void
    {
        //http://jsperf.com/removechildren/8
        
        var len = listGroup.childNodes.length;
        
        while (len-- > 0) 
        {
        	listGroup.removeChild(listGroup.lastChild);
        };
        
        items = [];
    }
    
    public function getItems():Array<AnchorElement>
    {
        return items;
    }
    
	public function getElement():DivElement
	{
		return listGroup;
	}
	
}