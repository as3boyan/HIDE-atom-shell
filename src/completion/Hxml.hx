package completion;
import completion.Hxml.CompletionData;
import core.Completion.CompletionItem;
import core.HaxeHelper;
import core.ProcessHelper;

/**
 * ...
 * @author AS3Boyan
 */

typedef CompletionData =
{
	@:optional var text:String;
	@:optional var displayText:String;
	@:optional var hint:CodeMirror->Dynamic->CompletionData->Void;
	@:optional var info:CompletionData->Dynamic;
	@:optional var className:String;
}

class Hxml
{
	static var completions:Array<CompletionData>;
	
	public static function load()
	{
		completions = [];
		
		getArguments(getDefines.bind(getHaxelibList));
	}
	
	static function getHaxelibList(onComplete:Dynamic) 
	{
		HaxeHelper.getInstalledHaxelibList(function (installedLibs:Array<String>):Void 
		{
			for (item in installedLibs)
			{
				var completionItem:CompletionData = { };
				completionItem.text =  "-lib " + item;
				completionItem.displayText =  completionItem.text + " - installed";
				completionItem.className = "CodeMirror-Tern-completion" + " CodeMirror-Tern-completion-lib";
				
				completions.push(completionItem);
			}
						
			HaxeHelper.getHaxelibList(function (libs:Array<String>):Void 
			{
				for (item in libs) 
				{
					if (installedLibs.indexOf(item) == -1)
					{
						var completionItem:CompletionData = { };
						completionItem.text =  "-lib " + item;
						completionItem.displayText =  completionItem.text + " - not installed";
						completionItem.className = "CodeMirror-Tern-completion" + " CodeMirror-Tern-completion-lib";
						
						completions.push(completionItem);
					}
				}
				
				if (onComplete != null) 
				{
					onComplete();
				}
			}
			);
		}
		);
	}
	
	static function getDefines(onComplete:Dynamic) 
	{
		HaxeHelper.getDefines(function (data:Array<String>):Void 
		{
			for (item in data)
			{
				completions.push( { text: "-D " + item, className: "CodeMirror-Tern-completion" + " CodeMirror-Tern-completion-define" } );
			}
			
			if (onComplete != null) 
			{
				onComplete();
			}
		}
		);
	}
	
	static function getArguments(?onComplete:Dynamic) 
	{
		HaxeHelper.getArguments(function (data:Array<String>):Void 
		{
			for (item in data)
			{
				completions.push( { text: item, className: "CodeMirror-Tern-completion"} );
            
            	if (item == "-dce")
                {
                    completions.push( { text: item + " " + "no", className: "CodeMirror-Tern-completion"} );
                    completions.push( { text: item + " " + "std", className: "CodeMirror-Tern-completion"} );
                    completions.push( { text: item + " " + "full", className: "CodeMirror-Tern-completion"} );
				}
			}
			
			if (onComplete != null) 
			{
				onComplete();
			}
		}
		);
	}
	
	public static function getCompletion():Array<CompletionData>
	{
		return completions;
	}
}