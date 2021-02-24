% This script compares hand drawn V1-V3 ROIs to anatomical and bayesian atlas V1-V3 ROIs
% Run this after you have run atlases_anatomical.m and atlases_bayesian.m
% it also superimposes the ROI labels on the subject's measured phase map
%
% KGS 2/20

%% set path
subDir='/Users/kalanit/Courses/psych224/data/TestSubject/TestSubject_190725';
cd(subDir);

%% Open a mrVista 3D view
vw = mrVista('3');
%% Load Wang Atlas V1-V3 ROIs

Wang_ROIs={'WangAtlas_V1d.mat','WangAtlas_V1v.mat' 'WangAtlas_V3d.mat','WangAtlas_V3v.mat' 'WangAtlas_V2d.mat' 'WangAtlas_V2v.mat'};
%load ROIs
[vw,ok]=loadROI(vw, Wang_ROIs);    

% set ROI color to blue
nWang_ROIs = length(Wang_ROIs);
Wang_color = [ 0 0 1];
for ii = 1:nWang_ROIs
   vw = viewSet(vw, 'ROI color', Wang_color, ii); 
end

%% Benson Anatomical Atlas V1-V3 ROIs
Benson_ROIs={'BensonAtlas_V1.mat','BensonAtlas_V2.mat','BensonAtlas_V3.mat'};
%load ROIs
[vw,ok]=loadROI(vw, Benson_ROIs);    

nBenson_ROIs = length(Benson_ROIs);
% set ROI color to yellow
Benson_color = [ 1 1 0];
startROI=nWang_ROIs;
endROI=nWang_ROIs+nBenson_ROIs;
for ii = startROI+1:endROI
   vw = viewSet(vw, 'ROI color', Benson_color, ii); 
end

%% Benson Bayesian Atlas V1-V3 ROIs
Benson_BayesianROIs={'BensonBayesianAtlas_V1.mat','BensonBayesianAtlas_V2.mat','BensonBayesianAtlas_V3.mat'};
%load ROIs
[vw,ok]=loadROI(vw, Benson_BayesianROIs);    
nBensonBayesian_ROIs = length(Benson_BayesianROIs);

startROI=endROI;
endROI=startROI+nBensonBayesian_ROIs;

% set ROI color to white
BensonBayesian_color = [ 1 1 1];
for ii = startROI+1:endROI
   vw = viewSet(vw, 'ROI color', BensonBayesian_color, ii); 
end

%% edit this to your list of ROI names
% Your ROIs should be stored in SubjectSession/3DAnatomy/ROIs

myROIs={'toonRet_CSS_rh_V1_HK.mat'	...
    'toonRet_CSS_rh_V2d_hk.mat','toonRet_CSS_rh_V2v_hk?.mat'...
    'toonRet_CSS_rh_V3d_hk.mat','toonRet_CSS_rh_V3v_hk.mat'...
    'toonRet_CSS_lh_V1_hk.mat'	...
    'toonRet_CSS_lh_V2d_hk.mat','toonRet_CSS_lh_V2v_hk.mat'...
    'toonRet_CSS_lh_V3d_hk.mat','toonRet_CSS_lh_V3v_hk.mat'};
%load ROIs
[vw,ok]=loadROI(vw, myROIs);  
% set ROI color to black
my_color=[ 0 0 0];
nmyROIs=length(myROIs);
startROI=endROI;
endROI=startROI+nmyROIs;

for ii = startROI+1:endROI
   vw = viewSet(vw, 'ROI color', my_color, ii); 
end

%% load & update meshes

% define lights
L.ambient=[.4 .4 .4];
L.diffuse=[.5 .5 .5];

meshlh = fullfile('3DAnatomy', 'lh_inflated_200_1.mat');
meshrh = fullfile('3DAnatomy', 'rh_inflated_200_1.mat');

% if you defined a mesh angle  for each of your meshes in
% Gray->mesh view settings -> store mesh settings
% you can remove these comments and use your mesh settings
% meshAngleSettinglh='lh_medial';
% meshAngleSettingrh='rh_medial';

if exist('meshAngleSettinglh','var')
    vw=atlases_loadNsetMesh (vw, meshlh, L, 'all', meshAngleSettinglh);
else
    vw=atlases_loadNsetMesh (vw, meshlh, L);
end
if exist('meshAngleSettingrh','var')
    vw=atlases_loadNsetMesh (vw, meshrh, L, 'all', meshAngleSettingrh);
else
    vw=atlases_loadNsetMesh (vw, meshrh, L);
end

vw = meshUpdateAll(vw);

fig_counter=1;

% Copy the meshes to Matlab figures & save
if ~exist('./Images','dir')
        !mkdir ./Images
end
for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_compare_V1V2V3.jpg');
    else
        figname=fullfile(subDir,'Images','rh_compare_V1V2V3.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end


%% Compare to the pRF model on this subject
% load the prf model for this session


pth = subDir;
dt =  'Averages'
prfModel =  'retModel-cssFit-fFit.mat'
fspath =  fullfile('.', '3DAnatomy', 'FreeSurferSegmentation_TestSubject'); 

% % Load the PRF model and set the view to phase mode
vw = viewSet(vw, 'Hide Gray ROIs', true);
vw = viewSet(vw, 'current dataTYPE', dt);
vw = rmSelect(vw, 1, prfModel);
vw=rmLoadDefault(vw);
vw = viewSet(vw, 'display mode', 'ph');
vw = setDisplayMode(vw, 'ph');

%update left mesh & make figure
vw = viewSet(vw, 'current mesh n', 1);
vw=cmapSetLumColorPhaseMap(vw, 'left');vw=refreshScreen(vw); vw = meshColorOverlay(vw);
figH(fig_counter)=figure('Color', 'w'); 
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
figname=fullfile(subDir,'Images','lh_compare_V1V2V3_withPhasemap.jpg');
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;
    
%update right mesh & make figure
vw = viewSet(vw, 'current mesh n', 2);
vw=cmapSetLumColorPhaseMap(vw, 'right');vw=refreshScreen(vw); vw = meshColorOverlay(vw);
figH(fig_counter)=figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
figname=fullfile(subDir,'Images','rh_compare_V1V2V3_withPhasemap.jpg');
saveas(figH(fig_counter),figname,'jpg');

%% just for fun we can also look at the eccentricity map
vw = viewSet(vw, 'display mode', 'map');
vw = setDisplayMode(vw, 'map');
vw.ui.ampMode=setColormap(vw.ui.ampMode,'hsvTbCmap');vw=refreshScreen(vw); vw = meshColorOverlay(vw);
vw = meshUpdateAll(vw);

for ii = 1:2
    vw = viewSet(vw, 'current mesh n', ii);
    figH(fig_counter)=figure('Color', 'w'); 
    imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
    if ii==1
        figname=fullfile(subDir,'Images','lh_compare_V1V2V3eccen.jpg');
    else
        figname=fullfile(subDir,'Images','rh_compare_V1V2V3eccen.jpg');
    end
    saveas(figH(fig_counter),figname,'jpg');
    fig_counter=fig_counter+1;
end