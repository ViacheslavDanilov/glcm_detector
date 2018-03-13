
for numSl = 58:81
%     imshowpair(BWr(:,:,numSl),I(:,:,numSl),'montage');
    imshow(BWr(:,:,numSl));
    str = ['Slice: ', num2str(numSl)];
    addTitle(str);
%     set(gcf, 'Position', scrSz, 'Color', 'w');
%     set(0,'DefaultFigureWindowStyle','docked')
end