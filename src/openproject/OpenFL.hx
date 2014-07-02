package openproject;
import js.node.Path;
import core.RecentProjectsList;
import core.Splitter;
import filetree.FileTree;
import js.Browser;
import js.Node;
import openflproject.OpenFLTools;
import projectaccess.Project;
import projectaccess.ProjectAccess;
import projectaccess.ProjectOptions;

/**
 * ...
 * @author AS3Boyan
 */
class OpenFL
{
	public static function open(path:String):Void
	{
		var pathToProject:String = Path.dirname(path);
				
		var project:Project = new Project();
		project.name = pathToProject.substr(pathToProject.lastIndexOf(Path.sep));
		project.type = Project.OPENFL;
		project.openFLTarget = "flash";
		project.openFLBuildMode = "Debug";
		ProjectAccess.path = pathToProject;
		project.buildActionCommand = ["haxelib", "run", "lime", "build", '"%path%"', project.openFLTarget, "--connect", "5000"].join(" ");
		project.runActionType = Project.COMMAND;
		project.runActionText = ["haxelib", "run", "lime", "run", '"%path%"', project.openFLTarget].join(" ");
		
		var pathToProjectHide:String = Path.join(pathToProject, "project.hide");
		
		ProjectAccess.currentProject = project;
		
		var projectOptions = ProjectOptions.get();
		var splitter = Splitter.get();
		var fileTree = FileTree.get();
		var recentProjectsList = RecentProjectsList.get();
		
		projectOptions.updateProjectOptions();
		
		ProjectAccess.save(fileTree.load.bind(project.name, pathToProject));
		
		splitter.show();
		
		Browser.getLocalStorage().setItem("pathToLastProject", pathToProjectHide);
		recentProjectsList.add(pathToProjectHide);
	}
	
	public static function parseOpenFLDisplayParameters(pathToProject:String, target:String, onComplete:Array<String>->Void):Void
	{
		OpenFLTools.getParams(pathToProject, target, function (stdout:String)
		{					
			var args:Array<String> = [];
		
			var currentLine:String;
			
			for (line in stdout.split("\n"))
			{
				currentLine = StringTools.trim(line);
				
				if (!StringTools.startsWith(currentLine, "#"))
				{
					args.push(currentLine);
				}
			}
			
			onComplete(args);
		}
		);
	}
}