%% Initial state of the programm
clear all; close all; clc;
set(0, 'DefaultFigureWindowStyle', 'normal');
currentFolder = pwd;
addpath(genpath(pwd));

%% Creating new folder for processed images
[filename,dataFolderName] = uigetfile('*','Select a NRRD file');
if isequal(filename,0)
    disp('User selected Cancel')
else
    disp(['User selected ', filename])
end

%% NRRD reading
tic;
nTimeframe = 1; % Choose the number of a timeframe 
[X, meta] = nrrdread(filename);
Y = double(X);
sz = sscanf(meta.sizes, '%d');
nDims = sscanf(meta.dimension, '%d');
I = squeeze(X(:,:,:,nTimeframe));
toc;
%% Visualization with certain colormap
colorDepth = 256;
hFig = implay(I,15);
cmap = jet(colorDepth); %parula(256), gray(256), magma, inferno, plasma, viridis
hFig.Visual.ColorMap.Map = cmap; 
play(hFig.DataSource.Controls);
vars.playMovie = {'hFig', 'colorDepth', 'cmap'};
clear(vars.playMovie{:});

%% Writing .bmp files
tic;
ext = '.bmp';
nslice = sz(3);
tframeName = num2str(nTimeframe);
for i = 1:nslice
    filename = strcat(num2str(i), ext);
    foldername = strcat(currentFolder, '\Data\Slice by slice catheter (low gain)\', tframeName);
    if ~isdir(foldername)
        mkdir(foldername);
    end
    cd(foldername);
    if exist(fullfile(pwd, filename), 'file') == 2
        fprintf('File %s already exists\n', filename);
    else
        imwrite(I(:,:,i),filename);
    end
end
cd ..\..\..;
vars.writingImages = {'ext', 'tframeName', 'i', 'filename', 'foldername'};
clear(vars.writingImages{:});
toc;
