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

run("Analyze Particles...", "size=1200-Infinity circularity=0.005-1.0 show=Masks display summarize in_situ");
run("Fill Holes");
for (i = 0; i < 4; i++) run("Close-");
for (i = 0; i < 2; i++) run("Dilate");
run("Fill Holes");

run("Set Measurements...", "area centroid perimeter fit shape feret's area_fraction display redirect=None decimal=3");
run("Analyze Particles...", "size=1200-Infinity circularity=0.005-1.0 show=Masks display summarize in_situ");

poresMaskTitle = getTitle();

selectImage(image); 

run("Duplicate...", "title=fibras ignore");
duplicatedTitle = getTitle(); 

imageCalculator("Subtract create", duplicatedTitle, poresMaskTitle);
resultTitle = "Result of " + duplicatedTitle;
selectWindow(resultTitle);

run("32-bit");

setAutoThreshold("Minimum dark no-reset");

run("NaN Background");