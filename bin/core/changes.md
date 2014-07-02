0.4.1
-----------

* CHANGED: switched to "Segoe UI" font for GUI

0.4.0
-----------

* CHANGED: metrodark theme
* ADDED: completion on type
* ADDED: indentation settings
* ADDED: YAML syntax highlighting
* ADDED: overridden method parameters hinting
* ADDED: preserve code folding, cursor position and indentation between sessions
* ADDED: Move variable declaration to class scope action(using Ctrl-Shift-1)
* ADDED: Code suggestions
* ADDED: XML completion
* ADDED: Project Options: Debug/Release switch for OpenFL projects

0.3.9
-----------

* FIX: typing dot in non Haxe files
* FIX: theme file switching on settings.json file save
* FIX: added additional checks for process stdout and stderr parsing to fix parsing issues
* FIX: create directory recursively for new project using "mkdirp" node module(which will create folders recursively, if some of them doesn't exists)
* FIX: code editor zoom(using Alt and View menu) will call refresh on code editor(should fix issues with cursor)
* FIX: various fixes affecting completion(Hxml, regular completion)
* FIX: catch exceptions on EReg preview parsing errors
* CHANGED: do not change file using Navigation->Open File(completionItem.text = "", completionItem.displayText = "path/to/file")
* CHANGED: scroll to bottom output textarea
* CHANGED: Hxml completion: show completion on "-" only if it's at beginning of line
* CHANGED: do not wrap file tree context menu items
* CHANGED: do not save file for function parameters hint
* CHANGED: close documents on project switch(and open project documents)
* ADDED: install missing haxelib dialog
* ADDED: annotation ruler(with very basic style)
* ADDED: basic outline panel
* ADDED: Vim mode(can be switched on and off in Options->Open editor configuration file, comment '"keyMap": "sublime"' line and uncomment '//"vimMode": true, //"keyMap": "vim",')
* ADDED: Python target support
* ADDED: Code Completion description
* ADDED: Improved function parameters hinting(show active parameter).
* ADDED: Configurable code snippets
* ADDED: File tree lazy loading
* ADDED: Show top level classes in top level completion
* ADDED: Dark theme
* ADDED: Cappuccino menu theme
* ADDED: Autoimport(Ctrl-Shift-1 or Cmd-Shift-1 on Mac)

0.3.8
-----------

* FIX: add all haxelibs from haxelib server(using 'haxelib search ""', previously some haxelibs were not added due to "lib.haxe.org/all" page html parsing issues)
* FIX: project saving on quit
* FIX: trigger completion on dot only for Haxe mode
* FIX: do not reparse classpath on watcher file change event
* FIX: opening same file on Windows on build errors
* CHANGED: submenu max-height to 500px, overflow: auto
* ADDED: macro to look for CodeMirror themes and add them to
View->Themes
* ADDED: download button to browse directory dialog(for specifying path to Haxe, as suggested by @underscorediscovery)
* ADDED: Options->Configure Haxe SDK(compiler will still be used from PATH, this is used for parsing purposes)
* ADDED: Haxe pick completion on dot and show completion again(completion chaining)

0.3.7
-----------

* FIX: OpenFL project import(*.xml, *.lime)
* FIX: Do not show multiple hxml options for HXML projects(which depend on only one hxml)
* FIX: Do not update linting for non Haxe files on project build
* FIX: Class path walker for HAXE projects
* CHANGED: created OpenFL projects will not hardcode to "project.xml", instead just use "haxelib run lime build flash", lime/OpenFL can detect project file itself
* ADDED: Help->Open Haxe nightly build download URL(which should open default browser and start latest Haxe nightly build download for your platform)
* ADDED: update Open File completion using file tree watcher
* ADDED: Hxml toggle comment

0.3.6
-----------

* FIX: Code Completion for Haxe project type(Thanks Philippe Elsass for bug report)
* FIX: Dirty fix for custom completion hotkey(Introduced in 0.3.5 - code completion hotkey was moved to hotkeys.json to make it customizable). From now, code editor should not type data, when user presses code completion hotkey, for example, it shoudn't insert space character when user presses "Ctrl-Space" and etc.
* FIX: Code Completion for OpenFL projects

0.3.5
-----------

* FIX: opening two instances of flash player issue
* FIX: showing multiple notifications issue for run command(will show only one for build)
* FIX: code editor resize on window maximize/unmaximize event
* FIX: functions parameters hint issue(for functions with one argument, do not show function parameters for non-functions)
* CHANGED: Show file list(Ctrl-Shift-O) for any file(previously worked only for *.hxml and *.hx)
* CHANGED: Do not show prompt for path to Haxe dialog if 'std' folder was found
* CHANGED: config files moved to 'config' folder
* CHANGED: locale files moved to 'locale' folder
* CHANGED: File->Open... was replaced with File->Open Project...(with file extension filter) and File->Open File
* CHANGED: Do not add hotkeys for submenu menu items
* CHANGED: Open File completion: Set higher priority for project files
* CHANGED: Parse Haxe Std only once on start
* CHANGED: Set tween duration to 250 ms(previously it were 400 ms)
* CHANGED: File saving behaviour changed, file saving will not clear undo/redo history for document
* ADDED: Hxml syntax highlighting mode
* ADDED: Check default path for Haxe on all platforms
* ADDED: EReg Preview
* ADDED: Color Picker
* ADDED: Watch file tree for changes
* ADDED: File Tree drag 'n' drop support for files and folders
* UPDATED: lime/OpenFL support updated to work with latest versions

0.3.4
-----------

* FIX: project.json saving
* FIX: CM theme loading
* FIX: completion for hxml projects
* FIX: multiple haxe processes issue(check if process if already started)
* FIX: window state preserving
* FIX: project options padding
* FIX: Tab Manager context menu: Close others
* FIX: Hotkeys for Mac
* CHANGED: Plugins were moved to the core(for performance, stability and to make development easier), HIDE still supports plugin system.
* CHANGED: Release on haxelib only JavaScript code(without source)
* CHANGED: removed Acorn(unused parser, which Tern depends on)
* CHANGED: removed Tern
* CHANGED: use TJSON to encode/parse JSON data
* CHANGED: show anyword completion when no completion available
* CHANGED: moved elements CSS to one file theme.css
* CHANGED: moved source code to packages
* CHANGED: renamed config.json to hotkeys.json
* CHANGED: Project options panel: show run action option for hxml projects
* CHANGED: check if run action url/file/command is empty
* CHANGED: replaced jQuery layout plugin with jQWidget splitter
* CHANGED: project options panel moved to tab
* CHANGED: use Mustache for templates
* CHANGED: use alertify for prompt/confirm/alert dialogs and notifications
* CHANGED: tab manager was rewritten
* CHANGED: hide outline panel and file tree when no project open
* CHANGED: linting will get updated on build/parse
* ADDED: Help: changelog command
* ADDED: Options: Open editor configuration file command
* ADDED: Help: Show code editor key bindings
* ADDED: Options: Open stylesheet(to customize visual look of HIDE)
* ADDED: Show hints for function parameters
* ADDED: compile time errors linting
* ADDED: Options: Open autoformat configuration file to adjust code formatter options
* ADDED: restore open tabs
* ADDED: Select last active tab when restoring open tabs
* ADDED: check document extension before showing function parameters/completion/linting
* ADDED: Results and Options tabs
* ADDED: Toggle comments on Ctrl-Q(was fixed in CM), also Ctrt-/ should work too as default hotkey
* ADDED: show compile-time errors in Results tab
* ADDED: Show build status indicator on output tab header
* ADDED: watch theme.css for changes and apply to UI
* ADDED: CM Haxe mode indent
* ADDED: Watch open files(and show confirmation for reload)
* ADDED: Prompt path to haxe
* ADDED: Go to Line(Ctrl-G) dialog
* ADDED: On close tab - confirm dialog to save file or not(hotkeys: Enter - to save, Esc - to not save)
* ADDED: open file(Ctrl-Shift-O)
* ADDED: show class list(Ctrl-Shift-P)
* ADDED: welcome screen
* ADDED: completion for hxml
* ADDED: imports completion(same as show class list)
* ADDED: show installed lib list in hxml completion
* UPDATED: CodeMirror to v4

0.3.3
-----------

* Use jQueryExtern and nodejs from haxelib(instead of local copies)
* Source: Autoformat(uses haxeprinter to format code)
* hxml project management changes: from now, HIDE will not import hxml data to project arguments, it will create reference to them instead
* Override Project: Build command if currently active document matches hxml file extension, added Project: Set hxml as project
* View: Themes(saves current theme to localStorage)
* Drag and drop project files(project.json, project.xml, *.hxml) to open project
* Replaced prompt dialog for file tree context menu commands(New File..., New Folder...) to Bootbox.js prompt(Bootstrap based)
* Hotkeys management using config file in JSON format, added "Options: Open hotkey configuration file" command to open configuration file in HIDE(It will update hotkeys on configuration file save)

0.3.2
-----------

* Project options panel: relative paths now should work fine for Run Action: Open File
* boyan.bootstrap.tab-manager now should save files on tab close and "Close Others" context menu command
* Drag and drop folder to HIDE to show it's contents in file tree
* Preprocess build and run commands(use %path% var to specify path to project and %join%(path/to/folder,project.xml) function to join two paths). For example for OpenFL build and run commands preprocessed with such pattern: "%join%(%path%,project.xml)".
* Added context menu to file tree(needs custom prompt dialog, because default starts not focused)

0.3.1
-----------

* Fix for HIDE haxelib - don't recompile HIDE plugins on first start(to make it start faster first time)

0.3.0
-----------

* Release on haxelib