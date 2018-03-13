function imageshow(img, text) 
f = figure;
imshow(img); addTitle(text);
h = uicontrol('Position',[10 10 200 40],'String','Continue', 'Callback','uiresume(gcbf)');
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
uiwait(gcf); 
close(f);
end