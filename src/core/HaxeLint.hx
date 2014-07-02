package core;
import parser.OutlineHelper;
import cm.Xml;
import cm.Editor;
import haxe.ds.StringMap.StringMap;
import tabmanager.TabManager;

typedef Info = {
	var from:CodeMirror.Pos;
	var to:CodeMirror.Pos;
	var message:String;
	var severity:String;
}

/**
 * ...
 * @author 
 */
class HaxeLint
{
	public static var fileData:StringMap<Array<Info>> = new StringMap();
	public static var parserData:StringMap<Array<Info>> = new StringMap();

	public static function load():Void
	{
		CodeMirror.registerHelper("lint", "haxe", function (text:String) 
		{
			var found = [];
			
			var tabManagerInstance = TabManager.get();
			var path:String = tabManagerInstance.getCurrentDocumentPath();
			
			if (fileData.exists(path)) 
			{
				var data:Array<Info> = fileData.get(path);
				
				found = found.concat(data);
			}
			
			if (parserData.exists(path)) 
			{
				var data:Array<Info> = parserData.get(path);
				
				found = found.concat(data);
			}
			
			return found;
		}
		);
	}
	
	public static function updateLinting():Void
	{
		var annotationRuler = AnnotationRuler.get();
		annotationRuler.clearErrorMarkers();
		
		var tabManagerInstance = TabManager.get();
		var outlinePanel = OutlinePanel.get();
		var outlineHelper = OutlineHelper.get();
		var xmlInstance = Xml.get();
        var doc = tabManagerInstance.getCurrentDocument();
        
		if (doc != null)
		{
            if (doc.getMode().name == "haxe")
            {
               	try
                {
                    HaxeParserProvider.getClassName();
                }
                catch (e:Dynamic)
                {
                    trace(e);
                }

				var path:String = tabManagerInstance.getCurrentDocumentPath();
					
                outlineHelper.getList(doc.getValue(), path);

                if (fileData.exists(path)) 
                {
                    var data:Array<Info> = fileData.get(path);

                    for (item in data) 
                    {
                        annotationRuler.addErrorMarker(path, item.from.line, item.from.ch, item.message);
                    }
                }

                Editor.editor.setOption("lint", false);
                Editor.editor.setOption("lint", true); 
            }       
            else if (doc.getMode().name == "xml")
            {
                xmlInstance.generateXmlCompletion();
            }
        	else
           	{
                outlinePanel.clearFields();
            	outlinePanel.update();
            }
			
		}
    	else
        {
            outlinePanel.clearFields();
            outlinePanel.update();
        }
	}
	
}