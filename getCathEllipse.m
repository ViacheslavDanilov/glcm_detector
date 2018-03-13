% Automatically take measurements for diameter
% cathRange = 58:81;
cathRange = 53:104;
% cathRange = 58;
isVisual = 0;
diameter = zeros(cathRange(end)-cathRange(1),2);
str = 1;
for numSl = cathRange
    BWfill = BWr(:,:,numSl);
    [featuresMSER,CCmser] = detectMSERFeatures(BWfill, 'RegionAreaRange', [limits.minArea limits.maxArea]);
    numMSER = featuresMSER.Count;
    if isVisual == 1
        figure('Position', [scrSz(1), scrSz(2), scrSz(3)/2, scrSz(4)]); 
        imshow(BWfill, 'InitialMagnification', 'Fit');
        str1 = sprintf('Extract MSER features');
        str2 = sprintf('Objects found: %d', numMSER);
        addTitle({str1, str2});
        hold on;
        plot(featuresMSER);
        figure('Position', [scrSz(3)/2, scrSz(2), scrSz(3)/2, scrSz(4)]); 
        imshow(BWfill, 'InitialMagnification', 'Fit');
        addTitle({str1, str2});
        hold on;
        plot(featuresMSER, 'showPixelList', true, 'showEllipses', false);
        vars.extractMSER = {'str1', 'str2'};
        clear(vars.extractMSER{:});
    end
    diameter(str, :) = [featuresMSER.Axes(1), featuresMSER.Axes(2)];
    str = str + 1;
end
