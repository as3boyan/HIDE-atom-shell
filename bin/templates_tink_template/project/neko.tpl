::static function generateHxml(file: String)::
#integrate files to classpath
-cp src

#this class wil be used as entry point for your app.
-main Main

#neko target
-neko ::file::

#Add debug information
-debug

#dead code elimination : remove unused code
#"-dce no" : do not remove unused code
#"-dce std" : remove unused code in the std lib (default)
#"-dce full" : remove all unused code
-dce full
::end::