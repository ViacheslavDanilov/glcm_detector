%% SURF features
if ~isempty(featuresGLCM)
    for i = 1:numGLCM
        ROI = featuresGLCM(i).BoundingBox;
        pointsSURF = detectSURFFeatures(img, 'ROI', ROI);
        
    end
else
    glcmprops = struct([]);
end

vars.SURF = {'i', 'rect', 'croppedImg', 'str2'};
clear(vars.glcmCondition{:});