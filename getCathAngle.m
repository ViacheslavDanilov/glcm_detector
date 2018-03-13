% Skeletonization and writing
J = permute(I, [1 3 2]);
K = rot90(J);
% implay(K)
isVisual = 1;
isWrite = 0;

for sliceSkel = 95:101
    imgSkel = K(:,:,sliceSkel);
    
    if isWrite == 1
        nameOrig = [num2str(sliceSkel),'_original','.tiff'];
        imwrite(imgSkel, nameOrig);
    end
    
    levelSkel = graythresh(imgSkel);
    BWimgSkel = imbinarize(imgSkel, levelSkel);
    BWskel = bwmorph(BWimgSkel,'skel', Inf);
    
    if isVisual == 1
        imshowpair(imgSkel,BWskel,'montage');
        set(gcf, 'Position', scrSz, 'Color', 'w');
    end

    if isWrite == 1
        nameSkel = [num2str(sliceSkel),'_skel','.tiff'];
        imwrite(BWskel, nameSkel);
    end
    
    imgFusedSkel = imoverlay(imgSkel, BWskel, [0.498039 1 0.831373]);
    if isVisual == 1
        imshow(imgFusedSkel, 'InitialMagnification', 'fit');
        set(gcf, 'Position', scrSz, 'Color', 'w');
    end
    
    if isWrite == 1
        nameFusedSkel = [num2str(sliceSkel),'_fused','.tiff'];
        imwrite(imgFusedSkel, nameFusedSkel);
    end
    % imtool(imgFused);
end