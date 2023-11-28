run("Close All");
dir = getDirectory("Choose folder to check");
          filelist = getFileList(dir); //list of files inside directory to look through
          checkset = 0;
           	for (f=0;f<filelist.length;f++){  //load distance image and objects image	
          		if(startsWith(filelist[f], "C1") && endsWith(filelist[f],"mask.tif")){
          			open(dir+filelist[f]);
          			checkset = checkset+1;
          		}
          		if(startsWith(filelist[f], "C2") && endsWith(filelist[f],"mask.tif")){
          			open(dir+filelist[f]);
          			checkset = checkset+1;
          		}
          		if(startsWith(filelist[f], "C3") && endsWith(filelist[f],"mask.tif")){
          			open(dir+filelist[f]);
          			checkset = checkset+1;
          		}	
           }	
			if(checkset != 3){
          		print("Missing a file");
          		}else {
				print(dir);
          		}

run("Tile");
list = getList("image.titles");
run("Merge Channels...", "c1="+list[0]+" c2="+list[1]+" c5="+list[2]+" create ignore");
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");


saveCleanedImage();

function saveCleanedImage(){
Dialog.createNonBlocking("Save_FilteredImage_forSIMSTED");
Dialog.addImageChoice("Click to save Image: Must be 3 CH labeled image");
Dialog.show;
imname = Dialog.getImageChoice();
setBatchMode(true);
//imname = getTitle(); 
dir = getDirectory("Choose folder to save");
filelist = getFileList(dir); //list of files inside directory to look through
selectWindow(imname);
run("Split Channels");
          checkset = 0;
           	for (f=0;f<filelist.length;f++){  //load distance image and objects image	
          		if(startsWith(filelist[f], "C1") && endsWith(filelist[f],"mask.tif")){
          			fnstart = indexOf(filelist[f], "mask.tif");
          			selectWindow("C1-"+imname);
          			saveAs("Tiff",dir+substring(filelist[f],0,fnstart)+"mask_fltrd.tif");
          			checkset = checkset+1;
          			close(substring(filelist[f],0,fnstart)+"mask_fltrd.tif");
          		}
          		if(startsWith(filelist[f], "C2") && endsWith(filelist[f],"mask.tif")){
          			fnstart = indexOf(filelist[f], "mask.tif");
          			selectWindow("C2-"+imname);
          			saveAs("Tiff",dir+substring(filelist[f],0,fnstart)+"mask_fltrd.tif");
          			checkset = checkset+1;
          			close(substring(filelist[f],0,fnstart)+"mask_fltrd.tif");
          		}
          		if(startsWith(filelist[f], "C3") && endsWith(filelist[f],"mask.tif")){
          			fnstart = indexOf(filelist[f], "mask.tif");
          			selectWindow("C3-"+imname);
          			saveAs("Tiff",dir+substring(filelist[f],0,fnstart)+"mask_fltrd.tif");
          			checkset = checkset+1;
          			close(substring(filelist[f],0,fnstart)+"mask_fltrd.tif");
          		}	
           }	
			if(checkset != 3){
          		print("Missing a file");
          		}else {
				print(dir);
          		}

print("Finished Saving");
}


