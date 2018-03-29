%% Initial state of the programm
clear all; close all; clc;
set(0, 'DefaultFigureWindowStyle', 'normal');
currentFolder = pwd;
addpath(genpath(pwd));

%% Reading the data
% [filename,dataFolderName] = uigetfile('*','Select a NRRD file');
% if isequal(filename,0)
%     disp('User selected Cancel')
% else
%     disp(['User selected ', filename])
% end
filename = 'LV Catheter 07.nrrd'; % delete after getting  features

% NRRD reading
tic;
[X, meta] = nrrdread(filename);
Y = double(X);
sz = sscanf(meta.sizes, '%d');
nDims = sscanf(meta.dimension, '%d');
toc;

%% Global variables
onlyCath = 0;
if onlyCath == 1
    limits = struct('maxBlobsArea', 5,... % 5
                    'minArea', 5, 'maxArea', 200,... % 1 300
                    'minStd', 16, 'maxStd', 53,...     % old: 3:53 new: 16:53
                    'minMean', 68, 'maxMean', 132,... % old: 60:132 new 68:132
                    'minContrast', 91, 'maxContrast', 508,... % old: 45:574 new 91:508
                    'minCorrelation', 0.79, 'maxCorrelation', 0.96,... % old: 0.90:0.96 new 0.79:0.96
                    'minEnergy', 0.003, 'maxEnergy', 0.022,... % old: 0.003:0.011 new 0.003:0.022
                    'minHomogeneity', 0.09, 'maxHomogeneity', 0.23,... % old: 0.07:0.27 new 0.09:0.23
                    'minVolume', 2000, 'maxVolume', 10000); % 300 10000
else               
    limits = struct('maxBlobsArea', 4,... % 5
                    'minArea', 5, 'maxArea', 300,... % 1 300
                    'minStd', 3, 'maxStd', 53,...     % old: 3:53 new: 16:53
                    'minMean', 60, 'maxMean', 132,... % old: 60:132 new 68:132
                    'minContrast', 45, 'maxContrast', 574,... % old: 45:574 new 91:508
                    'minCorrelation', 0.90, 'maxCorrelation', 0.96,... % old: 0.90:0.96 new 0.79:0.96
                    'minEnergy', 0.003, 'maxEnergy', 0.011,... % old: 0.003:0.011 new 0.003:0.022
                    'minHomogeneity', 0.07, 'maxHomogeneity', 0.27,... % old: 0.07:0.27 new 0.09:0.23
                    'minVolume', 2000, 'maxVolume', 10000); % 300 10000
end         
            
isVisual = 0;
nTimeframe = 17; %9 Choose the number of timeframe %2
% nSlice = 65; %65
scrSz = get(0, 'Screensize');%89
for nSlice = 53:208 
%% Binarization
tic;
I = squeeze(X(:,:,:,nTimeframe));
% J = double(I);

img = I(:,:,nSlice);
% level = threshTool(img)/255;
[level,EM] = graythresh(img);
% level = 0.21515;
BW = imbinarize(img, level);
if isVisual == 1
    str1 = sprintf('Binarized image');
    str2 = sprintf('Thresholding level: %.3f (%d out of 255)', level, uint8(level*255));
    str3 = sprintf('Effectiveness metric: %.3f', EM);
    imshow(BW, 'InitialMagnification', 'fit'); addTitle({str1; str2; str3});
    set(gcf, 'Position', scrSz, 'Color', 'w');
end
vars.reading = {'str1', 'str2', 'str3', 'EM'};
clear(vars.reading{:});

%% Filling holes
BWfill = imfill(BW, 'holes');
CCini = bwconncomp(BWfill);
Lini = labelmatrix(CCini);
numFill = CCini.NumObjects; 
if isVisual == 1
    colorLabelIni = label2rgb(Lini, 'parula', 'k', 'shuffle');
    str1 = sprintf('Region labeling');
    str2 = sprintf('Objects found: %d', numFill);
    imshow(colorLabelIni, 'InitialMagnification', 'fit'); addTitle({str1; str2});
    set(gcf, 'Position', scrSz, 'Color', 'w');
end
vars.blobsAnalysis = {'str1', 'str2'};
clear(vars.blobsAnalysis{:});

%% Enumeration of the regions
if isVisual == 1
    str1 = sprintf('Region enumeration');
    str2 = sprintf('Objects found: %d', numFill);
    vislabels(Lini); addTitle({str1; str2});
    set(gcf, 'Position', scrSz, 'Color', 'w');
    vars.enumeration = {'str1', 'str2'};
    clear(vars.enumeration{:});
end

%% Properties of each region
featuresFill = regionprops(Lini,  img, {'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid'});
if isVisual == 1
    str1 = sprintf('Initial state after Otsu thresholding with area opening');
    str2 = sprintf('Bounding boxes (cyan), weighted centroids (red) and unweighted centroids (green)');
    str3 = sprintf('Objects found: %d', numFill);
    imshowpair(img, colorLabelIni, 'montage'); addTitle({str1; str2; str3});
%     imshow(img, 'InitialMagnification', 'fit');
%     imshow(colorLabelIni, 'InitialMagnification', 'fit');
    hold on
    for count = 1:numFill
        rectangle('Position', featuresFill(count).BoundingBox,'EdgeColor', 'c');
        plot(featuresFill(count).WeightedCentroid(1), featuresFill(count).WeightedCentroid(2), 'r*');
        plot(featuresFill(count).Centroid(1), featuresFill(count).Centroid(2), 'go');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off
end
vars.regionProperties = {'count', 'str1', 'str2', 'str3'};
clear(vars.regionProperties{:});

%% Open small areas
if ~isempty(featuresFill)
    BWopen = bwareaopen(Lini, limits.maxBlobsArea);
    CCopen = bwconncomp(BWopen);
    Lopen = labelmatrix(CCopen);
    BWopen = logical(Lopen);
else
    BWopen = BWfill;
end
    featuresOpen = regionprops(BWopen, img, {'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid'});
    numOpen = numel(featuresOpen);

if isVisual == 1
    if ~isempty(featuresFill)
        colorLabelOpen = label2rgb(Lopen, 'parula', 'k', 'shuffle');
    else
        colorLabelOpen = label2rgb(BWopen, 'parula', 'k', 'shuffle');
    end
    str1 = sprintf('Removing objects having fewer than %d pixels', limits.maxBlobsArea);
    str2 = sprintf('Bounding boxes (cyan), weighted centroids (red) and unweighted centroids (green)');
    str3 = sprintf('Objects found: %d', numOpen);
    imshowpair(img, colorLabelOpen, 'montage'); addTitle({str1; str2; str3});
    % imshow(img, 'InitialMagnification', 'fit');
%         imshow(colorLabelOpen, 'InitialMagnification', 'fit');
    hold on
    for count = 1:numOpen
        rectangle('Position', featuresOpen(count).BoundingBox,'EdgeColor', 'c');
        plot(featuresOpen(count).WeightedCentroid(1), featuresOpen(count).WeightedCentroid(2), 'r*');
        plot(featuresOpen(count).Centroid(1), featuresOpen(count).Centroid(2), 'go');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off
end
vars.regionPropertiesOpen = {'removedPix', 'str1', 'str2', 'str3', 'count'};
clear(vars.regionPropertiesOpen{:});

%% Labeling comparison
if isVisual == 1
    if ~isempty(featuresFill)
        str1 = sprintf('Labeling comparison');
        str2 = sprintf('Initial labeling: %d objects (left)     and     Opened labeling: %d objects (right)', numFill, numOpen);
        imshowpair(colorLabelIni, colorLabelOpen,'montage'); addTitle({str1; str2});
        set(gcf, 'Position', scrSz, 'Color', 'w');
    end
end
%% Area detection
if ~isempty(featuresOpen)
    index = find([featuresOpen.Area] > limits.minArea & [featuresOpen.Area] < limits.maxArea);
    CCarea = bwconncomp(BWopen);
    Larea = labelmatrix(CCarea);
    BWarea = ismember(Larea,index);
else
    BWarea = BWopen;
end
featuresArea = regionprops(BWarea, img, 'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid');
numArea = numel(featuresArea);

if isVisual == 1
    str1 = sprintf('Area sorting');
    str2 = sprintf('Objects found: %d', numArea);
    vislabels(BWarea); addTitle({str1, str2});
    hold on
    for count = 1:numArea
        rectangle('Position', featuresArea(count).BoundingBox,'EdgeColor', 'c');
        plot(featuresArea(count).WeightedCentroid(1), featuresArea(count).WeightedCentroid(2), 'r*');
        plot(featuresArea(count).Centroid(1), featuresArea(count).Centroid(2), 'go');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off
end
vars.areaCondition = {'index', 'str1', 'str2', 'count'};
clear(vars.areaCondition{:});

%% Calculate Custom Pixel Value-Based Properties
BWpix = BWarea; 
featuresPix = regionprops(BWpix, img, {'Centroid','Extrema','PixelValues','BoundingBox', 'WeightedCentroid'});
numPix = numel(featuresPix);
for count = 1 : numPix
        featuresPix(count).StandardDeviation = std(double(featuresPix(count).PixelValues));
        featuresPix(count).Mean = mean(double(featuresPix(count).PixelValues));
end

if isVisual == 1
    % imshowpair(BWpix, img, 'montage');
    imshow(BWpix, 'InitialMagnification', 'fit');
    addTitle('Mean and Standard deviation of regions');
    pmSymbol = char(177);
    hold on
    for count = 1 : numPix
        posX = featuresPix(count).Extrema(1,1) - 17;
        posY = featuresPix(count).Extrema(1,2) - 6;
        str = sprintf("%d: %d%s%d", count, round(featuresPix(count).Mean,0), pmSymbol, round(featuresPix(count).StandardDeviation, 0));
        text(posX, posY, char(str), 'FontSize', 34, 'FontName', 'Times New Roman', 'Color', 'g');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off
end
vars.stdCalc = {'index', 'str1', 'str2', 'count', 'posX', 'posY', 'str'};
clear(vars.stdCalc{:});

%% Histogram of Mean and Std
if isVisual == 1
    if ~isempty(featuresPix)
        bar(1:numPix, [featuresPix.Mean], 0.5, 'FaceColor', [0.2 0.2 0.5])
        hold on
        bar(1:numPix, [featuresPix.StandardDeviation], 0.25, 'FaceColor', [0 0.74902 1])
        hold off
        set(gca,'color','none')
        grid on
        ylabel('Feature value')
        xlabel('Region')
        legend({'Mean','Standard deviation'},'Location','northeast')
        ax = gca;
        ax.XTick = 1:numPix; 
        ax.XTickLabelRotation = 0;
        ax.FontName = 'Times New Roman';
        ax.FontSize = 12;
        set(gcf, 'Position', scrSz, 'Color', 'w');
        set(gcf, 'Position', [10 10 500 500], 'Color', 'w');
        saveas(gcf, 'Mean and Std.pdf');
    end
    vars.histogramm = {'ax'};
    clear(vars.histogramm{:});
end

%% Std detection
if ~isempty(featuresPix)
    index = find([featuresPix.StandardDeviation] >= limits.minStd & [featuresPix.StandardDeviation] <= limits.maxStd);
    CCstd = bwconncomp(BWpix);
    Lstd = labelmatrix(CCstd);
    BWstd = ismember(Lstd, index);
else
    BWstd = BWpix;
end
featuresStd = regionprops(BWstd, img, {'Centroid', 'PixelValues', 'BoundingBox', 'WeightedCentroid'});
numStd = numel(featuresStd);
for count = 1:numStd
    featuresStd(count).Mean = mean(double(featuresStd(count).PixelValues));
end

if isVisual == 1
    imshow(img, 'InitialMagnification', 'fit');
    str1 = sprintf('Objects Having Standard Deviation [%g:%d]', limits.minStd, limits.maxStd); 
    str2 = sprintf('Objects found: %d', numStd); 
    addTitle({str1; str2});
    hold on;
    for count = 1:numStd
        rectangle('Position', featuresStd(count).BoundingBox, 'EdgeColor','c');
        plot(featuresStd(count).WeightedCentroid(1), featuresStd(count).WeightedCentroid(2), 'r*');
        plot(featuresStd(count).Centroid(1), featuresStd(count).Centroid(2), 'go');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off;
end
vars.stdCondition = {'count', 'index', 'str1', 'str2', 'hFig'};
clear(vars.stdCondition{:});

%% Mean detection
if ~isempty(featuresStd)
    index = find([featuresStd.Mean] >= limits.minMean & [featuresStd.Mean] <= limits.maxMean);
    CCmean = bwconncomp(BWstd);
    Lmean = labelmatrix(CCmean);
    BWmean = ismember(Lmean, index);
else
    BWmean = BWstd;
end
featuresMean = regionprops(BWmean, img, {'Centroid', 'PixelValues', 'BoundingBox', 'WeightedCentroid', 'Extrema'});
numMean = numel(featuresMean);
if isVisual == 1
    imshow(img, 'InitialMagnification', 'fit');
    str1 = sprintf('Objects Having Mean [%d:%d]', limits.minMean, limits.maxMean); 
    str2 = sprintf('Objects found: %d', numMean); 
    addTitle({str1; str2});
    hold on
    for count = 1:numMean
        rectangle('Position', featuresMean(count).BoundingBox, 'EdgeColor','c');
        plot(featuresMean(count).WeightedCentroid(1), featuresMean(count).WeightedCentroid(2), 'r*');
        plot(featuresMean(count).Centroid(1), featuresMean(count).Centroid(2), 'go');
        posX = featuresMean(count).Extrema(1,1) - 4;
        posY = featuresMean(count).Extrema(1,2) - 6;
        str = sprintf("%d", count);
        text(posX, posY, char(str), 'FontSize', 34, 'FontName', 'Times New Roman', 'Color', 'g');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off
end
vars.meanCondition = {'count', 'index', 'str1', 'str2', 'hFig'};
clear(vars.meanCondition{:});

%% GLCM analysis
glcm = cell(1, numMean);
glcmprops = struct('Contrast', [], 'Correlation', [], 'Energy', [], 'Homogeneity', []);
if ~isempty(featuresMean)
    for i = 1:numMean
        rect = featuresMean(i).BoundingBox;
        croppedImg = imcrop(img, rect);
        glcm{i} = graycomatrix(croppedImg, 'NumLevels', 255);
        glcmprops(i) = graycoprops(glcm{i});
    end
    
    if isVisual == 1
        figure('Position', [scrSz(1), scrSz(2), scrSz(3)/2, scrSz(4)]);
        hold on
        colorScheme = [0.384 0.690 0.937];
        subplot(2,2,1);
        bar(1:numMean, [glcmprops.Contrast], 0.5, 'FaceColor', colorScheme);
        addTitle('Contrast');

        subplot(2,2,2);
        bar(1:numMean, [glcmprops.Correlation], 0.5, 'FaceColor', colorScheme);
        addTitle('Correlation');

        subplot(2,2,3);
        bar(1:numMean, [glcmprops.Energy], 0.5, 'FaceColor', colorScheme);
        addTitle('Energy');

        subplot(2,2,4);
        bar(1:numMean, [glcmprops.Homogeneity], 0.5, 'FaceColor', colorScheme);
        addTitle('Homogeneity');
        hold off

        figure('Position', [scrSz(3)/2, scrSz(2), scrSz(3)/2, scrSz(4)]);
        imshow(img, 'InitialMagnification', 'Fit'); 
        str1 = sprintf('GLCM object analysis'); 
        str2 = sprintf('Objects found: %d', numMean); 
        addTitle({str1; str2}); 
        hold on
        for count = 1:numMean
            rectangle('Position', featuresMean(count).BoundingBox, 'EdgeColor','c');
            posX = featuresMean(count).Extrema(1,1) - 3;
            posY = featuresMean(count).Extrema(1,2) - 6;
            str = sprintf("%d", count);
            text(posX, posY, char(str), 'FontSize', 34, 'FontName', 'Times New Roman', 'Color', 'g');
        end
        hold off
    end
else
    glcmprops = struct([]);
end
vars.glcmAnalysis = {'i', 'rect', 'str1', 'str2', 'croppedImg', 'colorScheme', 'posX', 'posY', 'str'};
clear(vars.glcmAnalysis{:});
% delete(findall(0,'Type','figure')); % close all

%% GLCM detection
if ~isempty(glcmprops)
    index = find([glcmprops.Contrast] >= limits.minContrast & [glcmprops.Contrast] <= limits.maxContrast & ...
                 [glcmprops.Correlation] >= limits.minCorrelation & [glcmprops.Correlation] <= limits.maxCorrelation & ...
                 [glcmprops.Energy] >= limits.minEnergy & [glcmprops.Energy] <= limits.maxEnergy & ...
                 [glcmprops.Homogeneity] >= limits.minHomogeneity & [glcmprops.Homogeneity] <= limits.maxHomogeneity);
    CCglcm = bwconncomp(BWmean);
    Lglcm = labelmatrix(CCglcm);
    BWglcm = ismember(Lglcm, index);
else
    BWglcm = BWmean;
end
featuresGLCM = regionprops(BWglcm, img, {'Centroid', 'PixelValues', 'BoundingBox', 'WeightedCentroid', 'Extrema'});
numGLCM = numel(featuresGLCM);
if isVisual == 1
    imshow(img, 'InitialMagnification', 'fit');
    str1 = sprintf('GLCM object detection'); 
    str2 = sprintf('Objects found: %d', numGLCM); 
    addTitle({str1; str2});
    hold on
    for count = 1:numGLCM
        rectangle('Position', featuresGLCM(count).BoundingBox, 'EdgeColor','c');
        plot(featuresGLCM(count).WeightedCentroid(1), featuresGLCM(count).WeightedCentroid(2), 'r*');
        plot(featuresGLCM(count).Centroid(1), featuresGLCM(count).Centroid(2), 'go');
        posX = featuresGLCM(count).Extrema(1,1) - 2;
        posY = featuresGLCM(count).Extrema(1,2) - 6;
        str = sprintf("%d", count);
        text(posX, posY, char(str), 'FontSize', 34, 'FontName', 'Times New Roman', 'Color', 'g');
    end
    set(gcf, 'Position', scrSz, 'Color', 'w');
    hold off
end
vars.glcmCondition = {'count', 'index', 'str1', 'str2', 'posX', 'posY'};
clear(vars.glcmCondition{:});
toc;

% Array with the objects detected in different steps
row = nSlice - 52;
numObjects(row, 1) = nSlice;
numObjects(row, 2) = numFill;
numObjects(row, 3) = numOpen;
numObjects(row, 4) = numArea;
numObjects(row, 5) = numStd;
numObjects(row, 6) = numMean;
numObjects(row, 7) = numGLCM;

end
%% Visualization
% DataExplorer(J); %double
%  viewer3d(J); %double
% showvol(X(:,:,:,1));
% CrossSectionIsosurface(X(:,:,:,1), 'aspect', [1 1 1], 'subvolume', [0, sz(1), 0, sz(2), 0, sz(3)/2-10], 'color', 'b');
