package autoformat;
import js.node.Fs;
import js.node.Path;

import haxe.io.Bytes;
import haxeprinter.Printer;
import hxparse.NoMatch;
import hxparse.Unexpected;
import js.Node;
import tjson.TJSON;

/**
 * ...
 * @author David Peek
 */
class HaxePrinter
{
	public static function formatSource(source:String)
	{
		var input = byte.ByteData.ofString(source);
		var parser = new haxeparser.HaxeParser(input, "");

		var ast = try {
			parser.parse();
		} catch(e:NoMatch<Dynamic>) {
			throw e.pos.format(input) + ": Unexpected " +e.token.tok;
		} catch(e:Unexpected<Dynamic>) {
			throw e.pos.format(input) + ": Unexpected " + e.token.tok;
		}

		var printer = new Printer();
		
// 		var options:NodeFsFileOptions = { };
// 		options.encoding = "utf8";
		printer.config = TJSON.parse(Fs.readFileSync(Path.join("core", "config", "autoformat.json"), "utf8"));
		return printer.printAST(ast);
	}
}