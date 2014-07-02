package completion;
import core.Completion;

/**
 * ...
 * @author AS3Boyan
 */
class Filter
{
	public static function filter(completions:Array<Hxml.CompletionData>, word:String, completionType:CompletionType):Array<Hxml.CompletionData>
	{
		var list:Array<Hxml.CompletionData> = [];
		
		if (word != null) 
		{
			var filtered_results = [];
			var sorted_results = [];
			
			word = word.toLowerCase();
			
			for (completion in completions) 
			{
				var n = completion.text.toLowerCase();
				var b = true;
			  
				  for (j in 0...word.length)
				  {
					  if (n.indexOf(word.charAt(j)) == -1)
					  {
						  b = false;
						  break;
					  }
				  }

				if (b)
				{
					filtered_results.push(completion);
				}
			}
			
			var results = [];
			var filtered_results2 = [];
			var filtered_results3 = [];
			var exactResults = [];
			
			for (i in 0...filtered_results.length) 
			{
				var str = filtered_results[i].text.toLowerCase();
				var index:Int = str.indexOf(word);
				
				if (word == str) 
				{
					exactResults.push(filtered_results[i]);
				}
				else if (index == 0)
				{
					sorted_results.push(filtered_results[i]);
				}
                else if (index == str.length)
				{
					filtered_results3.push(filtered_results[i]);
				}
				else if (index != -1) 
				{
					filtered_results2.push(filtered_results[i]);
				}
				else
				{
					results.push(filtered_results[i]);
				}
			}
			
			for (completion in exactResults) 
			{
				list.push(completion);
			}
			
			for (completion in sorted_results) 
			{
				list.push(completion);
			}
			
			for (completion in filtered_results2) 
			{
				list.push(completion);
			}
                
            for (completion in filtered_results3) 
			{
				list.push(completion);
			}
			
			for (completion in results) 
			{
				list.push(completion);
			}
		}
		else 
		{
			list = completions;
		}
		
		return list;
	}
        
    public static function sortFileList(list:Array<parser.ClassParser.FileData>)
	{        
        list.sort(function(a:parser.ClassParser.FileData, b:parser.ClassParser.FileData):Int
        {
            var aCount:Int;
            var bCount:Int;

            var aHaxeFile:Bool = StringTools.endsWith(a.filename, ".hx");
            var bHaxeFile:Bool = StringTools.endsWith(b.filename, ".hx");

            if (aHaxeFile && !bHaxeFile) return -1;
            if (!aHaxeFile && bHaxeFile) return 1;

            aCount = a.path.split("\\").length + a.path.split("/").length;
            bCount = b.path.split("\\").length + b.path.split("/").length;
            if (aCount < bCount) return -1;
            if (aCount > bCount) return 1;
            return 0;
        } );
        
        return list;
    }

	public static function filterFiles(fileList:Array<parser.ClassParser.FileData>, word:String)
	{
        var list:Array<parser.ClassParser.FileData> = [];
        
        var filtered_results = [];
        var sorted_results = [];

        word = word.toLowerCase();

        for (completion in fileList) 
        {
            var n = completion.path.toLowerCase();
            var b = true;

              for (j in 0...word.length)
              {
                  if (n.indexOf(word.charAt(j)) == -1)
                  {
                      b = false;
                      break;
                  }
              }

            if (b)
            {
                filtered_results.push(completion);
            }
        }

        var results = [];
        var filtered_results2 = [];
        var filtered_results3 = [];
        var exactResults = [];
		var filenameResults = [];

        for (i in 0...filtered_results.length) 
        {
            var path = filtered_results[i].path.toLowerCase();
			var filename = filtered_results[i].filename.toLowerCase();

            var index:Int = path.indexOf(word);

			if (word == filename)
            {
                filenameResults.push(filtered_results[i]);
            }
            else if (StringTools.startsWith(filename, word))
            {
                filenameResults.push(filtered_results[i]);
            }
            else if (word == path) 
            {
                exactResults.push(filtered_results[i]);
            }
            else if (index == 0)
            {
                sorted_results.push(filtered_results[i]);
            }
            else if (index == path.length)
            {
                filtered_results3.push(filtered_results[i]);
            }
            else if (index != -1) 
            {
                filtered_results2.push(filtered_results[i]);
            }
            else
            {
                results.push(filtered_results[i]);
            }
        }

        for (completion in filenameResults) 
        {
            list.push(completion);
        }
            
        for (completion in exactResults) 
        {
            list.push(completion);
        }

        for (completion in sorted_results) 
        {
            list.push(completion);
        }

        for (completion in filtered_results2) 
        {
            list.push(completion);
        }

        for (completion in filtered_results3) 
        {
            list.push(completion);
        }

        for (completion in results) 
        {
            list.push(completion);
        }
            
        return list;
    }
}