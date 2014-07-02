package projectaccess;
import js.node.Path;
import js.node.Fs;
import bootstrap.ButtonManager;
import bootstrap.InputGroupButton;
import core.FileDialog;
import haxe.ds.ArraySort;
import js.Browser;
import js.html.DivElement;
import js.html.InputElement;
import js.html.OptionElement;
import js.html.ParagraphElement;
import js.html.SelectElement;
import js.html.TextAreaElement;
import js.Node;
import parser.ClasspathWalker;
import projectaccess.Project.TargetData;
import tabmanager.TabManager;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */
class ProjectOptions
{	
	public var page:DivElement;
	
	//Select element(ComboBox-like) for project target selection
	var projectTargetList:SelectElement;
	var projectTargetText:ParagraphElement;
	
	//OpenFL specific targets
	var openFLTargetList:SelectElement;
	var openFLTargetText:ParagraphElement;
	var openFLTargets:Array<String>;
	var openFLBuildModeList:SelectElement;
	var openFLBuildModeText:ParagraphElement;
	var buildModes:Array<String>;
	
	//Build action(currently only shown for OpenFL projects)
	var buildActionDescription:ParagraphElement;
	var buildActionTextArea:TextAreaElement;
	
	//Run action type and command/file/url
	var actionTextArea:TextAreaElement;
	var runActionList:SelectElement;
	var runActionTextAreaDescription:ParagraphElement;
	var runActionDescription:ParagraphElement;
	
	//Multiple Hxml-based projects(Project.HAXE)
	var pathToHxmlDescription:ParagraphElement;
	var inputGroupButton:bootstrap.InputGroupButton;
	var pathToHxmlInput:InputElement;
	
	static var instance:ProjectOptions;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new ProjectOptions();
		}
			
		return instance;
	}
	
	public function create():Void
	{
		page = Browser.document.createDivElement();
		
		createOptionsForMultipleHxmlProjects();
		
		projectTargetText = Browser.document.createParagraphElement();
		projectTargetText.textContent = LocaleWatcher.getStringSync("Project target:");
		projectTargetText.setAttribute("localeString", "Project target:");
		projectTargetText.className = "custom-font-size";
		page.appendChild(projectTargetText);
		
		projectTargetList = Browser.document.createSelectElement();
		projectTargetList.id = "project-options-project-target";
		projectTargetList.className = "custom-font-size";
		projectTargetList.style.width = "100%";
		
		openFLTargetList = Browser.document.createSelectElement();
		openFLTargetList.id = "project-options-openfl-target";
		openFLTargetList.className = "custom-font-size";
		openFLTargetList.style.width = "100%";
		
		openFLTargetText = Browser.document.createParagraphElement();
		openFLTargetText.textContent = LocaleWatcher.getStringSync("OpenFL target:");
		openFLTargetText.setAttribute("localeString", "OpenFL target:");
		openFLTargetText.className = "custom-font-size";
		
		openFLBuildModeList = Browser.document.createSelectElement();
		openFLBuildModeList.id = "project-options-openfl-build-mode";
		openFLBuildModeList.className = "custom-font-size";
		openFLBuildModeList.style.width = "100%";
		
		openFLBuildModeText = Browser.document.createParagraphElement();
		openFLBuildModeText.textContent = LocaleWatcher.getStringSync("Build mode:");
		openFLBuildModeText.setAttribute("localeString", "Build mode:");
		openFLBuildModeText.className = "custom-font-size";
		
		for (target in ["Flash", "JavaScript", "Neko", "OpenFL", "PHP", "C++", "Java", "C#", "Python"])
		{
			projectTargetList.appendChild(createListItem(target));
		}
					
		//projectTargetList.disabled = true;
		projectTargetList.onchange = function (e):Void 
		{
			var project = ProjectAccess.currentProject;
			
			switch (projectTargetList.value) 
			{
				case "Flash":
					project.target = Project.FLASH;
				case "JavaScript":
					project.target = Project.JAVASCRIPT;
				case "Neko":
					project.target = Project.NEKO;
				case "OpenFL":
					project.target = Project.OPENFL;
				case "PHP":
					project.target = Project.PHP;
				case "C++":
					project.target = Project.CPP;
				case "Java":
					project.target = Project.JAVA;
				case "C#":
					project.target = Project.CSHARP;
				case "Python":
					project.target = Project.PYTHON;
				default:
					throw "Unknown target";
			}
			
			var classpathWalker = ClasspathWalker.get();
			
			classpathWalker.parseProjectArguments();
			
			updateProjectOptions();
		};
		
		openFLTargets = ["flash", "html5", "neko", "android", "blackberry", "emscripten", "webos", "tizen", "ios", "windows", "mac", "linux"];
		
		for (target in openFLTargets)
		{
			openFLTargetList.appendChild(createListItem(target));
		}
		
		openFLTargetList.onchange = function (_)
		{
			var project = ProjectAccess.currentProject;
			
			updateOpenFLBuildCommand();
			
			project.runActionType = Project.COMMAND;
			project.runActionText = ["haxelib", "run", "lime", "run", '"%path%"', project.openFLTarget].join(" ");
			
			var classpathWalker = ClasspathWalker.get();
			
			classpathWalker.parseProjectArguments();
			
			updateProjectOptions();
		};
	
		buildModes = ["Debug", "Release"];	

		for (mode in buildModes)
		{
			openFLBuildModeList.appendChild(createListItem(mode));
		}
			
		openFLBuildModeList.onchange = function (_)
		{
			var mode = buildModes[openFLBuildModeList.selectedIndex];
			
			var project = ProjectAccess.currentProject;
			
			project.openFLBuildMode = mode;
			
			updateOpenFLBuildCommand();
		};
		
		runActionDescription = Browser.document.createParagraphElement();
		runActionDescription.className = "custom-font-size";
		runActionDescription.textContent = LocaleWatcher.getStringSync("Run action:");
		runActionDescription.setAttribute("localeString", "Run action:");
		
		runActionTextAreaDescription = Browser.document.createParagraphElement();
		runActionTextAreaDescription.textContent = LocaleWatcher.getStringSync("URL:");
		runActionTextAreaDescription.setAttribute("localeString", "URL:");
		runActionTextAreaDescription.className = "custom-font-size";
		
		var actions:Array<String> = ["Open URL", "Open File", "Run command"];
		
		runActionList = Browser.document.createSelectElement();
		runActionList.style.width = "100%";
		
		runActionList.onchange = update;
		
		for (action in actions)
		{
			runActionList.appendChild(createListItem(action));
		}
		
		actionTextArea = Browser.document.createTextAreaElement();
		actionTextArea.id = "project-options-action-textarea";
		actionTextArea.className = "custom-font-size";
		actionTextArea.onchange = function (e)
		{	
			var project = ProjectAccess.currentProject;
			
			if (project.type == Project.HAXE) 
			{
				var targetData:TargetData = project.targetData[project.target];
				targetData.runActionText = actionTextArea.value;
			}
			else 
			{
				project.runActionText = actionTextArea.value;
			}
			
			update(null);
		};
		
		buildActionDescription = Browser.document.createParagraphElement();
		buildActionDescription.className = "custom-font-size";
		buildActionDescription.textContent = LocaleWatcher.getStringSync("Build command:");
		buildActionDescription.setAttribute("localeString", "Build command:");
		
		buildActionTextArea = Browser.document.createTextAreaElement();
		buildActionTextArea.id = "project-options-build-action-textarea";
		buildActionTextArea.className = "custom-font-size";
		buildActionTextArea.onchange = function (e)
		{
			ProjectAccess.currentProject.buildActionCommand = buildActionTextArea.value;
			ProjectAccess.save();
		};
		
		page.appendChild(projectTargetList);
		page.appendChild(buildActionDescription);
		page.appendChild(buildActionTextArea);
		page.appendChild(pathToHxmlDescription);
		page.appendChild(inputGroupButton.getElement());
		page.appendChild(openFLTargetText);
		page.appendChild(openFLTargetList);
		page.appendChild(openFLBuildModeText);
		page.appendChild(openFLBuildModeList);
		page.appendChild(runActionDescription);
		page.appendChild(runActionList);
		page.appendChild(runActionTextAreaDescription);
		page.appendChild(actionTextArea);
	}
	
	public function updateOpenFLBuildCommand()
	{
		var project = ProjectAccess.currentProject;

		project.openFLTarget = openFLTargets[openFLTargetList.selectedIndex];

		var buildParams:Array<String> = ["haxelib", "run", "lime", "build", '"%path%"', project.openFLTarget];

		if (project.openFLBuildMode == "Debug")
		{
			buildParams.push("-debug");

			if (project.openFLTarget == "flash")
			{
				buildParams.push("-Dfdb");
			}
		}

		switch (project.openFLTarget) 
		{
			case "flash", "html5", "neko":
				buildParams = buildParams.concat(["--connect", "5000"]);
			default:

		}

		project.buildActionCommand = buildParams.join(" ");
	}

		
	function createOptionsForMultipleHxmlProjects() 
	{
		pathToHxmlDescription = Browser.document.createParagraphElement();
		pathToHxmlDescription.textContent = LocaleWatcher.getStringSync("Path to Hxml:");
		pathToHxmlDescription.setAttribute("localeString", "Path to Hxml:");
		pathToHxmlDescription.className = "custom-font-size";
		
		inputGroupButton = new InputGroupButton("Browse...");
		
		pathToHxmlInput = inputGroupButton.getInput();
		
		pathToHxmlInput.onchange = function (e):Void 
		{
			if (Fs.existsSync(pathToHxmlInput.value)) 
			{
				var project = ProjectAccess.currentProject;
				project.targetData[project.target].pathToHxml = pathToHxmlInput.value;
				ProjectAccess.save();
			}
			else 
			{
				Alertify.error(pathToHxmlInput.value + " is not found");
			}
		};
		
		var browseButton = inputGroupButton.getButton();
		
		browseButton.onclick = function (e):Void 
		{
			FileDialog.openFile(function (path:String):Void 
			{
				pathToHxmlInput.value = path;
				
				var project = ProjectAccess.currentProject;
				project.targetData[project.target].pathToHxml = pathToHxmlInput.value;
				ProjectAccess.save();
			}
			, ".hxml");
		};
		
		var buttonManager = ButtonManager.get();
		
		var editButton = buttonManager.createButton("Edit", false, true);
		editButton.onclick = function (e):Void 
		{
			var tabManagerInstance = TabManager.get();
			tabManagerInstance.openFileInNewTab(Path.resolve(ProjectAccess.path, pathToHxmlInput.value));
		};
		
		inputGroupButton.getSpan().appendChild(editButton);
	}
	
	function update(_):Void
	{
		var project = ProjectAccess.currentProject;
		
		if (project.type == Project.OPENFL)
		{
			openFLTargetList.style.display = "";
			openFLTargetText.style.display = "";
			openFLBuildModeList.style.display = "";
			openFLBuildModeText.style.display = "";
			//textarea.style.display = "none";
			//projectOptionsText.style.display = "none";
		}
		else
		{
			openFLTargetList.style.display = "none";
			openFLTargetText.style.display = "none";
			openFLBuildModeList.style.display = "none";
			openFLBuildModeText.style.display = "none";
			//textarea.style.display = "";
			//projectOptionsText.style.display = "";
		}
		
		if (project.type == Project.HXML) 
		{
// 			openFLTargetList.style.display = "none";
// 			openFLTargetText.style.display = "none";
			//textarea.style.display = "none";
			//projectOptionsText.style.display = "none";
			
			buildActionTextArea.style.display = "none";
			buildActionDescription.style.display = "none";
			//runActionTextAreaDescription.style.display = "none";
			//runActionList.style.display = "none";
			//runActionDescription.style.display = "none";
			projectTargetList.style.display = "none";
			projectTargetText.style.display = "none";
			//actionTextArea.style.display = "none";
		}
		else 
		{
			buildActionTextArea.style.display = "none";
			buildActionDescription.style.display = "none";
			runActionTextAreaDescription.style.display = "";
			runActionList.style.display = "";
			runActionDescription.style.display = "";
			projectTargetList.style.display = "";
			projectTargetText.style.display = "";
			actionTextArea.style.display = "";
		}
		
		if (project.type == Project.HAXE) 
		{
			pathToHxmlDescription.style.display = "";
			inputGroupButton.getElement().style.display = "";
		}
		else
		{
			pathToHxmlDescription.style.display = "none";
			inputGroupButton.getElement().style.display = "none";
		}
		
		var runActionType;
		
		switch (runActionList.selectedIndex) 
		{
			case 0:
				runActionTextAreaDescription.innerText = LocaleWatcher.getStringSync("URL: ");
				runActionType = Project.URL;
			case 1:
				runActionTextAreaDescription.innerText = LocaleWatcher.getStringSync("Path: ");
				runActionType = Project.FILE;
			case 2:
				runActionTextAreaDescription.innerText = LocaleWatcher.getStringSync("Command: ");
				runActionType = Project.COMMAND;
				
			default:
				runActionType = 0;
		}
		
		switch (project.type) 
		{
			case Project.HAXE:
				var targetData:TargetData = project.targetData[project.target];
				targetData.runActionType = runActionType;
			default:
				project.runActionType = runActionType;
		}
		
		ProjectAccess.save();
	}
	
	public function updateProjectOptions():Void
	{		
		var project = ProjectAccess.currentProject;
		
		var runActionType;
		var runActionText;
		
		switch (project.type) 
		{
			case Project.HAXE:
				var targetData:TargetData = project.targetData[project.target];
				
				runActionType = targetData.runActionType;
				runActionText = targetData.runActionText;
				
				pathToHxmlInput.value = targetData.pathToHxml;
			default:
				runActionType = project.runActionType;
				runActionText = project.runActionText;
		}
		
		if (project.type == Project.OPENFL)
		{
			projectTargetList.selectedIndex = 3;
			
			var i:Int = Lambda.indexOf(openFLTargets, project.openFLTarget);
			if (i != -1)
			{
				openFLTargetList.selectedIndex = i;
			}
			else 
			{
				openFLTargetList.selectedIndex = 0;
			}
			
			openFLBuildModeList.selectedIndex = buildModes.indexOf(project.openFLBuildMode);
		}
		else 
		{			
			switch (project.target) 
			{
				case Project.FLASH:
					projectTargetList.selectedIndex = 0;
				case Project.JAVASCRIPT:
					projectTargetList.selectedIndex = 1;
				case Project.NEKO:
					projectTargetList.selectedIndex = 2;
				case Project.PHP:
					projectTargetList.selectedIndex = 4;
				case Project.CPP:
					projectTargetList.selectedIndex = 5;
				case Project.JAVA:
					projectTargetList.selectedIndex = 6;
				case Project.CSHARP:
					projectTargetList.selectedIndex = 7;
				case Project.PYTHON:
					projectTargetList.selectedIndex = 8;
				default:
					
			}
			
			//textarea.value = ProjectAccess.currentProject.args.join("\n");
		}
		
		buildActionTextArea.value = project.buildActionCommand;
		
		switch (runActionType) 
		{
			case Project.URL:
				runActionList.selectedIndex = 0;
			case Project.FILE:
				runActionList.selectedIndex = 1;
			case Project.COMMAND:
				runActionList.selectedIndex = 2;
			default:
				
		}
		
		if (runActionText == null) 
		{
			runActionText = "";
		}
		actionTextArea.value = runActionText;
		
		update(null);
	}
	
	function createListItem(text:String):OptionElement
	{		
		var option:OptionElement = Browser.document.createOptionElement();
		option.textContent = LocaleWatcher.getStringSync(text);
		option.value = text;
		return option;
	}
}