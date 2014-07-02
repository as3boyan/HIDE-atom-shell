package core;
import js.atomshell.browser.BrowserWindow;
import bootstrap.ButtonManager;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.MouseEvent;
import menu.BootstrapMenu;
import openproject.OpenProject;
import tabmanager.TabManager;
import tjson.TJSON;

/**
 * ...
 * @author AS3Boyan
 */
class RecentProjectsList
{
	var projectList:Array<String> = [];
	var fileList:Array<String> = [];

	static var instance:RecentProjectsList;
	
	public static function get():RecentProjectsList
	{
		if (instance == null)
		{
			instance = new RecentProjectsList();
		}
			
		return instance;
	}
	
	public function new()
	{
		var localStorage2 = Browser.getLocalStorage();
		
		if (localStorage2 != null) 
		{
			var recentProjectsData:String = localStorage2.getItem("recentProjects");
			var recentFilesData:String = localStorage2.getItem("recentFiles");
			var recentFilesData:String = localStorage2.getItem("recentFiles");
			
			if (recentProjectsData != null) 
			{
				try 
				{
					projectList = TJSON.parse(recentProjectsData);
				}
				catch (unknown:Dynamic)
				{
					trace(unknown);
				}
			}
			
			if (recentFilesData != null) 
			{
				try 
				{
					fileList = TJSON.parse(recentFilesData);
				}
				catch (unknown:Dynamic)
				{
					trace(unknown);
				}
			}
		}
		
		BrowserWindow.getAllWindows()[0].on("close", function ():Void 
		{
			localStorage2.setItem("recentProjects", TJSON.encode(projectList));
			localStorage2.setItem("recentFiles", TJSON.encode(fileList));
		}
		);
		
		updateMenu();
		updateWelcomeScreen();
		updateRecentFileMenu();
	}
	
	public function add(path:String):Void
	{
		addItemToList(projectList, path);
		
		updateMenu();
		updateWelcomeScreen();
	}
	
	public function addFile(path:String):Void
	{
		addItemToList(fileList, path);
		updateRecentFileMenu();
	}
	
	function addItemToList(list:Array<String>, item:String):Void 
	{
		if (list.indexOf(item) == -1) 
		{
			if (list.length >= 10) 
			{
				list.pop();
			}
		}
		else 
		{
			list.remove(item);
		}
		
		list.insert(0, item);
	}
	
	function updateMenu():Void
	{
		var submenu = BootstrapMenu.getMenu("File").getSubmenu("Open Recent Project");
		submenu.clear();
		
		for (i in 0...projectList.length) 
		{
			submenu.addMenuItem(projectList[i], i + 1, OpenProject.openProject.bind(projectList[i]));
		}
		
// 		var submenu = BootstrapMenu.getMenu("Project").getSubmenu("Build Recent Project");
// 		submenu.clear();
		
// 		for (i in 0...projectList.length) 
// 		{
// 			submenu.addMenuItem(projectList[i], i + 1, RunProject.buildProject.bind(projectList[i]));
// 		}
	}
	
	function updateWelcomeScreen():Void
	{
		var listGroup:DivElement = cast(Browser.document.getElementById("recentProjectsList"), DivElement);
		
		while (listGroup.firstChild != null) 
		{
			listGroup.removeChild(listGroup.firstChild);
		}
		
		for (i in 0...projectList.length) 
		{
			var a:AnchorElement = Browser.document.createAnchorElement();
			a.href = "#";
			a.className = "list-group-item recentProject";
			a.textContent = projectList[i];
			a.onclick = function (e):Void 
			{
				OpenProject.openProject(projectList[i]);
			};
			
// 			var buildButton = ButtonManager.createButton("Build");
// 			buildButton.classList.add("buildButton");
			
// 			buildButton.onclick	= function (e:MouseEvent):Void 
// 			{
// 				e.stopPropagation();
// 				e.preventDefault();
				
// 				RunProject.buildProject(projectList[i]);
// 			};
			
// 			a.appendChild(buildButton);
			
			listGroup.appendChild(a);
		}
	}
	
	function updateRecentFileMenu():Void
	{
		var submenu = BootstrapMenu.getMenu("File").getSubmenu("Open Recent File");
		submenu.clear();
		
		for (i in 0...fileList.length) 
		{
			 var tabManagerInstance = TabManager.get();
			 submenu.addMenuItem(fileList[i], i + 1, tabManagerInstance.openFileInNewTab.bind(fileList[i]));
		}
	}
}