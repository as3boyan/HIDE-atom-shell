package core;
import js.node.Fs;
import js.node.Path;
import js.node.fs.Stats;
import filetree.FileTree;
import js.Browser;
import openproject.OpenProject;

/**
 * ...
 * @author AS3Boyan
 */
class DragAndDrop
{	
	//If this plugin is selected as active in HIDE, then HIDE will call this function once on load	
	public static function prepare():Void
	{		
		Browser.window.addEventListener("dragover", function(e) 
		{
			e.preventDefault();
			e.stopPropagation();
			return false;
		}
		);
		
		Browser.window.addEventListener("drop", function(e:Dynamic) 
		{
			e.preventDefault();
			e.stopPropagation();
			
			for (i in 0...e.dataTransfer.files.length) 
			{
				var path:String = e.dataTransfer.files[i].path;
				Fs.stat(path, function (err, stats:Stats)
				{
					if (stats.isDirectory())
					{
						var filetreeInstance = FileTree.get();
						filetreeInstance.load(Path.basename(path), path);
					}
					else 
					{
						OpenProject.openProject(path);
					}
				}
				);
				
				
			}

			return false;
		}
		);
	}
	
}