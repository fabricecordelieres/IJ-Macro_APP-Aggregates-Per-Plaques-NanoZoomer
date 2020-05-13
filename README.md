# IJ-Macro_APP-Aggregates-Per-Plaques-NanoZoomer
The aim of this ImageJ toolset is to isolate and count both the plaques and aggregates, measure the average surface of the plaques, and the average number of aggregates on the plaques/within a neighborhood of 20µm around the plaques. 

## User's request

The users has images acquired on the NanoZoomer. Each dataset is composed of three images:
1. APP CTerm, image file tagged as FITC, labelling the aggregates;
2. Metoxy, image file tagged as DAPI, labelling the plaques;
3. Abeta42, image file tagged as DAPI, labelling the plaques.
Both the second and third labelling should overlap.

The aim of the tool would be to isolate and count both the plaques and aggregates, measure the average surface of the plaques, and the average number of aggregates on the plaques/within a neighborhood of 20µm around the plaques. Aggregates outside the plaques/defined surrounding should also be counted.

All the data should be extracted within 5 anatomical regions to be user-drawn: molecular layer, CA4, CA3-CA2, CA1-subiculum and enterohinal cortex..

## What does it do ?

This macro comes in the form of a toolset which graphical user interface allows performing the 4 steps of analysis:

![GUI_Toolset](/Images/GUI_Toolset.jpg)

### Step 1: Get ROIs to extract
1. The user is invited to point at the input folder containing the NDPIS files to analyze, and an output folder in which to save the data.
2. For each ndpis file:
    1. The preview image of the virtual slide is displayed.
    2. The user is asked to draw the relevant part of the virtual slide to analyze.
    3. The corresponding ROI is saved in the output folder.

### Step 2: Extract images
1. The user is invited to point at the input folder containing the NDPIS files to analyze, and an output folder in which to save the data/where the ROIs from step 1 have been saved.
2. For each ndpis file:
    1. For each channel: 
        1. The preview image of the virtual slide is displayed.
        2. The user defined ROI is loaded onto the channel's preview.
        3. The NDPI Tools is called to extract the full resolution image of the highlighted area.
    2. Once all channels have been extracted for the ndpis file, all full resolution images are overlayed, then saved in the output folder.

### Step 3: Get anatomical regions
1. The user is invited to point at the output folder used in steps 1 & 2 to store both the extracted images and the ROIs.
2. For each dataset:
    1. The composite image is loaded and displayed.
    2. The user is requested to draw the 5 anatomical regions to analyze: molecular layer, CA4, CA3-CA2, CA1-subiculum and enterohinal cortex.
    3. Each ROI is added in turn to the ROI Manager.
    4. The content of the ROI Manager is saved in the output folder for later use.

### Step 4: Analyze
![GUI_Analyze](/Images/GUI_Analyze.png)
1. The user is first presented with a graphical interface on which some parameters might be set:
    1. Median radius (default: 2 pixels)
    2. Subtract background radius (default: 25 pixels)
    3. Surrounding to analyze in microns (default: 20 microns)
2. The user is invited to point at the output folder used in steps 1-3 to store both the extracted images and the ROIs.
3. For each dataset (extracted image and the corresponding recorded anatomical ROIs), the following operations are performed:
    1. The image and the corresponding ROIs set are loaded.
    2. The three channels are splitted.
    3. Plaques detection is performed:
        1. The metoxy signal is pre-processed as follows:
            1. The original image is duplicated and the copy subjected to a median filtering of user-defined radius.
            2. The background is subtracted in a surrounding of user-defined radius.
            3. A binary mask of the metoxy signal is obtained by applying an automated threshold using the Yen method.
        2. The ABeta42 signal is pre-processed as follows:
            1. The original image is duplicated and the copy subjected to a median filtering of user-defined radius.
            2. The background is subtracted in a surrounding of user-defined radius.
            3. A binary mask of the ABeta42 signal is obtained by applying an automated threshold using the Yen method
        3. Finally, the two masks are combined into a single mask using a logical OR operation.
        4. The image is renamed "Plaques".
        5. All the anatomical regions in the ROI Manager are combined into one and applied onto the mask.
        6. All pixels outside the combined ROIs are set to black: signal pixels within the anatomical regions are now white, all the other pixels being black.
        7. In order to individualize signal pixel in each anatomical region, the following procedure is applied:
            1. The n-th anatomical region is activated.
            2. Positive pixels within the n-th region get their intensity set to n.
        8. We now have a map where all signal pixels from the molecular layer carry an intensity of 1, the ones from the CA4 an intensity of 2 etc.
    4. Aggregates detection is performed:
        1. The original image is duplicated and the copy subjected to a median filtering of user-defined radius.
        2. The background is subtracted in a surrounding of user-defined radius.
        3. A binary mask of the APP-Cterm signal is obtained by applying an automated threshold using the Yen method.
        4. The image is renamed "Aggregates".
        5. All the anatomical regions in the ROI Manager are combined into one and applied onto the mask.
        6. All pixels outside the combined ROIs are set to black: signal pixels within the anatomical regions are now white, all the other pixels being black.
        7. In order to individualize signal pixel in each anatomical region, the following procedure is applied:
            1. The n-th anatomical region is activated.
            2. Positive pixels within the n-th region get their intensity set to n.
        8. We now have a map where all signal pixels from the molecular layer carry an intensity of 1, the ones from the CA4 an intensity of 2 etc.
    5. Data is collected. For each anatomical region, the following steps are performed:
        1. Retrieval of informations about the plaques:
            1. The plaques mask is selected.
            2. A threshold is set from n to n, n being the number of the anatomical region (1:molecular layer, 2: CA4 etc): it allows selecting only pixel lying in the current anatomical region.
            3. A ROI is created, outlaying the signal pixels that are thresholded (plaques' pixels within the anatomical region).
            4. A particle analysis is run, without size or circularity filtering, outputing individual plaques' areas.
            5. The "Data" table is selected and the following informations are logged:
                1. The name of the dataset is used as a label for the row. 
                2. The name of the anatomical region is logged on the same line.
                3. The number of individual plaques is logged.
                4. The average plaques area is logged, computed from all the individual areas.
        2. Retrieval of informations about the aggregates:
            1. The aggregates mask is selected.
            2. A threshold is set from n to n, n being the number of the anatomical region (1:molecular layer, 2: CA4 etc): it allows selecting only pixel lying in the current anatomical region.
            3. A ROI is created, outlaying the signal pixels that are thresholded (aggregates' pixels within the anatomical region).
            4. A particle analysis is run, without size or circularity filtering, outputing individual aggregates' areas.
            5. The "Data" table is selected and the following informations are logged:
                1. The number of individual aggregates is logged.
                2. The average aggregates area is logged, computed from all the individual areas.
        3. Retrieval of informations about the aggregates on the plaques:
            1. The plaques' mask is activated: it still contains the ROI outlying the plaques of the current anatomical region.
            2. The aggregates' mask is activated and the previous ROI is recalled: the image now displays the aggregates' pixels and the plaques' outlines.
            3. A threshold is set from n to n, n being the number of the anatomical region (1:molecular layer, 2: CA4 etc): it allows selecting only pixel lying in the current anatomical region.
            4. A particle analysis is run, without size or circularity filtering. Due to the threshold, only pixels within the anatomical region are considered. Due to the presence of the ROI, only thresholded pixels within the ROI will be analyzed. Analysis therefore only considers the aggregates' pixels on the plaques.
            5. The "Data" table is selected and the following informations are logged:
                1. The number of individual aggregates falling onto plaques is logged.
                2. The average number of aggregates per plaque is computed by dividing previous value by the number of plaques.
                3. The average aggregates on plaques' area is logged, computed from all the individual areas divided by the number of plaques. ***WARNING: this is an approximated value as an aggregate falling half on the plaque will get only half of its area considered ! As aggregates are supposed to be really small relative to the resolution, it is assumed to hardly happen.***
        4. Retrieval of informations about the aggregates outside the plaques:
            1. No further processing is done: values are computed from already extracted data. 
            2. The "Data" table is selected and the following informations are logged:
                1. The number of individual aggregates falling outside plaques is computed by subtracting the number of aggregates falling onto plaques to the total number of aggregates. ***WARNING: this is an approximated value as an aggregate falling half on the plaque will get counted twice: once on it, once outside of it ! As aggregates are supposed to be really small relative to the resolution, it is assumed to hardly happen.***
                2. The average number of aggregates per plaque located outside the plaques is computed by dividing previous value by the number of plaques.
        5. Retrieval of informations about the aggregates within a certain radius around the plaques:
            1. The plaques' mask is activated: it still contains the ROI outlying the plaques of the current anatomical region.
            2. The aggregates' mask is activated and the previous ROI is recalled: the image now displays the aggregates' pixels and the plaques' outlines.
            3. The selection is enlarged by the user-defined width.
            4. A threshold is set from n to n, n being the number of the anatomical region (1:molecular layer, 2: CA4 etc): it allows selecting only pixel lying in the current anatomical region.
            5. A particle analysis is run, without size or circularity filtering. Due to the threshold, only pixels within the anatomical region are considered. Due to the presence of the ROI, only thresholded pixels within the ROI will be analyzed. Analysis therefore only considers the aggregates' pixels on the plaques.
            6. The "Data" table is selected and the following informations are logged:
                1. The number of individual aggregates falling onto plaques or within the defined vicinity.
                2. The average number of aggregates per enlarged plaque is computed by dividing previous value by the number of plaques.
                3. The average aggregates on the enlarged plaques' area is logged, computed from all the individual areas divided by the number of plaques. ***WARNING: this is an approximated value as an aggregate falling half on the zone will get only half of its area considered ! As aggregates are supposed to be really small relative to the resolution, it is assumed to hardly happen.***
        6. Retrieval of informations about the aggregates outside a certain radius around the plaques:
            1. No further processing is done: values are computed from already extracted data. 
            2. The "Data" table is selected and the following informations are logged:
                1. The number of individual aggregates falling outside the plaques surrounding is computed by subtracting the number of aggregates falling onto/close to the plaques to the total number of aggregates. ***WARNING:this is an approximated value as an aggregate falling half on the zone will get only half of its area considered ! As aggregates are supposed to be really small relative to the resolution, it is assumed to hardly happen.***
                2. The average number of aggregates per plaque located outside the plaques' surrounding is computed by dividing previous value by the number of plaques.
6. The final data table is saved to the designated output folder.
7. From the plaques ROI, a new image is generated as a mask, where the expanded aggregates surface is turned on: it displays the considered surface of the plaques and its surroundings.
8. This images (blue) is overlayed to the plaques mask (red) and the aggregates mask (green) as a composite image that will be saved in the output folder.

##How to use it ?
___Versions of the software used___

Fiji, ImageJ 2.0.0-rc-69/1.52n

___Additional required software___

Install the following plugin
NDPI Tools: [http://www.imnc.in2p3.fr/pagesperso/deroulers/software/ndpitools/](http://www.imnc.in2p3.fr/pagesperso/deroulers/software/ndpitools/). Precisely follow the step-by-step installation instructions given on the author's website.

## How to install and use the ImageJ Toolset ?
1. Update ImageJ : Help/update puis Ok.
2. Drag and drop the macro file into ImageJ's installation folder/Macros/Toolset.
3. Under ImageJ's toolbar, click on the last tool on the right side (two red arrows) and select the macro from the drop-down list.
4. Follow the instructions given under the "what does it do" section.
