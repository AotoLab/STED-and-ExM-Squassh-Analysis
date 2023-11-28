dir = getDirectory("Choose Source Directory");
list = getFileList(dir);
setBatchMode(true); 
for(i = 0; i < list.length; i++) {
name = list[i];
if (endsWith(name, "/")){
run("Squassh", "regularization_(>0)_ch1=0.050 regularization_(>0)_ch2=0.050 "+
"minimum_object_intensity_channel_1_(0_to_1)=0.15 _channel_2_(0_to_1)=0.15 "+
"subpixel_segmentation standard_deviation_xy=0.8 standard_deviation_z=1 "+
"remove_region_with_intensities_<=0 remove_region_with_size_<=2 local_intensity_estimation=Low noise_model=Poisson "+
"intermediate_steps colored_objects objects_intensities labeled_objects outlines_overlay soft_mask save_objects_characteristics "+
"number=1 input=["+dir+name+"]");
run("Close All");
print("Finished folder: "+name);
print(i+1+" out of "+list.length);
}
else {
	continue;
}
}
print("All Done");

close("\\Others")