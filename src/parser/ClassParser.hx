package parser;
import js.node.Path;
import haxeparser.Data.TypeDecl;
import byte.ByteData;
import cm.Editor;
import haxe.ds.StringMap.StringMap;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;
import haxeparser.Data.ClassFlag;
import haxeparser.Data.Definition;
import haxeparser.Data.TypeDef;
import haxeparser.HaxeParser;
import hxparse.NoMatch;
import hxparse.Unexpected;
import js.Node;

/**
 * ...
 * @author 
 */

typedef FileData =
{
    path: String, 
    directory:String,
    filename: String,
    displayText: String
}
	
typedef ClassData =
{
	fields: Array<String>
}

class ClassParser
{
    public static var haxeStdTopLevelClassList:Array<String> = ["Int", "Float", "String", "Void", "Std", "Bool", "Dynamic", "Array", "null", "this", "break", "continue", "extends", "implements", "in", "override", "package", "inline", "throw", "untyped", "using", "import", "return", "extern"];
	public static var topLevelClassList:Array<String> = [];
    
    public static var haxeStdImports:Array<String> = [];
	public static var importsList:Array<String> = [];
    
	public static var classCompletions:StringMap<ClassData> = new StringMap();
    
    public static var haxeStdFileList:Array<FileData> = [];
    public static var filesList:Array<FileData> = [];
	
	public static function parse(data:String, path:String)
	{
		var input = ByteData.ofString(data);
		var parser = new HaxeParser(input, path);
		var ast = null;
		
		try 
		{
			ast = parser.parse();
		}
		catch (e:NoMatch<Dynamic>) 
		{
// 			trace(e.pos.format(input) + ": Unexpected " + e.token.tok);
		}
		catch (e:Unexpected<Dynamic>) 
		{
// 			trace(e.pos.format(input) + ": Unexpected " + e.token.tok);
		} 
		catch (e:Dynamic)
		{			
			//trace("Unhandled parsing error: ");
			//trace(e);
		}
		
		return ast;
	}
	
	public static function processFile(data:String, path:String, std:Bool):Void 
	{
		var ast = parse(data, path);
		
        var mainClass = Path.basename(path, ".hx");
        
		if (ast != null) 
		{
			parseDeclarations(ast, mainClass, std);
		}
		else 
		{
            var filePackage = RegexParser.getFilePackage(data);
            var typeDeclarations = RegexParser.getTypeDeclarations(data);
            
            var packages;
            
            if (filePackage.filePackage != null)
            {
                packages = filePackage.filePackage.split(".");
            }
            else
            {
                packages = [];
            }
            
            for (item in typeDeclarations)
            {                 
                var className:String = resolveClassName(packages, mainClass, item.name);
                addClassName(className, std);
			}
            
			//trace("ast for " + path + " is null");
		}
	}
	
	static function parseDeclarations(ast:{decls:Array<TypeDecl>, pack:Array<String>}, mainClass:String, std:Bool) 
	{		
		for (decl in ast.decls) switch (decl.decl) 
		{
			case EImport(sl, mode): 
			case EUsing(path): 
			case EAbstract(data): 
				var className:String = resolveClassName(ast.pack, mainClass, data.name);
				addClassName(className, std);
			case EClass(data): 
				var className:String = resolveClassName(ast.pack, mainClass, data.name);
				processClass(className, data);
				addClassName(className, std);
				
				//
				
				//if (processClass(data, pos)) 
				//{
					//break;
				//}
			case EEnum(data): 
				var className:String = resolveClassName(ast.pack, mainClass, data.name);
				addClassName(className, std);
			case ETypedef(data): 
				var className:String = resolveClassName(ast.pack, mainClass, data.name);
				addClassName(className, std);
		}
	}
	
	static function processClass(className:String, type:Definition<ClassFlag, Array<Field>>) 
	{
		var completions:Array<String> = [];
		
		for (i in 0...type.data.length)
		{
			if (getScope(type.data[i]))
			{
				completions.push(type.data[i].name);
			}
		}
		
		//switch (type.data[i].kind) 
		//{
			//case FFun(f):
				//
				//currentFunctionScopeType = getFunctionScope(type.data[i], f);
				//
				//if (pos > f.expr.pos.min && pos < f.expr.pos.max) 
				//{
					//if (processExpression(f.expr.expr, pos)) 
					//{
						//break;
					//}
				//}
			//case FVar(t, e):
				//completions.push(type.data[i].name);
				//trace(e);
				//currentFunctionScopeType = SClass;
			//case FProp(get, set, t, e):
				//completions.push(type.data[i].name);
				//currentFunctionScopeType = SClass;
		//}
		
		if (completions.length > 0)
		{
			classCompletions.set(className, {fields: completions});
		}
	}
	
	static function getScope(field:Field) 
	{
		var isPublic:Bool = false;
		var access:Array<Access> = field.access;
		
		for (accessType in access)
		{
			switch (accessType) 
			{
				case APublic:
					isPublic = true;
				case AStatic:
				case AMacro:
				case AInline:
				case ADynamic:
				case AOverride:
				case APrivate:
			}
		}
		
		return isPublic;
	}
	
	static function resolveClassName(pack:Array<String>, mainClass:String, name:String):String 
	{
		var classPackage = pack.copy();
				
		if (name == mainClass) 
		{
			classPackage.push(name);
		}
		else 
		{
			classPackage.push(mainClass);
			classPackage.push(name);
		}
		
		var className= classPackage.join(".");
		return className;
	}
	
	static function addClassName(name:String, std:Bool):Void 
	{
        var list:Array<String>;
        
		if (name.indexOf(".") == -1) 
		{
			if (std) 
			{
                list = haxeStdTopLevelClassList;
			}
            else
            {
                list = topLevelClassList;
            }
            
			if (list.indexOf(name) == -1)
			{
				list.push(name);
			}
		}
		else 
		{
			if (std) 
			{
				list = haxeStdImports;
			}
            else
            {
                list = importsList;
            }
			
			if (list.indexOf(name) == -1)
			{
				list.push(name);
			}
		}
	}
}