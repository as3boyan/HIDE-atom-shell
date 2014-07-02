
package tabmanager;
import js.node.Fs.FsReadFileOpt;
import js.node.Fs;
import js.node.Path;
import parser.ClasspathWalker;
import haxe.Template;
import watchers.SettingsWatcher;
import projectaccess.Project.FileData;
import js.html.KeyboardEvent;
import js.html.InputElement;
import cm.Xml;
import core.OutlinePanel;
import cm.CMDoc;
import cm.Editor;
import core.FileDialog;
import core.HaxeLint;
import core.RecentProjectsList;
import core.Utils;
import core.WelcomeScreen;
import filetree.FileTree;
import haxe.ds.StringMap.StringMap;
import haxe.Timer;
import jQuery.JQuery;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.Element;
import js.html.LIElement;
import js.html.MouseEvent;
import js.html.SpanElement;
import js.html.UListElement;
import js.Node;
import projectaccess.ProjectAccess;
import watchers.LocaleWatcher;

/**
 * ...
 * @author AS3Boyan
 */
typedef FileTemplate = 
{
	?name:String,
	?pack:String,
 	?author:String,
 	?license:String,
 	?url:String	
}

class TabManager
{
	public var tabs:UListElement;
	public var tabMap:TabMap;
	public var selectedPath:String;
	var selectedIndex:Int;
	
	static var instance:TabManager;
	
	public static function get():TabManager
	{
		if (instance == null)
		{
			instance = new TabManager();
		}
			
		return instance;
	}
	
	public function new():Void
	{
		
	}
	
	public function load()
	{
		tabs = cast(Browser.document.getElementById("tabs"), UListElement);
		
		tabMap = new TabMap();
		
		ContextMenu.createContextMenu();
		
		var options:Alertify.Options = { };
		options.labels = { };
		options.labels.ok = LocaleWatcher.getStringSync("Yes");
		options.labels.cancel = LocaleWatcher.getStringSync("No");
		
		Alertify.set(options);
		
		var indentWidthLabel = cast (Browser.document.getElementById("indent-width-label"), DivElement);
		var indentWidthInput = cast (Browser.document.getElementById("indent-width-input"), InputElement);
		
		indentWidthLabel.onclick = function (e)
			{
				indentWidthLabel.classList.add("hidden");
                indentWidthInput.classList.remove("hidden");
				indentWidthInput.focus();
				
				indentWidthInput.select();
				
				indentWidthInput.onblur = function (_)
					{
						indentWidthLabel.classList.remove("hidden");
                		indentWidthInput.classList.add("hidden");

						// remove all event handlers from the input field
						indentWidthInput.onblur = null;
						indentWidthInput.onkeyup = null;

						// restore focus to the editor
						Editor.editor.focus();
						
						setIndentationSize(Std.parseInt(indentWidthInput.value));	
					};
				
				indentWidthInput.onkeyup = function (event)
					{
						if (event.keyCode == 13) 
						{
                        	indentWidthInput.blur();
                        }
						else if (event.keyCode == 27)
						{
							resetIndentationSettings();
                        }
					};
			};
		
		var indentType = Browser.document.getElementById("indent-type");
		
		indentType.onclick = function (_)
			{
				var selectedFile = ProjectAccess.getFileByPath(getCurrentDocumentPath());
				
				if (selectedFile != null)
				{	
					selectedFile.useTabs = !selectedFile.useTabs;
                    trace(selectedFile.useTabs);
					updateIndentationSettings(selectedFile);
					loadIndentationSettings(Editor.editor, selectedFile);
				}
			}
	}

	
	function setIndentationSize(indentSize:Int)
	{
		var selectedFile = ProjectAccess.getFileByPath(getCurrentDocumentPath());
				
		if (selectedFile != null)
		{
			selectedFile.indentSize = indentSize;
			updateIndentationSettings(selectedFile);
			loadIndentationSettings(Editor.editor, selectedFile);
		}
	}

	
	function resetIndentationSettings()
	{
		var selectedFile = ProjectAccess.getFileByPath(getCurrentDocumentPath());
				
		if (selectedFile != null)
		{	
			updateIndentationSettings(selectedFile);
		}
	}

	
	public function createNewTab(name:String, path:String, doc:CodeMirror.Doc, ?save:Bool = false):Void
	{
		var tab = new Tab(name, path, doc, save);
		tabMap.add(tab);
		
		tabs.appendChild(tab.getElement());
		
		if (ProjectAccess.path != null) 
		{
			var relativePath = Path.relative(ProjectAccess.path, path);
			var selectedFile = ProjectAccess.getFileByPath(path);
			
			if (selectedFile == null) 
			{
				ProjectAccess.currentProject.files.push({path: relativePath});
			}
		}
			
		
		var recentProjectsList = RecentProjectsList.get();
		recentProjectsList.addFile(path);
		
		Editor.resize();
	}
	
	public function openFile(path:String, onComplete:String->Void)
	{
		var options:FsReadFileOpt = { };
		options.encoding = "utf8";
		
		Fs.readFile(path, options, function (error, code:String):Void
		{
			if (error != null)
			{
				trace(error);
			}
			else 
			{
				onComplete(code);
			}
		}
		);
	}
	
	public function openFileInNewTab(path:String, ?show:Bool = true, ?onComplete:Dynamic):Void
	{        
		//Fix opening same file
		if (Utils.os == Utils.WINDOWS) 
		{
			var ereg:EReg = ~/[a-z]:\\/i;
			
			if (ereg.match(path)) 
			{
				path = path.substr(0, 3).toLowerCase() + path.substr(3);
			}
		}
		
		//path = js.Node.require('path').relative(js.Node.process.cwd(), path);
		path = StringTools.replace(path, "\\", Path.sep); 
		
		if (isAlreadyOpened(path, show))
		{
			if (onComplete != null) 
			{
				onComplete();
			}
            
			return;
		}
		
		openFile(path, function (code:String):Void 
		{
			if (isAlreadyOpened(path, show))
			{
				if (onComplete != null) 
				{
					onComplete();
				}
                
				return;
			}
			
			if (code != null)
			{
				var mode:String = getMode(path);
				var name:String = Path.basename(path);
				
				var doc = new CodeMirror.Doc(code, mode);
				
				createNewTab(name, path, doc);
				
                if (show)
                {
                	selectDoc(path);    
                }
				
				checkTabsCount();
				
				if (onComplete != null) 
				{
					onComplete();
				}
			}
			else 
			{
				trace("tab-manager: can't load file " + path);
			}
		}
		);
	}
	
	public function createFileInNewTab(?pathToFile:String):Void
	{
		var path:String = pathToFile;
		
		if (path == null) 
		{
			FileDialog.saveFile(function (_selectedPath:String)
			{			
				//var path:String = convertPathToUnixFormat(value);
		
				//if (isAlreadyOpened(path))
				//{
					//return;
				//}
				
				createNewFile(_selectedPath);
			}
			);
		}
		else 
		{
			createNewFile(path);
		}
	}
	
	function resolvePackage(pathToFile:String, onComplete:Dynamic)
	{
		var pathToProject = ProjectAccess.path;

		var filePackage:String = "";
		
		if (pathToProject != null)
		{
			var classpathWalker = ClasspathWalker.get();
			classpathWalker.getProjectClasspaths(ProjectAccess.currentProject, function (classpathAndLibs)
				{								
					var classpaths = [];

					for (item in classpathAndLibs.classpaths)
					{
						 classpaths.push(item);
					}

					for (item in classpathAndLibs.libs)
					{
						 classpaths.push(item.path);
					}

					for (classpath in classpaths)
					{
						if (StringTools.startsWith(pathToFile, classpath))
						{
							var dirname = Path.dirname(pathToFile);
							var relativePath = Path.relative(classpath, dirname);
							var fullPackagePath = StringTools.replace(relativePath, Path.sep, ".");
							filePackage = fullPackagePath;
						}
					}
	
					onComplete(filePackage);
				}
			);
		}
		else
		{
			onComplete(filePackage);
		}
	}

	function createNewFile(path:String):Void
	{
		var name:String = Path.basename(path);
		var mode:String = getMode(name);
		
		var code:String = "";
		
		var extname:String = Path.extname(name);
		
		switch (extname) 
		{
			case ".hx":
				path = path.substr(0, path.length - name.length) + name.substr(0, 1).toUpperCase() + name.substr(1); // + Utils.capitalize(name)
			
// 				var options:NodeFsFileOptions = { };
// 				options.encoding = "utf8";
				
				var pathToTemplate:String = Path.join("core", "templates", "New.tpl");
				var templateCode:String = Fs.readFileSync(pathToTemplate, "utf8");
				
				resolvePackage(path, function (filePackage)
							   {
								    // code = Mustache.render(templateCode, { name: js.Path.basename(name, extname), pack:"", author:"" } );
								   	//author:""
								   	
								   	var data:FileTemplate = {};
								   	data.name = Path.basename(name, extname);
								   
								   	generateTemplate(data, filePackage);
								   
									code = new Template(templateCode).execute(data);
								   	createNewDoc(path, name, code, mode);
							   }
							  );
			case ".hxml":
// 				var options:NodeFsFileOptions = { };
// 				options.encoding = "utf8";
				
				var pathToTemplate:String = Path.join("core", "templates", "build.tpl");
				var templateCode:String = Fs.readFileSync(pathToTemplate, "utf8");
				
				code = templateCode;
				createNewDoc(path, name, code, mode);
			default:
				createNewDoc(path, name, code, mode);
		}
	}

	public function generateTemplate(data:FileTemplate, filePackage:String)
	{
		data.pack = filePackage;

		var project = ProjectAccess.currentProject;

		if (project != null)
		{
			data.author = project.company;
			data.license = project.license;
			data.url = project.url;
		}
			
		return data;
	}

	function createNewDoc(path:String, name:String, code:String, mode:String)
	{
		var doc = new CodeMirror.Doc(code, mode);

		createNewTab(name, path, doc, true);
		selectDoc(path);

		checkTabsCount();

		var fileTreeInstance = FileTree.get();
		fileTreeInstance.load();
	}
	
	function checkTabsCount():Void
	{			
		if (Browser.document.getElementById("editor").style.display == "none" && tabMap.getTabs().length > 0)
		{
			new JQuery("#editor").show(0);
			
			var welcomeScreen = WelcomeScreen.get();
			welcomeScreen.hide();
			
			Editor.editor.refresh();
			
			Editor.resize();
			//Main.updateMenu();
		}
	}
	
	public function closeAll():Void
	{
		for (key in tabMap.keys()) 
		{
			closeTab(key, false);
		}
	}
        
	public function closeOthers(path:String):Void
	{		
		for (key in tabMap.keys()) 
		{
			if (key != path) 
			{
				closeTab(key, false);
			}
		}
		
		if (tabMap.getTabs().length == 1)
		{
			showNextTab();
		}
	}
	
	public function closeTab(path:String, ?switchToTab:Bool = true):Void
	{
		Editor.saveFoldedRegions();
		
		if (isChanged(path)) 
		{
			Alertify.confirm(LocaleWatcher.getStringSync("File ") + path +  LocaleWatcher.getStringSync(" was changed. Save it?"), function (e)
			{
				if (e)
				{
					saveDoc(path);
				}
				
				removeTab(path, switchToTab);
			}
			);
		}
		else 
		{
			removeTab(path, switchToTab);
		}
		
		Editor.resize();
	}
	
	function removeTab(path:String, ?switchToTab:Bool)
	{
		var tab = tabMap.get(path);
		tabMap.remove(path);
		
		tab.remove();
		
		selectedPath = null;
		
		if (tabMap.getTabs().length > 0)
		{
			if (switchToTab)
			{
				showPreviousTab();
			}
		}
		else 
		{
			new JQuery("#editor").hide(0);
			
			var welcomeScreen = WelcomeScreen.get();
			
			if (ProjectAccess.path != null) 
			{
				welcomeScreen.hide();
			}
			else 
			{
				welcomeScreen.show();
			}
			
			var outlinePanel = OutlinePanel.get();
            outlinePanel.clearFields();
            outlinePanel.update();
		}
		
		if (ProjectAccess.path != null) 
		{
// 			var pathToDocument:String = Path.relative(ProjectAccess.path, path);
			
			var selectedFile = ProjectAccess.getFileByPath(path);
			
			ProjectAccess.currentProject.files.remove(selectedFile);
		}
	}
	
	public function showPreviousTab() 
	{
		var index = selectedIndex - 1;
		var tabArray = tabMap.getTabs();
		
		if (index < 0) 
		{
			index = tabArray.length - 1;
		}
		
		selectDoc(tabArray[index].path);
	}
	
	public function showNextTab() 
	{
		var index = selectedIndex + 1;
		var tabArray = tabMap.getTabs();
		
		if (index > tabArray.length - 1) 
		{
			index = 0;
		}
		
		selectDoc(tabArray[index].path);
	}
	
	public function closeActiveTab():Void
	{
		closeTab(selectedPath);
	}

	function isAlreadyOpened(path:String, ?show:Bool = true):Bool
	{
		var opened:Bool = tabMap.exists(path);
		
		if (opened && show) 
		{
			selectDoc(path);
		}
		
		return opened;
	}
	
	function getMode(path:String):String
	{
		var mode:String = null;
				
		switch (Path.extname(path)) 
		{
			case ".hx":
					mode = "haxe";
			case ".hxml":
					mode = "hxml";
			case ".js":
					mode = "javascript";
			case ".css":
					mode = "css";
            case ".json":
                	mode = "application/json";
			case ".xml":
					mode = "xml";
			case ".html":
					mode = "text/html";
			case ".md":
					mode = "markdown";
			case ".sh", ".bat":
					mode = "shell";
			case ".ml":
					mode = "ocaml";
			case ".yml":
					mode = "yaml";
			default:
					
		}
		
		return mode;
	}
	
	public function selectDoc(path:String):Void
	{
		var found = false;

		var keys = tabMap.keys();
		for (i in 0...keys.length) 
		{
			if (keys[i] == path) 
			{
				tabMap.get(keys[i]).getElement().className = "selected";
				selectedIndex = i;
				found = true;
			}
			else 
			{
				tabMap.get(keys[i]).getElement().className = "";
			}
		}
		
		var cm = Editor.editor;

		if (found)
		{
			var project = ProjectAccess.currentProject;

			if (selectedPath != null && project != null)
			{
				Editor.saveFoldedRegions();
				cm.refresh();
			}
			
			selectedPath = path;
			
			if (ProjectAccess.path != null) 
			{
				project.activeFile = Path.relative(ProjectAccess.path, selectedPath);
			}

			var tab = tabMap.get(selectedPath);
			var doc = tab.doc;

			Editor.editor.swapDoc(doc);

			HaxeLint.updateLinting();

			var completionActive = Editor.editor.state.completionActive;

			if (completionActive != null && completionActive.widget != null) 
			{
				completionActive.widget.close();
			}

			if (ProjectAccess.currentProject != null)
			{		
				var selectedFile = ProjectAccess.getFileByPath(selectedPath);
				
				if (selectedFile != null)
				{
					if (!tab.loaded)
					{
						var foldedRegions = selectedFile.foldedRegions;

						if (foldedRegions != null)
						{
							for (pos in foldedRegions)
							{
								cm.foldCode(pos, null, "fold");
							}
						}

						if (selectedFile.activeLine != null)
						{
							var pos = {line: selectedFile.activeLine, ch: 0};

							doc.setCursor(pos);
							cm.centerOnLine(pos.line);
						}

						tab.loaded = true;
					}
					
					if (selectedFile.useTabs == null || selectedFile.indentSize == null)
					{
						var indentWithTabs = SettingsWatcher.settings.indentWithTabs;
						var indentSize = SettingsWatcher.settings.indentSize;
						
						if (indentWithTabs == null)
						{
							indentWithTabs = true;
						}
							
						if (indentSize == null)
						{
							indentSize = 4;
						}
						
						selectedFile.useTabs = indentWithTabs;
						setIndentationSize(indentSize);
					}
						
					loadIndentationSettings(cm, selectedFile);
					updateIndentationSettings(selectedFile);
				}
				else
				{
					trace("can't load folded regions for active document");
				}
			}

			cm.focus();		
			Browser.document.getElementById("status-file").textContent = "-" + Std.string(doc.lineCount()) + " Lines";
		}
	}
	
	function loadIndentationSettings(cm:CodeMirror, selectedFile:FileData)
	{
		cm.setOption("indentWithTabs", selectedFile.useTabs);
		
		if (selectedFile.useTabs)
		{
			cm.setOption("tabSize", selectedFile.indentSize);
		}
		else
		{
			cm.setOption("indentUnit", selectedFile.indentSize);
		}
	}
		
	function updateIndentationSettings(selectedFile:FileData)
	{
		var indentType = Browser.document.getElementById("indent-type");

		if (selectedFile.useTabs)
		{
			indentType.textContent = "Tab Size:";
		}
		else
		{
			indentType.textContent = "Spaces:";
		}
		
		var indentWidthInput = cast(Browser.document.getElementById("indent-width-input"), InputElement);
		indentWidthInput.value = Std.string(selectedFile.indentSize);
		
		var indentWidthLabel = cast(Browser.document.getElementById("indent-width-label"), DivElement);
		indentWidthLabel.textContent = Std.string(selectedFile.indentSize);
	}
		
	public function getCurrentDocumentPath():String
	{
		return selectedPath;
	}
	
	public function getCurrentDocument():CodeMirror.Doc
	{
        var doc:CodeMirror.Doc = null;
        
        if (selectedPath != null)
        {
            var tab = tabMap.get(selectedPath);

	    if (tab != null)
	    {
		doc = tab.doc;
	    }
        }
            
		return doc;
	}
	
	public function saveDoc(path:String, ?onComplete:Dynamic):Void
	{
		if (isChanged(path)) 
		{
			var tab:Tab = tabMap.get(path);
			tab.save();
		}
		
		if (onComplete != null)
		{
			onComplete();
		}	
	}
	
	public function isChanged(path:String):Bool
	{
		var tab:Tab = tabMap.get(path);
		
		//tab.doc.changeGeneration()
		return !tab.doc.isClean();
	}
	
	public function saveActiveFile(?onComplete:Dynamic):Void
	{
		if (selectedPath != null) 
		{
			saveDoc(selectedPath, onComplete);
		}
        else
        {
            trace(selectedPath);
        }
	}
	
	public function saveActiveFileAs():Void
	{		
		var tab = tabMap.get(selectedPath);
		
		FileDialog.saveFile(function (path:String):Void
		{
			tabMap.remove(selectedPath);
			tab.path = path;
			selectedPath = path;
			tabMap.add(tab);
			saveDoc(selectedPath);
		}
		, tab.name);
	}
	
	public function saveAll(?onComplete:Dynamic):Void
	{		
		for (key in tabMap.keys()) 
		{
			saveDoc(key);
		}
		
		if (onComplete != null)
		{
			onComplete();
		}
	}
}
