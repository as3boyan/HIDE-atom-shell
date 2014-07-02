package cm;
#if !macro
import js.Error;
import js.node.Path;
import js.node.Fs;
import projectaccess.Project.FileData;
import parser.RegexParser;
import CodeMirror.Pos;
import core.Completion;
import core.FunctionParametersHelper;
import core.HaxeLint;
import core.HaxeParserProvider;
import core.Helper;
import core.Hotkeys;
import core.OutlinePanel;
import haxe.Json;
import haxe.Timer;
import jQuery.JQuery;
import js.Browser;
import js.html.DivElement;
import js.html.KeyboardEvent;
import js.html.svg.TextElement;
import js.html.TextAreaElement;
import js.Lib;
import js.Node;
import menu.BootstrapMenu;
import parser.OutlineHelper;
import projectaccess.ProjectAccess;
import tabmanager.TabManager;
import tjson.TJSON;
#end

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
#end
    
/**
 * ...
 * @author AS3Boyan
 */
class Editor
{	
	#if !macro
	
	public static var editor:CodeMirror;
	public static var regenerateCompletionOnDot:Bool;
	
	public static function load():Void
	{		
		regenerateCompletionOnDot = true;
		
// 		var readFileOptions:NodeFsFileOptions = {};
// 		readFileOptions.encoding = "utf8";
		
		var options:Dynamic = { };
		
		try 
		{
			options = TJSON.parse(Fs.readFileSync(Path.join("core", "config", "editor.json"), "utf8"));
		}
		catch (err:Error)
		{
			trace(err);
		}
		
		walk(options);
		
		var tabManagerInstance = TabManager.get();
		var completionInstance = Completion.get();
		var xmlInstance = cm.Xml.get();
		
		options.extraKeys = 
		{
			"." : 
				function passAndHint(cm) 
				{
					if (tabManagerInstance.getCurrentDocument().getMode().name == "haxe") 
					{
						var completionActive = editor.state.completionActive;
						var completionType = completionInstance.getCompletionType();
                        
						if ((completionType == CompletionType.REGULAR || completionType == CompletionType.CLASSLIST) && completionActive != null && completionActive.widget != null) 
						{
							completionActive.widget.pick();
						}
					}
					
					return CodeMirrorStatic.Pass;
				},
			";":
				function passAndHint(cm:CodeMirror) 
				{
					var cursor = editor.getCursor();
					var ch = editor.getRange(cursor, { line: cursor.line, ch: cursor.ch +1 } );
					
					if (ch == ";") 
					{
						cm.execCommand("goCharRight");
						return null;
					}
					else 
					{
						return CodeMirrorStatic.Pass;
					}
				},
           	"=":
				function passAndHint(cm2:CodeMirror) 
				{
                    var mode = tabManagerInstance.getCurrentDocument().getMode().name;
                    
					if (completionInstance.getCompletionType() == CompletionType.REGULAR && mode == "haxe" || mode == "xml")
					{
						var completionActive = cm2.state.completionActive;
						
						if (completionActive != null && completionActive.widget != null) 
						{
							completionActive.widget.pick();
						}
                            
                        if (mode == "xml")
                        {
                            var cur = cm2.getCursor();
                            cm2.replaceRange("=\"\"", cur, cur);
                            cm2.execCommand("goCharLeft");
                            xmlInstance.completeIfInTag(cm2);
							return null;
                        }
                        else
                        {
                            return CodeMirrorStatic.Pass;
                        }
                        
					}
					else
                    {
                        return CodeMirrorStatic.Pass;
                    }
					
				},
//             "\\\'(\\\'":
//             	function passAndHint(cm2:CodeMirror)
//             	{
//                     trace("test");
//                     cm.Xml.completeIfInTag(cm2);
//                     untyped __js__("return CodeMirror.Pass");
//                 },
            	
            "\\\'<\\\'":
            	function passAndHint(cm2:CodeMirror)
            	{
                    xmlInstance.completeAfter(cm2);
                    return CodeMirrorStatic.Pass;
                },
            	
            "\\\'/\\\'":
            	function passAndHint(cm2:CodeMirror)
            	{
                    xmlInstance.completeIfAfterLt(cm2);
                    return CodeMirrorStatic.Pass;
                },
            "\\\' \\\'":
                function passAndHint(cm2:CodeMirror)
            	{
                    xmlInstance.completeIfInTag(cm2);
                    return CodeMirrorStatic.Pass;
                },
            "Ctrl-J": "toMatchingTag"
		}
		
		editor = CodeMirror.fromTextArea(Browser.document.getElementById("code"), options);
        
		editor.on("keypress", function (cm:CodeMirror, e:KeyboardEvent):Void 
		{
			if (e.shiftKey) 
			{
                if (e.keyCode == 40 || e.keyCode == 62)
                {
                    if (completionInstance.getCompletionType() == CompletionType.REGULAR && tabManagerInstance.getCurrentDocument().getMode().name == "haxe")
                    {
                        var completionActive = editor.state.completionActive;

                        if (completionActive != null && completionActive.widget != null) 
                        {
                            completionActive.widget.pick();
                        }
                    }
                }
			}
		}
		);
		
		new JQuery("#editor").hide(0);
		
		loadThemes(getThemeList(), loadTheme);
		
		var value:String = "";
		var map = CodeMirror.keyMap.sublime;
		var mapK = untyped CodeMirror.keyMap["sublime-Ctrl-K"];
		
		  for (key in Reflect.fields(map)) 
		  {
			  //&& !/find/.test(map[key])
			if (key != "Ctrl-K" && key != "fallthrough")
			{
				value += "  \"" + key + "\": \"" + Reflect.field(map, key) + "\",\n";
			}
			  
		  }
		  for (key in Reflect.fields(mapK)) 
		  {
			if (key != "auto" && key != "nofallthrough")
			{
				value += "  \"Ctrl-K " + key + "\": \"" + Reflect.field(mapK, key) + "\",\n";
			}
			  
		  }
		
// 		trace(Editor.editor);
		
		Fs.writeFileSync(Path.join("core", "bindings.txt"), value, "utf8");
		
		Browser.window.addEventListener("resize", function (e)
		{			
			Helper.debounce("resize", function ():Void 
			{
				editor.refresh();
			}, 100);
			
			Timer.delay(resize, 50);
		}
		);
		
		new JQuery('#thirdNested').on('resize', 
		function (event) {       
			var panels = event.args.panels;
			
			resize();
		});
		
		ColorPreview.create(editor);
		
		editor.on("cursorActivity", function (cm:CodeMirror)
		{
			Helper.debounce("cursorActivity", function ():Void 
			{
				var functionParametersHelper = FunctionParametersHelper.get();
				functionParametersHelper.update(cm);
				ColorPreview.update(cm);
				ERegPreview.update(cm);
			}, 100);
			
			var doc = tabManagerInstance.getCurrentDocument();
			if (doc != null)
			{
				var pos = doc.getCursor();
				Browser.document.getElementById("status-cursor").textContent = "Line " + Std.string(pos.line + 1) + ", Column " + Std.string(pos.ch + 1);
			}
		}
		);
		
		editor.on("scroll", function (cm:CodeMirror):Void 
		{
			ColorPreview.scroll(editor);
		}
		);
		
		var timer:Timer = null;
		
		var basicTypes = ["Array", "Map", "StringMap"];
		
// 		var ignoreNewLineKeywords = ["function", "for ", "while"];
		
		editor.on("change", function (cm:CodeMirror, e:CodeMirror.ChangeEvent):Void 
		{			
            if (e.origin == "paste" && (e.from.line - e.to.line) > 0)
            {
                for (line2 in e.from.line...e.to.line)
                {
					cm.indentLine(line2);                
                }
            }
            
			var doc = tabManagerInstance.getCurrentDocument();
			var modeName:String = doc.getMode().name;
			
			if (modeName == "haxe") 
			{
				Helper.debounce("change", function ():Void 
				{
					HaxeLint.updateLinting();
				}, 100);
				
				var cursor = cm.getCursor();
				var data = cm.getLine(cursor.line);
				
				//if (StringTools.endsWith(e.text[0], ";")) 
				//{
					//var insertNewLine:Bool = true;
					//
					//for (keyword in ignoreNewLineKeywords) 
					//{
						//if (data.indexOf(keyword) != -1) 
						//{
							//insertNewLine = false;
							//break;
						//}
					//}
					//
					//cm.execCommand("newlineAndIndent");
				//}
				
				var lastChar = data.charAt(cursor.ch - 1);
				
				if (lastChar == ".")
                {
                    triggerCompletion(Editor.editor, true);
                }	
				else if (data.charAt(cursor.ch - 2) == "=" && lastChar == " ")
                {
                    var name = StringTools.trim(data.substring(0, cursor.ch - 2));
					
					var type = null;
					
					var ereg = ~/[a-z_0-9]+$/i;
					
					var start = name.length;
					
					while (start - 1 > 0 && ereg.match(name.charAt(start - 1))) 
					{
						start--;
					}

					name = name.substr(start);
					
					if (name != "" && name.indexOf(".") == -1)
					{						
						var variableDeclarations = RegexParser.getVariableDeclarations(doc.getValue());
						
						var variableWithExplicitType = [];
						
						for (item in variableDeclarations)
						{
							if (item.type != null)							
							{
								variableWithExplicitType.push(item);
							}
						}
							
						for (item in variableWithExplicitType)
						{
							if (name == item.name)
							{
								type = item.type;
								break;
							}	 
						}
						
						var suggestions = [];
					
						var value = doc.getValue();		
				
						if (type != null)
						{
							if (type == "Bool")
							{
								suggestions = ["false;", "true;"];
							}
							else if (StringTools.startsWith(type, "Array<"))
							{
								suggestions = ["["];
							}
							else if (type == "String")
							{
								suggestions = ["\""];
							}
							else if (type == "Dynamic")
							{
								suggestions = ["{"];
							}
							
							var variableWithSameType = [];
						
							for (item in variableWithExplicitType)
							{
								if (type == item.type)
								{
									variableWithSameType.push(item.name);
								}
							}
				
							for (item in variableWithSameType)
							{
// 								~/[\t ]*editor2[\t ]*= *(.+)$/gm
// 								~/[\t ]*editor2[\t ]*:[a-zA-Z0-9_]*[\t ]*= *(.+)$/gm
								 
								var ereg = new EReg("[\t ]*" + item + "[\t ]*= *(.+)$", "gm");
								var ereg2 = new EReg("[\t ]*" + item + "[\t ]*:[a-zA-Z0-9_<>]*[\t ]*= *(.+)$", "gm");
				
								ereg.map(value, function (ereg3)
										{
											var text = StringTools.trim(ereg3.matched(1));
											
											if (text != "" && suggestions.indexOf(text) == -1)
											{
												suggestions.push(text);
											}
											return "";
										});
				
								ereg2.map(value, function (ereg3)
										{
											var text = StringTools.trim(ereg3.matched(1));
											
											if (text != "" && suggestions.indexOf(text) == -1)
											{
												suggestions.push(text);
											}
											return "";
										});
							}
				
							suggestions.push("new " + type);
							completionInstance.showCodeSuggestions(suggestions);
						}
						else
						{
							trace(name);
							
							var ereg = new EReg("[\t ]*" + name + "[\t ]*= *(.+)$", "gm");
							
							ereg.map(value, function (ereg3)
										{
											var text = StringTools.trim(ereg3.matched(1));
											
											if (text != "" && suggestions.indexOf(text) == -1)
											{
												suggestions.push(text);
											}
											return "";
										});
							
							if (suggestions.length > 0)
							{
								completionInstance.showCodeSuggestions(suggestions);
							}
						}
					}
                }	
				else if (lastChar == ":")
				{
					if (data.charAt(cursor.ch - 2) == "@")
					{
						completionInstance.showMetaTagsCompletion();
					}
					else
					{
						var pos = {line: cursor.line, ch: cursor.ch - 1};
						var word = completionInstance.getCurrentWord(editor, {word: ~/[A-Z_0-9\.]+$/i}, pos);
						
						if (word.word == null || word.word != "default")
						{
							var len = 0;
							
							if (word.word != null)
							{
								len = word.word.length;
							}
							
							var dataBeforeWord = data.substring(0, pos.ch - len);
							dataBeforeWord = StringTools.trim(dataBeforeWord);
						
							if (!StringTools.endsWith(dataBeforeWord, "case"))
							{
								completionInstance.showClassList();
							}
						}
					}
				}
				else if (lastChar == "<")
				{
					for (type in basicTypes) 
					{
						if (StringTools.endsWith(data.substr(0, cursor.ch - 1), type)) 
						{
							completionInstance.showClassList();
							break;
						}
					}
				}
				else if (StringTools.endsWith(data, "import ")) 
				{                    
					completionInstance.showClassList(true);
				}
				else if (StringTools.endsWith(data, "in )"))
				{	
					var ereg = ~/for[\t ]*\([a-z_0-9]+[\t ]+in[\t ]+\)/gi;
					
					if (ereg.match(data))
					{
						triggerCompletion(editor, false);
					}
				}
				else if	(StringTools.endsWith(data, "new ") || StringTools.endsWith(data, "extends "))
				{
					completionInstance.showClassList(false);
				}
			}
			else if (modeName == "hxml") 
			{
				var cursor = cm.getCursor();
				var data = cm.getLine(cursor.line);
				
				if (data == "-")
				{
					completionInstance.showHxmlCompletion();
				}
                else if (data == "-cp ")
                {
                    completionInstance.showFileList(false, true);
                }
                else if (data == "-dce " || data == "-lib ")
                {
                    completionInstance.showHxmlCompletion();
				}
                else if (data == "--macro ")
               	{
                    completionInstance.showClassList(true);
                }
			}
			
			//Helper.debounce("filechange", function ():Void 
			//{
				var tab = tabManagerInstance.tabMap.get(tabManagerInstance.selectedPath);
				tab.setChanged(!tab.doc.isClean());
			//}
			//, 150);
			
			trace(e);

			if (["+input", "+delete"].indexOf(e.origin) != -1)
			{
// 				Helper.debounce("type", function ():Void
// 						   {
							 var text = e.text[0];
							 var removed = e.removed[0];
				
							   if (text != "\t" && text != " " && removed != "\t" && removed != " " && isValidWordForCompletionOnType())
							   {
								   var doc = tabManagerInstance.getCurrentDocument();
								   var pos = doc.getCursor();
								   
								   completionInstance.getCompletion(function ()
															{
																if (isValidWordForCompletionOnType())
																{
// 																	var pos2 = doc.getCursor();
																	
// 																	if (pos.line == pos2.line && pos.ch == pos2.ch)
// 																	{
																		completionInstance.showRegularCompletion(false);
// 																	}
																}
															}, pos);
							   }
								   
								
// 						   }, 500);
			}
		}
		);
		
		CodeMirror.prototype.centerOnLine = function(line) 
		{
			untyped __js__(" var h = this.getScrollInfo().clientHeight;  var coords = this.charCoords({line: line, ch: 0}, 'local'); this.scrollTo(null, (coords.top + coords.bottom - h) / 2); ");
		};

		editor.on("gutterClick", function (cm:CodeMirror, line:Int, gutter:String, e)
						{
							if (ProjectAccess.currentProject != null && gutter == "CodeMirror-foldgutter")
							{
								saveFoldedRegions();
							}
						});
	}
		
		static function isValidWordForCompletionOnType()
		{
			var isValid:Bool = false;
			
			var cm = editor;
			
			var tabManagerInstance = TabManager.get();
			var completionInstance = Completion.get();
			
			var doc = tabManagerInstance.getCurrentDocument();

		    if (doc != null && doc.getMode().name == "haxe")
		    {
				var completionActive = editor.state.completionActive;

				if (completionActive == null) 
				{
					var pos = doc.getCursor();

					var word = completionInstance.getCurrentWord(editor, {word: ~/[A-Z_0-9]+$/i}, pos);

					var type = cm.getTokenTypeAt(pos);

					var eregDigit = ~/[0-9]+$/i;
					
					if (word.word != null && type != "string" && type != "string-2")
					{
						if (word.word.length >= 1 && !eregDigit.match(word.word.charAt(0)))
						{
							var lineData = doc.getLine(pos.line);
							var dataBeforeWord = lineData.substring(0, pos.ch - word.word.length);

							if (!StringTools.endsWith(dataBeforeWord, "var ") && !StringTools.endsWith(dataBeforeWord, "function "))
							{													
								isValid = true;
							}
						}
					}
				}
		    }
				
			return isValid;
		}

		
	public static function saveFoldedRegions()
	{
		var tabManagerInstance = TabManager.get();
		
		var doc = tabManagerInstance.getCurrentDocument();
		
		if (doc != null && ProjectAccess.currentProject != null)
		{
			var cm = editor;
			var cursor = doc.getCursor();
			var foldedRegions:Array<Pos> = [];

			for (marker in doc.getAllMarks())
			{
				var pos = marker.find().from;

				if (cm.isFolded(pos))
				{
					foldedRegions.push(pos);
				}
			}

			var selectedFile = ProjectAccess.getFileByPath(tabManagerInstance.getCurrentDocumentPath());

			if (selectedFile != null)
			{
				selectedFile.foldedRegions = foldedRegions;
				selectedFile.activeLine = cursor.line;
				
				trace("folding regions saved successfully for" + Std.string(selectedFile));
			}
			else
			{
				trace("cannot save folded regions for this document");
			}
		}
		else
		{
			trace("unable to preserve code folding for" + Std.string(doc));
		}
	}

		
	public static function triggerCompletion(cm:CodeMirror, ?dot:Bool = false) 
	{
        trace("triggerCompletion");
        
		var tabManagerInstance = TabManager.get();
		var completionInstance = Completion.get();
		
		var modeName:String = tabManagerInstance.getCurrentDocument().getMode().name;
		
		switch (modeName)
		{
			case "haxe":
				//HaxeParserProvider.getClassName();
				
				if (!dot || regenerateCompletionOnDot || (dot && !cm.state.completionActive)) 
				{
					tabManagerInstance.saveActiveFile(function ():Void 
					{
						completionInstance.showRegularCompletion();
					});
				}
			case "hxml":
				completionInstance.showHxmlCompletion();
        	case "xml":
        		cm.showHint({completeSingle: false});
			default:
				
		}
	}
	
	private static function walk(object:Dynamic)
	{		
		var regexp = untyped __js__("RegExp");
		
		for (field in Reflect.fields(object))
		{
			var value = Reflect.field(object, field);
			
			if (Std.is(value, String)) 
			{
				if (StringTools.startsWith(value, "regexp")) 
				{
					try
					{
						Reflect.setField(object, field, Type.createInstance(regexp, [value.substring(6)]));
					}
					catch (err:Error)
					{
						trace(err);
					}
				}
				else if (StringTools.startsWith(value, "eval")) 
				{
					try 
					{
						Reflect.setField(object, field, Lib.eval(value.substring(4)));
					}
					catch (err:Error)
					{
						trace(err);
					}
				}
				
			}

			if (Reflect.isObject(value) && !Std.is(value, Array) && Type.typeof(value).getName() == "TObject") 
			{
				walk(value);
			}
		}
	}
	
	public static function resize():Void 
	{		
		var panels = untyped new JQuery('#thirdNested').jqxSplitter('panels');

		var height = Browser.window.innerHeight - 34 - new JQuery("ul.tabs").height() - panels[1].element[0].clientHeight - 5;
		new JQuery(".CodeMirror").css("height", Std.string(Std.int(height)) + "px");
		
		new JQuery("#annotationRuler").css("height", Std.string(Std.int(height - 1)) + "px");
	}
	
	static function loadTheme() 
	{
		var localStorage2 = Browser.getLocalStorage();
		
		if (localStorage2 != null)
		{
			var theme:String = localStorage2.getItem("theme");
			
			if (theme != null) 
			{
				setTheme(theme);
			}
			else
			{
            	setTheme("mbo");
			}
		}
		
	}
	
	static function loadThemes(themes:Array<String>, onComplete:Dynamic):Void
	{
		var themesSubmenu = BootstrapMenu.getMenu("View").getSubmenu("Themes");
		var theme:String;
		
		var pathToThemeArray:Array<String> = new Array();
		
		themesSubmenu.addMenuItem("default", 0, setTheme.bind("default"));
		
		for (i in 0...themes.length)
		{
			theme = themes[i];
			themesSubmenu.addMenuItem(theme, i + 1, setTheme.bind(theme));
		}
		
		onComplete();
	}
	
	public static function setTheme(theme:String):Void
	{
		editor.setOption("theme", theme);
		Browser.getLocalStorage().setItem("theme", theme);
	}
	
	#end
	
	macro public static function getThemeList() 
	{
		var p = Context.currentPos();
		var result = [];
		
		for (theme in sys.FileSystem.readDirectory(Sys.getCwd() + "libs/js/CodeMirror/theme")) 
		{
			var basename = theme.split(".").shift();
			var eConst = EConst(CString(basename));
			result.push( { expr: eConst, pos: p } );
		}
        
//         for (theme in sys.FileSystem.readDirectory(Sys.getCwd() + "libs/css/theme"))
// 		{
// 			var eConst = EConst(CString(theme.split(".").shift()));
// 			result.push( { expr: eConst, pos: p } );
// 		}
		
		return { expr: EArrayDecl(result), pos: p };
    }
}
