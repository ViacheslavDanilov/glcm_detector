%% CPU
tic;
BWcpu = imbinarize(img, level);
toc;
%% GPU
tic;
BWgpu = gpuArray(imbinarize(img, level));
toc;
%% CPU
tic;
BWfillcpu = imfill(BWcpu, 'holes');
toc;
%% GPU
tic;
% BWfillgpu = ones(sz(1),sz(2),'gpuArray');
BWfillgpu = imfill(BWgpu, 'holes');
toc;
