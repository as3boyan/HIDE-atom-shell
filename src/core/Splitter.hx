package core;
import jQuery.JQuery;
import tabmanager.TabManager;

/**
 * ...
 * @author AS3Boyan
 */
class Splitter
{
	var visible:Bool;
	
	static var instance:Splitter;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new Splitter();
		}
			
		return instance;
	}
	
	public function load():Void
	{
		hide();
	}
	
	public function show():Void
	{
		if (visible == false) 
		{
			visible = true;
		
			//untyped new JQuery('#mainSplitter').jqxSplitter('enable');
			untyped new JQuery('#mainSplitter').jqxSplitter({ resizable: true });
			untyped new JQuery('#mainSplitter').jqxSplitter('expand');
			untyped new JQuery('#mainSplitter').jqxSplitter( { showSplitBar: true } );
			
			//untyped new JQuery('#thirdNested').jqxSplitter('enable');
			untyped new JQuery('#thirdNested').jqxSplitter({ resizable: true });
			
			var panels:Array<Dynamic> = [{size:"85%"}, {size:"15%"}];
			panels[0].collapsible = false;
			panels[1].collapsible = true;
			untyped new JQuery('#thirdNested').jqxSplitter({ panels: panels });         
			
			untyped new JQuery('#thirdNested').jqxSplitter('expand');
			untyped new JQuery('#thirdNested').jqxSplitter( { showSplitBar: true } );
			new JQuery("#annotationRuler").fadeIn(250);
			
			var welcomeScreen = WelcomeScreen.get();
			welcomeScreen.hide();
		}
	}
	
	public function hide():Void
	{
		visible = false;
		
		var panels:Array<Dynamic> = [{size:170}, {size:170}];
		panels[0].collapsible = true;
		panels[1].collapsible = false;
		untyped new JQuery('#mainSplitter').jqxSplitter({ panels: panels });         
		untyped new JQuery('#mainSplitter').jqxSplitter('collapse');
		//untyped new JQuery('#mainSplitter').jqxSplitter('disable');
		untyped new JQuery('#mainSplitter').jqxSplitter( { resizable: false } );
		untyped new JQuery('#mainSplitter').jqxSplitter( { showSplitBar: false } );
		
		var panels:Array<Dynamic> = [{size:"85%"}, {size:"15%"}];
		panels[0].collapsible = false;
		panels[1].collapsible = true;
		untyped new JQuery('#thirdNested').jqxSplitter({ panels: panels });         
		untyped new JQuery('#thirdNested').jqxSplitter('collapse');
		//untyped new JQuery('#thirdNested').jqxSplitter('disable');
		untyped new JQuery('#thirdNested').jqxSplitter( { resizable: false } );
		untyped new JQuery('#thirdNested').jqxSplitter( { showSplitBar: false } );
		new JQuery("#annotationRuler").fadeOut(250);
		
		var tabManagerInstance = TabManager.get();
		
		if (tabManagerInstance.tabMap != null && tabManagerInstance.tabMap.getTabs().length == 0) 
		{
			var welcomeScreen = WelcomeScreen.get();
			welcomeScreen.show();
		}
	}
	
	public function isVisible():Bool
	{
		return visible;
	}
}