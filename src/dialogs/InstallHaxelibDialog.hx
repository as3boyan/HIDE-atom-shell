package dialogs;
import projectaccess.ProjectAccess;
import bootstrap.ButtonManager;
import bootstrap.InputGroup;
import bootstrap.InputGroupButton;
import bootstrap.RadioElement;
import core.ProcessHelper;
import jQuery.JQuery;
import js.Browser;
import js.html.InputElement;
import js.html.KeyboardEvent;
import js.html.ParagraphElement;

/**
 * ...
 * @author AS3Boyan
 */
class InstallHaxelibDialog extends ModalDialog
{
	//var inputGroupButton:InputGroupButton;
	var lib:String;
	var pathToHxml:String;
	var input:InputElement;
	var installHxmlLibsRadio:RadioElement;
	var commandPreviewP:ParagraphElement;
	var installLibRadio:RadioElement;
	var installAllHxmlLibsRadio:RadioElement;

	public function new()
	{
		super("Missing haxelib");
		
		var form = Browser.document.createFormElement();
		form.setAttribute("role", "form");
		
		var inputGroup:InputGroup = new InputGroup();
		inputGroup.getElement().id = "commandInputElement";
		
		inputGroup.getElement().style.display = "none";
		
		input = inputGroup.getInput();
		
		installLibRadio = new RadioElement("haxelibInstallOptions", "installLib", "install from haxelib", function ():Void 
		{
			input.value = "haxelib install " + lib;
			input.onchange(null);
			inputGroup.getElement().style.display = "none";
		});
		installLibRadio.getInput().checked = true;
		form.appendChild(installLibRadio.getElement());
		
		installHxmlLibsRadio = new RadioElement("haxelibInstallOptions", "installHxmlLibs", "install all libs for hxml from haxelib", function ():Void 
		{
			input.value = "haxelib install " + pathToHxml;
			input.onchange(null);
			inputGroup.getElement().style.display = "none";
		});
		installHxmlLibsRadio.getInput().checked = true;
		form.appendChild(installHxmlLibsRadio.getElement());
		
		installAllHxmlLibsRadio = new RadioElement("haxelibInstallOptions", "installHxmlLibs", "install all libs for all hxml from haxelib", function ():Void 
		{
			input.value = "haxelib install all";
			input.onchange(null);
			inputGroup.getElement().style.display = "none";
		});
		installAllHxmlLibsRadio.getInput().checked = true;
		form.appendChild(installAllHxmlLibsRadio.getElement());
		
		var installLibFromGitRadio = new RadioElement("haxelibInstallOptions", "installLibFromGit", "install from git", function ():Void 
		{
			input.value = "haxelib git " + lib + " <git-clone-path> <branch> <subdirectory>";
			input.onchange(null);
			inputGroup.getElement().style.display = "";
		});
		installLibFromGitRadio.getInput().checked = true;
		form.appendChild(installLibFromGitRadio.getElement());
		
		var installLibFromDevRadio = new RadioElement("haxelibInstallOptions", "installLibFromDev", "set development directory", function ():Void 
		{
			input.value = "haxelib dev " + lib + " <directory>";
			input.onchange(null);
			inputGroup.getElement().style.display = "";
		});
		
		installLibFromDevRadio.getInput().checked = true;
		form.appendChild(installLibFromDevRadio.getElement());
		
		getBody().appendChild(form);
		
		getBody().appendChild(inputGroup.getElement() );
		
		commandPreviewP = Browser.document.createParagraphElement();
		commandPreviewP.id = "commandPreviewText";
		
		input.onchange = function (e):Void 
		{
			commandPreviewP.textContent = "Run command: " + input.value;
		};
		
		getBody().appendChild(commandPreviewP);
		
		var buttonManager = ButtonManager.get();
		
		var cancelButton = buttonManager.createButton("Cancel", false, true);
		getFooter().appendChild(cancelButton);
		
		var okButton = buttonManager.createButton("OK", false, false, true);
		okButton.onclick = function (e):Void 
		{	
			Alertify.log("Running command: " + input.value);
			
			var params = StringTools.trim(input.value).split(" ");
			
			var cwd = ProjectAccess.path;
			
			var processHelper = ProcessHelper.get();
			
			processHelper.runPersistentProcess(params.shift(), params, cwd, function (code, stdout, stderr):Void 
			{
				if (code == 0) 
				{
					Alertify.success(lib + " install complete(" + input.value + ").");
				}
				else
				{
					Alertify.error("Error on running command " + input.value);
					Alertify.error(stdout);
					Alertify.error(stderr);
				}
			}, true);
			
			hide();
		};
		
		getFooter().appendChild(okButton);
		
		Browser.document.addEventListener("keyup", function (e:KeyboardEvent):Void 
		{
			if (e.keyCode == 13 && new JQuery(getModal()).is(":visible"))
			{
				okButton.click();
			}
		}
		);
	}
	
	public function setLib(name:String):Void 
	{
		lib = name;
		setTitle('Missing "' + lib + '" haxelib');
	}
	
	public function setPathToHxml(?path:String):Void 
	{
		pathToHxml = path;
		
		if (path != null) 
		{
			installHxmlLibsRadio.getInput().disabled = false;
			installAllHxmlLibsRadio.getInput().disabled = false;
		}
		else 
		{
			installHxmlLibsRadio.getInput().disabled = true;
			installAllHxmlLibsRadio.getInput().disabled = true;
		}
	}
	
	override public function show():Void 
	{
		super.show();
		installLibRadio.getInput().checked = true;
		input.value = "haxelib install " + lib;
		input.onchange(null);
	}
	
}