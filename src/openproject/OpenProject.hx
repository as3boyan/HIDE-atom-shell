package openproject;
import haxe.Json;
import js.node.Fs.FsReadFileOpt;
import js.node.Fs;
import js.node.Path;
import core.ProcessHelper;
import projectaccess.Project.FileData;
import core.OutlinePanel;
import core.FileDialog;
import core.RecentProjectsList;
import core.Splitter;
import filetree.FileTree;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.xml.Fast;
import jQuery.JQuery;
import js.Browser;
import js.html.TextAreaElement;
import js.Node;
import openflproject.OpenFLTools;
import parser.ClasspathWalker;
import projectaccess.Project;
import projectaccess.ProjectAccess;
import projectaccess.ProjectOptions;
import tabmanager.TabManager;
import tjson.TJSON;

/**
 * ...
 * @author AS3Boyan
 */
class OpenProject
{	
	public static function openProject(?pathToProject:String, ?project:Bool = false):Void
	{
		if (pathToProject == null)
		{
			if (project) 
			{
				FileDialog.openFile(parseProject, ".hide,.lime,.xml,.hxml");
			}
			else 
			{
				FileDialog.openFile(parseProject);
			}
		}
		else 
		{
			checkIfFileExists(pathToProject);
		}
	}
	
	static function checkIfFileExists(path:String):Void
	{
		Fs.exists(path, function (exists:Bool)
		{
			if (exists) 
			{
				parseProject(path);
			}
			else 
			{
				trace("previously opened project: " + path + " was not found");
			}
		}
		);
	}
	
	static function parseProject(path:String):Void
	{	
		trace("open: " + path);
        
		var filename:String = Path.basename(path);
			
		var outlinePanel = OutlinePanel.get();
		var tabManagerInstance = TabManager.get();
		var fileTree = FileTree.get();
		var projectOptions = ProjectOptions.get();
		var recentProjectsList = RecentProjectsList.get();
		var splitter = Splitter.get();
		
		switch (filename) 
		{
			case "project.hide":	
				closeProject(true);
				
                outlinePanel.clearFields();
                outlinePanel.update();
                
				var options:FsReadFileOpt = { };
				options.encoding = "utf8";
				
				Fs.readFile(path, options, function (error, data:String):Void
				{
					var pathToProject:String = Path.dirname(path);
					
					ProjectAccess.currentProject = parseProjectData(data);
					ProjectAccess.path = pathToProject;
					
					var project = ProjectAccess.currentProject;
					
					var classpathWalker = ClasspathWalker.get();
					
					classpathWalker.parseProjectArguments();
					
                    var loadedFilesCount:Int = 0;
                    var totalFilesCount:Int;
                    
					if (project.files == null) 
					{
						project.files = [];
					}
					else 
					{
                        totalFilesCount = project.files.length;
                        
						for (i in 0...totalFilesCount)
						{
							if (Std.is(project.files[i], String))
							{
								project.files[i] = {path: untyped project.files[i]};
							}
						}
						
						for (file in project.files) 
						{
							var fullPath:String = Path.join(pathToProject, file.path);
                            
							Fs.exists(fullPath, function (exists:Bool) 
							{
								if (exists) 
								{
									tabManagerInstance.openFileInNewTab(fullPath, false, function ()
                                                               {
                                                                   loadedFilesCount++;
                                                                   
                                                                   if (loadedFilesCount == totalFilesCount)
                                                                   {
                                                                       	var activeFile = project.activeFile;
                                                                       
                                                                        if (activeFile != null) 
                                                                        {
                                                                            var fullPathToActiveFile:String = Path.join(pathToProject, activeFile);
                                                                            
                                                                            Fs.exists(fullPathToActiveFile, function (exists:Bool)
                                                                            {
                                                                                if (exists) 
                                                                                {
										    										trace(fullPathToActiveFile);
                                                                                    tabManagerInstance.selectDoc(fullPathToActiveFile);
                                                                                    cm.Editor.editor.focus();
                                                                                }
                                                                            }
                                                                            );
                                                                        }
                                                                   }
                                                               });
								}
							}
							);
						}
						
						
					}
					
					if (project.hiddenItems == null) 
					{
						project.hiddenItems = [];
					}
					
					if (project.showHiddenItems == null) 
					{
						project.showHiddenItems = false;
					}
					
					if (project.type == Project.OPENFL)
					{
						if (project.openFLBuildMode == null)
						{
							project.openFLBuildMode = "Debug";
						}
					}
						
					projectOptions.updateProjectOptions();
					fileTree.load(project.name, pathToProject);
					
					splitter.show();
					
					Browser.getLocalStorage().setItem("pathToLastProject", path);
					recentProjectsList.add(path);
				}
				);
			default:				
				var extension:String = Path.extname(filename);
		
				switch (extension) 
				{
					case ".hxml":
						closeProject(true);
						
                        outlinePanel.clearFields();
                        outlinePanel.update();
                        
						var pathToProject:String = Path.dirname(path);
						
						var project:Project = new Project();
						project.name = pathToProject.substr(pathToProject.lastIndexOf(Path.sep));
						project.type = Project.HXML;
						ProjectAccess.path = pathToProject;
						project.main = Path.basename(path);
						
						ProjectAccess.currentProject = project;
						projectOptions.updateProjectOptions();
						
						var pathToProjectHide:String = Path.join(pathToProject, "project.hide");
						
						ProjectAccess.save(function ()
						{
							fileTree.load(project.name, pathToProject);
						}
						);
						
						splitter.show();
						
						Browser.getLocalStorage().setItem("pathToLastProject", pathToProjectHide);
						recentProjectsList.add(pathToProjectHide);
					case ".lime", ".xml":
						closeProject(true);
						
                        outlinePanel.clearFields();
                		outlinePanel.update();
                        
						var options:FsReadFileOpt = { };
						options.encoding = "utf8";
						
						Fs.readFile(path, options, function (error, data:String):Void 
						{
							if (error == null) 
							{
								var xml:Xml = Xml.parse(data);
								var fast:Fast = new Fast(xml);
								
								if (fast.hasNode.project) 
								{
									OpenFL.open(path);
								}
								else 
								{
									Alertify.error("This is not an OpenFL project. OpenFL project xml should have 'project' node");
								}
							}
							else 
							{
								trace(error);
								Alertify.error("Can't open file: " + path + "\n" + error);
							}
						}
						);
					default:
						
				}
				
				tabManagerInstance.openFileInNewTab(path);
		}
	}
	
	public static function searchForLastProject():Void
	{
		var pathToLastProject:String = Browser.getLocalStorage().getItem("pathToLastProject");
		if (pathToLastProject != null)
		{
			openProject(pathToLastProject);
		}
	}
	
	public static function closeProject(?sync:Bool = false):Void
	{
		var tabManagerInstance = TabManager.get();
		
		var processHelper = ProcessHelper.get();
		
		if (ProjectAccess.path != null) 
		{
			ProjectAccess.save(updateProjectData, sync);
            tabManagerInstance.closeAll();
			processHelper.clearErrors();
		}
		else 
		{
			updateProjectData();
		}
	}
	
	static function updateProjectData()
	{
		var splitter = Splitter.get();
		
		ProjectAccess.path = null;
		ProjectAccess.currentProject = null;
		splitter.hide();
		Browser.getLocalStorage().removeItem("pathToLastProject");
	}
	
	static function parseProjectData(data:String):Project
	{		
		var project:Project = null;
		
		try 
		{
			project = TJSON.parse(data);
		}
		catch (unknown:Dynamic)
		{
			trace(unknown);
			trace(data);
			project = Json.parse(data);
		}
		
		return project;
	}
	
}
