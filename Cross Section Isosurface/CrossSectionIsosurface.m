%% CrossSectionIsosurface
% 
% this function plots an isosurface, and fills in any open holes with a
% coloration map. this is useful for visualizing complex 3D data. common
% modifications to such plots (3D rotation, lighting, larger font, etc.)
% are added by default. all such options can be input as argument variables
% 
% -- default --
% 
% for a 3D dataset "data3D", this program creates a red isosurface similar
% to what "isosurface(data3D)" creates, except that it is cut in half. the
% open cross-section is then filled in with a copper-colormap. for exact
% details, see the "if no arguments defined" section below.
% 
% 
% -- required input --
% density3D
%     this is the 3D matrix that will be plotted. it must be 3-dimensional
% 
% 
% -- options --
% 
% 'color'           default: 'red'
%                   format:  string (i.e. 'black') or vector (i.e. [1 1 0])
%     (also can be 'isoColor' or 'facecolor')
%     this is the color of the isosurface. the
%     standard RGB inputs in the "plot" function, or a 3-value vector may
%     be used here. the function "colorIs" in this script interprets this
%     option.
% 
% 'scale'           default: 1
%                   format:  single number
%     this is the dx,dy,dz length, or voxel length of the plot.
% 
% 'isovalue'        default: mean(mean(mean(density3D)))
%     the value that defines the 3D solid surface to be plotted. all values
%     below this number will be enclosed by the isosurface
% 
% 'aspect ratio'    default: [1 1 1]
%                   format:  single number
%                   format:  [ aspectXdim aspectYdim aspectZdim]
%     (also can be 'aspect' or 'daspect')
%     the figure's scaling of the data for the X Y and Z axes. this is used
%     to stretch or squish the plot along any or all axes
% 
% 'subvolume'       default: [ nan nan halfLength nan nan nan ]
%                   format:  [ minX maxX minY maxY minZ maxZ ] 
%     (also can be 'clipRange')
%     this 6-value array holds the max/min values of the volume to be
%     shown. a "nan" value is equivalent to the data's extrema. the
%     "halfLength" value above is calculated as the middle of the 3D data
%     in the Y-dimension (for details, see code below)
% 
% 'offset'          default: [0 0 0]
%                   format:  [ offsetXdim offsetYdim offsetZdim ]
%     (also can be 'origin' or 'originPoint')
%     put values in here to offset the axes by a value. the data is plotted
%     the same, but the axes will appear different
% 
% 'fontSize'        default: 18
%                   format:  single number
%     the size of font as it appears in the figure.
% 
% 'boxOnOff'        default: 'on'
%                   format:  string of value 'on' or 'off'
%     turn the box lines in the figure on or off
% 
% 
% -- examples --
% 
% 
% % plot the sample D-orbital included with this file
% load('./sample3Dmatrix.mat');
% CrossSectionIsosurface(mat3D);
% 
% 
% % plot the sample D-orbital included with this file with realistic axes
% load('./sample3Dmatrix.mat');
% CrossSectionIsosurface(mat3D, 'isovalue', 0.5*10^(26), ...
%     'scale', 0.04, 'origin', [-2.5 -2.5 -2.5], 'box', 'off');
% xlabel('angstroms x');
% ylabel('angstroms y');
% zlabel('angstroms z');
% title('3d0 orbital');
% 
% 
% % plot the Matlab sample 3D matrix "mri"
% load mri;
% D = squeeze(D);
% CrossSectionIsosurface(D, 'aspect', [1 1 0.4]);
% 
% 
% % plot a slice of the Matlab sample 3D matrix "mri", color outside blue
% load mri;
% D = squeeze(D);
% CrossSectionIsosurface(D, 'aspect', [1 1 0.4], 'subvolume', ...
%                             [60,80,nan,80,nan,nan], 'color', 'b');
% 


%--------------------------------------------------------------------------
% plot a cross section of a solid isosurface

function CrossSectionIsosurface(density3D, varargin)

% check the only required input
if (ndims(density3D) ~= 3)
    fprintf(['\n\n>>> ERROR! <<<\n\t' ...
        'a 3D matrix with only three dimensions must be input\n\n']);
    return;
end
density3D = double(density3D);

%--------------------------------------------------------------------------
% process inputs

% run through arguments looking for information
if ~isempty(varargin)
    numArg = length(varargin);
    
    n = 1;
    while n <= numArg
        thisArg = varargin{n};
        
        if strcmpi(thisArg, 'color') || strcmpi(thisArg, 'isoColor') ...
                || strcmpi(thisArg, 'FaceColor')
            n = n + 1;
            isoColor = colorIs(varargin{n});
        elseif strcmpi(thisArg, 'scale')
            n = n + 1;
            scale = varargin{n};
        elseif strcmpi(thisArg, 'isovalue')
            n = n + 1;
            isovalue = varargin{n};
        elseif strcmpi(thisArg, 'aspect') || strcmpi(thisArg, 'daspect') ...
                || strcmpi(thisArg, 'aspect ratio')
            n = n + 1;
            aspectRatio = varargin{n};
        elseif strcmpi(thisArg, 'colormap')
            n = n + 1;
            thisColorMap = varargin{n};
        elseif strcmpi(thisArg, 'clipRange') || strcmpi(thisArg, 'subvolume')
            n = n + 1;
            clipRange = varargin{n};
        elseif strcmpi(thisArg, 'offset') || strcmpi(thisArg, 'origin') ...
                || strcmpi(thisArg, 'originPoint')
            n = n + 1;
            originPoint = varargin{n};
        elseif strcmpi(thisArg, 'fontSize')
            n = n + 1;
            fontSize = varargin{n};
        elseif strcmpi(thisArg, 'boxOnOff') || strcmpi(thisArg, 'box')
            n = n + 1;
            boxOnOff = varargin{n};
        
        % allow unlabled variables to be used
        elseif ischar(thisArg)
            isoColor = colorIs(thisArg);
        elseif isnumeric(thisArg) && length(thisArg) == 1
            isovalue = thisArg;
        end
        n = n + 1;
    end
    
    % if variables were not defined, use default values
    if ~exist('scale', 'var')
        scale  = 1;
    end
    if ~exist('isoColor', 'var')
        isoColor = colorIs('red');
    end
    if ~exist('isovalue', 'var')
        isovalue = mean(mean(mean(density3D)));
    end
    if ~exist('aspectRatio', 'var')
        aspectRatio = [1 1 1];
    end
    if ~exist('thisColorMap', 'var')
        thisColorMap = 'Copper';
    end
    if ~exist('originPoint', 'var')
        originPoint = [0 0 0];
    end
    if ~exist('fontSize', 'var')
        fontSize = 18;
    end
    if ~exist('boxOnOff', 'var')
        boxOnOff = 'on';
    end
    if ~exist('clipRange', 'var')
        halfLength = ((size(density3D,2) - 1) * scale / 2) + originPoint(2);
        clipRange = [nan,nan,halfLength,nan,nan,nan];
    end
    
% if no arguments defined, use defaults
else
    scale        = 1.0;
    isoColor     = colorIs('red');
    isovalue     = mean(mean(mean(density3D)));
    aspectRatio  = [1.0 1.0 1.0];
    thisColorMap = 'Copper';
    originPoint  = [0.0 0.0 0.0];
    fontSize     = 18;
    boxOnOff     = 'on';
    
    halfLength = ((size(density3D,2) - 1) * scale / 2) + originPoint(2);
    clipRange  = [nan,nan,halfLength,nan,nan,nan];
end

%--------------------------------------------------------------------------
% generate 3D cartesian space based on inputs

% generate XYZ 3D space using meshgrid
XYZdim = size(density3D);
xRange = (1 : XYZdim(1)) * scale;
yRange = (1 : XYZdim(2)) * scale;
zRange = (1 : XYZdim(3)) * scale;
[x3Dspace, y3Dspace, z3Dspace] = meshgrid(xRange, yRange, zRange);
x3Dspace = x3Dspace + originPoint(1);
y3Dspace = y3Dspace + originPoint(2);
z3Dspace = z3Dspace + originPoint(3);

% normalize data (prevents errors with very large/small data values)
min3DmatValue = min(min(min(density3D)));
max3DmatValue = max(max(max(density3D))) - min3DmatValue;
density3D = (density3D - min3DmatValue) / max3DmatValue;
isovalue  = (isovalue - min3DmatValue) / max3DmatValue;

% define subsection of space to observe
[x,y,z,v] = subvolume(x3Dspace, y3Dspace, z3Dspace, density3D, clipRange);

%--------------------------------------------------------------------------
% create figure

% generate figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'FontName','Arial','FontSize',fontSize);
box(axes1,boxOnOff);
hold(axes1,'all');

% patch and interpret isosurface for better coloration
p1 = patch(isosurface(x,y,z,v,isovalue),'FaceColor',isoColor,'EdgeColor','none');
isonormals(x,y,z,v,p1);
patch(isocaps(x,y,z,v,isovalue),'FaceColor','interp','EdgeColor','none');

% lighting, aspect ratio, figure options
daspect(aspectRatio)
view(3); 
axis vis3d;
colormap(thisColorMap);
colorbar('FontName','Arial','FontSize',fontSize);
camlight; 
camlight right; 
camlight left; 
camlight headlight;
lighting gouraud;
rotate3d on;

% label axes
xlabel('X','FontName','Arial','FontSize',fontSize);
ylabel('Y','FontName','Arial','FontSize',fontSize);
zlabel('Z','FontName','Arial','FontSize',fontSize);


end


%--------------------------------------------------------------------------
% convert an input color name/value into a standard 0-to-1 numeric code

function [thisColor] = colorIs(colorName)

% if input is a string, map it to a color value
if ischar(colorName)
    if strcmpi(colorName, 'yellow') || strcmpi(colorName, 'y')
        thisColor = [1 1 0];
    elseif strcmpi(colorName, 'magenta') || strcmpi(colorName, 'm')
        thisColor = [1 0 1];
    elseif strcmpi(colorName, 'cyan') || strcmpi(colorName, 'c')
        thisColor = [0 1 1];
    elseif strcmpi(colorName, 'red') || strcmpi(colorName, 'r')
        thisColor = [1 0 0];
    elseif strcmpi(colorName, 'green') || strcmpi(colorName, 'g')
        thisColor = [0 1 0];
    elseif strcmpi(colorName, 'blue') || strcmpi(colorName, 'b')
        thisColor = [0 0 1];
    elseif strcmpi(colorName, 'white') || strcmpi(colorName, 'w')
        thisColor = [1 1 1];
    elseif strcmpi(colorName, 'black') || strcmpi(colorName, 'k')
        thisColor = [0 0 0];
    elseif strcmpi(colorName, 'grey') || strcmpi(colorName, 'gray')
        thisColor = [0.3 0.3 0.3];
    else
        fprintf('color not recognized, defaulting to red\n');
        thisColor = [1 0 0];
    end
    
% if input is a number code, check if 0-to-1 color or 1-to-256 color
elseif length(colorName) == 3
    if (max(colorName) > 256)
        thisColor = colorName / max(colorName);
    elseif (max(colorName) > 1)
        thisColor = colorName / 256;
    else
        thisColor = colorName;
    end
    
% if nothing works, just make it red
else
    fprintf('color not recognized, defaulting to red\n');
    thisColor = [1 0 0];
end
    
end
