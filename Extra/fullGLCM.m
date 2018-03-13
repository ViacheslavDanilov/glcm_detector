if ~isempty(featuresGLCM)
    glcmExtra = cell(1, numGLCM);
    glcmpropsExtra = struct('Autocorrelation', [], 'Contrast', [], 'Correlation', [], 'Correlation_e', [], ...
                'Cluster_prominence', [], 'Cluster_shade', [], 'Dissimilarity', [], 'Energy', [], ...
                'Entropy', [], 'Homogeneity', [], 'Homogeneity_e', [], 'Maximum_probability', [], ...
                'Sum_of_sqaures', [], 'Sum_average', [], 'Sum_variance', [], 'Sum_entropy', [], ...
                'Difference_variance', [], 'Difference_entropy', [], 'Information_measure_of_correlation_1', [], 'Information_measure_of_correlation_2', [], ...
                'Inverse_difference_normalized', [], 'Inverse_difference_moment_normalized', []);
    for i = 1:numGLCM
        rect = featuresGLCM(i).BoundingBox;
        croppedImg = imcrop(img, rect);
        glcmExtra{i} = graycomatrix(croppedImg, 'NumLevels', 255);
        glcmpropsExtra(i) = glcmFeatures_full(glcmExtra{i},0);
    end
else
    glcmpropsExtra = struct([]);
end