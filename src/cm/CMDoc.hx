package cm;

/**
 * ...
 * @author AS3Boyan
 */
class CMDoc
{
	public var name:String;
	public var doc:CodeMirror.Doc;
	public var path:String;
	
	public function new(_name:String, _doc:CodeMirror.Doc, _path:String) 
	{
		name = _name;
		doc = _doc;
		path = _path;
	}	
}