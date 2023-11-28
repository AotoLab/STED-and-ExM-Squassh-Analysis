/* Split '*_outline_overlay.tif' images from Mosaic SB output.  Batch processes subdirectories...
 *  Draft initialize: 181106; refined previous *_wrkng.ijm version of script
 */

 run("Close All");

 // select main directory
parentDir = getDirectory("Choose a main directory "); 
subList = getFileList(parentDir); // Array.print(subList);
suffix = "overlay.tif";  
setBatchMode(true);

for (i=0; i<subList.length; i++) {  // for loop to parse through names in main folder 
     if(endsWith(subList[i], "/")){   // if the name is a subfolder... 
     	subDir = parentDir + subList[i]; subname = replace(subList[i],"/","");
     	processFolder(subDir);
		print(i);
     }
}
print("Now this is all Done");
function processFolder(subDir) {
	list = getFileList(subDir); // Array.print(list);
	for (j = 0; j < list.length; j++) {
		if(endsWith(list[j], suffix)) 	{
			processFile(subDir, list[j]);
		}
	}
}

function processFile(input,file) {
	// load composite '*_outline_overlay.tif'; split image
	filepath = input+file; open(filepath); filedir = getDirectory("image");
	filec=getTitle(); run("Split Channels");

	// process C1 outline image-----
	selectWindow("C1-" + filec); run("Grays"); rename(File.nameWithoutExtension+"_objOutline.tif");
	file1=getTitle(); file1 = replace(file1,"_outline_overlay","");
	file1out = filedir+file1; save(file1out); rename(file1); close();

	//process ch2, intensity Map image
	selectWindow("C2-" + filec); run("Grays"); rename(File.nameWithoutExtension+"_intensityMap.tif");
	file2=getTitle(); file2 = replace(file2,"_outline_overlay","");
	file2out = filedir+file2; save(file2out); rename(file2); close();
}
