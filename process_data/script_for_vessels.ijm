roiManager("Reset");
run("Clear Results");
run("Select None");

// get attributes from the original image
path=getDirectory("image");

Original_image=getImageID();
image = getTitle();
getStatistics(area, mean, min, max, std, histogram);
print(mean, min, max, std);

//create a mask for measuring the vessels 

//image = getTitle();
selectWindow(image);
run("Duplicate...", " ");
vessels_mask=getImageID();
rename(image+"_vessels");
vessels_mask_title=getTitle();
selectWindow(vessels_mask_title);


run("Subtract Background...", "rolling=250 light sliding");
run("Split Channels");
selectWindow(vessels_mask_title+" (blue)");
rename(image+"_vessels2");
vessels_mask_blue_title=getTitle();
selectWindow(vessels_mask_blue_title);


run("Gamma...", "value=2");
setAutoThreshold("Minimum dark stack");

run("Analyze Particles...", "size=0.0005-Infinity circularity=0.10-1.00 show=Masks display summarize in_situ");
run("Fill Holes");
run("EDM Binary Operations", "iterations=4 operation=close");
run("EDM Binary Operations", "iterations=2 operation=dilate");
run("Fill Holes");

run("Set Measurements...", "area centroid perimeter fit shape feret's area_fraction display redirect=None decimal=3");
run("Analyze Particles...", "size=0.0005-Infinity circularity=0.10-1.00 show=Overlay display summarize add");


