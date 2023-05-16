//Macro to rename replace letter in file names and to save them in subfolders

dir1 = getDirectory("Choose Source Directory");
dir2 = getDirectory("Choose Destination Directory");
list = getFileList(dir1);
//numSubfolders = 3;

#@int(label="Please enter the number of subfolders you would like to create", description="Number of subfolders") numSubfolders


setBatchMode(true);

// Create subfolders for ROIs


for (j=0; j < numSubfolders; j++){
	File.makeDirectory(dir2 + "\\" + j);
}

print("list.length", list.length);

indexLimit = floor(list.length/numSubfolders);
print("indexLimit", indexLimit);

for (i=0; i<list.length; i++){
 	if (endsWith(list[i], "roi")) //check if it is a roi file before processing it
	{
		open(dir1+list[i]);
		
		name = replace(list[i], ".roi", "") + "";
    	name = replace(name, ".", "-");
	
		print("i", i);		
		j = i%numSubfolders; // Name of the destination folder for list element no.i
		
		print("j",j);
		saveAs("ROI", "" + dir2 + "\\" + j + "\\" + name +""); //save images with the new name
	}
}

print("Renaming done")

/// FUNCTIONS

function getTitleStripExtension() {
  t = getTitle();
  extensions = newArray(".tif", ".tiff", ".lif", ".lsm", ".czi", ".nd2", ".ND2", ".roi");    
  for(i=0; i<extensions.length; i++)
    t = replace(t, extensions[i], "");  
  return t;
}
	