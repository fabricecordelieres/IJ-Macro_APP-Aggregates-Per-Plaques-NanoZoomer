//Channels
var channels=newArray("DAPI", "FITC", "TRITC");
var channelsNames=newArray("Metoxy", "APP-Cterm", "ABeta42");
var LUTs=newArray("Blue", "Green", "Red");

var refChannel=0;

//Names of the anatomical regions of interest
var names=newArray("Molecular_layer", "CA4", "CA3_CA2", "CA1_subiculum", "Enterohinal_cortex");

//Colors to be used for display
var colors=newArray("red", "green", "blue", "cyan", "magenta", "yellow", "darkGray", "orange", "gray", "pink", "lightGray");


//Parameters for analysis
var medRad=2;
var subBkgdRad=25;
var surrounding=20;

macro "Get rois to extract Action Tool - Cf00D74D75D76D77D78D79D7aD7bD7cD84D8cD94D9cDa4DacDb4DbcDc4DccDd4DdcDe4DecDf4Df5Df6Df7Df8Df9DfaDfbDfcC00fD02D03D04D05D11D12D13D14D15D17D18D19D21D22D23D24D25D27D28D29D2aD31D32D33D34D35D37D38D39D3aD3bD3cD41D42D43D44D45D48D49D4aD4bD4cD51D52D53D54D55D5aD5bD5cD5dD61D62D63D64D65D6bD6cD6dD71D72D73D7dD81D82D83D85D8bD8dD92D93D95D9bD9dDa2Da3Da5Da6DaaDabDadDb3Db5Db6Db7Db8Db9DbaDbbDbdDc5Dc6Dc7Dc8Dc9DcaDcbDd6Dd7Dd8Dd9DdaDe7De8De9"{
	getRoisToExtract();
}

macro "Extract images Action Tool - Cf00D11D12D13D14D15D16D17D21D27D31D37D41D47D51D61D67D71D72D73D74D76D77C03fD99D9aD9bD9cD9dD9eD9fDa9DafDb9DbfDc9DcfDd9DdfDe9DefDf9DfaDfbDfcDfdDfeDffC4f0D55D56D57D58D59D5aD5bD65D6bD75D7bD85D8bD95Da5DabDb5Db6Db7Db8DbaDbb"{
	extractImages()
}

macro "Get anatomical regions Action Tool - Cb20D21D22D23D24D25D26D27D31D37D41D47D51D57D61D62D63D64D65D66D67C0ffDb9DbaDbbDbcDbdDbeDbfDc9DcfDd9DdfDe9DefDf9DfaDfbDfcDfdDfeDffC03fD02D03D04D05D0eD0fD11D12D13D14D15D2dD2eD32D33D34D35D3dD3eD42D43D44D45D46D4cD4dD4eD52D53D54D55D56D7cD7dD7eD83D84D85D86D87D8bD8cD8dD8eD93D94D95D96D97D9aD9bD9cD9dD9eDa3Da4Da5Da6Da7Dc3Dc4Dc5Dc6Dc7Dc8DcaDcbDccDcdDd5Dd6Dd7Dd8DdaDdbDe5De6De7De8DeaDf7Df8C0f0D72D73D74D75D76D77D78D82D88D92D98Da2Da8Db2Db3Db4Db5Db6Db7Db8Cf90D19D1aD1bD1cD1dD1eD1fD29D2fD39D3fD49D4fD59D5aD5bD5cD5dD5eD5fCb0fD69D6aD6bD6cD6dD6eD6fD79D7fD89D8fD99D9fDa9DaaDabDacDadDaeDaf"{
	getRoisToAnalyze();
}

macro "Analyze Action Tool - C000D11D12D13D14D15D16D17D19D1aD1bD1cD1dD1eD1fD29D2fD31D32D33D34D35D36D37D39D3fD41D47D49D4aD4bD4cD4dD4eD4fD51D57D61D62D63D64D65D66D67D69D6aD6bD6cD6dD6eD6fD81D82D83D84D85D86D87D89D8aD8bD8cD8dD8eD8fD99D9fDa1Da2Da3Da4Da5Da6Da7Da9DafDb1Db7Db9DbaDbbDbcDbdDbeDbfDc1Dc7Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd9DdaDdbDdcDddDdeDdfDf1Df2Df3Df4Df5Df6Df7Df9DfaDfbDfcDfdDfeDff"{
	analyzeGUI();
	analyze(surrounding);
}




//-----------------------------------------------
function getRoisToExtract(){
	run("Close All");
	in=getDirectory("Where are the files ?");
	out=getDirectory("Where to save the files ?");

	files=getSpecificFilesList(in, ".ndpis");

	for(i=0; i<files.length; i++){
		filename=replace(files[i], ".ndpis", "-"+channels[refChannel]+".ndpi");
		run("Preview NDPI...", "ndpitools=["+in+filename+"]");
		run("8-bit");
		run("Enhance Contrast", "saturated=0.35");
		
		setTool("rectangle");
		while(selectionType==-1) waitForUser("Draw the region to analyze,\nthen press Ok");
		saveAs("Selection", out+replace(files[i], ".ndpis", ".roi"));

		close();
	}
}

//-----------------------------------------------
function extractImages(){
	run("Close All");
	in=getDirectory("Where are the files ?");
	out=getDirectory("Where are the ROIs/to save the files ?");

	files=getSpecificFilesList(out, ".roi");

	for(i=0; i<files.length; i++){
		arg="";
		for(j=0; j<channels.length; j++){
			filename=replace(files[i], ".roi", "-"+channels[j]+".ndpi");
			run("Preview NDPI...", "ndpitools=["+in+filename+"]");
			preview=getTitle();
			run("8-bit");
			run("Enhance Contrast", "saturated=0.35");
			open(files[i]);
			
			run("Extract to TIFF");
			run("8-bit");
			run("Enhance Contrast", "saturated=0.35");
			rename(channels[j]);
			run(LUTs[j]);

			arg+="c"+d2s(j+1,0)+"="+channels[j]+" ";
			close(preview);
		}
		run("Merge Channels...", arg+"create");
		saveAs("ZIP", out+replace(files[i],".roi", "_img.zip"));
		run("Close All");
	}
}

//-----------------------------------------------
function getRoisToAnalyze(){
	run("Close All");
	in=getDirectory("Where are the extracted files ?");

	files=getSpecificFilesList(in, ".roi");

	for(i=0; i<files.length; i++){
		roiManager("Reset");
		filename=replace(files[i], ".roi", "_img.zip");
		open(filename);

		askForRois(names, colors);

		roiManager("Deselect");
		roiManager("Save", in+replace(filename, "img", "RoiSet"));
		run("Close All");
	}
}

//------------------------------------------------------------------------------------
function askForRois(names, colors){
	setTool("freehand");
	roiManager("Show All without labels");
	
	for(i=0; i<names.length; i++){
		run("Select None");
		while(selectionType==-1) waitForUser("ROI "+(i+1)+"/"+names.length+":\nDraw the ROI \""+names[i]+"\",\nthen press Ok");
		Roi.setName(names[i]);
		Roi.setStrokeColor(colors[i%colors.length]);
		roiManager("Add");
	}	
}

//------------------------------------------------------------------------------------
function analyzeGUI(){
	Dialog.create("Analysis parameters");
	Dialog.addNumber("Median radius, in pixels", medRad);
	Dialog.addNumber("Subtract background radius, in pixels", subBkgdRad);
	Dialog.addNumber("Surrounding to analyze, in microns", surrounding);
	Dialog.show();
	
	medRad=Dialog.getNumber();
	subBkgdRad=Dialog.getNumber();
	surrounding=Dialog.getNumber();
}

//------------------------------------------------------------------------------------
function analyze(surrounding){
	run("Close All");
	in=getDirectory("Where are the extracted files ?");

	files=getSpecificFilesList(in, ".roi");

	for(i=0; i<files.length; i++){
		run("Close All");
		roiManager("Reset");
		img=replace(files[i], ".roi", "_img.zip");
		rois=replace(files[i], ".roi", "_RoiSet.zip");

		open(img);
		open(rois);

		getPixelSize(unit, pixelWidth, pixelHeight);
		if(unit=="cm") run("Properties...", "unit=um pixel_width="+pixelWidth*10000+" pixel_height="+pixelHeight*10000+" voxel_depth=1.0000000");

		run("Split Channels");
		for(j=0; j<channelsNames.length; j++){
			selectWindow("C"+d2s(j+1, 0)+"-"+replace(img, ".zip", ".tif"));
			rename(channelsNames[j]);
		}

		getPlaquesMask();
		getAggregatesMask();
		run("Tile");

		collectData(replace(files[i], ".roi", ""), surrounding);
		saveAs("ZIP", in+replace(files[i],".roi", "_check-img.zip"));
		selectWindow("Data");
		Table.save(in+"_Data.xls");

		run("Close All");
	}
}

//------------------------------------------------------------------------------------
function getPlaquesMask(){
	preProcess("Metoxy", medRad, subBkgdRad, "Yen");
	preProcess("ABeta42", medRad, subBkgdRad, "Yen");
	imageCalculator("OR create", "Mask-Metoxy","Mask-ABeta42");
	rename("Plaques");
	tagMask();
	close("Mask-*");
}

//------------------------------------------------------------------------------------
function getAggregatesMask(){
	preProcess("APP-Cterm", medRad, subBkgdRad, "Yen");
	rename("Aggregates");
	tagMask();
}

//----------------------------------------------------
function preProcess(img, medRad, subBkgdRad, thrMeth){
	selectWindow(img);
	run("Duplicate...", "title=Mask-"+img);
	run("Median...", "radius="+medRad);
	run("Subtract Background...", "rolling="+subBkgdRad);
	setAutoThreshold(thrMeth+" dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
}

//----------------------------------------------------
function tagMask(){
	roiManager("Combine");
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	
	for(i=0; i<roiManager("Count"); i++){
		roiManager("Select", i);
		run("Macro...", "code=[if(v==255) v="+d2s(i+1, 0)+";]");
	}
	run("Select None");
	setMinAndMax(0, roiManager("Count"));
}

//----------------------------------------------------
function collectData(datasetName, surrounding){
	run("Set Measurements...", "area redirect=None decimal=3");

	closeResults();
	
	if(!tableExists("Data")){
		Table.create("Data");
	}

	selectWindow("Data");
	currRow=Table.size;
	
	for(i=0; i<names.length; i++){
		
		
		//Retrieve infos about plaques
		selectWindow("Plaques");
		run("Select None");
		setThreshold(i+1, i+1);
		run("Create Selection");
		run("Analyze Particles...", "display clear");

		tmp=getMeanAreaAndNumber();
		nPlaques=tmp[0];
		mean=tmp[1];
		
		selectWindow("Data");
		Table.set("Dataset", currRow+i, datasetName);
		Table.set("Region", currRow+i, names[i]);
		Table.set("n plaques", currRow+i, nPlaques);
		Table.set("Avg area plaques (um^2)", currRow+i, mean);
		Table.update;


		//Retrieve aggregates infos
		selectWindow("Aggregates");
		setThreshold(i+1, i+1);
		run("Create Selection");
		run("Analyze Particles...", "display clear");

		tmp=getMeanAreaAndNumber();
		nAggregates=tmp[0];
		mean=tmp[1];

		selectWindow("Data");
		Table.set("n aggregates", currRow+i, nAggregates);
		Table.set("Avg area aggregates (um^2)", currRow+i, mean);
		Table.update;


		//Retrieve aggregates infos on the plaques
		selectWindow("Plaques");
		selectWindow("Aggregates"); //Required to reactivate the plaques as last image/Roi
		run("Restore Selection");

		setThreshold(i+1, i+1);
		run("Analyze Particles...", "display clear");
		
		tmp=getMeanAreaAndNumber();
		nAggregatesOnPlaques=tmp[0];
		mean=tmp[1];
		
		selectWindow("Data");
		Table.set("n aggregates on plaques", currRow+i, nAggregatesOnPlaques);
		Table.set("n aggregates per plaque", currRow+i, nAggregatesOnPlaques/nPlaques);
		Table.set("Avg area aggregates on plaques (um^2)", currRow+i, mean);
		Table.update;


		//Retrieve aggregates infos outside
		nAggregatesOutside=nAggregates-nAggregatesOnPlaques;
		
		selectWindow("Data");
		Table.set("n aggregates outside plaques", currRow+i, nAggregatesOutside);
		Table.set("n aggregates outside plaques, per plaque", currRow+i, nAggregatesOutside/nPlaques);
		Table.update;


		//Retrieve aggregates within a certain radius around plaques
		selectWindow("Plaques");
		setThreshold(i+1, i+1);
		run("Create Selection");
		
		selectWindow("Aggregates");
		run("Restore Selection");
		run("Enlarge...", "enlarge="+surrounding);
		setThreshold(i+1, i+1);
		run("Analyze Particles...", "display clear");
		
		tmp=getMeanAreaAndNumber();
		nAggregatesOnPlaques_surr=tmp[0];
		mean=tmp[1];
		
		selectWindow("Data");
		Table.set("n aggregates on plaques+"+surrounding+"um", currRow+i, nAggregatesOnPlaques_surr);
		Table.set("n aggregates per plaque+"+surrounding+"um", currRow+i, nAggregatesOnPlaques_surr/nPlaques);
		Table.set("Avg area aggregates on plaques+"+surrounding+"um"+" (um^2)", currRow+i, mean);
		Table.update;


		//Retrieve aggregates outside a certain radius around plaques
		nAggregatesOutside_surr=nAggregates-nAggregatesOnPlaques_surr;
		
		selectWindow("Data");
		Table.set("n aggregates outside plaques+"+surrounding+"um", currRow+i, nAggregatesOutside_surr);
		Table.set("n aggregates outside plaques+"+surrounding+"um, per plaque", currRow+i, nAggregatesOutside_surr/nPlaques);
		Table.update;
	}

	//Prepare output image
	selectWindow("Plaques");
	setMinAndMax(0, 0);
	selectWindow("Aggregates");
	setMinAndMax(0, 0);

	selectWindow("Plaques");
	run("Select None");
	run("Duplicate...", "title=Surrounding");
	setThreshold(1, names.length);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Create Selection");
	run("Enlarge...", "enlarge="+surrounding);
	setForegroundColor(0, 0, 255);
	run("Fill", "slice");
	
	run("Merge Channels...", "c1=Plaques c2=Aggregates c3=Surrounding create");
}

//-----------------------------------------------
function tableExists(table){
	list=getList("window.titles");

	out=false;
	for(i=0; i<list.length; i++) if(table==list[i]) out=true;

	return out;
}

//-----------------------------------------------
function closeResults(){
	if(tableExists("Results")){
		selectWindow("Results");
		run("Close");
	}
}

//-----------------------------------------------
function getMeanAreaAndNumber(){
	nb=0;	
	mean=0;

	if(nResults>0){
		data=Table.getColumn("Area");
		nb=data.length;
		Array.getStatistics(data, min, max, mean, stdDev);
		closeResults();
	}

	return newArray(nb, mean);
}

//-----------------------------------------------
function getSpecificFilesList(dir, ext){
	tmp=getFileList(dir);
	filesList=newArray(0);

	for(i=0; i<tmp.length; i++) if(endsWith(tmp[i], ext)) filesList=Array.concat(filesList, tmp[i]);
	
	return filesList;
}
