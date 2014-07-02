package parser;
import CodeMirror.Pos;
import cm.Editor;

/**
* @author 
 */

typedef VariableData = {
	var name:String;
	@:optional var type:String;
	var pos:{pos:Int, len:Int};
}

//Regex for parsing imports ported from haxe-sublime-bundle
//https://github.com/clemos/haxe-sublime-bundle/blob/master/HaxeHelper.py#L21
class RegexParser
{
    public static function getFileImportsList(data:String)
    {
        var fileImports:Array<String> = [];
        
        var ereg = ~/^[ \t]*import ([a-z0-9._*]+);$/gim;
		
        ereg.map(data, function (ereg)
                 {
                     fileImports.push(ereg.matched(1));
                     return "";
                 });
        
        return fileImports;
    }
    
    public static function getFilePackage(data:String)
    {
        var filePackage:String = null;
        var pos:Int = null;
        
        var ereg = ~/package *([^;]*);$/m;
        
        if (ereg.match(data))
        {
            filePackage = StringTools.trim(ereg.matched(1));
            pos = ereg.matchedPos().pos;
        }
        
        return {filePackage: filePackage, pos: pos};
    }
	
    public static function getTypeDeclarations(data:String)
    {
        var typeDeclarations:Array<{type:String, name:String, ?opaqueType:String}> = [];
        
        var ereg = ~/(class|typedef|enum|typedef|abstract) +([A-Z][a-zA-Z0-9_]*) *(<[a-zA-Z0-9_,]+>)?/gm;
        
        ereg.map(data, function (ereg2)
                {
                    var typeDeclaration = {type: ereg2.matched(1), name: ereg2.matched(2)};
                    typeDeclarations.push(typeDeclaration);
                    return "";
                });
            
       	return typeDeclarations;
    }
    
    public static function getFunctionDeclarations(data:String)
    {
        var functionDeclarations:Array<{name:String, ?params:Array<String>}> = [];
        
        var eregFunction = ~/function +([^;\.\(\) ]*)/gi;
        var eregFunctionWithParameters = ~/function *([a-zA-Z0-9_]*) *\(([^\)]*)/gm;
        var eregParamDefault = ~/(= *"*[^"]*")/gm;
        
        eregFunctionWithParameters.map(data, function (ereg2:EReg)
                        {
                            var name:String = ereg2.matched(1);
                            
                            if (name != null)
                            {
								if (name != "new")
								{
									var params = null;
									
									var str = ereg2.matched(2);
									
									if (str != null)
									{
										params = str.split(",");
									}
									
									functionDeclarations.push({name: name, params: params});
								}
                            }
                            
                            return "";
                        });
        
        return functionDeclarations;
    }

    public static function getVariableDeclarations(data:String):Array<VariableData>
    {
		var variableDeclarations:Array<VariableData> = [];
        
        var eregVariables = ~/var +([a-z_0-9]+):?([^=;]+)?/gi;
			//~/var +([^:;\( ]*)/gi;
        
        eregVariables.map(data, function(ereg2:EReg)
                         {							 
							 var pos = ereg2.matchedPos();
							 var index = pos.pos + pos.len;
							 
// 							 var tokenType = cm.getTokenAt(cm.posFromIndex(index)).type;							 
// 							 if (true)
//  							 {
								 var name = ereg2.matched(1);
								 var type = ereg2.matched(2);
								 
							 	var varDecl = Lambda.find(variableDeclarations, function (varDecl1:VariableData)
											{
												return varDecl1.name == name;
											});

								if (varDecl == null)
								{
									 var varDecl1:VariableData = {name: name, pos: pos};

									 if (type != null)
									 {
										 type = StringTools.trim(type);

										 if (type != "")
										 {
											varDecl1.type = type;	 
										 }
									 }

									 variableDeclarations.push(varDecl1);
								}
//  							 }
							 
                             return ""; 
                         });
		
        return variableDeclarations;
    }
	
	public static function getClassDeclarations(data:String)
	{
		var classDeclarations = [];
		
		var eregClass = ~/class[\t ]+([a-z_0-9]+)[^;\n]+\n?\{/gi;
		
		eregClass.map(data, function (ereg)
					 {
						var pos = ereg.matchedPos();
						classDeclarations.push({name: ereg.matched(1), pos: pos});
						return ""; 
					 });
		
		return classDeclarations;
	}
	
	public static function getFunctionParameters(data:String, pos:Pos)
	{
		var functionDeclarations = [];
		var functionParams = [];
		
		var eregFunction = ~/[public|private|static|inline|macro\t ]* function[\t ]+([^;\.\(\) ]+)\((.+)\)[^;\.{]+\{/gi;
		
		eregFunction.map(data, function (ereg)
						{
							functionDeclarations.push({name: ereg.matched(1), params: ereg.matched(2).split(","), pos: ereg.matchedPos()});
							return "";
						});
		
		var currentFunctionDeclaration = null;
		
		for (item in functionDeclarations)
		{
			if (Editor.editor.indexFromPos(pos) < item.pos.pos + item.pos.len)
			{
				break;
			}
		
			currentFunctionDeclaration = item;
		}
	
		if (currentFunctionDeclaration != null)
		{
			var ereg = ~/([a-z_0-9]+):?([^=;]+)?/gi;
			
			for (param in currentFunctionDeclaration.params)
			{
				if (ereg.match(param))
				{
					functionParams.push({name: ereg.matched(1), type: ereg.matched(2)});
				}
			}
		}

		return functionParams;
	}


}