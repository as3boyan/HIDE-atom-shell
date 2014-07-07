package tabmanager;
import js.npm.Pathwatcher;
import haxe.Timer;
import js.node.Fs;
import js.html.MouseEvent;
import js.html.Event;
import js.Browser;
import js.html.LIElement;
import js.html.SpanElement;
import js.Node;
import watchers.LocaleWatcher;
import watchers.Watcher;

/**
 * ...
 * @author AS3Boyan
 */
class Tab
{
	public var name:String;
	public var path:String;
	public var doc:CodeMirror.Doc;
	public var loaded:Bool;
	public var mtime:Float;
	var li:LIElement;
	var span3:SpanElement;
	var watcher:Dynamic;

	public function new(_name:String, _path:String, _doc:CodeMirror.Doc, ?_save:Bool)
	{
		name = _name;
		doc = _doc;
		path = _path;
		loaded = false;

		li = Browser.document.createLIElement();
		li.title = path;
		li.setAttribute("path", path);

		var tabManagerInstance = TabManager.get();

		span3 = Browser.document.createSpanElement();
		span3.textContent = name + "\t";
		li.addEventListener("click", function (e:MouseEvent):Void
		{
			if (e.button != 1)
			{
				tabManagerInstance.selectDoc(path);
			}
			else
			{
				tabManagerInstance.closeTab(path);
			}
		}
		);

		li.addEventListener("contextmenu", function (e):Void
		{
			ContextMenu.showMenu(path, e);
		}
		);

		li.appendChild(span3);

		var span:SpanElement = Browser.document.createSpanElement();
		span.style.position = "relative";
		span.style.top = "2px";

		span.addEventListener("click", function (e:Event):Void
		{
			tabManagerInstance.closeTab(path);
			e.stopPropagation();
		}
		);

		var span2:SpanElement = Browser.document.createSpanElement();
		span2.className = "glyphicon glyphicon-remove-circle";
		span.appendChild(span2);

		li.appendChild(span);

		if (_save)
		{
			save();
		}
			
		startWatcher();
	}

	public function startWatcher():Void
	{
		mtime = Date.now().getTime();
		
// 		watcher = Watcher.watchFileForUpdates(path, function ():Void
// 		{
// 			trace(path + " is updated");
			
// 			checkStat();
			
// 		}
// 		, 2100);
		
// 		trace("startWatcher");
		
		var watcher = Pathwatcher.watch(path, function (event, _path)
									   {										
										   switch (event)
										   {
											   case PathwatcherEvent.CHANGE:
												   checkStat();
											   case PathwatcherEvent.DELETE:
												   checkIfExistsAndStartWatching();
											   default:
												   trace(event);

										   }


									   });
	}

	function checkIfExistsAndStartWatching()
	{
		 Timer.delay(function ()
			 {											 
				 Fs.exists(path, function (exists2)
						  {														  
							  var tabManagerInstance = TabManager.get();

							  if (tabManagerInstance.tabMap.exists(path) && exists2 && Pathwatcher.getWatchedPaths().indexOf(path) == -1)
							  {		
								  Fs.stat(path, function (err, stat)
										 {
											 if (stat.mtime.getTime() > mtime)
											 {
												 dialogs.DialogManager.showReloadFileDialog(path, reloadFile);
											 }
												 
											 startWatcher();
										 });
							  }

						  });
			 }
			 , 1500);
	}
	
	function checkStat()
	{
		Fs.exists(path, function (exists)
					 {
						 if (exists)
						 {
							 Fs.stat(path, function (err, stats)
							   {
								   if (err == null)
								   {
									   if (stats.mtime.getTime() > mtime)
									   {
										   dialogs.DialogManager.showReloadFileDialog(path, reloadFile);
									   }

								   }
								   else
								   {
									   trace(err);
								   }

							   });
						 }
					 });
		
	}
	
    function reloadFile()
    {
		var tabManagerInstance = TabManager.get();

        tabManagerInstance.openFile(path,
		function (contents:String):Void
        {
            doc.setValue(contents);
			doc.markClean();
			setChanged(false);
			mtime = Date.now().getTime();
        }
        );
    }

	public function setChanged(changed:Bool):Void
	{
		span3.textContent = name;

		if (changed)
		{
			span3.textContent += "*";
		}

		span3.textContent += "\n";
	}

	public function remove():Void
	{
		li.remove();

		if (Pathwatcher.getWatchedPaths().indexOf(path) != -1 && watcher != null)
		{
			watcher.close();
			watcher = null;
		}
	}

	public function save():Void
	{
		Fs.writeFileSync(path, doc.getValue(), "utf8");
		doc.markClean();
		setChanged(false);
		
		mtime = Date.now().getTime();
	}
	
	public function getElement():LIElement
	{
		return li;
	}

}
