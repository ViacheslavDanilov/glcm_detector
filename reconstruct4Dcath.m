tic;
BWrend = zeros(sz(1), sz(2), sz(3), sz(4));
BWfullopen = zeros(sz(1), sz(2), sz(3), sz(4));
BWfull = zeros(sz(1), sz(2), sz(3), sz(4));
step = 1;
for nTimeframe = 1:sz(4) %% uncomment for full time reconstruction
    BWr = zeros(sz(1), sz(2), sz(3));
    BWrfill = zeros(sz(1), sz(2), sz(3));
    I = squeeze(X(:,:,:,nTimeframe));
    for nSlice = 1:sz(3)  
        img = I(:,:,nSlice);

        % Binarization
        [level,EM] = graythresh(img);
%         level = 0.21515;
        BW = imbinarize(img, level);

        % STEP 1
        if (step == 1) || (step == 2) || (step == 3)
            % Blobs analysis
            BWfill = imfill(BW, 'holes');
            CCini = bwconncomp(BWfill);
            Lini = labelmatrix(CCini);
            featuresIni = regionprops(Lini,  img, {'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid'});

            % Open small areas
            if ~isempty(featuresIni)
                BWopen = bwareaopen(Lini, limits.maxBlobsArea);
                CCopen = bwconncomp(BWopen);
                Lopen = labelmatrix(CCopen);
                BWopen = logical(Lopen);
            else
                BWopen = BWfill;
            end
            featuresOpen = regionprops(BWopen, img, {'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid'});

            % Area detection
            if ~isempty(featuresOpen)     
                index = find([featuresOpen.Area] > limits.minArea & [featuresOpen.Area] < limits.maxArea);
                CCarea = bwconncomp(BWopen);
                Larea = labelmatrix(CCarea);
                BWarea = ismember(Larea,index);
            else
                BWarea = BWopen;
            end
            featuresArea = regionprops(BWarea, img, 'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid');

            if step == 1
                BWr(:,:,nSlice) = BWarea;
                BWrfill(:,:,nSlice) = BWopen;
            end       
        end

        % STEP 2
        if (step == 2) || (step == 3) 
            % Calculate Custom Pixel Value-Based Properties
            BWpix = BWarea; 
            featuresPix = regionprops(BWpix, img, {'Centroid','Extrema','PixelValues','BoundingBox', 'WeightedCentroid'});
            numPix = numel(featuresPix);
            for count = 1:numPix
                featuresPix(count).StandardDeviation = std(double(featuresPix(count).PixelValues));
                featuresPix(count).Mean = mean(double(featuresPix(count).PixelValues));
            end

            % Std detection
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

            % Mean detection
            if ~isempty(featuresStd)
                index = find([featuresStd.Mean] >= limits.minMean & [featuresStd.Mean] <= limits.maxMean);
                CCmean = bwconncomp(BWstd);
                Lmean = labelmatrix(CCmean);
                BWmean = ismember(Lmean, index);
            else
            BWmean = BWstd;
            end
            featuresMean = regionprops(BWmean, img, {'Centroid', 'BoundingBox', 'WeightedCentroid', 'Extrema'});
            numMean = numel(featuresMean);

            if step == 2
                BWr(:,:,nSlice) = BWmean;
            end  
        end

        % STEP 3
        if (step == 3) 
            % GLCM analysis
            if ~isempty(featuresMean)
                glcm = cell(1, numMean);
                glcmprops = struct('Contrast', [], 'Correlation', [], 'Energy', [], 'Homogeneity', []);
                for i = 1:numMean
                    rect = featuresMean(i).BoundingBox;
                    croppedImg = imcrop(img, rect);   
                    glcm{i} = graycomatrix(croppedImg, 'NumLevels', 2^8 - 1);
                    glcmprops(i) = graycoprops(glcm{i}); 
                end
            else
                glcmprops = struct([]);
            end

            % GLCM detection
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
        end

        if step == 3
            BWr(:,:,nSlice) = BWglcm;
        end  

    end
    
    % Volume detection
    if ~isempty(BWr)
        CCvol = bwconncomp(BWr);
        Lvol = labelmatrix(CCvol);
        featuresVol = regionprops(CCvol,'Centroid','PixelIdxList');
        numVol = numel(featuresVol);
        for count = 1:numVol
            featuresVol(count).Volume = numel(featuresVol(count).PixelIdxList);
        end
            index = find([featuresVol.Volume] > limits.minVolume & [featuresVol.Volume] < limits.maxVolume);
        BWvol = ismember(Lvol, index);
        BWvol = double(BWvol);
    else
        BWvol = zeros();
    end  
    % implay(BWr)
    BWrend(:,:,:,nTimeframe) = BWvol;
    BWsvol = smooth3(BWvol,'box',[3,3,3]);
    BWfull(:,:,:,nTimeframe) = BWsvol;
end
toc;
% show4D(BWfull, 1); %% uncomment for full time reconstruction
% show3Dcathinheart(BWrfill, BWs, 0.20, 0.20)
% DataExplorer(BWfull);