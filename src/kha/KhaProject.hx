package kha;
import newprojectdialog.NewProjectDialog;

/**
* @author 
 */
class KhaProject
{
	static var instance:KhaProject = null;
	
	public function new()
	{
			
	}
	
	public static function get()
	{
		if (instance == null)
		{
			instance = new KhaProject();
		}
		
		return instance;
	}
	
    public function load()
    {
//         NewProjectDialog.getCategory("Kha", 3).addItem("Empty project", null, false, false);
    }
    
    function cloneKhaEmptyProject(data:ProjectData)
    {
		
    }


}