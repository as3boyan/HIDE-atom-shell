package completion;
import completion.Hxml.CompletionData;
import haxe.ds.StringMap;

/**
 * ...
 * @author AS3Boyan
 */
class Anyword
{
	var seen:StringMap<Bool>;
	var list:Array<CompletionData>;
	
	public function getCompletion(cm:CodeMirror):Array<CompletionData>
	{
		list = [];
		seen = new StringMap();
		scan(cm, -1);
		scan(cm, 1);
	}
	
	function scan(cm:CodeMirror, dir:Int):Void
	{			
		var line:Int = cur.line;
		var end2 = Math.min(Math.max(line + dir * range, cm.firstLine()), cm.lastLine()) + dir;
		while (line != end2) 
		{
			var text = cm.getLine(line);
			var m:Dynamic = null;
			
			var re:EReg = ~/([A-Z]+)/ig;
			
			re.map(text, function(e:EReg):String
			{
				m = e.matched(0);
				
				if (!(line == cur.line) || !(m == curWord))
				{
					if ((curWord == null || m.indexOf(curWord) == 0) && !seen.exists(m)) 
					{
						seen.set(m, true);
						list.push({text: m});
					}
				}
				
				return e.matched(0);
			}
			);
			
			line += dir;
		}
	}
}