package core;
import js.atomshell.webpage.WebView;
import js.atomshell.browser.App;
import js.atomshell.browserandwebpage.Clipboard;
import js.atomshell.browserandwebpage.Shell;
import js.node.Path;
import js.atomshell.browser.BrowserWindow;
import haxe.Timer;
import cm.Editor;
import dialogs.DialogManager;
import dialogs.ProjectOptionsDialog;
import filetree.FileTree;
import js.Node;
import menu.BootstrapMenu;
import newprojectdialog.NewProjectDialog;
import openproject.OpenProject;
import parser.ClasspathWalker;
import projectaccess.ProjectAccess;
import tabmanager.TabManager;
import watchers.SettingsWatcher;
import completion.GoToDeclaration;

/**
 * ...
 * @author AS3Boyan
 */
class MenuCommands
{
	public static function add():Void 
	{
		var window = BrowserWindow.getAllWindows()[0];

		BootstrapMenu.getMenu("View").addMenuItem("Zoom In", 2, function ():Void
		{
			var level = WebView.getZoomLevel();
			WebView.setZoomLevel(level + 1);
		}
		, "Ctrl-Shift-+");

		BootstrapMenu.getMenu("View").addMenuItem("Zoom Out", 3, function ():Void
		{
			var level = WebView.getZoomLevel();
			WebView.setZoomLevel(level - 1);
		}
		, "Ctrl-Shift--");

		BootstrapMenu.getMenu("View").addMenuItem("Reset", 4, function ():Void
		{
			WebView.setZoomLevel(0);
		}
		, "Ctrl-Shift-0");
		
		BootstrapMenu.getMenu("View", 3).addMenuItem("Toggle Fullscreen", 1, function ():Void
		{
			window.setFullScreen(!window.isFullScreen());
		}
		, "F11");
		
		var tabManagerInstance = TabManager.get();
		var completionInstance = Completion.get();
		var fileTreeInstance = FileTree.get();
		
		BootstrapMenu.getMenu("Help").addMenuItem("changelog", 1, tabManagerInstance.openFileInNewTab.bind(Path.join("core", "changes.md")));
		
		BootstrapMenu.getMenu("Developer Tools", 100).addMenuItem("Reload IDE", 1, window.webContents, "Ctrl-Shift-R");

		BootstrapMenu.getMenu("Developer Tools").addMenuItem("Compile plugins and reload IDE", 2, function ():Void
		{			
			HIDE.compilePlugins(function ():Void
			{
				//Only when all plugins successfully loaded
				window.webContents.reloadIgnoringCache();
			}
			//On plugin compilation failed
			, function (data:String):Void
			{
				
			}
			);
			
		}
		, "Shift-F5");
		
		BootstrapMenu.getMenu("Developer Tools").addMenuItem("Console", 3, window.toggleDevTools);
		
		BootstrapMenu.getMenu("Help").addMenuItem("Show code editor key bindings", 1, tabManagerInstance.openFileInNewTab.bind(Path.join("core", "bindings.txt")));
		BootstrapMenu.getMenu("Help").addMenuItem("View HIDE repository on GitHub", 2, Shell.openExternal.bind("https://github.com/as3boyan/HIDE"));
		BootstrapMenu.getMenu("Help").addMenuItem("Report issue/request feature at GitHub issue tracker", 3, Shell.openExternal.bind("https://github.com/as3boyan/HIDE/issues/new"));
		BootstrapMenu.getMenu("Help").addMenuItem("Open Haxe nightly build download URL", 4, function ():Void 
		{
			var serverUrl = "http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/";
			
			var target;
			
			switch (Utils.os) 
			{
				case Utils.WINDOWS:
					target = "windows";
				case Utils.LINUX:
					target = "linux64";
				case Utils.MAC:
					target = "mac";
					
				default:
					throw "Utils class was not able to detect OS";
			}
			
			Shell.openExternal(serverUrl + target + "/haxe_latest.tar.gz");
		});
		BootstrapMenu.getMenu("Help").addMenuItem("About HIDE...", 5, HIDE.openPageInNewBrowserWindow.bind(null, "about.html", {toolbar:false}));
		
		//Ctrl-Tab
		Hotkeys.add("Tab Manager->Show Next Tab", "Ctrl-Tab", null, tabManagerInstance.showNextTab);
		
		//Ctrl-Shift-Tab
		Hotkeys.add("Tab Manager->Show Previous Tab", "Ctrl-Shift-Tab", null, tabManagerInstance.showPreviousTab);
		
		//Ctrl-W
		Hotkeys.add("Tab Manager->Close File", "Ctrl-W", null, tabManagerInstance.closeActiveTab);
		
		//Ctrl-Shift-W
		Hotkeys.add("Tab Manager->Close All", "Ctrl-Shift-W", null, tabManagerInstance.closeAll);
		
		BootstrapMenu.getMenu("File", 1).addMenuItem("New Project...", 1, NewProjectDialog.show, "Ctrl-Shift-N");
		
		//Ctrl-N
		BootstrapMenu.getMenu("File").addMenuItem("New File...", 2, tabManagerInstance.createFileInNewTab, "Ctrl-N");
		BootstrapMenu.getMenu("File").addSeparator();
		BootstrapMenu.getMenu("File").addMenuItem("Open Project...", 3, OpenProject.openProject.bind(null, true));
		BootstrapMenu.getMenu("File").addSubmenu("Open Recent Project");
		BootstrapMenu.getMenu("File").addMenuItem("Close Project", 4, OpenProject.closeProject);
		BootstrapMenu.getMenu("File").addMenuItem("Open File...", 5, OpenProject.openProject, "Ctrl-O");
		BootstrapMenu.getMenu("File").addSubmenu("Open Recent File");
		BootstrapMenu.getMenu("File").addSeparator();
		
		//Ctrl-S
		BootstrapMenu.getMenu("File").addMenuItem("Save", 6, tabManagerInstance.saveActiveFile, "Ctrl-S");
		//Ctrl-Shift-S
		BootstrapMenu.getMenu("File").addMenuItem("Save As...", 7, tabManagerInstance.saveActiveFileAs, "Ctrl-Shift-S");
		BootstrapMenu.getMenu("File").addMenuItem("Save All", 8, tabManagerInstance.saveAll);
		BootstrapMenu.getMenu("File").addSeparator();
		
		//App.closeAllBrowserWindows
		BootstrapMenu.getMenu("File").addMenuItem("Exit", 9, App.quit);
		
		BrowserWindow.getAllWindows()[0].on(BrowserWindowEvent.CLOSE, function ()
			{
				tabManagerInstance.saveAll();
			}
		);
		
// 		BootstrapMenu.getMenu("Options").addMenuItem("Open haxelib manager", 1, DialogManager.showHaxelibManagerDialog);
		BootstrapMenu.getMenu("Options").addMenuItem("Open settings", 1, tabManagerInstance.openFileInNewTab.bind(Path.join(SettingsWatcher.pathToFolder,"settings.json")));
		BootstrapMenu.getMenu("Options").addMenuItem("Open stylesheet", 1, function ()
													 {
														 tabManagerInstance.openFileInNewTab(Path.join("core", SettingsWatcher.settings.theme));
													 }
													);
		
		var classpathWalker = ClasspathWalker.get();
		
		BootstrapMenu.getMenu("Options").addMenuItem("Open editor configuration file", 1, tabManagerInstance.openFileInNewTab.bind(Path.join(SettingsWatcher.pathToFolder,"editor.json")));
		BootstrapMenu.getMenu("Options").addMenuItem("Open templates folder", 1, fileTreeInstance.load.bind("templates", Path.join("core","templates")));
		BootstrapMenu.getMenu("Options").addMenuItem("Open localization file", 1, tabManagerInstance.openFileInNewTab.bind(Path.join("core", "locale",SettingsWatcher.settings.locale)));
		BootstrapMenu.getMenu("Options").addMenuItem("Open hotkey configuration file", 1, tabManagerInstance.openFileInNewTab.bind(Path.join(SettingsWatcher.pathToFolder, "hotkeys.json")));
		BootstrapMenu.getMenu("Options", 90).addMenuItem("Open snippets configuration file", 1, tabManagerInstance.openFileInNewTab.bind(Path.join(SettingsWatcher.pathToFolder, "snippets.json")));
		BootstrapMenu.getMenu("Options").addMenuItem("Configure Haxe toolkit", 100, classpathWalker.showHaxeDirectoryDialog);
		
		BootstrapMenu.getMenu("Edit", 2).addMenuItem("Undo", 1, Editor.editor.execCommand.bind("undo"));
		BootstrapMenu.getMenu("Edit").addMenuItem("Redo", 1, Editor.editor.execCommand.bind("redo"));
		BootstrapMenu.getMenu("Edit").addSeparator();
		BootstrapMenu.getMenu("Edit").addMenuItem("Cut", 1, function ():Void 
		{
			Clipboard.writeText(Editor.editor.getSelection());
			Editor.editor.replaceSelection("");
		});
		
		BootstrapMenu.getMenu("Edit").addMenuItem("Copy", 1, function ():Void 
		{
			Clipboard.writeText(Editor.editor.getSelection());
		});
		
		BootstrapMenu.getMenu("Edit").addMenuItem("Paste", 1, function ():Void 
		{
			Editor.editor.replaceSelection(Clipboard.readText());
		});
		
		BootstrapMenu.getMenu("Edit").addSeparator();
		BootstrapMenu.getMenu("Edit").addMenuItem("Find...", 1, Editor.editor.execCommand.bind("find"));
		BootstrapMenu.getMenu("Edit").addMenuItem("Replace...", 1, Editor.editor.execCommand.bind("replace"));
		
		var goToLine = GoToLine.get();
		
		BootstrapMenu.getMenu("Navigate", 4).addMenuItem("Go to Line", 2, goToLine.show, "Ctrl-G");
		BootstrapMenu.getMenu("Navigate").addMenuItem("Open File", 3, function ()
                                                      {
                                                          Timer.delay(function ()
                                                                          {
                                                                              completionInstance.showFileList();
                                                                          }, 10);
                                                      }, "Ctrl-Shift-O");
		
		BootstrapMenu.getMenu("Navigate").addMenuItem("Go To Declaration", 4, function ()
													  {
														  var goToDeclaration = GoToDeclaration.get();
														  goToDeclaration.start();
													  }
													  , "Ctrl-B");
		
		BootstrapMenu.getMenu("Source").addMenuItem("Show Class List", 4, completionInstance.showClassList, "Ctrl-Shift-P");
		BootstrapMenu.getMenu("Source").addMenuItem("Show Code Completion", 5, Editor.triggerCompletion.bind(Editor.editor), "Ctrl-Space");
		BootstrapMenu.getMenu("Source").addMenuItem("Toggle Comment", 5, Editor.editor.execCommand.bind("toggleComment"), "Ctrl-Q");
		BootstrapMenu.getMenu("Source").addMenuItem("Import Class Definition", 6, function ():Void
		{
            var selectedPath = tabManagerInstance.getCurrentDocumentPath();
            
            if (selectedPath != null)
            {
            	ImportDefinition.searchImport(tabManagerInstance.getCurrentDocument().getValue(), selectedPath);   
            }
		}, "Ctrl-Shift-1");
				
		BootstrapMenu.getMenu("Project", 80).addMenuItem("Run", 1, RunProject.runProject, "F5");
		BootstrapMenu.getMenu("Project").addMenuItem("Build", 2, RunProject.buildProject, "F8");
		BootstrapMenu.getMenu("Project").addMenuItem("Clean", 3, RunProject.cleanProject, "Shift-F8");
// 		BootstrapMenu.getMenu("Project").addMenuItem("Set This Hxml As Project Build File", 4, RunProject.setHxmlAsProjectBuildFile);
// 		BootstrapMenu.getMenu("Project").addSubmenu("Build Recent Project");
		BootstrapMenu.getMenu("Project").addMenuItem("Project Options...", 5, function ():Void 
		{
			if (ProjectAccess.path != null) 
			{
				DialogManager.showProjectOptions();
			}
			else 
			{
				Alertify.error("Open or create project first");
			}
		});
	}
}
