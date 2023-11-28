/* **** procesROIs_bkgnd;; kevin.crosby@ucdenver.edu
one channel, 2D data. designed for smt reference PSD images
fixed issue with i/j loops 171020
version current as of 171020 
current work: update to function with SIM 3C stack data 
171114 current version 
TODO: write parameters to log file*/

//=============User Entered Parameters======
// enter background window edge length parameters
L1 = 10; L2 = 20; L3 = 20;
// enter channel details
c1 = "GluA1"; c2 = "Homer1"; c3 = "nada";
//==========================================
// add channel tags to ensure numerical order
c1 = "c1_" + c1; c2 = "c2_" + c2; c3 = "c3_" + c3;

setBatchMode(true); 
// close any open images
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
// prompt user to select parent directory
mainDir = getDirectory("Choose a main directory "); 
mainList = getFileList(mainDir); 
suffix = ".tif"; //apparently wildcards '*' don't work in IJ macro language...

for (i=0; i<mainList.length; i++) {  // for loop to parse through names in main folder 
     if(endsWith(mainList[i], "/")){   // if the name is a subfolder... 

          subDir = mainDir + mainList[i]; 
          subList = getFileList(subDir); 
//print(subList);
           //for (j=0; j<subList.length; j++) {  // for loop to parse through names in subfolder 
			input = subDir; output = input;	
			// print(input); print(output);
			//process outline_overlay files in each subfolder
			processFolder(input);	
            
               function processFolder(input) {
					list = getFileList(input);
					for (j = 0; j < list.length; j++) {
					if(File.isDirectory(input + list[j]))
					processFolder("" + input + list[j]);
					if(endsWith(list[j], suffix))
					processFile(input, output, list[j]);
					// processFile(input, list[i]);
					}
				}

// split channels from original multi-channel image, perform individual
// background subtractions
// TODO: restructure naming format? Only if using single0channel bkgnd images in downstream IJ processing
function processFile(input, output, file) {
// print(file); 
filepath = input+file; // print(filepath); // nospace = replace(file," ","_"); print(nospace);
open(filepath); filedir = getDirectory("image"); 
oldname = getTitle(); filec = replace(oldname," ","_"); // print(filec);
rename(filec);
// selectImage(file); rename(nospace); filec=getTitle(); print(filec);
run("Split Channels");
// process ch1-----
selectWindow("C1-" + filec); run("Grays"); //run("Duplicate...", " ");
	run("Background Subtractor", "length=" + L1 + " stack");
	temp = getTitle(); print(temp); rename(temp);
	//rename(File.nameWithoutExtension+c1+"_bkgcor.tif");
	//rename(File.nameWithoutExtension+"_"+c1+"_bkgcor.tif");
	rename(File.nameWithoutExtension+"_bkgcor-"+c1+".tif");
	file1=getTitle(); //file1out = filedir+file1; save(file1out); rename(file1);
	// print(file1);
//process ch2------
selectWindow("C2-" + filec); run("Grays");
	//run("Background Subtractor", "length=" + L2 + " stack");
	//run("Background Subtractor", "length=5");
	//rename(File.nameWithoutExtension+"_bkgcor_c2.tif");
	rename(File.nameWithoutExtension+"_bkgcor-"+c2+".tif");
	file2=getTitle(); //file2out = filedir+file2; save(file2out); rename(file2);
//	print (file2);
//process ch3-----
selectWindow("C3-" + filec); run("Grays");
	//run("Background Subtractor", "length=" + L3 + " stack");
	//rename(File.nameWithoutExtension+"_bkgcor_c2.tif");
	rename(File.nameWithoutExtension+"_bkgcor-"+c3+".tif");
	file3=getTitle(); //file3out = filedir+file3; save(file3out); rename(file3);
	//print (file3);
//merge bkg corrected images-----------
//run("Merge Channels...", "c1=" + file1 + " c2=" + file2 + " create keep");
// 170913 Update to preserve channel numerical order
// 171109 update filename output to account for IJ lack of wildcard
run("Merge Channels...", "c1=" + file1 + " c2=" + file2 + " create keep");
//rename(filec); rename(File.nameWithoutExtension+"_"+c1+"_"+c2+"_cmpst.tif");
rename(filec); rename(File.nameWithoutExtension+"_"+c1+"_"+c2+"_bkgCmpst.tif");
filec=getTitle(); filecout = output+filec; save(filecout); //print (filec);

run("Merge Channels...", "c1=" + file1 + " c2=" + file3 + " create keep");
rename(filec); rename(File.nameWithoutExtension+"_"+c1+"_"+c3+"_bkgCmpst.tif");
filec=getTitle(); filecout = output+filec; save(filecout); //print (filec);

run("Merge Channels...", "c1=" + file2 + " c2=" + file3 + " create keep");
rename(filec); rename(File.nameWithoutExtension+"_"+c2+"_"+c3+"_bkgCmpst.tif");
filec=getTitle(); filecout = output+filec; save(filecout); //print (filec);
     print("Processed a file");
     while (nImages>0) { 
       selectImage(nImages); 
       close(); 
      }



          } 
     } 
   }
   print("All done");
//}   