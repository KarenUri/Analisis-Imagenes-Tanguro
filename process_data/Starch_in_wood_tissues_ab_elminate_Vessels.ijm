roiManager("Reset");
run("Clear Results");
run("Select None");

// get attributes from the original image
path=getDirectory("image");
//print(path);
//print(getDirectory("image"))

Original_image=getImageID();
image = getTitle();
getStatistics(area, mean, min, max, std, histogram);
//print(mean, min, max, std);
//run("Histogram");

// creat mask for measuring starch in the whole wood starch content


//image = getTitle();
//getStatistics(area, mean, min, max, std, histogram);
selectWindow(image);
run("Duplicate...", " ");
wood_starch_mask=getImageID();
rename(image+"_woodStarch");
wood_starch_mask_title=getTitle();
selectWindow(wood_starch_mask_title);

run("Pseudo flat field correction", "blurring=40"); 
close();
selectWindow(wood_starch_mask_title);
run("32-bit");
run("Mean...", "radius=1");
run("Gamma...", "value=1.1");

if(mean<219){
setAutoThreshold("Shanbhag");
}
else{
setAutoThreshold("Yen");
}

getThreshold(lower, upper);

if(upper>200){
setThreshold(-1000000000000000000000000000000.0000, 200);
}
run("Analyze Particles...", "size=0.00003-Infinity show=Masks display summarize in_situ");
setOption("BlackBackground", false);
run("Convert to Mask");
//run("Fill Holes");

// create a mask for measuring the parenchyma

//image = getTitle();
//getStatistics(area, mean, min, max, std, histogram);
//print(mean,min,max,std);
selectWindow(image);
run("Duplicate...", " ");
parenchyma_mask=getImageID();
rename(image+"_parenchyma");
parenchyma_mask_title=getTitle();
selectWindow(parenchyma_mask_title);
run("Subtract Background...", "rolling=60 light sliding");
run("16-bit");
run("Median...", "radius=10");
run("Gamma...", "value=2.5");

if(std>45){
setAutoThreshold("Minimum");
}
else{
setAutoThreshold("Moments");
}

run("Analyze Particles...", "size=0.0002-Infinity circularity=0.00-0.70 show=Masks display summarize in_situ");
run("EDM Binary Operations", "iterations=15 operation=close");
run("EDM Binary Operations", "iterations=1 operation=dilate");

//setOption("BlackBackground", false);
//run("Convert to Mask");
//run("Fill Holes");



// create a mask for measuring the starch in the parenchyma tissue

parenchyma_mask_title=getTitle();
selectWindow(parenchyma_mask_title);
run("Duplicate...", " ");
parenchyma_mask1=getImageID();
rename(parenchyma_mask_title+"1");
parenchyma_mask_title1=getTitle();
selectWindow(parenchyma_mask_title1);
run("Invert");

//image = getTitle();
selectWindow(image);
run("Duplicate...", " ");
starch_parenchyma_mask=getImageID();
rename(image+"_parenchymaStarch");
starch_parenchyma_mask_title=getTitle();
selectWindow(starch_parenchyma_mask_title);

run("Pseudo flat field correction", "blurring=40"); 
close();
selectWindow(starch_parenchyma_mask_title);
run("32-bit");
run("Mean...", "radius=1");
run("Gamma...", "value=1.1");

imageCalculator("Transparent-zero create", starch_parenchyma_mask_title, parenchyma_mask_title1);
starch_parenchyma_mask=getImageID();
rename(image+"_parenchymaStarch1");
starch_parenchyma_mask_title1=getTitle();
selectWindow(starch_parenchyma_mask_title1);


if(upper<200){
setThreshold(-1000000000000000000000000000000.0000, upper);
}else{
setThreshold(-1000000000000000000000000000000.0000, 200);
}

run("Analyze Particles...", "size=0.00003-Infinity show=Masks display summarize in_situ");
setOption("BlackBackground", false);
run("Convert to Mask");
//run("Fill Holes");

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

run("Analyze Particles...", "size=0.0005-0.1 circularity=0.20-1.00 show=Masks display summarize in_situ");
run("Fill Holes");
run("EDM Binary Operations", "iterations=10 operation=close");
run("EDM Binary Operations", "iterations=2 operation=dilate");
//run("Watershed");


// creat a mask for measuring the fibers


imageCalculator("Add create", vessels_mask_blue_title, parenchyma_mask_title);
rename(image+"_fibers");
fibers_mask_title=getTitle();
selectWindow(fibers_mask_title);
run("Convert to Mask");
run("Invert");


//generate mask for measuring starch in the fibers 


//image = getTitle();
selectWindow(image);
run("Duplicate...", " ");
starch_fibers_mask=getImageID();
rename(image+"_starchfibers");
starch_fibers_mask_title=getTitle();
selectWindow(starch_fibers_mask_title);
run("Pseudo flat field correction", "blurring=40"); 
close();
selectWindow(starch_fibers_mask_title);
run("32-bit");
run("Mean...", "radius=1");
run("Gamma...", "value=1.1");

selectWindow(fibers_mask_title);
run("Duplicate...", " ");
starch_fibers_mask1=getImageID();
rename(image+"_starchfibers1");
starch_fibers_mask_title1=getTitle();
selectWindow(starch_fibers_mask_title1);
run("Invert");

ima

selectImage("fibers.tif")
fibers_mask_title=getTitle();
selectImage("Vessels.tif")
Vessle_mask_title1=getTitle();
imageCalculator("divide create", fibers_mask_title, Vessle_mask_title1);
rename(image+"_starchfibers2");
starch_fibers_mask_title2=getTitle();
selectWindow(starch_fibers_mask_title2);


if(upper<200){
setThreshold(-1000000000000000000000000000000.0000, upper);
}else{
setThreshold(-1000000000000000000000000000000.0000, 200);
}

run("Analyze Particles...", "size=0.00003-Infinity show=Masks display summarize in_situ");

//setOption("BlackBackground", false);
run("Convert to Mask");
//run("Fill Holes");

///Generate the ROIs for measuring 

roiManager("Reset");
run("Clear Results");
Table.deleteRows(0, 5, "Summary");
run("Select None");

//image=getTitle();
selectWindow(image);

H = getHeight();
W = getWidth();
getPixelSize(unit, pw, ph, pd);

// We generate the 50 1mm^2 ROI over the images to measure the percentage of starch over each one.

for (k=0;k<50;) {
RH = random();
RW = random();
Ht = RH * H;
Wt = RW * W;
Ht=d2s(Ht,0);
Wt=d2s(Wt,0);
makeRectangle(Wt, Ht, 1/pw, 1/pw);
getStatistics(area,mean);
		if (area>0.99) {
		roiManager("Add");
		roiManager("Select",k);
		k++;
		roiManager("Rename", "selection- "+k);
		}
}


//We use analyse particles to identify and count every starch particle in each ROI generated. 

//measure starch in the wood

selectWindow(wood_starch_mask_title);
for (i=0; i<=roiManager("count")-1; i++) {
roiManager("select", i);
run("Analyze Particles...", "size=0-Infinity display summarize in_situ");
}

//measure starch in the parenchyma
selectWindow(starch_parenchyma_mask_title1);
for (i=0; i<=roiManager("count")-1; i++) {
roiManager("select", i);
run("Analyze Particles...", "size=0-Infinity display summarize in_situ");
}

//measure starch in the fibers 
selectWindow(starch_fibers_mask_title2);
for (i=0; i<=roiManager("count")-1; i++) {
roiManager("select", i);
run("Analyze Particles...", "size=0-Infinity display summarize in_situ");
}

//measure parenchyma
selectWindow(parenchyma_mask_title);
for (i=0; i<=roiManager("count")-1; i++) {
roiManager("select", i);
run("Analyze Particles...", "size=0-Infinity display summarize in_situ");
}

//measure vessels
selectWindow(vessels_mask_blue_title);
for (i=0; i<=roiManager("count")-1; i++) {
roiManager("select", i);
run("Analyze Particles...", "size=0-Infinity display summarize in_situ");
}

//measure fibers
selectWindow(fibers_mask_title);
for (i=0; i<=roiManager("count")-1; i++) {
roiManager("select", i);
run("Analyze Particles...", "size=0-Infinity display summarize in_situ");
}


// Finally we save the measurements to analyse in R. 

//image = getTitle();
//path=getDirectory("image");
//print(path);
selectWindow("Summary");
saveAs("Results", path+File.separator+"automatic_measurements2"+File.separator+"Summary_starch_"+image+".csv");




