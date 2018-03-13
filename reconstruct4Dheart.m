tic;
BWfullopen = zeros(sz(1), sz(2), sz(3), sz(4));
BWvolopen = zeros(sz(1), sz(2), sz(3));
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
        BWvolopen(:,:,nSlice) = BWopen;
        BWvolopen = double(BWvolopen);
        BWsopen = smooth3(BWvolopen,'box',[3,3,3]);
    end
    BWfullopen(:,:,:,nTimeframe) = BWsopen;
end
% show4D(BWfullopen, 1); %uncomment for visualization
toc;