%% Extract SURF Features from an Image (Speeded-Up Robust Features)
testimg = img;
pointsSURF = detectSURFFeatures(testimg);
figure; imshow(testimg); hold on
strongestPoints = pointsSURF.selectStrongest(1);
strongestPoints.plot('showOrientation',true);

%% Extract BRISK Features from an Image (Binary Robust Invariant Scalable Keypoints)
pointsBRISK = detectBRISKFeatures(testimg);
figure; imshow(testimg); hold on
plot(pointsBRISK.selectStrongest(5));

%% Extract MSER Features from an Image (Maximally Stable Extremal Regions)
[regions,mserCC] = detectMSERFeatures(testimg);
figure; imshow(testimg); hold on;
plot(regions);
figure; imshow(testimg); hold on;
plot(regions, 'showPixelList', true, 'showEllipses', false);

%% Extract Harris Corner Features from an Image (Features from Accelerated Segment Test)
cornerHaris = detectHarrisFeatures(testimg);
figure; imshow(testimg); hold on
plot(cornerHaris.selectStrongest(5));

%% Extract FAST Corner Features from an Image (Features from Accelerated Segment Test)
cornerFAST = detectFASTFeatures(testimg);
figure; imshow(testimg); hold on
plot(cornerFAST.selectStrongest(5));

%% Extract Minimum Eigenvalue Corner Features from an Image
cornerMinEigen = detectMinEigenFeatures(testimg);
figure; imshow(testimg); hold on
plot(cornerMinEigen.selectStrongest(5));

