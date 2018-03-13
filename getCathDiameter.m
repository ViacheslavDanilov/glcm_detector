
for numSl = 58:81
%     imshowpair(BWr(:,:,numSl),I(:,:,numSl),'montage');
    imgBW = BWr(:,:,numSl);
    imgGS = I(:,:,numSl);
%     imshow(BWr(:,:,numSl));
%     str = ['Slice: ', num2str(numSl)];
%     addTitle(str);
    
    nameImgBW = [num2str(numSl),'_BW','.tiff'];
    imwrite(imgBW, nameImgBW);
    
    nameImgGS = [num2str(numSl),'_GS','.tiff'];
    imwrite(imgGS, nameImgGS);

%     set(gcf, 'Position', scrSz, 'Color', 'w');
%     set(0,'DefaultFigureWindowStyle','docked')
end