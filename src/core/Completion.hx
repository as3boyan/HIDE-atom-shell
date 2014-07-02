package core;
import js.node.Path;
import haxe.Timer;
import completion.Hxml.CompletionData;
import parser.RegexParser;
import cm.Editor;
import CodeMirror;
import completion.Filter;
import completion.Hxml;
import completion.MetaTags;
import completion.SnippetsCompletion;
import haxe.ds.StringMap.StringMap;
import haxe.xml.Fast;
import js.Browser;
import js.html.DivElement;
import js.html.SpanElement;
import js.Node;
import openproject.OpenFL;
import parser.ClassParser;
import projectaccess.Project;
import projectaccess.ProjectAccess;
import tabmanager.TabManager;

/**
 * ...
 * @author AS3Boyan
 */
enum CompletionType
{
	REGULAR;
	FILELIST;
	PASTEFOLDER;
    OPENFILE;
	CLASSLIST;
	HXML;
	METATAGS;
}

typedef CompletionItem = 
{
	@:optional
	var d:String;
	@:optional
	var t:String;
	var n:String;
}
    
typedef TopLevelImport =
{
    name:String,
    ?fullName:String
}

class Completion
{
	var list:Array<CompletionData>;
	var editor:CodeMirror;
	var word:EReg;
	var range:Int;
	var cur:Pos;
	var end:Int;
	var start:Int;
	var WORD:EReg = ~/[A-Z_0-9]+$/i;
	var RANGE = 500;
	public var curWord:String;
	public var completions:Array<CompletionItem> = [];
	public var declarationPositions:Array<String> = [];
	var completionType:CompletionType = REGULAR;
	var completionActive:Bool;
    
	static var instance:Completion;
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new Completion();
		}
			
		return instance;
	}
	
	public function new() 
	{
		
	}
	
	public function load()
	{
		Hxml.load();
		MetaTags.load();
		
		var snippetsCompletion = SnippetsCompletion.get();
		
		snippetsCompletion.load();
		
        completionActive = false;
        
        Editor.editor.on("endCompletion", function ()
                        {
                            completionActive = false;
                        });
	}

	
	function getHints(cm:CodeMirror, ?options:Dynamic): { list: Array<CompletionData>, from: CodeMirror.Pos, to: CodeMirror.Pos }
	{		
		word = null;
		
		range = null;
		
		if (options != null && options.range != null)
		{
			range = options.range;
		}
		else if (RANGE != null)
		{
			range = RANGE;
		}
		
		list = new Array();

		switch (completionType) 
		{
			case REGULAR:
				for (completion in completions) 
				{
					var completionItem = generateCompletionItem(completion.n, completion.t, completion.d);
					list.push(completionItem);
				}
        		
        		getCurrentWord(cm, {word: ~/[A-Z_0-9.]+$/i});
        
        		var className = "CodeMirror-Tern-completion";	
        
				if (curWord == null || curWord.indexOf(".") == -1)
                    
				{
					var tabManagerInstance = TabManager.get();
					
					var doc = tabManagerInstance.getCurrentDocument();
					
					if (doc != null)
					{
						var data = doc.getRange({line: 0, ch: 0}, {line: cm.getCursor().line + 1, ch: 0});
						
						var functionParams = RegexParser.getFunctionParameters(data, doc.getCursor());
						
						for (item in functionParams)
						{
							var completionItem = generateCompletionItem(item.name, item.type);
							list.push(completionItem);
						}
						
						var variableDeclarations = RegexParser.getVariableDeclarations(data);
						
						for (item in variableDeclarations)
						{
							var completionItem = generateCompletionItem(item.name, item.type);
							list.push(completionItem);
						}
						
						var functionDeclarations = RegexParser.getFunctionDeclarations(doc.getValue());

						for (item in functionDeclarations)
						{
							if (item.name != "")
							{
								var completionData = generateFunctionCompletionItem(item.name, item.params);
								var completionItem = createCompletionItem(item.name, null, completionData);
								list.push(completionItem);
							}
						}
					}
					
					var snippetsCompletion = SnippetsCompletion.get();

				    list = list.concat(snippetsCompletion.getCompletion());

                    var classList = getClassList();
                    
					var packages:Array<String> = [];				
	
                    for (item in classList.topLevelClassList)
                    {
                        var completion:CompletionData = {text: item.name };
                        completion.className = className + " CodeMirror-Tern-completion-class";
                    	list.push(completion);
                    }

					for (list in [ClassParser.importsList, ClassParser.haxeStdImports])
					{
						for (item in list)
						{
							var str = item.split(".")[0];
	
							if (packages.indexOf(str) == -1 && str.charAt(0) == str.charAt(0).toLowerCase())
							{
								packages.push(str);
							}	 
						}
					}

					for (item in packages)
					{
						var completion:CompletionData = {text: item };
                        completion.className = className + " CodeMirror-Tern-completion-package";
                    	list.push(completion);
					}
				}
			case METATAGS:
				list = MetaTags.getCompletion();
			case HXML:
				list = Hxml.getCompletion().copy();
        
        		for (list2 in [ClassParser.topLevelClassList, ClassParser.importsList, ClassParser.haxeStdTopLevelClassList, ClassParser.haxeStdImports])
                {
                	for (item in list2) 
                    {
                        list.push( { text: item} );
                    }
                }
			case FILELIST:
        		var displayText:String;
        
				for (list2 in [ClassParser.filesList, ClassParser.haxeStdFileList])
                {
                    for (item in list2) 
                    {                    
                        list.push( { text: item.path, displayText: processDisplayText(item.path)} );
                    }
				}
            case PASTEFOLDER:
        		var displayText:String;
        
        		for (item in ClassParser.filesList) 
				{
					list.push( { text: item.directory, displayText: processDisplayText(item.path)} );
				}
			case CLASSLIST:
				var classList = getClassList();
                     
				var className = "CodeMirror-Tern-completion";

                for (item in classList.topLevelClassList)
                {
                    var completion:CompletionData = {text: item.name };
                    completion.className = className + " CodeMirror-Tern-completion-class";
                    list.push(completion);
                }
                    
                for (item in classList.importsList)
                {
                    var completion:CompletionData = {text: item};
                    completion.className = className + " CodeMirror-Tern-completion-class";
                    list.push(completion);
                }

			default:
				
		}
		
    	getCurrentWord(cm, options);
    
		list = Filter.filter(list, curWord, completionType);
		
		var data:Dynamic = { list: list, from: { line:cur.line, ch:start }, to: { line:cur.line, ch:end } };
		CodeMirrorStatic.attachContextInfo(Editor.editor, data);

		switch (completionType)
        {
        	case REGULAR, CLASSLIST:
                CodeMirrorStatic.on(data, "pick", searchForImport);
            default:
        }

		return data;
	}
	
    function searchForImport(completion:CompletionData)
    {
        var cm = Editor.editor;
        
        var cursor = cm.getCursor();
        var curLine:String = cm.getLine(cursor.line);
        
		if (!StringTools.startsWith(curLine, "import "))
		{
			var word = ~/[A-Z_0-9\.]+$/i;
        
			var importStart = cursor.ch;
			var importEnd = importStart;

			while (importStart > 0 && word.match(curLine.charAt(importStart - 1))) --importStart;

			if (importStart != importEnd) 
			{
				var fullImport = curLine.substring(importStart, importEnd);

				if (fullImport.indexOf(".") != -1)
				{
					var topLevelClassList = getClassList().topLevelClassList;
					ImportDefinition.searchImportByText(topLevelClassList, fullImport, {line: cursor.line, ch:importStart}, {line: cursor.line, ch:importEnd}, false);
				}
			}
		}
    }
	
    public function processDisplayText(displayText:String):String
    {
        if (displayText.length > 70)
        {
            displayText = displayText.substr(0, 35) + " ... " + displayText.substr(displayText.length - 35);
        }
            
        return displayText;
    }
    
	public function getCurrentWord(cm:CodeMirror, ?options:Dynamic, ?pos:Pos):{word:String, from:CodeMirror.Pos, to:CodeMirror.Pos}
	{
		if (options != null && options.word != null)
		{
			word = options.word;
		}
		else if (WORD != null)
		{
			word = WORD;
		}
		
		if (pos != null) 
		{
			cur = pos;
		}
		
		var curLine:String = cm.getLine(cur.line);
		start = cur.ch;
		
		end = start;
		
		while (end < curLine.length && word.match(curLine.charAt(end))) ++end;
		while (start > 0 && word.match(curLine.charAt(start - 1))) --start;
		
		curWord = null;
		
		if (start != end) 
		{
			curWord = curLine.substring(start, end);
		}
		
		return {word:curWord, from: {line:cur.line, ch: start}, to: {line:cur.line, ch: end}};
	}
	
	public function getCompletion(onComplete:Dynamic, ?_pos:Pos, ?mode:String, ?moveCursorToStart:Bool = true):Void
	{        
		if (ProjectAccess.path != null) 
		{
			var projectArguments:Array<String> = [];
			//= ProjectAccess.currentProject.args.copy();
			
			var project = ProjectAccess.currentProject;
            
			switch (project.type)
			{
				case Project.HAXE:
					var pathToHxml:String = project.targetData[project.target].pathToHxml;
					projectArguments.push(pathToHxml);
					processArguments(projectArguments, onComplete, _pos, mode, moveCursorToStart);
				case Project.HXML:
					projectArguments.push(project.main);
					processArguments(projectArguments, onComplete, _pos, mode, moveCursorToStart);
				case Project.OPENFL:
					OpenFL.parseOpenFLDisplayParameters(ProjectAccess.path, project.openFLTarget, function (args:Array<String>):Void 
					{
						projectArguments = args;
						processArguments(projectArguments, onComplete, _pos, mode, moveCursorToStart);
					}
					);
				default:
					
			}
		}
	}
	
	function processArguments(projectArguments:Array<String>, onComplete:Dynamic, ?_pos:Pos, mode:String, moveCursorToStart:Bool):Void 
	{
        trace("processArguments");
        
		projectArguments.push("--no-output");
		projectArguments.push("--display");
		
		var cm:CodeMirror = Editor.editor;
		cur = _pos;
		
		if (cur == null) 
		{
			cur = cm.getCursor();
		}
		
		getCurrentWord(cm, null, cur);
		
		if (curWord != null) 
		{
			cur = {line: cur.line,  ch:start};
		}
			
		if (moveCursorToStart == false)
		{
// 			cur.ch = cm.getCursor().ch;
			cur.ch = end;
			
			if (mode == "position")
			{
				cur.ch += 1;
			}

// 			trace(cm.getRange({line:cur.line, ch: 0}, {line:cur.line, ch:end}));
		}
		
		var tabManagerInstance = TabManager.get();
			
		var displayArgs = tabManagerInstance.getCurrentDocumentPath() + "@" + Std.string(cm.indexFromPos(cur));
		
		if (mode != null)
		{
			displayArgs += "@" + mode;
		}
			
		projectArguments.push(displayArgs);
		
		completions = [];
		declarationPositions = [];
		
		var params = ["--connect", "5000", "--cwd", HIDE.surroundWithQuotes(ProjectAccess.path)].concat(projectArguments);
		trace(params);
		var pathToHaxe = HaxeHelper.getPathToHaxe();
		
		var processHelper = ProcessHelper.get();
		
		processHelper.runProcess(pathToHaxe, params, null, function (stdout:String, stderr:String)
		{
			generateCompletion(stderr);
			onComplete();
		}, 
		function (code:Int, stdout:String, stderr:String)
		{
			trace(code);
			trace(stderr);
			
			generateCompletion(stderr);
			onComplete();
		}
		);
	}
	
	function generateCompletion(stderr:String)
	{
		var data = stderr;
		var index = stderr.indexOf("<list>");

		if (index == -1)
		{
			index = stderr.indexOf("<pos>");
		}

		if (index != -1)
		{
			if (index != 0)
			{
				data = data.substring(index);	
			}
		}

		var xml:Xml = Xml.parse(data);

		var fast = new Fast(xml);

		if (fast.hasNode.list)
		{
			var list = fast.node.list;
			var completion:CompletionItem;

			if (list.hasNode.i)
			{
				for (item in list.nodes.i) 
				{
					if (item.has.n)
					{
						completion = {n: item.att.n};

						if (item.hasNode.d)
						{
							var str = StringTools.trim(item.node.d.innerHTML);
							str = StringTools.replace(str, "\t", "");
							str = StringTools.replace(str, "\n", "");
							str = StringTools.replace(str, "*", "");
							str = StringTools.replace(str, "&lt;", "<");
							str = StringTools.replace(str, "&gt;", ">");
							str = StringTools.trim(str);
							completion.d = str;
						}

						if (item.hasNode.t)
						{
							completion.t = item.node.t.innerData;
						}

						completions.push(completion);
					}
				}
			}
		}
		else if (fast.hasNode.pos)
		{
			for (item in fast.nodes.pos)
			{
				 declarationPositions.push(item.innerData);
			}

		}
	}

    function getHintAsync(cm:CodeMirror, c:Dynamic->Void)
	{
        if (completionActive)
        {
            c(getHints(cm));
        }
        else
        {
            getCompletion(function ()
                                     {
                                         c(getHints(cm));
                                     });
            
            completionActive = true;
			
        }
    }
        
	public function isEditorVisible():Bool
	{
		var editor = cast(Browser.document.getElementById("editor"), DivElement);
		return editor.style.display != "none";
	}
	
	public function showRegularCompletion(?getCompletionFromHaxeCompiler:Bool = true):Void
	{
		if (isEditorVisible()) 
		{
			Editor.regenerateCompletionOnDot = true;
			WORD = ~/[A-Z_0-9]+$/i;
			completionType = REGULAR;
            
			var cm = Editor.editor;
			
            if (!getCompletionFromHaxeCompiler)
			{
				completionActive = true;
			}
			
			var hint:Dynamic = getHintAsync;
			hint.async = true;
			cm.showHint({hint: hint, completeSingle: false});
		}
	}
	
	public function showMetaTagsCompletion():Void
	{
		if (isEditorVisible()) 
		{
            cur = Editor.editor.getCursor();
            Editor.regenerateCompletionOnDot = false;
			WORD = ~/[A-Z_0-9@:]+$/i;
			completionType = METATAGS;
			CodeMirrorStatic.showHint(Editor.editor, getHints, { closeCharacters: untyped __js__("/[\\s()\\[\\]{};>,]/") } );
		}
	}
        
	public function showHxmlCompletion():Void
	{
		if (isEditorVisible()) 
		{
            cur = Editor.editor.getCursor();
            Editor.regenerateCompletionOnDot = false;
			WORD = ~/[A-Z_0-9- \.\\\/]+$/i;
			completionType = HXML;
			CodeMirrorStatic.showHint(Editor.editor, getHints, { closeCharacters: untyped __js__("/[()\\[\\]{};:>,]/") } );
		}
	}
	
//     Quick Open/Show File List for Hxml completion
	public function showFileList(?openFile:Bool = true, ?insertDirectory:Bool = false):Void
	{		
        if (openFile)
        {
            completionType = OPENFILE;
			
			var quickOpen = QuickOpen.get();
			
            quickOpen.show(ClassParser.filesList.copy().concat(ClassParser.haxeStdFileList));
        }
        else if (isEditorVisible()) 
		{
            cur = Editor.editor.getCursor();
			Editor.regenerateCompletionOnDot = false;
			WORD = ~/[A-Z_0-9-\.\\\/]+$/i;
            
            if (insertDirectory == false)
            {
                completionType = FILELIST;
            }
            else
            {
                completionType = PASTEFOLDER;
            }
                
            CodeMirrorStatic.showHint(Editor.editor, getHints);
		}
	}
	
//     Shows list of all classes available for project, used to provide imports completion("import |"), triggered on ":" symbol
	public function showClassList(?ignoreWhitespace:Bool = false):Void
	{
		if (isEditorVisible()) 
		{
            cur = Editor.editor.getCursor();
			Editor.regenerateCompletionOnDot = true;
			WORD = ~/[A-Z_0-9\.]+$/i;
			completionType = CLASSLIST;
            
//             default closeCharacters value
//             "/[\s()\[\]{};:>,]/"
			
			var closeCharacters = untyped __js__("/[\\s()\\[\\]{};>,]/");
			
			if (ignoreWhitespace) 
			{
				closeCharacters = untyped __js__("/[()\\[\\]{};>,]/");
			}
			
			CodeMirrorStatic.showHint(Editor.editor, getHints, { closeCharacters: closeCharacters  } );
		}
	}
	
// 	static function getImportHints(cm:CodeMirror)
// 	{
        
//     }

	function searchImage(name:String, ?type:String, ?description:String)
	{
		var functionParametersHelper = FunctionParametersHelper.get();
		
		var functionData = functionParametersHelper.parseFunctionParams(name, type, description);
		
		var info:String = null;

		var className = "CodeMirror-Tern-completion";

		if (functionData.parameters != null) 
		{
			var data = generateFunctionCompletionItem(name, functionData.parameters);
			className = data.className;
			info = data.info + ":" + functionData.retType;
		}
		else if (type != null)
		{
			info = type;

			switch (info) 
			{
				case "Bool":
					className += " CodeMirror-Tern-completion-bool";
				case "Float", "Int", "UInt":
					className += " CodeMirror-Tern-completion-number";
				case "String":
					className += " CodeMirror-Tern-completion-string";
				default:
					if (info.indexOf("Array") != -1) 
					{
						className += " CodeMirror-Tern-completion-array";
					}
					else if(info.indexOf("Map") != -1 || info.indexOf("StringMap") != -1) 
					{
						className += " CodeMirror-Tern-completion-map";
					}
					else 
					{
						className += " CodeMirror-Tern-completion-object";
					}
			}
		}
			
		return {className: className, info: info};
	}

	function generateFunctionCompletionItem(name:String, params:Array<String>)
	{
		var info:String = null;

		var className = "CodeMirror-Tern-completion";
		
		info = name + "(";
		
		if (params != null)
		{
			info += params.join(", ");
		}
			
		info += ")";
		
		className += " CodeMirror-Tern-completion-fn";
		
		return {className: className, info: info};
	}

	function generateCompletionItem(name:String, ?type:String, ?description:String)
	{
		var completionData = searchImage(name, type, description);
		return createCompletionItem(name, description, completionData);
	}

	function createCompletionItem(name:String, description:String, completionData:Dynamic)
	{
		var completionItem:CompletionData = { text: name };

		completionItem.className = completionData.className;	

		var infoSpan:SpanElement = Browser.document.createSpanElement();

		if (completionData.info != null)
		{
			var infoTypeSpan:SpanElement = Browser.document.createSpanElement();
			infoTypeSpan.textContent = completionData.info;
			infoSpan.appendChild(infoTypeSpan);

			infoSpan.appendChild(Browser.document.createElement("br"));
			infoSpan.appendChild(Browser.document.createElement("br"));
		}

		if (description != null)
		{
			var infoDescriptionSpan:SpanElement = Browser.document.createSpanElement();
			infoDescriptionSpan.className = "completionDescription";
			infoDescriptionSpan.innerHTML = description;
			infoSpan.appendChild(infoDescriptionSpan);
		}

		if (completionData.info != null || description != null)
		{
			completionItem.info = function (completionItem) 
			{
				return infoSpan;
			};
		}

		return completionItem;
	}


	public function showImportDefinition(importsSuggestions:Array<String>, ?from:CodeMirror.Pos, ?to:CodeMirror.Pos)
	{
        var cm = Editor.editor;
        
        CodeMirrorStatic.showHint(cm, function ()
            {
                var completions:Array<CompletionData> = [];
                
                var completion:CompletionData;
                
                for (item in importsSuggestions)
                {
                     completion = {};
                     completion.text = item;
                     completion.displayText = "import " + item;
                     completion.hint = ImportDefinition.importClassHint.bind(from, to);
                     completions.push(completion);
				}
        		
				var pos = cm.getCursor();
                                  
        		var data:Dynamic = { list: completions, from: pos, to: pos };
        		return data;
            }
        , {completeSingle: false});
    }
		
	public function showActions(completions:Array<CompletionData>)
	{
		var cm = Editor.editor;
        
        CodeMirrorStatic.showHint(cm, function ()
            {        		
				var pos = cm.getCursor();
                                  
        		var data:Dynamic = { list: completions, from: pos, to: pos };
        		return data;
            }
        , {completeSingle: false});
	}

		
	public function showCodeSuggestions(suggestions:Array<String>)
	{
		var cm = Editor.editor;
        
        CodeMirrorStatic.showHint(cm, function ()
            {
                var completions:Array<CompletionData> = [];
                
                var completion:CompletionData;
                
				var pos = cm.getCursor();
				
				var word = getCurrentWord(cm, {word: ~/[A-Z_0-9]+$/i}, pos).word;
				
                for (item in suggestions)
                {
					 if (word == null || StringTools.startsWith(item, word))
					 {
						 completion = {};
						 completion.text = item;
						 completions.push(completion); 
					 } 
				}
                                  
				var data:Dynamic = { list: completions, from: {line: pos.line, ch: start}, to: {line: pos.line, ch: end} };
        		return data;
            }
        , {completeSingle: false});
	}
	
    public function getClassList()
    {
		var tabManagerInstance = TabManager.get();
		
        var value = tabManagerInstance.getCurrentDocument().getValue();
		var mainClass = Path.basename(tabManagerInstance.getCurrentDocumentPath(), ".hx");

        var filePackage = RegexParser.getFilePackage(value);
        var fileImports = RegexParser.getFileImportsList(value);

        var topLevelClassList:Array<TopLevelImport> = [];
        var importsList:Array<String> = [];
        
        var relativeImport:String = null;

        var parentPackages:Array<String> = [];
        
        if (filePackage.filePackage != null && filePackage.filePackage != "")
        {
            var packages = filePackage.filePackage.split(".");

            var parentPackage:String;

            while (packages.length > 0)
            {
                parentPackage = packages.join(".");
                packages.pop();
                parentPackages.push(parentPackage);
            }
        }
        
        var found:Bool;
            
        for (list2 in [ClassParser.importsList, ClassParser.haxeStdImports])
        {
            for (item in list2) 
            {
                found = false;
                
                for (parentPackage in parentPackages)
                {
                	if (StringTools.startsWith(item, parentPackage + ".") && item.indexOf(".", parentPackage.length + 1) == -1)
                    {
                        relativeImport = item.substr(parentPackage.length + 1);
                        topLevelClassList.push({name: relativeImport, fullName: item});
                        found = true;
                        break;
                    }
                }
                
            	if (!found)
                {
                    if (fileImports.indexOf(item) != -1)
                    {
                        relativeImport = item.split(".").pop();
                        topLevelClassList.push({name: relativeImport, fullName: item});
                    }
                    else if (filePackage.filePackage != null && filePackage.filePackage != "" && StringTools.startsWith(item, filePackage.filePackage + "."))
                    {
						relativeImport = item.substr(filePackage.filePackage.length + 1);
						
						trace(relativeImport);
						
						if (StringTools.startsWith(relativeImport, mainClass + "."))
						{
							relativeImport = relativeImport.substr(mainClass.length + 1);
							trace(relativeImport);
							topLevelClassList.push({name: relativeImport, fullName: item});
						}
						else
						{
							importsList.push(relativeImport);
						}
                    }
                    else
                    {
                        relativeImport = item;
                        importsList.push(relativeImport);
                    }
                }
                
            }
        }

        for (list2 in [ClassParser.haxeStdTopLevelClassList, ClassParser.topLevelClassList])
        {
            for (item in list2) 
            {

                topLevelClassList.push({name: item});
            }
        }
            
       	for (item in fileImports)
        {
            found = false;
             
			relativeImport = item.split(".").pop();
			
			for (topLevelItem in topLevelClassList)
            {
                if (topLevelItem.name == relativeImport)
                {
                    found = true;
                    break;
                }
			}

			if (!found)
            {
                topLevelClassList.push({name: relativeImport, fullName: item});
            }
		}
            
        return {topLevelClassList: topLevelClassList, importsList: importsList};
    }

        
	public function getCompletionType()
    {
        return completionType;
    }

}
