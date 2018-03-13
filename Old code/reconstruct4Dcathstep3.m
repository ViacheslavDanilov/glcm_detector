tic;
BWrend = zeros(sz(1), sz(2), sz(3), sz(4));
BWfullopen = zeros(sz(1), sz(2), sz(3), sz(4));
BWfull = zeros(sz(1), sz(2), sz(3), sz(4));
for nTimeframe = 1:sz(4) %% uncomment for full time reconstruction
    BWr = zeros(sz(1), sz(2), sz(3));
    I = squeeze(X(:,:,:,nTimeframe));
    for nSlice = 1:sz(3)  
        img = I(:,:,nSlice);

        % Binarization
        [level,EM] = graythresh(img);
        BW = imbinarize(img, level);

        % Blobs analysis
        BWfill = imfill(BW, 'holes');
        CCini = bwconncomp(BWfill);
        Lini = labelmatrix(CCini);
        featuresIni = regionprops(Lini,  img, {'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid'});

        % Open small areas
        excessBlobsArea = 5;
        if ~isempty(featuresIni)
            BWopen = bwareaopen(Lini, excessBlobsArea);
            CCopen = bwconncomp(BWopen);
            Lopen = labelmatrix(CCopen);
            BWopen = logical(Lopen);
        else
            BWopen = BWfill;
        end
        featuresOpen = regionprops(BWopen, img, {'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid'});

        % Area detection
        lowLimitArea = 5;
        highLimitArea = 200;
        if ~isempty(featuresOpen)     
            index = find([featuresOpen.Area] > lowLimitArea & [featuresOpen.Area] < highLimitArea);
            CCarea = bwconncomp(BWopen);
            Larea = labelmatrix(CCarea);
            BWarea = ismember(Larea,index);
        else
            BWarea = BWopen;
        end
        featuresArea = regionprops(BWarea, img, 'Area', 'BoundingBox', 'Centroid', 'WeightedCentroid');

        % Calculate Custom Pixel Value-Based Properties
        BWpix = BWarea; 
        featuresPix = regionprops(BWpix, img, {'Centroid','Extrema','PixelValues','BoundingBox', 'WeightedCentroid'});
        numPix = numel(featuresPix);
        for count = 1:numPix
            featuresPix(count).StandardDeviation = std(double(featuresPix(count).PixelValues));
            featuresPix(count).Mean = mean(double(featuresPix(count).PixelValues));
        end

        % Std detection
        lowLimitStd = 3;
        highLimitStd = 53;
        if ~isempty(featuresPix)
            index = find([featuresPix.StandardDeviation] >= lowLimitStd & [featuresPix.StandardDeviation] <= highLimitStd);
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
        lowLimitMean = 74;
        highLimitMean = 132;
        if ~isempty(featuresStd)
            index = find([featuresStd.Mean] >= lowLimitMean & [featuresStd.Mean] <= highLimitMean);
            CCmean = bwconncomp(BWstd);
            Lmean = labelmatrix(CCmean);
            BWmean = ismember(Lmean, index);
        else
        BWmean = BWstd;
        end
        featuresMean = regionprops(BWmean, img, {'Centroid', 'BoundingBox', 'WeightedCentroid', 'Extrema'});
        numMean = numel(featuresMean);

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
        lowLimitContrast = 77;
        highLimitContrast = 574;
        lowLimitCorrelation = 0.55;
        highLimitCorrelation = 0.97;
        lowLimitEnergy = 0.002;
        highLimitEnergy = 0.112;
        lowLimitHomogeneity = 0.07;
        highLimitHomogeneity = 0.27;   
        if ~isempty(glcmprops)
            index = find([glcmprops.Contrast] >= lowLimitContrast & [glcmprops.Contrast] <= highLimitContrast & ...
                         [glcmprops.Correlation] >= lowLimitCorrelation & [glcmprops.Correlation] <= highLimitCorrelation & ...
                         [glcmprops.Energy] >= lowLimitEnergy & [glcmprops.Energy] <= highLimitEnergy & ...
                         [glcmprops.Homogeneity] >= lowLimitHomogeneity & [glcmprops.Homogeneity] <= highLimitHomogeneity);
            CCglcm = bwconncomp(BWmean);
            Lglcm = labelmatrix(CCglcm);
            BWglcm = ismember(Lglcm, index);
        else
            BWglcm = BWmean;
        end
        featuresGLCM = regionprops(BWglcm, img, {'Centroid', 'PixelValues', 'BoundingBox', 'WeightedCentroid', 'Extrema'});
        numGLCM = numel(featuresGLCM);

    % %     % Extra GLCM analysis
    % %     if ~isempty(featuresMean)
    % %         glcmExtra = cell(1, numGLCM);
    % %         glcmpropsExtra = struct('Autocorrelation', [], 'Dissimilarity', [], 'Entropy', []);
    % %         for i = 1:numGLCM
    % %                 rect = featuresGLCM(i).BoundingBox;
    % %                 croppedImg = imcrop(img, rect);
    % %                 glcmExtra{i} = graycomatrix(croppedImg, 'NumLevels', 255);
    % %                 glcmpropsExtra(i) = glcmFeatures(glcmExtra{i},0);
    % %         end
    % %     else
    % %         glcmpropsExtra = struct([]);
    % %     end
    % %     
    % %     % Extra GLCM detection
    % %     lowLimitAutocorrelation = 4349.39835;
    % %     highLimitAutocorrelation = 14823.0147;
    % %     lowLimitDiss = 7.3326;
    % %     highLimitDiss = 20.6627803571429;
    % %     lowLimitEnropy = 2.19700485487849;
    % %     highLimitEnropy = 5.79080134417099;
    % %     if ~isempty(glcmpropsExtra)
    % %         index = find([glcmpropsExtra.Autocorrelation] >= lowLimitAutocorrelation & [glcmpropsExtra.Autocorrelation] <= highLimitAutocorrelation &...
    % %                      [glcmpropsExtra.Dissimilarity] >= lowLimitDiss & [glcmpropsExtra.Dissimilarity] <= highLimitDiss &...
    % %                      [glcmpropsExtra.Entropy] >= lowLimitEnropy & [glcmpropsExtra.Entropy] <= highLimitEnropy);
    % %         CCextraglcm = bwconncomp(BWglcm);
    % %         Lextraglcm = labelmatrix(CCextraglcm);
    % %         BWextraglcm = ismember(Lextraglcm, index);
    % %     else
    % %         BWextraglcm = BWglcm;
    % %     end
    % %     BWr(:,:,nSlice) = BWextraglcm;
        BWr(:,:,nSlice) = BWglcm;
    end
    
    % Volume detection
    lowLimitVolume = 300;
    highLimitVolume = 10000;
    if ~isempty(BWr)
        CCvol = bwconncomp(BWr);
        Lvol = labelmatrix(CCvol);
        featuresVol = regionprops(CCvol,'Centroid','PixelIdxList');
        numVol = numel(featuresVol);
        for count = 1:numVol
            featuresVol(count).Volume = numel(featuresVol(count).PixelIdxList);
        end
        index = find([featuresVol.Volume] > lowLimitVolume & [featuresVol.Volume] < highLimitVolume);
        BWvol = ismember(Lvol, index);
        BWvol = double(BWvol);
    else
        BWvol = zeros();
    end  
    % implay(BWr)
    BWrend(:,:,:,nTimeframe) = BWvol;
    BWs = smooth3(BWvol,'box',[3,3,3]);
    BWfull(:,:,:,nTimeframe) = BWs;
end
toc;
% show4D(BWfull, 1); %% uncomment for full time reconstruction
% DataExplorer(BWfull);