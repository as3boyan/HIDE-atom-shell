###How to compile:
1. Clone source using git

        git clone --recursive https://github.com/as3boyan/HIDE.git

1. You will need Haxe 3. Install haxelibs:
	
        haxelib install jQueryExtern
        haxelib install hxparse
        haxelib install tjson
        haxelib install jQueryExtern
        haxelib install node-webkit

2. Navigate to __HIDE/bin__ and run __npm install__ to install required dependencies(you might need to add __sudo__ if you work under Linux/Mac OS X)

		npm install

3. Navigate to the root folder and compile HIDE by running:

        haxe HIDE.hxml

4. Navigate to __HIDE/bin__ folder and run node-webkit there using:

        haxelib run node-webkit

5. Select __File__ -> __Open Project...__ and select __project.hide__ in the root folder of the HIDE repository to open HIDE project in HIDE

###How to contribute:

1. Make sure you have a [GitHub Account](https://github.com/signup/free)
2. Fork [HIDE](https://github.com/misterpah/hide)
  ([how to fork a repo](https://help.github.com/articles/fork-a-repo))
3. Make your changes
4. Submit a pull request
([how to create a pull request](https://help.github.com/articles/fork-a-repo))

Contributions are welcome.

###Getting help

Community discussion, questions, and informal bug reporting is done on the
[HIDE Google group](https://groups.google.com/group/haxeide).
	
## Submitting bug reports

The preferred way to report bugs is to use the
[GitHub issue tracker](https://github.com/misterpah/hide/issues).

###Developer's Guide

####How HIDE works

A few words on inner structure of HIDE.

HIDE walks through "plugins" directory and search for "plugin.hxml" file.

When "plugin.hxml" is found, HIDE will try to add

```
<script src="path/to/plugin/bin/Main.js">
```

to html page. Which will cause script loading and execution.

NOTE: HIDE tracks changes in plugins and recompiles plugin if it's source was changed.

####Plugin Structure:

Required files:
1. plugin.hxml
2. bin/Main.js

####How to develop a plugin

Create a copy of "plugins/boyan/samples/helloworld" folder.
And rename it to plugin name, for example "plugins/john/samples/test".

Modify "src/Main.hx" to suit your needs.

you can use HIDE core functions to load JS and CSS scripts you may need:

```
//JS
HIDE.loadJS(name, ["script1.js", "script2.js", "script3.js"], function ()
{
	trace("JS scripts load complete");
}
);

//CSS
HIDE.loadCSS(name, ["stylesheet1.css", "stylesheet2.css", "stylesheet3.css"], function ()
{
	trace("CSS load complete");
}
);
```

notify HIDE core, that plugin is ready to use:

```
HIDE.notifyLoadingComplete(name);
```

So if some plugins depend on this plugin, then they can start loading themselves.
