package core;
import js.node.Path;
import js.node.ChildProcess;
import js.html.DivElement;
import cm.Editor;
import dialogs.DialogManager;
import haxe.ds.StringMap;
import jQuery.JQuery;
import js.Browser;
import js.html.AnchorElement;
import js.html.TextAreaElement;
import js.Node;
import projectaccess.Project;
import projectaccess.Project.TargetData;
import projectaccess.ProjectAccess;
import tabmanager.TabManager;

/**
 * ...
 * @author 
 */
class ProcessHelper
{
	var processStdout:String;
	var processStderr:String;
	
	static var instance:ProcessHelper;
	
	public function new() 
	{
		
	}	
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new ProcessHelper();
		}
			
		return instance;
	}
	
	public function runProcess(process:String, params:Array<String>, path:String, onComplete:String->String->Void, ?onFailed:Int->String->String->Void):ChildProcess
	{		
		var command:String = processParamsToCommand(process, params);
		
		var options = { cwd: null };
		
		if (path != null) 
		{
			options.cwd = path;
		}
		
		var process:ChildProcess = ChildProcess.exec(command, options, function (error, stdout:String, stderr:String):Void
		{			
			//if (stdout != "")
			//{
				//trace("stdout:\n" + stdout);
			//}
			//
			//if (stderr != "")
			//{
				//trace("stderr:\n" + stderr);
			//}
			
			if (error == null)
			{				
				onComplete(stdout, stderr);
			}
			else if (onFailed != null)
			{
				onFailed(error.code, stdout, stderr);
			}
		}
		);
		
		return process;
	}
	
	public function runProcessAndPrintOutputToConsole(process:String, params:Array<String>, cwd:String, ?onComplete:Void->Void):ChildProcess
	{
		var command:String = processParamsToCommand(process, params);
		
		new JQuery("#outputTab").click();
		
		var textarea = cast(Browser.document.getElementById("outputTextArea"), TextAreaElement);
		textarea.value = "Build started\n";
		textarea.value += command + "\n";
		
		clearErrors();
		
		var process:ChildProcess = runPersistentProcess(process, params, cwd, function (code:Int, stdout:String, stderr:String):Void 
		{
			processOutput(code, processStdout, processStderr, onComplete);
		}
		);
		
		return process;
	}
	
	public function clearErrors()
	{
		//http://jsperf.com/removechildren/9
		
		var div = cast (Browser.document.getElementById("errors"), DivElement);
		
		while (div.lastChild != null)
		{
			div.removeChild(div.lastChild);
		}
	}

	
	function processOutput(code:Int, stdout:String, stderr:String, ?onComplete:Dynamic):Void
	{
		var textarea = cast(Browser.document.getElementById("outputTextArea"), TextAreaElement);
		
		if (StringTools.trim(stdout) != "")
		{
			textarea.value += "stdout:\n" + stdout;
			trace("stdout:\n" + stdout);
		}
		
		HaxeLint.fileData = new StringMap();
		
		var switchToResultsTab:Bool = false;
		
		if (stderr != "")
		{		
			var lines = stderr.split("\n");
			
			for (line in lines) 
			{
				line = StringTools.trim(line);
				
				if (line.indexOf("Error:") == 0) 
				{
					Alertify.error(line);
					
					if (line.indexOf("unknown option `-python'") != -1) 
					{
						Alertify.log("You may need to install latest version of Haxe to compile to Python target", "", 10000);
					}
				}
				else if (line.indexOf(":") != 0) 
				{
					var args:Array<String> = line.split(":");
					
					if (args.length > 3) 
					{
						var relativePath:String = args[0];
						var fullPath:String = Path.join(ProjectAccess.path, relativePath);
						
                        if (!HaxeLint.fileData.exists(fullPath))
                        {
                        	HaxeLint.fileData.set(fullPath, []);    
                        }
                        
                        var data:Array<HaxeLint.Info> = HaxeLint.fileData.get(fullPath);
                        
						HaxeLint.fileData.set(fullPath, data);
						
						var lineNumber:Int = Std.parseInt(args[1]) - 1;
						
						var charsData:Array<String> = null;
						
						if (args[2].indexOf(" ") != -1)
						{
							var data = StringTools.trim(args[2]).split(" ");
							
							if (data.length > 1 && data[1].indexOf("-") != -1)
							{
								charsData = data[1].split("-");
							}
						}
						
						if (charsData != null) 
						{
							var start:Int = Std.parseInt(charsData[0]);
							var end:Int = Std.parseInt(charsData[1]);
							
							var message:String = "";
							
							for (i in 3...args.length) 
							{
								message += args[i];
								
								if (i != args.length - 1) 
								{
									message += ":";
								}
							}
							
							var tabManagerInstance = TabManager.get();
							
							var a:AnchorElement = Browser.document.createAnchorElement();
							a.href = "#";
							a.className = "list-group-item";
							a.innerText = line;
							a.onclick = function (e)
							{
								tabManagerInstance.openFileInNewTab(fullPath, true, function ():Void 
								{
									var cm = Editor.editor;
									cm.centerOnLine(lineNumber);
								});
								
							};
							
							new JQuery("#errors").append(a);
							
							var info:HaxeLint.Info = { from: {line:lineNumber, ch:start}, to: {line:lineNumber, ch:end}, message: message, severity: "error" };
							data.push(info);
							
							switchToResultsTab = true;
							
							//Check if it's open
							//Show hints when swithing document
							tabManagerInstance.openFileInNewTab(fullPath, false);
						}
					}
				}
				
				var lib:String = null;
				
				var ereg = ~/haxelib install ([^']+)/gim;
				if (ereg.match(line)) 
				{
					lib = ereg.matched(1);
				}
				
				var ereg2 = ~/library ([^ ]+) is not installed/gim;
				if (ereg2.match(line)) 
				{
					lib = ereg2.matched(1);
				}
				
				if (lib != null) 
				{
					var pathToHxml = ProjectAccess.getPathToHxml();
					DialogManager.showInstallHaxelibDialog(lib, pathToHxml);
				}
			}
			
			textarea.value += "stderr:\n" + stderr;
			trace("stderr:\n" + stderr);
		}
		
		if (code == 0) 
		{
			Alertify.success("Build complete!");
			
			textarea.value += "Build complete\n";
			
			if (onComplete != null)
			{
				onComplete();
			}
			
			new JQuery("#buildStatus").fadeIn(250);
		}
		else 
		{
			//trace(code);
			//trace(stdout);
			//trace(stderr);
			
			if (switchToResultsTab) 
			{
				new JQuery("#resultsTab").click();
			}
			
			Alertify.error("Build failed");
			
			//trace(command);
			textarea.value += "Build failed (exit code: " + Std.string(code) +  ")\n" ;
			
			new JQuery("#buildStatus").fadeOut(250);
		}
		
		HaxeLint.updateLinting();
	}
	
	public function runPersistentProcess(process:String, params:Array<String>, cwd:String, ?onClose:Int->String->String->Void, ?redirectToOutput:Bool = false):ChildProcess
	{
		var textarea = cast(Browser.document.getElementById("outputTextArea"), TextAreaElement);
		
		processStdout = "";
		processStderr = "";
		
		var process:ChildProcess = ChildProcess.spawn(process, params, { cwd: cwd } );
		
		process.stdout.setEncoding("utf8");
		process.stdout.on("data", function (data:String)
		{
			processStdout += data;
			
			if (redirectToOutput) 
			{
				textarea.value += data;
				textarea.scrollTop = textarea.scrollHeight;
			}
		}
		);
		
		process.stderr.setEncoding("utf8");
		process.stderr.on("data", function (data:String)
		{
			processStderr += data;
			
			if (redirectToOutput) 
			{
				textarea.value += data;
				textarea.scrollTop = textarea.scrollHeight;
			}
		}
		);
		
		process.on("error", function (e):Void 
		{
			trace(e);
		}
		);
		
		process.on("close", function (code:Int)
		{
			trace(processStdout);
			trace(processStderr);
			
			if (onClose != null) 
			{
				onClose(code, processStdout, processStderr);
			}
			
			if (code != 0)
			{
				process = null;
			}
			
			trace('started process quit with exit code ' + code);
		}
		);	
		
		return process;
	}
	
	public function checkProcessInstalled(process:String, params:Array<String>, onComplete:Bool->Void):Void
	{
		var installed:Bool;
		
		ChildProcess.exec(processParamsToCommand(process, params), { }, function (error, stdout, stderr) 
		{			
			if (error == null)
			{
				installed = true;
			}
			else 
			{
				//if (error.code = 1)
				//{
					//process not found
				//}
				
				trace(error);
				trace(stdout);
				trace(stderr);
				installed = false;
			}
			
			onComplete(installed);
		}
		);
	}
	
	function processParamsToCommand(process:String, params:Array<String>):String
	{
		return [process].concat(params).join(" ");
	}
}