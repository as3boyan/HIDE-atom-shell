package tabmanager;
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
	public var mtime:Int;
	var li:LIElement;
	var span3:SpanElement;
	var watcher:Dynamic;
	var ignoreNextUpdates:Int;

	public function new(_name:String, _path:String, _doc:CodeMirror.Doc, ?_save:Bool)
	{
		ignoreNextUpdates = 0;

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
		watcher = Watcher.watchFileForUpdates(path, function ():Void
		{
			trace(path + " is updated");
			
			if (ignoreNextUpdates <= 0)
			{
				dialogs.DialogManager.showReloadFileDialog(path, reloadFile);
			}
			else
			{
				ignoreNextUpdates--;
			}
		}
		, 2100);
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

		if (watcher != null)
		{
			watcher.close();
			watcher = null;
		}
	}

	public function save():Void
	{
		ignoreNextUpdates++;

		Fs.writeFileSync(path, doc.getValue(), "utf8");
		doc.markClean();
		setChanged(false);
	}
	
	public function getElement():LIElement
	{
		return li;
	}

}
