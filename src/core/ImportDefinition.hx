package core;
import tabmanager.TabManager;
import cm.Editor;
import core.Completion.TopLevelImport;
import parser.RegexParser;
import CodeMirror.TokenData;
import parser.ClassParser;
import parser.OutlineHelper;
import completion.Hxml.CompletionData;

/**
* @author AS3Boyan
 */
class ImportDefinition 
{
    public static function searchImport(data:String, path:String)
    {
        var ast = ClassParser.parse(data, path);
        
        var cm = cm.Editor.editor;
        var token = cm.getTokenAt(cm.getCursor());
		
//         var fileImports:Array<String> = [];
        var topLevelClassList:Array<TopLevelImport> = [];
        
        var mode:String = null;
        
        var selectedText:String = null;
        
        var from:CodeMirror.Pos = null;
        var to:CodeMirror.Pos = null;
        
        if (cm.somethingSelected())
        {
            selectedText = cm.getSelection();
            
            if (selectedText.indexOf(".") != -1)
            {
                mode = "selection";
                
                var selection = cm.listSelections()[0];
                
                from = selection.anchor;
                to = selection.head;
                
                cm.setSelection(to);
            }
        }
        else if (token.type != null && token.string != "")
        {
			mode = "token";
        }
            
        if (mode != null)
        {
//             if (ast != null) 
//             {
//                 fileImports = OutlineHelper.parseDeclarations(ast).fileImports;	            
//             }
//             else
//             {
//                 trace("haxeparser is unable to parse this file. Falling back to regex parsing.");
                
//                 var value = tabmanager.TabManager.getCurrentDocument().getValue();
                
//                 fileImports = RegexParser.getFileImportsList(value);
//             }
            
			var completionInstance = Completion.get();
			
            topLevelClassList = completionInstance.getClassList().topLevelClassList;
            
            switch (mode)
            {
                case "token":
                    checkImport(cm, topLevelClassList, token);
                case "selection":
                    searchImportByText(topLevelClassList, selectedText, from, to);
                default:

            }
        }
        else
        {
            Alertify.log("Place cursor on class name or select full class name to import it (for instance, you can select 'flash.display.Sprite' and it can be imported and selected text will be replaced to 'Sprite'");
        }
    }
    
    public static function searchImportByText(topLevelClassList:Array<TopLevelImport>, text:String, from:CodeMirror.Pos, to:CodeMirror.Pos, ?suggestImport:Bool = true)
    {
        var cm = Editor.editor;
        
        var found:Bool = false;
        var alreadyAdded:Bool = false;

        for (list in [ClassParser.importsList, ClassParser.haxeStdImports])
        {
            if (list.indexOf(text) != -1)
            {
                found = true;
                break;
            }
        }

        for (topLevelClass in topLevelClassList)
        {
            if (topLevelClass.fullName == text)
            {
                alreadyAdded = true;
                break;
            }
        }

        if (!alreadyAdded)
        {
            if (found)
            {
                importClass(cm, text, from, to);
            }
            else if (suggestImport)
            {
				var completionInstance = Completion.get();
                completionInstance.showImportDefinition([text], from, to);
            }
        }
        else
        {
            updateImport(cm, text.split(".").pop(), from, to);
        }
    }

    
    static function checkImport(cm:CodeMirror, topLevelClassList:Array<TopLevelImport>, token:TokenData)
    {
        var searchPattern = "." + token.string;

        var foundImports:Array<String> = [];
        var foundAtTopLevel:Bool = false;
        var alreadyImported:Array<String> = [];
        
        for (topLevelClass in topLevelClassList)
        {
            if (topLevelClass.name == token.string)     
            {
                foundAtTopLevel = true;
                alreadyImported.push(topLevelClass.fullName);
                break;
            }
        }
        
		if (!foundAtTopLevel)
        {
			var found:Bool = false;
        
            for (list in [ClassParser.importsList,  ClassParser.haxeStdImports])
            {
                for (item in list)
                {
                    if (StringTools.endsWith(item, searchPattern))
                    {
                        trace(item);

                        for (topLevelClass in topLevelClassList)
                        {
                            if (topLevelClass.fullName == item)     
                            {
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                        {
                            foundImports.push(item);
                        }
                        else
                        {
                            alreadyImported.push(item);
                        }
                    }
                }
            }            
        }

        if (foundAtTopLevel)
        {
            Alertify.log("'" + token.string + "' doesn't needs to be imported, since it's already found at top level");
        }
        else if (foundImports.length > 0)
        {
			var completionInstance = Completion.get();
            completionInstance.showImportDefinition(foundImports);
        }
        else
        {
			var cursor = cm.getCursor();
			
			var lineData:String = cm.getLine(cursor.line);
			
			var ereg = ~/var[\t ]*([^ =]+):([^ =;\n]+)/gim;
			var ereg2 = ~/var[\t ]*([^ =:;\n]+)/gim;
			
			var pos = null;
			var len = null;
			var variableName:String = null;
			var variableDeclarationString:String = null;
			
			var matchedEreg = null;
			
			if (ereg.match(lineData))
			{
				matchedEreg = ereg;
			}
			else if (ereg2.match(lineData))
			{
				matchedEreg = ereg2;
			}
				
			if (matchedEreg != null)
			{
				pos = matchedEreg.matchedPos();
				variableName = matchedEreg.matched(1);
				variableDeclarationString = matchedEreg.matched(0);
				
				len = variableDeclarationString.length;
				
				variableDeclarationString = StringTools.trim(variableDeclarationString);
				if (!StringTools.endsWith(variableDeclarationString, ";"))
				{
					variableDeclarationString += ";";
				}
			}
				
			var tabManagerInstance = TabManager.get();
				
			var classDeclarations = RegexParser.getClassDeclarations(tabManagerInstance.getCurrentDocument().getValue());
			
			var currentClassDeclaration = null;
			
			for (item in classDeclarations)
			{
				 var classDeclarationPos = cm.posFromIndex(item.pos.pos + item.pos.len);
				 
				 if (cursor.line < classDeclarationPos.line || (cursor.line == classDeclarationPos.line && cursor.ch < classDeclarationPos.ch))
				 {
					 break;
				 }
				 
				 currentClassDeclaration = item;
			}
			
			if (currentClassDeclaration != null && matchedEreg != null)
			{
				var completionItem:CompletionData = {};
				completionItem.displayText = "Move to the class scope";
				completionItem.hint = function (cm:CodeMirror, data, completion)
					{
						var classDeclarationPos = cm.posFromIndex(currentClassDeclaration.pos.pos + currentClassDeclaration.pos.len);
						var index = cm.indexFromPos({line: cursor.line, ch: 0});
						
						classDeclarationPos.line += 1;
						classDeclarationPos.ch = 0;
						variableDeclarationString += "\n";
						cm.replaceRange(variableDeclarationString, classDeclarationPos, classDeclarationPos);
						cm.indentLine(classDeclarationPos.line);
						
						var from = cm.posFromIndex(index + pos.pos + variableDeclarationString.length + 1);
						var to = cm.posFromIndex(index + pos.pos + pos.len + variableDeclarationString.length + 1);
						cm.replaceRange(variableName, from, to);
					};
				
				var completionInstance = Completion.get();
				completionInstance.showActions([completionItem]);
			}
			else
			{
				var info = "Unable to find additional imports for '" + token.string + "'.";

				if (alreadyImported.length > 0)
				{
					info += " Already imported:\n" + Std.string(alreadyImported);
				}

				Alertify.log(info);
			}
        }
    }
        
    public static function importClassHint(from:CodeMirror.Pos, to:CodeMirror.Pos, cm:CodeMirror, data:Dynamic, completion:CompletionData)
	{
        importClass(cm, completion.text, from, to);
    }
        
    static function importClass(cm:CodeMirror, text:String, from:CodeMirror.Pos, to:CodeMirror.Pos)
	{
		var tabManagerInstance = TabManager.get();
		
        var value = tabManagerInstance.getCurrentDocument().getValue();
        
        var filePackage = RegexParser.getFilePackage(value);
        
        if (from != null && to != null)
       	{
            updateImport(cm, text, from, to);
        }
        
        var pos:CodeMirror.Pos;

        if (filePackage.filePackage != null)
        {
            pos = cm.posFromIndex(filePackage.pos);
            pos.ch = 0;
            pos.line++;
        }
        else
        {
            pos = cm.posFromIndex(0);
        }

        cm.replaceRange("import " + text + ";\n", pos, pos);
        
        Alertify.success(text + " definition successfully imported");
    }

	static function updateImport(cm:CodeMirror, text:String, from:CodeMirror.Pos, to:CodeMirror.Pos)
	{
        cm.replaceRange(text.split(".").pop(), from, to);
    }

}