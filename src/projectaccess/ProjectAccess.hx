package projectaccess;
import js.node.Fs;
import js.node.Path;
import js.atomshell.browser.BrowserWindow;
import cm.Editor;
import tabmanager.TabManager;
import core.Helper;
import haxe.Json;
import js.Browser;
import js.Node;
import projectaccess.Project.TargetData;
import projectaccess.Project.FileData;
import tjson.TJSON;

/**
 * ...
 * @author AS3Boyan
 */
class ProjectAccess
{
	public static var currentProject:Project = new Project();
	
	public static var path:String;
	
	public static function registerSaveOnCloseListener():Void
	{
		var window = BrowserWindow.getAllWindows()[0];
		
		var tabManagerInstance = TabManager.get();
		
		window.on("close", function ():Void 
		{
			if (currentProject != null && tabManagerInstance.getCurrentDocumentPath() != null)
			{
				Editor.saveFoldedRegions();
			}
			
			save(null, true);
			window.close();
			
		});
	}
	
	public static function save(?onComplete:Dynamic, ?sync:Bool = false):Void
	{
		if (ProjectAccess.path != null)
		{
			Editor.saveFoldedRegions();
			
			var pathToProjectHide:String = Path.join(ProjectAccess.path, "project.hide");
			
			var data:String = TJSON.encode(ProjectAccess.currentProject, 'fancy');
			
			if (sync) 
			{
				Fs.writeFileSync(pathToProjectHide, data, "utf8");
			}
			else 
			{
				Helper.debounce("saveProject", function ():Void 
				{
					Fs.writeFile(pathToProjectHide, data, "utf8", function (error)
					{
						if (onComplete != null)
						{
							onComplete();
						}
					}
					);
				}, 250);
			}
		}
		else 
		{
			trace("project path is null");
		}
	}
	
	public static function load(path:String, ?onComplete:Dynamic):Void
	{
		//trace(js.Node.parse());
	}
	
	public static function isItemInIgnoreList(path:String):Bool
	{        
		var ignore:Bool = false;
        
		if (ProjectAccess.path != null && !ProjectAccess.currentProject.showHiddenItems) 
		{
			var relativePath:String = Path.relative(ProjectAccess.path, path);
			
			if (ProjectAccess.currentProject.hiddenItems.indexOf(relativePath) != -1) 
			{
				ignore = true;
			}
		}
		
		return ignore;
	}
	
	public static function isItemHidden(path:String)
	{
		var relativePath:String = Path.relative(ProjectAccess.path, path);
		return ProjectAccess.currentProject.hiddenItems.indexOf(relativePath) != -1;
	}
	
	public static function hideItem(path:String)
	{
		var relativePath:String = Path.relative(ProjectAccess.path, path);
		ProjectAccess.currentProject.hiddenItems.push(relativePath);
	}
	
	public static function unhideItem(path:String)
	{
		var relativePath:String = Path.relative(ProjectAccess.path, path);
		ProjectAccess.currentProject.hiddenItems.push(relativePath);
	}
	
	public static function getPathToHxml():String
	{
		var pathToHxml:String = null;
					
		var project = ProjectAccess.currentProject;
		
		switch (project.type) 
		{
			case Project.HAXE:
				var targetData:TargetData = project.targetData[project.target];
				pathToHxml = targetData.pathToHxml;
			case Project.HXML:
				pathToHxml = project.main;
			default:
		}
		
		return pathToHxml;
	}
	
	public static function getFileByPath(path:String)
	{
		var selectedFile = null;
		
		if (ProjectAccess.path != null)
		{
			var relativePath:String = Path.relative(ProjectAccess.path, path);
		
			var project = ProjectAccess.currentProject;
		
			selectedFile = Lambda.find(project.files, function (file:FileData)
				{
					return file.path == relativePath;
				});
		}
		
		return selectedFile;
	}
}