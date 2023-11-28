run("Close All")
 // select main directory
parentDir = getDirectory("Choose a main directory ");  print(parentDir);
subList = getFileList(parentDir);   // Array.show(subList);

// setBatchMode(true);

for (i=0; i<subList.length; i++) {  // for loop to parse through names in main folder
	 run("Collect Garbage");
     if(endsWith(subList[i], "/")){   // if the name is a subfolder; File.separator does not work...
     	subDir = parentDir + subList[i]; subname = replace(subList[i],"/",""); 
     	print(subDir); print(subname);
     	
        processFolder(subDir);
        
        }
}

print("Processing complete...");

function processFolder(input) {
            
        print("processing folder "+ subname);

        run("Squassh", "regularization_(>0)_ch1=0.050 regularization_(>0)_ch2=0.050 "+
			"minimum_object_intensity_channel_1_(0_to_1)=0.250 _channel_2_(0_to_1)=0.150 "+
			"subpixel_segmentation standard_deviation_xy=0.80 standard_deviation_z=0.80 "+
			"remove_region_with_intensities_<=80 remove_region_with_size_<=2 local_intensity_estimation=Medium noise_model=Poisson "+
			"intermediate_steps colored_objects objects_intensities labeled_objects outlines_overlay soft_mask save_objects_characteristics "+
			"number=1 input=["+subDir+"]");

		run("Close All");         
}




