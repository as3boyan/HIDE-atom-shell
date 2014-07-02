package parser;
import js.node.fs.Stats;
import js.npm.Walkdir;
import js.node.Path;
import js.node.Fs.FsReadFileOpt;
import js.node.Fs;
import core.Completion;
import core.HaxeHelper;
import core.Hotkeys;
import core.ProcessHelper;
import core.Utils;
import dialogs.BrowseDirectoryDialog;
import dialogs.DialogManager;
import dialogs.ModalDialog;
import haxe.ds.StringMap.StringMap;
import js.Browser;
import js.Node;
import openflproject.OpenFLTools;
import projectaccess.Project;
import projectaccess.ProjectAccess;
import watchers.LocaleWatcher;
import watchers.SettingsWatcher;
import parser.ClassParser.FileData;

/**
 * ...
 * @author 
 */
typedef ClasspathAndLibs = 
{
	classpaths: Array<String>,
	libs: Array<LibClassPath>
}
	
typedef LibClassPath = 
{
	path: String,
	std: Bool
}

class ClasspathWalker
{
	public var pathToHaxeStd:String;
	public var pathToHaxe:String;
    
	static var instance:ClasspathWalker;
	
	public static function get():ClasspathWalker
	{
		if (instance == null)
		{
			instance = new ClasspathWalker();
		}
			
		return instance;
	}
	
	public function new():Void 
	{		
		
	}
	
	public function load()
	{
		var localStorage2 = Browser.getLocalStorage();
		
		var pathToHaxe2 = Node.process.env.HAXE_STD_PATH;
		
		if (pathToHaxe2 != null)
		{
			pathToHaxe2 = Path.dirname(pathToHaxe2);
		}
		
		var paths:Array<String> = [Node.process.env.HAXEPATH, pathToHaxe2, Node.process.env.HAXE_HOME];
		
		if (localStorage2 != null) 
		{
			var path = localStorage2.getItem("pathToHaxe");
			paths.insert(0, path);
		}
		
		switch (Utils.os) 
		{
			case Utils.WINDOWS:
				paths.push("C:/HaxeToolkit/haxe");
			case Utils.LINUX, Utils.MAC:
				paths.push("/usr/lib/haxe");
			default:
				
		}
		
		for (envVar in paths)
		{
			if (envVar != null) 
			{
				pathToHaxeStd = getHaxeStdFolder(envVar);
				
				if (pathToHaxeStd != null) 
				{
					pathToHaxe = envVar;
					localStorage2.setItem("pathToHaxe", pathToHaxe);
					HaxeHelper.updatePathToHaxe();
					break;
				}
			}
		}
		
		if (pathToHaxeStd == null) 
		{
			showHaxeDirectoryDialog();
		}
		else 
		{
			parseClasspath(pathToHaxeStd, true);
		}
	}

	
	public function showHaxeDirectoryDialog()
	{
		var localStorage2 = Browser.getLocalStorage();
		
		var currentLocation = "";
		
		var pathToHaxe2 = localStorage2.getItem("pathToHaxe");
		
		if (pathToHaxe2 != null) 
		{
			currentLocation = pathToHaxe2;
		}
		
		DialogManager.showBrowseFolderDialog("Please specify path to Haxe compiler(parent folder of std): ", function (path:String):Void 
		{
			pathToHaxeStd = getHaxeStdFolder(path);
			
			if (pathToHaxeStd != null)
			{
				parseClasspath(pathToHaxeStd, true);
				pathToHaxe = path;
				localStorage2.setItem("pathToHaxe", pathToHaxe);
				HaxeHelper.updatePathToHaxe();
				DialogManager.hide();
			}
			else 
			{
				Alertify.error(LocaleWatcher.getStringSync("Can't find 'std' folder in specified path"));
			}
		}, currentLocation, "Download Haxe", "http://haxe.org/download");
	}
	
	function getHaxeStdFolder(path:String):String
	{
		var pathToStd:String = null;
		
		var fileName = "haxe";
		
		switch (Utils.os)
		{
			case Utils.WINDOWS:
				fileName += ".exe";
			default:

		}
		
		if (Fs.existsSync(path)) 
		{
			if (Fs.existsSync(Path.join(path, fileName)))
			{
				path = Path.join(path, "std");

				if (Fs.existsSync(path))
				{
					pathToStd = path;
				}
			}
		}
		
		return pathToStd;
	}

	public function getProjectClasspaths(project:Project, onComplete:ClasspathAndLibs->Void)
	{
		var classpathsAndLibs = null;
		
		switch (project.type) 
		{
			case Project.HAXE, Project.HXML:
				var path:String;

				if (project.type == Project.HAXE) 
				{
					path = Path.join(ProjectAccess.path, project.targetData[project.target].pathToHxml);
				}
				else 
				{
					path = Path.join(ProjectAccess.path, project.main);
				}
				
// 				var options:js.Node.NodeFsFileOptions = { };
// 				options.encoding = "utf8";

				var data:String = Fs.readFileSync(path, "utf8");
				classpathsAndLibs = getClasspaths(data.split("\n"));
				
				processHaxelibs(classpathsAndLibs.libs, function (libs)
								{
									var classpathsAndLibs2 = {classpaths: classpathsAndLibs.classpaths, libs: libs};
									onComplete(classpathsAndLibs2);
								}
							   );
			case Project.OPENFL:
				OpenFLTools.getParams(ProjectAccess.path, project.openFLTarget, function (stdout:String):Void 
				{
					classpathsAndLibs = getClasspaths(stdout.split("\n"));
					
					processHaxelibs(classpathsAndLibs.libs, function (libs)
								{
									var classpathsAndLibs2 = {classpaths: classpathsAndLibs.classpaths, libs: libs};
									onComplete(classpathsAndLibs2);
								}
							   );
				});
			default:

		}
	}

	public function parseProjectArguments():Void 
	{
		ClassParser.classCompletions = new StringMap();
		ClassParser.filesList = [];
		
		ClassParser.topLevelClassList = [];
		ClassParser.importsList = [];
		
		if (ProjectAccess.path != null) 
		{
			var project = ProjectAccess.currentProject;
			
			getProjectClasspaths(project, function (classpathsAndLibs)
								 {
									for (path in classpathsAndLibs.classpaths) 
									{
										parseClasspath(path);
									}

								 	for (lib in classpathsAndLibs.libs)
									{
										parseClasspath(lib.path, lib.std);
									}
								 }
								);
		}
		
		walkProjectDirectory(ProjectAccess.path);
	}
        
    function getFileDirectory(relativePath:String):String
	{
        var directory:String = "";
        
        if (relativePath.indexOf("/") != -1)
        {
            directory = relativePath.substring(0, relativePath.lastIndexOf("/"));
        }
        else if (relativePath.indexOf("\\") != -1)
        {
            directory = relativePath.substring(0, relativePath.lastIndexOf("\\"));
        }
            
        return directory;
    }
	
	function getClasspaths(data:Array<String>)
	{
		var classpaths:Array<String> = [];
		
		for (arg in parseArg(data, "-cp")) 
		{
			var classpath:String = Path.resolve(ProjectAccess.path, arg);
			classpaths.push(classpath);
		}

		var libs:Array<String> = parseArg(data, "-lib");
		return {classpaths: classpaths, libs: libs};
	}
	
	function processHaxelibs(libs:Array<String>, onComplete:Array<LibClassPath>->Void):Void 
	{		
		var n = libs.length;
		
		var classpaths = [];
		
		if (n > 0)
		{
			for (arg in libs) 
			{
				var processHelper = ProcessHelper.get();

				processHelper.runProcess(HaxeHelper.getPathToHaxelib(), ["path", arg], null, function (stdout:String, stderr:String):Void 
				{
					n--;

					for (path in stdout.split("\n")) 
					{
						if (path.indexOf(Path.sep) != -1) 
						{
							path = StringTools.trim(path);
							path = Path.normalize(path);

							Fs.exists(path, function (exists:Bool)
							{
								if (exists) 
								{
									classpaths.push({path: path, std: false});
								}
							}
							);
						}
					}

					if (n == 0)
					{
						onComplete(classpaths);
					}
				}
				);
			}
		}
		else
		{
			onComplete(classpaths);
		}
	}
	
	function parseArg(args:Array<String>, type:String):Array<String>
	{
		var result:Array<String> = [];
		
		for (arg in args)
		{
			arg = StringTools.trim(arg);
			
			if (StringTools.startsWith(arg, type)) 
			{
				result.push(arg.substr(type.length + 1));
			}
		}
		
		return result;
	}
	
	function parseClasspath(path:String, ?std:Bool = false):Void
	{        
        if (Main.sync)
        {
            for (pathToFile in Walkdir.sync(path))
            {
                var stat = Fs.lstatSync(pathToFile);
                
                if (stat.isFile())
                {
               		processFile(pathToFile, std);    
                }
            }
        }
        else
        {
            var emitter = Walkdir.walk(path, {});
		
            emitter.on("file", function (pathToFile, stat):Void 
            {
                processFile(pathToFile, std);
            }
            );

            emitter.on("error", function (pathToFile:String, stat):Void 
            {
                trace(pathToFile);
            }
            );
        }
	}
	
    function processFile(path:String, std:Bool)
    {
        addFile(path, std);

        var options:FsReadFileOpt = { };
       	options.encoding = "utf8";
            
        if (Path.extname(path) == ".hx") 
        {
            Fs.readFile(path, options, function (error, data:String):Void 
            {
                if (error == null) 
                {
                    ClassParser.processFile(data, path, std);
                }
            }
            );
        }
    }

	function getFileIndex(pathToFile:String, list:Array<FileData>):Int
	{
        var index:Int = -1;
            
        for (i in 0...list.length)
        {
            if (list[i].path == pathToFile)
            {
                index = i;
                break;
            }
        }
            
        return index;
    }

	public function addFile(path:String, ?std:Bool = false)
	{
        var relativePath:String;
        var list:Array<FileData>;
        
		var completionInstance = Completion.get();
		
		if (!SettingsWatcher.isItemInIgnoreList(path) && !ProjectAccess.isItemInIgnoreList(path)) 
		{            
            if (std)
            {
                list = ClassParser.haxeStdFileList;
            }
            else
            {
                list = ClassParser.filesList;
            }
                
            if (ProjectAccess.path != null && (core.Utils.os == core.Utils.WINDOWS || !std))
            {
                relativePath = Path.relative(ProjectAccess.path, path);

                if (getFileIndex(relativePath, list) == -1)
                {
                    list.push({path: relativePath, directory: getFileDirectory(relativePath), displayText: completionInstance.processDisplayText(relativePath), filename: Path.basename(relativePath)});
                }
            }
            else if (getFileIndex(path, list) == -1)
            {
                list.push({path: path, directory: getFileDirectory(path), displayText: completionInstance.processDisplayText(path), filename: Path.basename(path)});
            }            
		}
	}
	
	public function removeFile(path:String)
	{
		var relativePath;
		
        var index:Int = -1;
        
        for (list in [ClassParser.haxeStdFileList, ClassParser.filesList])
        {
			if (ProjectAccess.path != null) 
            {
                relativePath = Path.relative(ProjectAccess.path, path);

                index = getFileIndex(relativePath, list);

                if (index != -1)
                {
                    list.remove(list[index]);    
                }
            }

            index = getFileIndex(path, list);

            if (index != -1)
            {
                list.remove(list[index]);    
            }
        }
	}
	
	function walkProjectDirectory(path:String):Void 
	{
        if (Main.sync)
        {
			Walkdir.sync(path, {}, function (path:String, stat:Stats)
                            {
                                if (stat.isFile())
                                {
                                    addFile(path);
                                }
                            }
                            );
        }
        else
        {
            var emitter = Walkdir.walk(path, {});

//             var options:NodeFsFileOptions = { };
//             options.encoding = "utf8";

            emitter.on("file", function (path, stat):Void 
            {			
                addFile(path);
            }
            );

            emitter.on("error", function (path:String, stat):Void 
            {
                trace(path);
            }
            );
        }
	}
	
}
