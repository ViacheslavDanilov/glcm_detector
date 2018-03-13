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

        BWr(:,:,nSlice) = BWarea;
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
% show4D(BWfull, 5); %% uncomment for full time reconstruction
% DataExplorer(BWfull);