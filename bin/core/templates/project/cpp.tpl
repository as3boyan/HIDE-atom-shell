#integrate files to classpath
-cp src

#this class wil be used as entry point for your app.
-main ::if (pack != null)::::pack::.::end::Main

#CPP target
-cpp ::file::

#To produce 64 bit binaries the file should define the HXCPP_M64 compile variable:
-D HXCPP_M64

#Add debug information
-debug

#dead code elimination : remove unused code
#"-dce no" : do not remove unused code
#"-dce std" : remove unused code in the std lib (default)
#"-dce full" : remove all unused code
-dce full