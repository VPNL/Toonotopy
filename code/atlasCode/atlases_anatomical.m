%% This script ...
%  1. Produces anatomical templates (Wang et al 2015; Noah Benson et al, 2012, 2014, 2018) 
%       using Noah Benson's docker container
%  2. Converts the mgz formatted outputs to nifti
%  3. Loads the niftis into a mrVista session and views the outputs as
%        either ROIs (for areal outputs) or maps (for eccentricity and
%        polar angle outputs)
%  4. You will need to update your subDir to indicate its location in your
%     computer
% JW 02/20
% plotting KGS 2/20

%% Produce the anatomical templates using Docker

% These commands need to be executed in a terminal (not MATLAB)

%{
# Download the latest version of Noah Benson's Neuropythy docker
#   See GitHub for more: https://github.com/noahbenson/neuropythy/wiki
docker pull nben/neuropythy:latest
# To run the anatomical atlas, use the <atlas> function call. This command
#   will show the input arguments
docker run nben/neuropythy atlas --help
# Change directory to a folder that contains a freesurfer directory
#  Make sure to update the path for your computer
cd ~/Box/Psych_224/TestSubject_190725
# Create directories to store atlas outputs
mkdir -p 3DAnatomy/atlases/anatomical/surf
mkdir -p 3DAnatomy/atlases/anatomical/vol
# This command will run the atlas. 
docker run --rm -it \
           -v "$(pwd)/3DAnatomy:/subjects" \
           -v "$(pwd)/3DAnatomy/atlases/anatomical:/OUTDIR" \
           nben/neuropythy atlas FreeSurferSegmentation_TestSubject \
           --verbose --volume-export \
           --output-path="/OUTDIR/surf" \
           --volume-path="/OUTDIR/vol"
%}

%% Convert template results from MGZ to NIFTI

% Update the subDir for your computer. It should be the folder that contains
% the mrSESSION.mat file for your subject.
subDir='/Users/kalanit/Courses/psych224/data/TestSubject/TestSubject_190725/'
cd(subDir)

% -------- Convert MGZ files to NIFTI -------------
atlas.path   = fullfile('3DAnatomy','atlases', 'anatomical', 'vol');
atlas.fnames = {'wang15_mplbl' 'benson14_varea' 'benson14_eccen' 'benson14_angle' 'benson14_sigma'};

for ii = 1:length(atlas.fnames)
    mgzfname = fullfile(atlas.path, sprintf('%s.mgz', atlas.fnames{ii}));
    niifname = fullfile(atlas.path, sprintf('%s.nii.gz', atlas.fnames{ii}));
    system(sprintf('mri_convert %s %s --out_orientation RAS', mgzfname, niifname));
    switch atlas.fnames{ii}
        case 'wang15_mplbl',   atlas.wang   = niifname; 
        case 'benson14_varea', atlas.benson = niifname; 
        case 'benson14_eccen', atlas.eccen  = niifname;  
        case 'benson14_angle', atlas.angle  = niifname;  
        case 'benson14_sigma', atlas.size   = niifname; 
    end
end


%% Open a mrVista 3D view and load meshes

vw = mrVista('3');

% define lights
L.ambient=[.4 .4 .4];
L.diffuse=[.5 .5 .5];

layerMapMode= 'layer1';

meshlh = fullfile('3DAnatomy', 'lh_inflated_200_1.mat');
meshrh = fullfile('3DAnatomy', 'rh_inflated_200_1.mat');

% if you defined a mesh angle for each of your meshes in
% Gray->mesh view settings -> store mesh settings
% you can comment out these lines and use your mesh settings
 % meshAngleSettinglh='lh_medial';
 % meshAngleSettingrh='rh_medial';

if exist('meshAngleSettinglh','var')
    vw=atlases_loadNsetMesh (vw, meshlh, L,layerMapMode, meshAngleSettinglh);
else
    vw=atlases_loadNsetMesh (vw, meshlh, L,layerMapMode);
end
if exist('meshAngleSettingrh','var')
    vw=atlases_loadNsetMesh (vw, meshrh, L, layerMapMode, meshAngleSettingrh);
else
    vw=atlases_loadNsetMesh (vw, meshrh, L,layerMapMode);
end

vw = meshUpdateAll(vw);




%% View the Wang maximum probability map as ROIs in mrVista 

vw = wangAtlasToROIs(vw, atlas.wang);

% Save the ROIs
local = false; forceSave = true;
saveAllROIs(vw, local, forceSave);
 
% Store the coords to vertex mapping for each ROI for quicker drawing
vw = roiSetVertIndsAllMeshes(vw); 

% Let's look at the ROIs on meshes

% For fun, color the meshes
nROIs = length(viewGet(vw, 'ROIs'));
colors = hsv(nROIs);
for ii = 1:nROIs
   vw = viewSet(vw, 'ROI color', colors(ii,:), ii); 
end
vw = viewSet(vw, 'roi draw method', 'boxes');
vw = meshUpdateAll(vw); 

fig_counter=1;

% Copy the meshes to Matlab figures & save figures
if ~exist('./Images','dir')
        !mkdir ./Images
end
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_WangROIs.jpg');
    else
         figname=fullfile(subDir,'Images','rh_WangROIs.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end



%% View the Benson V1-V3 labels as ROIs in mrVista

% Hide ROIs in the volume view, because it is slow to find and draw the
% boundaries of so many ROIs
vw = viewSet(vw, 'Hide Gray ROIs', true);

% Load the nifti as ROIs
numROIs = length(viewGet(vw, 'ROIs'));
vw = nifti2ROI(vw, atlas.benson);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V1', numROIs + 1);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V2', numROIs + 2);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V3', numROIs + 3);

% just show the subset of Benson ROIs
ROIs = viewGet(vw, 'ROIs');
vw = viewSet(vw, 'ROIs', ROIs(1:numROIs + 3));

% Save the V1-V3 Benson ROIs
local = false; forceSave = true;
saveAllROIs(vw, local, forceSave);

% Visualize Benson ROIs overlayed on Wang atlas
vw = viewSet(vw, 'ROI draw method', 'perimeter');
vw = meshUpdateAll(vw); 

% Copy the meshes to Matlab figures
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonVsWangROIs.jpg');
    else
         figname=fullfile(subDir,'Images','rh_BensonVsWangROIs.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end

%% View the Benson Eccenricity and Polar Angle maps in mrVista

% ECCENTRICITY -----------------------------------------------------
% Load and display the eccentricity map
vw = viewSet(vw, 'display mode', 'map');
vw = loadParameterMap(vw, atlas.eccen);

% use truncated hsv colormap (fovea is red, periphery is blue)
vw.ui.mapMode = setColormap(vw.ui.mapMode, 'hsvTbCmap'); 

% limit to ecc > 0
vw = viewSet(vw, 'mapwin', [eps 90]);
vw = viewSet(vw, 'mapclip', [eps 90]);
vw = refreshScreen(vw);
vw = meshUpdateAll(vw); 

% Copy the meshes to Matlab figures
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w');
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonEccenMap.jpg');
    else
         figname=fullfile(subDir,'Images','rh_BensonEccenMap.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end

%% POLAR ANGLE -----------------------------------------------------
% Load and display the angle map
vw = viewSet(vw, 'display mode', 'map');
vw = loadParameterMap(vw, atlas.angle);

% use  hsv colormap
vw.ui.mapMode = setColormap(vw.ui.mapMode, 'hsvCmap'); 

% limit to angles > 0
vw = viewSet(vw, 'mapwin', [eps 180]);
vw = viewSet(vw, 'mapclip', [eps 180]);
vw = refreshScreen(vw);
vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
% Copy the meshes to Matlab figures
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off;
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonPolarAngleMap.jpg');
    else
         figname=fullfile(subDir,'Images','rh_BensonPolarAngleMap.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
   fig_counter=fig_counter+1;
end
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off;
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonPolarAngleMap.jpg');
    else
         figname=fullfile(subDir,'Images','rh_BensonPolarAngleMap.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
   fig_counter=fig_counter+1;
end