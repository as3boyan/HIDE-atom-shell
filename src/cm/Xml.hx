package cm;
import parser.ClassParser;
import haxe.xml.Fast;
import haxe.xml.Parser;
import tabmanager.TabManager;
import haxe.Timer;

/**
* @author 
 */
class Xml
{
	static var instance:Xml;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new Xml();
		}
			
		return instance;
	}
	
    var tags:Dynamic;
    
    public function generateXmlCompletion()
    {
		var tabManagerInstance = TabManager.get();
		
        var data = tabManagerInstance.getCurrentDocument().getValue();
        
        var xml = null;
        
        try
        {
            xml = Parser.parse(data);
        }
        catch (unknown:Dynamic)
        {
            trace(unknown);
        }
        
        var tags:Dynamic = {"!attrs": {}};
            
		if (xml != null)
        {
            var fast = new Fast(xml);
            walkThroughElements(tags, fast);
            cm.Editor.editor.setOption("hintOptions", {schemaInfo: tags});
        }
        
        
//         var dummy = {
//         attrs: {
//           color: ["red", "green", "blue", "purple", "white", "black", "yellow"],
//           size: ["large", "medium", "small"],
//           description: null
//         },
//         children: []
//     };
        
//         var a = untyped __js__("class");
        
//         tags = {
//         "!top": ["top"],
//         "!attrs": {
//           id: null
// //           a: ["A", "B", "C"]
//         },
//         top: {
//           attrs: {
//             lang: ["en", "de", "fr", "nl"],
//             freeform: null
//           },
//           children: ["animal", "plant"]
//         },
//         animal: {
//           attrs: {
//             name: null,
//             isduck: ["yes", "no"]
//           },
//           children: ["wings", "feet", "body", "head", "tail"]
//         },
//         plant: {
//           attrs: {name: null},
//           children: ["leaves", "stem", "flowers"]
//         },
//         wings: dummy, feet: dummy, body: dummy, head: dummy, tail: dummy,
//         leaves: dummy, stem: dummy, flowers: dummy
//       };
	}
    
    function walkThroughElements(tags:Dynamic, fast:Fast)
    {
        for (element in fast.elements)
        {
            if (Reflect.field(tags, element.name) == null)
            {
                Reflect.setField(tags, element.name, {attrs: {}});
            }
             
            var attrs:Dynamic = Reflect.field(tags, element.name).attrs;
        
            for (attribute in element.x.attributes())
            {
                var values:Array<String>;
                 
                if (Reflect.field(attrs, attribute) == null)
                {
                    values = [];
                    Reflect.setField(attrs, attribute, values);
                    
                    if (attribute == "path")
                    {
						for (item in ClassParser.filesList)
                        {
                            values.push(item.path);
                        }
                    }
                }
        		else
               	{
                    values = Reflect.field(attrs, attribute);
                }

        		var value = element.att.resolve(attribute);
        		
        		if (values.indexOf(value) == -1)
                {
                    values.push(value);
                }
            }
             
            Reflect.setField(tags, element.name, {attrs: attrs});
        	walkThroughElements(tags, element);
        }
    }

	public function completeAfter(cm:CodeMirror, ?pred:Dynamic) 
    {
        var cur = cm.getCursor();
        if (pred == null || pred() != null)
        {
			Timer.delay(function() 
            {
                if (cm.state.completionActive == null)
                {
                    cm.showHint({completeSingle: false});
                }
            }, 100);
        }
        
        return CodeMirrorStatic.Pass;
    }
    
    public function completeIfAfterLt(cm:CodeMirror) 
    {
        return completeAfter(cm, function() {
          var cur = cm.getCursor();
            return cm.getRange({line: cur.line, ch: cur.ch - 1}, cur) == "<";
        });
    }
    
	public function completeIfInTag(cm:CodeMirror) 
    {
        return completeAfter(cm, function() {
          var tok = cm.getTokenAt(cm.getCursor());
          if (tok.type == "string" && (!~/['"]/.match(tok.string.charAt(tok.string.length - 1)) || tok.string.length == 1)) return false;
          var inner = CodeMirrorStatic.innerMode(cm.getMode(), tok.state).state;
          return inner.tagName;
        });
	}
}