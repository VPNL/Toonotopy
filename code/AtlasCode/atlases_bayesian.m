%% This script ...
%  1. Produces Noah Benson's Bayesian retinotopic atlas (Noah Benson et al, 2012, 2014, 2018) 
%       using Noah's docker container
%  2. Converts the mgz formatted outputs to nifti
%  3. Loads the niftis into a mrVista session and views the outputs as
%        either ROIs (for areal outputs) or maps (for eccentricity and
%        polar angle outputs)
%  4. You will need to update your subDir to indicate its location in your
%     computer
%
% JW 02/20
% plotting KGS 2/20

%% Export vistasoft retinotopy results for inputs to Bayesian atlas
subDir='/Users/kalanit/Courses/psych224/data/TestSubject/TestSubject_190725/'
dt  =  'Averages'; 
prfModel =  'retModel-cssFit-gFit.mat'; 
fspath =  fullfile('.', '3DAnatomy', 'FreeSurferSegmentation_TestSubject'); 

vistaExportMeshData(subDir, dt, prfModel, fspath);

% check it in freeview
%{ 
cd ~/Box/Psych_224/TestSubject_190725/3DAnatomy/FreeSurferSegmentation_TestSubject
freeview -f surf/rh.inflated:overlay=../atlases/data/rh.varexp.mgz:overlay_threshold=0.1,0.3\
 -f surf/rh.inflated:overlay=../atlases/data/rh.eccen.mgz:overlay_threshold=0.1,10 \
 -f surf/lh.inflated:overlay=../atlases/data/lh.varexp.mgz:overlay_threshold=0.1,0.3  --viewport 3d
%}


%% Run the Bayesian Atlas fitting

%{
# To run the bayesian atlas, use the <register_retinotopy> function call. 
#   To get help with the input arguments, use this command
docker run nben/neuropythy register_retinotopy --help

cd ~/Box/Psych_224/TestSubject_190725/
mkdir -p 3DAnatomy/atlases/bayesian/surf
mkdir -p 3DAnatomy/atlases/bayesian/vol

# This command will run the atlas. 

 
docker run \
           --rm -it \
           -v "$(pwd)/3DAnatomy:/subjects" \
           -v "$(pwd)/3DAnatomy/atlases/data:/DATA" \
           -v "$(pwd)/3DAnatomy/atlases/bayesian:/OUTDIR" \
           nben/neuropythy:latest \
           register_retinotopy FreeSurferSegmentation_TestSubject \
           --verbose \
           --max-input-eccen=20 \
           --surf-outdir=/OUTDIR/surf \
           --vol-outdir=/OUTDIR/vol \
           --lh-theta=/DATA/lh.theta.mgz \
           --rh-theta=/DATA/rh.theta.mgz \
           --lh-eccen=/DATA/lh.eccen.mgz \
           --rh-eccen=/DATA/rh.eccen.mgz \
           --lh-radius=/DATA/lh.prfsize.mgz \
           --rh-radius=/DATA/rh.prfsize.mgz \
           --lh-weight=/DATA/lh.varexp.mgz \
           --rh-weight=/DATA/rh.varexp.mgz
%}

%% Convert the atlas outputs to RAS
pth = fullfile('.', '3DAnatomy', 'atlases', 'bayesian', 'vol');
d = dir(fullfile(pth, '*.mgz'));
for ii = 1:length(d)
    mgzfname = fullfile(d(ii).folder, d(ii).name);
    niifname = fullfile(d(ii).folder, strrep(d(ii).name, 'mgz', 'nii.gz'));
    system(sprintf('mri_convert %s %s --out_orientation RAS', mgzfname, niifname));
end

%% Open a mrVista 3D view and load meshes

% Update this path for your computer. It should be the folder that contains
%   the mrSESSION.mat file for your subject.
subDir='/Users/kalanit/Courses/psych224/data/TestSubject/TestSubject_190725/'
cd(subDir);
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
% 
% vw = meshUpdateAll(vw);


%% View the Benson V1-V3 labels as ROIs in mrVista
atlas.bayesian = fullfile('.', '3DAnatomy', 'atlases', 'bayesian', 'vol', 'inferred_varea.nii.gz');

% Hide ROIs in the volume view, because it is slow to find and draw the
% boundaries of so many ROIs
vw = viewSet(vw, 'Hide Gray ROIs', true);

% Load the nifti as ROIs
vw = nifti2ROI(vw, atlas.bayesian);
vw = viewSet(vw, 'ROI Name', 'BensonBayesianAtlas_V1', 1);
vw = viewSet(vw, 'ROI Name', 'BensonBayesianAtlas_V2', 2);
vw = viewSet(vw, 'ROI Name', 'BensonBayesianAtlas_V3', 3);

% Save the V1-V3 Bayseian ROIs
ROIs = viewGet(vw, 'ROIs');
vw = viewSet(vw, 'ROIs', ROIs(1:3));
local = false; forceSave = true;
saveAllROIs(vw, local, forceSave);

% Visualize ROIs on mesh
vw = viewSet(vw, 'ROI draw method', 'perimeter');
vw = meshUpdateAll(vw); 

fig_counter=1;
% Copy the meshes to Matlab figures
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off;
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonBayesian_V1V2V3.jpg');
    else
        figname=fullfile(subDir,'Images','rh_BensonBayesian_V1V2V3.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end

%% View the Benson Eccenricity and Polar Angle maps in mrVista

% ECCENTRICITY -----------------------------------------------------
% Load and display the eccentricity map

atlas.eccen = fullfile('.', '3DAnatomy', 'atlases', 'bayesian', 'vol', 'inferred_eccen.nii.gz');

vw = viewSet(vw, 'display mode', 'map');
vw = loadParameterMap(vw, atlas.eccen);

% use truncated hsv colormap (fovea is red, periphery is blue)
vw.ui.mapMode = setColormap(vw.ui.mapMode, 'hsvTbCmap'); 

% limit to ecc > 0
vw = viewSet(vw, 'mapwin', [eps 90]);
vw = viewSet(vw, 'mapclip', [eps 90]);
vw = refreshScreen(vw);
vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonBayesianEccen.jpg');
    else
        figname=fullfile(subDir,'Images','rh_BensonBayesianEccen.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end

%% POLAR ANGLE -----------------------------------------------------
% Load and display the angle map
atlas.angle = fullfile('.', '3DAnatomy', 'atlases', 'bayesian', 'vol', 'inferred_angle.nii.gz');

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
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_BensonBayesianPolarAngle.jpg');
    else
        figname=fullfile(subDir,'Images','rh_BensonBayesianPolarAngle.jpg');  
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end


