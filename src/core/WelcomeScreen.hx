package core;
import js.atomshell.browserandwebpage.Shell;
import jQuery.JQuery;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.HeadingElement;
import js.html.LIElement;
import js.html.NodeList;
import js.html.UListElement;
import js.Node;
import newprojectdialog.NewProjectDialog;
import openproject.OpenProject;

/**
 * ...
 * @author AS3Boyan
 */
class WelcomeScreen
{
	static var instance:WelcomeScreen;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new WelcomeScreen();
		}
			
		return instance;
	}
	
	var div:DivElement;
	
	public function load():Void
	{		
		div = cast(Browser.document.getElementById("welcomeScreen"), DivElement);
		
		new JQuery("#createNewProject").on("click", NewProjectDialog.show);
		
		new JQuery("#openProject").on("click", OpenProject.openProject.bind(null, true));
		
		var links:NodeList = Browser.document.getElementsByClassName("welcome-screen-link");
		
		for (i in 0...links.length) 
		{
			var link = cast(links.item(i), LIElement);
			link.onclick = function (e):Void 
			{
				for (j in 0...links.length) 
				{
					var link2 = cast(links.item(j), LIElement);
					
					if (link2 != link) 
					{
						link2.classList.remove("active");
						
						new JQuery("#welcomeScreenPage" + Std.string(j + 1)).hide(0);
					}
					else 
					{
						link2.classList.add("active");
						
						new JQuery("#welcomeScreenPage" + Std.string(j + 1)).fadeIn(250);
					}
				}
			};
		}
		
		new JQuery("#github").on("click", Shell.openExternal.bind("https://github.com/as3boyan/HIDE"));
		new JQuery("#as3boyan").on("click", Shell.openExternal.bind("http://twitter.com/As3Boyan"));
	}
	
	function createListElement(text:String, onClick:Dynamic)
	{
		var li:LIElement = Browser.document.createLIElement();
		
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.href = "#";
		a.textContent = text;
		a.onclick = function (e):Void 
		{
			onClick();
		};
		
		li.appendChild(a);
		
		return li;
	}
	
	public function show():Void
	{
		new JQuery(div).fadeIn(250);
	}
	
	public function hide():Void
	{
		new JQuery(div).fadeOut(250);
	}
}