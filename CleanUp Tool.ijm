macro "CleanUp Tool - C0a0L18f8L818f" {
	// only works for 3 channel labeled image
setBatchMode(true);
getLocationAndSize(window_x, window_y, window_width, window_height);
zm = getZoom()*100;
run("Select None");
imname = getTitle();
getDimensions(width, height, channels, slices, frames);
getCursorLoc(x, y, z, flags);
roiManager("Reset");
Table.reset("Results");
makePoint(x, y, "small yellow hybrid");
run("Set Measurements...", "mean integrated redirect=None decimal=3");
run("Measure");
currCH = getResult("Ch", 0);
Stack.setChannel(currCH);
currSlice = getResult("Slice", 0);
print(currSlice);
setSlice(currSlice);
yy=getResult("IntDen", 0);
run("Split Channels");
selectWindow("C"+currCH+"-"+imname);
for (j = 0; j < slices; j++) {
	setSlice(j+1);
	changeValues(yy, yy, 0);
}
run("Merge Channels...", "c1=C1-"+imname+" c2=C2-"+imname+" c5=C3-"+imname+" create ignore");
rename(imname);
setBatchMode("exit and display")
Table.setLocationAndSize(window_x, window_y, window_width, window_height, imname)
run("Scale to Fit");
run("Select None");
Stack.setChannel(currCH);
Stack.setSlice(currSlice);
}