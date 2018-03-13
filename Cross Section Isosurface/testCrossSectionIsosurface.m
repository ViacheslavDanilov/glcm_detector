
function testCrossSectionIsosurface

load mri;
D = squeeze(D);
% for n = 1:4
% CrossSectionIsosurface(D, 'aspect', [1 1 0.4], 'subvolume', ...
%                             [20 + n*10,nan,nan,nan,nan,nan], 'color', 'b');
% end
CrossSectionIsosurface(D, 'aspect', [1 1 0.4], 'subvolume', ...
                            [55,60,nan,80,nan,nan], 'color', 'b');


load('./sample3Dmatrix.mat');
CrossSectionIsosurface(mat3D, 'isovalue', 0.5*10^(26), ...
    'scale', 0.04, 'origin', [-2.5 -2.5 -2.5], 'box', 'off');
xlabel('angstroms x');
ylabel('angstroms y');
zlabel('angstroms z');
title('3d0 orbital');

end










