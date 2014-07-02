package core;
import byte.ByteData;
import cm.CMDoc;
import cm.Editor;
import core.HaxeLint.Info;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Position;
import haxeparser.Data.ClassFlag;
import haxeparser.Data.Definition;
import haxeparser.Data.ImportMode;
import haxeparser.Data.TypeDef;
import haxeparser.HaxeParser;
import haxeparser.HaxeParser.ParserErrorMsg;
import hxparse.NoMatch;
import hxparse.Unexpected;
import jQuery.JQuery;
import js.Node;
import tabmanager.TabManager;

/**
 * ...
 * @author
 */

enum FunctionScopeType
{
	SClass;
	SStatic;
	SRegular;
}

class HaxeParserProvider
{
	static var currentClass:String;
	static var currentFunctionScopeType:FunctionScopeType;
	
	public static function test():Void
	{
		//var path = "../src/Main.hx";
		//
		//var options:NodeFsFileOptions = { };
		//options.encoding = "utf8";
		//
		//var data:String = Fs.readFileSync(path, options);
		//
		//getClassName(data, path);
	}
	
	private static function processClass(type:Definition<ClassFlag, Array<Field>>, pos:Int):Bool
	{
		var found:Bool = false;
		
		currentClass = type.name;
		currentFunctionScopeType = SClass;
		
		for (i in 0...type.data.length) 
		{			
			if (pos > type.data[i].pos.min && pos < type.data[i].pos.max) 
			{
				switch (type.data[i].kind) 
				{
					case FFun(f):
						currentFunctionScopeType = getFunctionScope(type.data[i], f);
						
						if (pos > f.expr.pos.min && pos < f.expr.pos.max) 
						{
							if (processExpression(f.expr.expr, pos)) 
							{
								break;
							}
						}
					case FVar(t, e):
						//trace(e);
						currentFunctionScopeType = SClass;
					case FProp(get, set, t, e):
						currentFunctionScopeType = SClass;
				}
				
				//trace(type.data[i].name);
				//trace(currentFunctionScopeType);
				found = true;
				break;
			}
		}
		
		return found;
	}
	
	static function processExpression(expr:haxe.macro.ExprDef, pos:Int):Bool 
	{
		//trace(expr);
		
		var found:Bool = false;
		
		switch (expr)
		{
			case EWhile(econd, e, b):
			case EVars(vars):
			case EUntyped(e):
			case EUnop(op, postFix, e):
			case ETry(e, catches):
			case EThrow(e):
			case ETernary(econd, eif, eelse):
			case ESwitch(e, cases, edef):
			case EReturn(e):
			case EParenthesis(e):
			case EObjectDecl(fields):
			case ENew(t, params):
			case EMeta(s, e):
			case EIn(e1, e2):
			case EIf(econd, eif, eelse):
			case EFunction(name, f):
			case EFor(it, expr):
			case EField(e, field):
				processExpression(e.expr, pos);
				//trace(field);
			case EDisplayNew(t):
			case EDisplay(e, isCall):
			case EContinue:
			case EConst(c):
				switch (c) 
				{
					case CIdent(s):
						//trace(s);
					default:
						
				}
			case ECheckType(e, t):
			case ECast(e, t):
			case ECall(e, params):
				//trace(e);
				processExpression(e.expr, pos);
				
				for (param in params) 
				{
					processExpression(param.expr, pos);
				}
			case EBreak:
			case EBlock(exprs):
				for (e in exprs) 
				{
					if (pos > e.pos.max) 
					{
						//trace(e.expr);
					}
					if (pos > e.pos.min && pos <= e.pos.max) 
					{
						if (processExpression(e.expr, pos))
						{
							found = true;
							break;
						}
					}
				}
			case EBinop(op, e1, e2):
				//trace(op);
				//trace(e1);
				//trace(e2);
			case EArrayDecl(values):
			case EArray(e1, e2):
		}
		
		return found;
	}
	
	static function getFunctionScope(field:Field, f:Function) 
	{
		var	functionScopeType:FunctionScopeType = SRegular;
		
		var access:Array<Access> = field.access;
		
		for (accessType in access)
		{
			switch (accessType) 
			{
				case APublic:
				case AStatic:
					functionScopeType = SStatic;
				case AMacro:
				case AInline:
				case ADynamic:
				case AOverride:
				case APrivate:
			}
		}
		
		return functionScopeType;
	}
	
	public static function getClassName():Void 
	{
		var cm = Editor.editor;
		var pos = cm.indexFromPos(cm.getCursor());
		//trace(pos);
		
		var tabManagerInstance = TabManager.get();
		
		var doc:CodeMirror.Doc = tabManagerInstance.getCurrentDocument();
		
		var data:String = doc.getValue();
		var path:String = tabManagerInstance.getCurrentDocumentPath();
		
		var ast = parse(data, path);
		
		if (ast != null) 
		{
			var classPackage:Array<String> = ast.pack;
			
			for (decl in ast.decls) switch (decl.decl) 
			{
				case EImport(sl, mode): 
					currentClass = null;
					if (processImport(sl, mode, pos)) 
					{
						break;
					}
				case EUsing(path): 
					currentClass = null;
				case EAbstract(data): 
					currentClass = null;
				case EClass(data): 
					if (processClass(data, pos)) 
					{
						break;
					}
				case EEnum(data): 
					currentClass = null;
				case ETypedef(data): 
					currentClass = null;
			}
			
			//trace(classPackage);
			//trace(currentClass);
		}
		else 
		{
			trace("ast is null");
		}
	}
	
	private static function parse(data:String, path:String) 
	{
		var input = ByteData.ofString(data);
		
		var parser = new haxeparser.HaxeParser(input, path);

		var data:Array<Info> = [];
		HaxeLint.parserData.set(path, data);
		
		var ast = null;
		
		try 
		{
			ast = parser.parse();
		}
		catch (e:NoMatch<Dynamic>) 
		{
			//trace(e);
			var pos =  e.pos.getLinePosition(input);
			
			var info:Info = { from: {line:pos.lineMin - 1, ch:pos.posMin}, to: {line:pos.lineMax - 1, ch:pos.posMax}, message: "Parser error:\nUnexpected " + e.token.tok, severity: "warning"};
			data.push(info);
			
			//throw e.pos.format(input) + ": Unexpected " +e.token.tok;
		}
		catch (e:Unexpected<Dynamic>) 
		{
			//trace(e);
			var pos =  e.pos.getLinePosition(input);
			
			var info:Info = { from: {line: pos.lineMin - 1, ch: pos.posMin}, to: {line:pos.lineMax - 1, ch:pos.posMax}, message: "Parser error:\nUnexpected " + e.token.tok, severity: "warning"};
			data.push(info);
			//trace(e.pos.format(input) + ": Unexpected " + e.token.tok);
			//throw e.pos.format(input) + ": Unexpected " + e.token.tok;
		} 
		catch (e:Dynamic)
		{			
			if (e != null && e.pos) 
			{		
				var cm = Editor.editor;
				
				var message:String = "Parser error:\n";
				
				switch (e.msg) 
				{
					case MissingSemicolon:
						message += "Missing Semicolon";
					case MissingType:
						message += "Missing Type";
					case DuplicateDefault:
						message += "Duplicate Default";
					case Custom(s):
						message += s;
				}
				
				var info:Info = { from: cm.posFromIndex(e.pos.min), to: cm.posFromIndex(e.pos.max), message: message, severity: "warning"};
				data.push(info);
			}
		}
		
		return ast;
	}
	
	private static function processImport(path:Array<{pack:String, pos:Position}>, mode:ImportMode, currentPosition:Int):Bool 
	{
		var found:Bool = false;
		
		for (i in 0...path.length) 
		{			
			if (currentPosition > path[i].pos.min && currentPosition < path[i].pos.max) 
			{
				//trace(path[i].pack);
				
				found = true;
				break;
			}
		}
		
		return found;
	}
	
	private static function printImport(path:Array<{pack:String, pos:Position}>, mode:ImportMode):Void
	{
		var fullPackage:String = "";
		
		for (i in 0...path.length) 
		{
			fullPackage += path[i].pack;
			
			if (i != path.length - 1) 
			{
				fullPackage += ".";
			}
			
			//trace(path[i].pos);
		}
		
		trace(fullPackage);
	}
	
	private static function printClass(type:Definition<ClassFlag, Array<Field>>):Void 
	{
		trace(type.name);
		
		var publicFunctions:Array<Field> = [];
		var publicStaticFunctions:Array<Field> = [];
		
			//if (isPublic) 
			//{
				//if (isStatic) 
				//{
					//publicStaticFunctions.push(type.data[i]);
				//}
				//else 
				//{
					//publicFunctions.push(type.data[i]);
				//}
			//}
		
		//for (publicFunction in publicFunctions) 
		//{
			//trace("public " + publicFunction.name);
		//}
		//
		for (publicStaticFunction in publicStaticFunctions) 
		{
			//trace("public static " + publicStaticFunction.name);
			
			var info:String = publicStaticFunction.name;
			
			switch (publicStaticFunction.kind) 
			{
				case FFun(f):
					//trace(f);
					//trace(f.expr);
					//trace(f.params);
					info += "(";
					
					for (i in 0...f.args.length) 
					{
						info += f.args[i].name;
						
						switch (f.args[i].type) 
						{
							case TPath(p):
								//p.pack.join(".") + "."
								info += ":" + p.name;
								
								if (i != f.args.length - 1) 
								{
									info += ", ";
								}
							case TParent(t):
// 								trace(t);
							case TOptional(t):
								//trace(t);
							case TFunction(args, ret):
								//trace(args);
								//trace(ret);
							case TExtend(p, fields):
								//trace(p, fields);
							case TAnonymous(fields):
								//trace(fields);
						}
					}
					
					info += ")";
				case FVar(t, e):
					
				case FProp(get, set, t, e):
					
			}
			
// 			trace(info);
		}
	}
}