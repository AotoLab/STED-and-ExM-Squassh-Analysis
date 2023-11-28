imdir = getDirectory("SIM Image Directory");
ROIdir = getDirectory("ROI Directory");
saveTOPdir = getDirectory("Directory to Save _synROIs");

list = getFileList(imdir);
setBatchMode(true); 
//----------- 
//for(j = 0; j < list.length; j++) {
//name = list[j];
//print(name);
//if (endsWith(name, "_Reconstructed.nd2")){
//	print("This is a good one");
//}
//}

//------------
for(j = 0; j < list.length; j++) {
name = list[j];
print(name);
open(imdir+name);
print(imdir+name);
filename=getTitle();
print(filename);
rootname = replace(filename,".tif",""); 
//rootname = replace(filename,"_olig+light_deconvolution.tif",""); 	
print(rootname);
print(ROIdir+rootname+".zip");
open(ROIdir+rootname+".zip");
savedir = saveTOPdir+File.separator+rootname+"_synROIs";
print("savedir:"+savedir);
File.makeDirectory(savedir);
numrois = roiManager("count");
print(numrois);
for (i = 0; i < numrois; i++) {
print("counting ROIs");
RoiManager.select(i);
rnum=i+1;
roiManager("Rename", "syn"+rnum); 
selectWindow(filename);
run("Duplicate...", "duplicate");
roifile = savedir+File.separator+rootname+"_roi"+rnum;
save(roifile); close();
}
close();
roiManager("Deselect");
roiManager("Delete");

}


print("All Done");
