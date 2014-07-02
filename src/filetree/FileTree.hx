package filetree;
import js.npm.Remove;
import js.atomshell.browserandwebpage.Shell;
import js.npm.Mv;
import js.npm.Watchr;
import js.node.Path;
import js.node.Fs;
import js.node.fs.Stats;
import projectaccess.Project;
import core.RunProject;
import haxe.ds.StringMap.StringMap;
import jQuery.JQuery;
import jQuery.JQueryStatic;
import js.Browser;
import js.html.AnchorElement;
import js.html.DivElement;
import js.html.LIElement;
import js.html.MouseEvent;
import js.html.UListElement;
import parser.ClasspathWalker;
import projectaccess.ProjectAccess;
import tabmanager.TabManager;
import watchers.LocaleWatcher;
import watchers.SettingsWatcher;
import watchers.Watcher;
import core.OutlinePanel.TreeItem;

/**
 * ...
 * @author AS3Boyan
 */

typedef ContextMenuItem = 
{
	?element:LIElement,
	?cb:Dynamic
}

class FileTree
{
	var lastProjectName:String;
	var lastProjectPath:String;
	
	var contextMenu:Dynamic;
	var contextMenuCommandsMap:StringMap<ContextMenuItem>;
	var watcher:Dynamic;
	
	static var instance:FileTree;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new FileTree();
		}
			
		return instance;
	}
	
	public function init():Void
	{		
		contextMenuCommandsMap = new StringMap();
		
		appendToContextMenu("New File...", function (selectedItem):Void 
		{
			var path:String;
			
			if (selectedItem.value.type == 'folder') 
			{
				path = selectedItem.value.path;
			}
			else
			{
				path = Path.dirname(selectedItem.value.path);
			}
				
			Alertify.prompt(LocaleWatcher.getStringSync("Filename:"), function (e:Bool, str:String)
			{
				if (e) 
				{
					var pathToFile:String = Path.join(path, str);
					
					var tabManager = TabManager.get();
					tabManager.createFileInNewTab(pathToFile);
					untyped new JQuery('#filetree').jqxTree('addTo', createFileItem(pathToFile) , selectedItem.element);
					attachContextMenu();
				}
			}, "New.hx");
		});
		
		appendToContextMenu("New Folder...", function (selectedItem):Void 
		{
			var path:String;
			
			if (selectedItem.value.type == 'folder') 
			{
				path = selectedItem.value.path;
			}
			else
			{
				path = Path.dirname(selectedItem.value.path);
			}
			
			Alertify.prompt("Folder name:", function (e, str:String)
			{
				if (e) 
				{
					var dirname:String = str;
			
					if (dirname != null)
					{
						var pathToFolder = Path.join(path, dirname);
						
						Fs.mkdir(pathToFolder, function (error):Void
						{
							if (error == null) 
							{
								untyped new JQuery('#filetree').jqxTree('addTo', { label: str, value: {type: "folder", path: pathToFolder}}, selectedItem.element);
								//icon: "includes/images/folder.png"
								attachContextMenu();
							}
							else 
							{
								Alertify.error(error);
							}
						});
					}
				}
			}, "New Folder");
		});
		
		appendToContextMenu("Edit", function (selectedItem):Void 
		{
			var tabManager = TabManager.get();
			
			if (selectedItem.value.type == 'file') 
			{
				tabManager.openFileInNewTab(selectedItem.value.path);
			}
			else
			{
				untyped new JQuery('#filetree').jqxTree('expandItem', selectedItem.element);
			}
		});
		
		appendToContextMenu("Execute", function (selectedItem):Void 
		{
			Shell.openItem(selectedItem.value.path);
		});
		
		appendToContextMenu("Show Item In Folder", function (selectedItem):Void 
		{
			Shell.showItemInFolder(selectedItem.value.path);
		});
		
		appendToContextMenu("Rename...", function (selectedItem):Void 
		{			
			var path = selectedItem.value.path;
			
			Alertify.prompt(LocaleWatcher.getStringSync("Please enter new name for ") + path, function (e, str):Void 
			{
				if (e) 
				{
					var currentDirectory:String = Path.dirname(path);
					Mv.move(path, Path.join(currentDirectory, str), function (error):Void 
					{
						if (error == null) 
						{
							load();
						}
						else 
						{
							Alertify.error(error);
						}
					}
					);
				}
			}
			, Path.basename(path));
		}
		);
		
		appendToContextMenu("Delete...", function (selectedItem):Void 
		{
			var path = selectedItem.value.path;
			
			switch (selectedItem.value.type) 
			{
				case 'file':
					Alertify.confirm(LocaleWatcher.getStringSync("Remove file ") + path + " ?", function (e):Void 
					{
						if (e) 
						{
							Fs.unlink(path, function (error):Void 
							{
								if (error == null) 
								{
									untyped new JQuery('#filetree').jqxTree('removeItem', selectedItem.element);
									attachContextMenu();
								}
								else
								{
									Alertify.error(error);
								}
							}
							);
						}
					}
					);
				case 'folder':
					Alertify.confirm(LocaleWatcher.getStringSync("Remove folder ") + path + " ?", function (e):Void 
					{
						if (e) 
						{
							Remove.removeAsync(path, {}, function (error):Void 
							{
								if (error == null) 
								{
									untyped new JQuery('#filetree').jqxTree('removeItem', selectedItem.element);
									attachContextMenu();
								}
								else 
								{
									Alertify.error(error);
								}
							}
							);
						}
					}
					);
				default:
					
			}
		}
		);
		
		appendToContextMenu("Hide/Unhide All", function (selectedItem):Void 
		{
			if (ProjectAccess.path != null) 
			{
				ProjectAccess.currentProject.showHiddenItems = !ProjectAccess.currentProject.showHiddenItems;
				Alertify.success(LocaleWatcher.getStringSync("Hidden Items Visible: ") + Std.string(ProjectAccess.currentProject.showHiddenItems));
				
				if (!ProjectAccess.currentProject.showHiddenItems) 
				{
					Alertify.log("Hidden Items: \n" + Std.string(ProjectAccess.currentProject.hiddenItems));
				}
			}
			
			load();
		}
		);
		
		appendToContextMenu("Hide/Unhide", function (selectedItem):Void 
		{
			if (ProjectAccess.path != null) 
			{
				var path = selectedItem.value.path;
				
				if (!ProjectAccess.isItemHidden(path))
				{
					ProjectAccess.hideItem(path);
					untyped new JQuery('#filetree').jqxTree('removeItem', selectedItem.element);
					attachContextMenu();
				}
				else 
				{
					ProjectAccess.unhideItem(path);
					load();
				}
			}
			else 
			{
				untyped new JQuery('#filetree').jqxTree('removeItem', selectedItem.element);
			}
		}
		);
		
		appendToContextMenu("Set As Compile Main", function (selectedItem):Void
		{
			var path:String = selectedItem.value.path;
			
			if (RunProject.setHxmlAsProjectBuildFile(path))
			{
				
			}
		}
		);
		
		contextMenu = untyped new JQuery("#jqxMenu").jqxMenu({ autoOpenPopup: false, mode: 'popup' });
		
		attachContextMenu();
		
		// disable the default browser's context menu.
		new JQuery(Browser.document).on('contextmenu', function (e) {
			if (new JQuery(e.target).parents('.jqx-tree').length > 0) {
				return false;
			}
			return true;
		});
		
		new JQuery("#jqxMenu").on('itemclick', function (event) 
		{
			var item = Lambda.find(contextMenuCommandsMap, function (contextMenuItem)
						{
							return event.args == contextMenuItem.element;
						}
					   );
			
			item.cb();
		}
		);
		
		new JQuery('#filetree').dblclick(function (event):Void 
		{
			var item = untyped new JQuery('#filetree').jqxTree('getSelectedItem');
			
			if (item != null)
			{
				var value = item.value;
			
				if (value != null && value.type == 'file') 
				{
					var tabManager = TabManager.get();
					tabManager.openFileInNewTab(item.value.path);
				}
			}
		}
		);
		
		new JQuery('#filetree').bind('dragEnd', function (event) {
                var target = event.args.originalEvent.target;
                var targetParents = new JQuery(target).parents();
                var item:Dynamic = null;
                JQueryStatic.each(untyped new JQuery("#filetree").jqxTree('getItems'), function (index, value) {
                    if (value.label == event.args.label && value.value == event.args.value) {
                        item = value;
                        untyped __js__('return false');
                    }
                });
                if (item) {
                    var parents = new JQuery(item.element).parents('li');
                    var path = "";
					
                    JQueryStatic.each(parents, function (index, value) {
                        var item = untyped new JQuery("#filetree").jqxTree('getItem', value);
						
						if (item.level > 0) 
						{
							 path = item.label + "/" + path;
						}
                    });
					
					var topDirectory = untyped new JQuery("#filetree").jqxTree('getItems')[0].value.path;
					var selectedItem = untyped new JQuery("#filetree").jqxTree('getSelectedItem');
					
					var previousPath = selectedItem.value.path;
                    var newPath = Path.join(topDirectory, path, selectedItem.label);
					
					if (previousPath != newPath)
					{
						Mv.move(previousPath, newPath, function (error):Void 
						{
							if (error == null) 
							{
								Alertify.success("File were successfully moved to " + newPath);
								selectedItem.value.path = newPath;
								attachContextMenu();
							}
							else 
							{
								Alertify.error("Can't move file from " + previousPath + " to " + newPath);
								load();
							}
						}
						);
					}
                }
            });
	}
	
	static function updateProjectMainHxml()
	{
		var project = ProjectAccess.currentProject;
		
		var noproject = (ProjectAccess.path == null);
		
		var main = null;
		
		switch (project.type)
		{
			case Project.HAXE:
				if (!noproject)
				{
					main = Path.resolve(ProjectAccess.path, project.targetData[project.target].pathToHxml);
				}

			case Project.HXML:
				if (!noproject && project.main != null)
				{
					main = Path.resolve(ProjectAccess.path, project.main);
				}
			case Project.OPENFL:
			default:

		}
		
		var items:Array<Dynamic> = untyped new JQuery('#filetree').jqxTree('getItems');
				
		for (item in items)
		{
			var li = cast(item.element, LIElement);

			if (!noproject && main != null && item.value.path == main)
			{
				li.classList.add("mainHxml");
			}
			else
			{
				li.classList.remove("mainHxml");
			}
		}
	}

	function appendToContextMenu(name:String, onClick:Dynamic)
	{
		var li:LIElement = Browser.document.createLIElement();
		li.textContent = name;
		new JQuery("#filetreemenu").append(li);
		
		var contextMenuItem:ContextMenuItem = {};
		
		contextMenuItem.cb = function ():Void 
		{
			var selectedItem = untyped new JQuery('#filetree').jqxTree('getSelectedItem');
			if (selectedItem != null) 
			{
				onClick(selectedItem);
			}
		};
		
		contextMenuItem.element = li;
		
		contextMenuCommandsMap.set(name, contextMenuItem);
	}
	
	function attachContextMenu() 
	{
		// open the context menu when the user presses the mouse right button.
		new JQuery("#filetree li").on('mousedown', function (event) {			
			var target = new JQuery(event.target).parents('li:first')[0];
			var rightClick = isRightClick(event);
			if (rightClick && target != null) 
			{
				untyped new JQuery("#filetree").jqxTree('selectItem', target);
				var scrollTop = new JQuery(Browser.window).scrollTop();
				var scrollLeft = new JQuery(Browser.window).scrollLeft();
				
				var selectedItem = untyped new JQuery("#filetree").jqxTree('getSelectedItem');
				var extname = Path.extname(selectedItem.value.path);
				
				var editElement = contextMenuCommandsMap.get("Edit").element;
				
				if (selectedItem.value.type == "file")
				{
					editElement.textContent = "Edit";
				}
				else if (selectedItem.value.type == "folder")
				{
					editElement.textContent = "Open Folder";
				}
				
				var setAsCompileMainelement = contextMenuCommandsMap.get("Set As Compile Main").element;
				
				if (extname != ".hxml")
				{
					new JQuery(setAsCompileMainelement).hide();
				}
				else
				{
					new JQuery(setAsCompileMainelement).show();
				}
				
				if (ProjectAccess.path != null)
				{
					var hideUnhideItemElement = contextMenuCommandsMap.get("Hide/Unhide").element;
					
					if (!ProjectAccess.isItemHidden(selectedItem.value.path))
					{
						hideUnhideItemElement.textContent = "Hide";
					}
					else
					{
						hideUnhideItemElement.textContent = "Unhide";
					}
						
					var showHiddenItemsElement = contextMenuCommandsMap.get("Hide/Unhide All").element;
						
					if (ProjectAccess.currentProject.showHiddenItems)
					{
						showHiddenItemsElement.textContent = "Hide All";
					}
					else
					{
						showHiddenItemsElement.textContent = "Unhide All";
					}
				}
				
				contextMenu.jqxMenu('open', Std.parseInt(event.clientX) + 5 + scrollLeft, Std.parseInt(event.clientY) + 5 + scrollTop);
				return false;
			}
			else 
			{
				return true;
			}
		});
	}
	
	function isRightClick(event:Dynamic):Bool
	{
		var rightclick = null;
		if (!event) var event = Browser.window.event;
		if (event.which) rightclick = (event.which == 3);
		else if (event.button) rightclick = (event.button == 2);
		return rightclick;
	}
	
	public function load(?projectName:String, ?path:String):Void
	{        
		if (projectName == null)
		{
			projectName = lastProjectName;
		}
		
		if (path == null)
		{
			path = lastProjectPath;
		}
            
        var filetree:Dynamic = untyped new JQuery("#filetree");
        
        filetree.on('expand', function (event) 
        {
            var label = filetree.jqxTree('getItem', event.args.element).label;
            var element2 = new JQuery(event.args.element);
            var loader = false;
            var loaderItem:Dynamic = null;
            var children = element2.find('ul:first').children();
            jQuery.JQueryStatic.each(children, function (index, value) 
			{
                var item = filetree.jqxTree('getItem', value);
                if (item != null && item.label == "Loading...") 
                {
                    loaderItem = item;
                    loader = true;
                    untyped __js__("return false");
                };
            });
           	
            if (loader) 
            {
                var pathToItem:String = loaderItem.value;
                
            	var items:Array<TreeItem> = readDir2(pathToItem);
                
//                 for (i in 0...items.length)
//                 {
//                 	 items[i] = prepareForLazyLoading(items[i]);
//                 }
                
                filetree.jqxTree('addTo', items, element2[0]);
            	filetree.jqxTree('removeItem', loaderItem.element);
            	attachContextMenu();
            }
        });
		
		readDirItems(path, function (source:TreeItem):Void 
		{            
//             var source2:TreeItem = prepareForLazyLoading(source);
//             source2.expanded = true;
            
            untyped new JQuery('#filetree').jqxTree( { source: [source] } );
            attachContextMenu();
            			
			//var items = untyped new JQuery("#filetree").jqxTree('getItems');
			//trace(items);
		}, true);
		
		if (watcher != null) 
		{
			watcher.close();
			watcher = null;
		}
		
		var classpathWalker = ClasspathWalker.get();
			
		var config:WatchrConfig = {
			path: path,
			listener:
				function (changeType, filePath, fileCurrentStat, filePreviousStat):Void 
				{
					trace(changeType);
					trace(filePath);
					trace(fileCurrentStat);
					trace(filePreviousStat);
					
					switch (changeType) 
					{
						case 'create':
							trace(changeType);
							trace(filePath);
							//load();
							
							Fs.stat(filePath, function (error, stat:Stats):Void 
							{
								if (error == null) 
								{
									if (stat.isFile()) 
									{
										if (changeType == 'create') 
										{
											classpathWalker.addFile(filePath);
										}
										else
										{
											classpathWalker.removeFile(filePath);
										}
									}
									else if(stat.isDirectory()) 
									{
										trace(changeType);
										trace(filePath);
										//ClasspathWalker.parseProjectArguments();
									}
								}
								else 
								{
									trace(error);
								}
							}
							);
                        case 'delete':
                            if (Path.extname(filePath) != "")
                            {
                            	classpathWalker.removeFile(filePath);
                    		}
						default:
							
					}
				}
		};
		
		config.interval = 3000;
		
		watcher = Watchr.watch(config);
		
		lastProjectName = projectName;
		lastProjectPath = path;
		
		updateProjectMainHxml();
	}
	
	static function readDirItems(path:String, ?onComplete:Dynamic->Void, ?root:Bool = false)
	{
        var source:Dynamic = createFolderItem(path, []);
        source.expanded = true;
        
        source.items = readDir2(path);
        
        onComplete(source);
	}
	
    static function readDir2(path:String):Array<TreeItem>
	{
        var items:Array<TreeItem> = [];
        
        var pathToFolders:Array<String> = [];
        var pathToFiles:Array<String> = [];
        
        var fullPath:String;
        var stat:Stats;
        
        for (pathToItem in Fs.readdirSync(path))
        {      
            if (!SettingsWatcher.isItemInIgnoreList(pathToItem) && !ProjectAccess.isItemInIgnoreList(pathToItem))
            {
                fullPath = Path.join(path, pathToItem);
                stat = Fs.statSync(fullPath);

                if (stat.isDirectory())
                {
                    pathToFolders.push(fullPath);
                }
                else if(stat.isFile())
                {
                    pathToFiles.push(fullPath);
                }
            }
        }
        
        var type:String = null;
        type = "folder";
        
        var item:TreeItem = null;
        
        for (pathToItem in pathToFolders)
        {
             item = createFolderItem(pathToItem, []);
        	 item.items = [];
        	 item.items.push({label:"Loading...", value: pathToItem});
             items.push(item);
		}
    	
    	type = "file";
    
    	for (pathToItem in pathToFiles)
        {
             item = createFileItem(pathToItem);
             items.push(item);
		}

		return items;
	}
    
	static function createFileItem(path:String):TreeItem
	{
		var basename:String = Path.basename(path);
		var extname:String = Path.extname(basename);
		
		var data:TreeItem = { label: basename, value: {path: path, type: "file"} };
		
// 		switch (extname) 
// 		{
// 			case ".pdf":
// 				data.icon = "includes/images/page_white_acrobat.png";
// 			case ".swf":
// 				data.icon = "includes/images/page_white_flash.png";
// 			case ".jpg", ".jpeg", ".png", ".gif", ".tga":
// 				data.icon = "includes/images/photo.png";
// 			case ".html":
// 				data.icon = "includes/images/html.png";
// 			default:
				
// 		}
		
		return data;
	}
    
    static function createFolderItem(path:String, items:Array<TreeItem>):TreeItem
    {
    	return {label:Path.basename(path), items: items, value: {path: path, type: "folder"}}; //icon: "includes/images/folder.png"
    }
}
