% This script compares hand drawn V1-V3 ROIs from multiple raters
% KGS 2/20

%% set path
subDir='/Users/kalanit/Courses/psych224/data/TestSubject/TestSubject_190725';
cd(subDir);

%% Open a mrVista 3D view
vw = mrVista('3');
%% Load HK's V1-V3 ROIs

HK_ROIs={ 
'toonRet_CSS_lh_V1_hk.mat',
'toonRet_CSS_lh_V2d_hk.mat',
'toonRet_CSS_lh_V2v_hk.mat',
'toonRet_CSS_lh_V3d_hk.mat',
'toonRet_CSS_lh_V3v_hk.mat',
'toonRet_CSS_rh_V1_hk.mat'
'toonRet_CSS_rh_V2d_hk.mat'
'toonRet_CSS_rh_V2v_hk.mat'
'toonRet_CSS_rh_V3d_hk.mat'
'toonRet_CSS_rh_V3v_hk.mat'};
%load ROIs
[vw,ok]=loadROI(vw, HK_ROIs);    

% set ROI color to black
nHK_ROIs = length(HK_ROIs);
HK_color = [ 0 0 0];
for ii = 1:nHK_ROIs
   vw = viewSet(vw, 'ROI color', HK_color, ii); 
end

%% load JR's V1-V3 ROIs
JR_ROIs={
'ToonRet_css_lh_v1_jr.mat',
'ToonRet_css_lh_v2d_jr.mat',
'ToonRet_css_lh_v2v_jr.mat',
'ToonRet_css_lh_v3d_jr.mat',
'ToonRet_css_lh_v3v_jr.mat',
'ToonRet_css_rh_v1_jr.mat',
'ToonRet_css_rh_v2d_jr.mat',
'ToonRet_css_rh_v2v_jr.mat',
'ToonRet_css_rh_v3d_jr.mat',
'ToonRet_css_rh_v3v_jr.mat'};
%load ROIs
[vw,ok]=loadROI(vw, JR_ROIs);    

nJR_ROIs = length(JR_ROIs);

% set ROI color to pink
JR_color =  [ 1 .5 1]; %
startROI=nHK_ROIs;
endROI=nHK_ROIs+nJR_ROIs;
for ii = startROI+1:endROI
   vw = viewSet(vw, 'ROI color', JR_color, ii); 
end

%% KGS V1-V3 ROIs
KGS_ROIs={
'ToonRet_CSS_lh_V1_kgs.mat',
'ToonRet_CSS_lh_V2d_kgs.mat',
'ToonRet_CSS_lh_V2v_kgs.mat',
'ToonRet_CSS_lh_V3d_kgs.mat',
'ToonRet_CSS_lh_V3v_kgs.mat',
'ToonRet_CSS_rh_V1_kgs.mat',
'ToonRet_CSS_rh_V2d_kgs.mat',
'ToonRet_CSS_rh_V2v_kgs.mat',
'ToonRet_CSS_rh_V3d_kgs.mat'
'ToonRet_CSS_rh_V3v_kgs.mat'};
%load ROIs
[vw,ok]=loadROI(vw, KGS_ROIs);    
nKGS_ROIs = length(KGS_ROIs);

startROI=endROI;
endROI=startROI+nKGS_ROIs;

% set ROI color to white
KGS_color = [ 1 1 1];
for ii = startROI+1:endROI
   vw = viewSet(vw, 'ROI color', KGS_color, ii); 
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
meshAngleSettinglh='lh_medial';
meshAngleSettingrh='rh_medial';

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
%%
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
        figname=fullfile(subDir,'Images','lh_compare_handDrawnV1V2V3.jpg');
    else
        figname=fullfile(subDir,'Images','rh_compare_handDrawnV1V2V3.jpg');
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
figname=fullfile(subDir,'Images','lh_compare_handDrawnV1V2V3_withPhasemap.jpg');
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;
    
%update right mesh & make figure
vw = viewSet(vw, 'current mesh n', 2);
vw=cmapSetLumColorPhaseMap(vw, 'right');vw=refreshScreen(vw); vw = meshColorOverlay(vw);
figH(fig_counter)=figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
figname=fullfile(subDir,'Images','rh_compare_handDrawnV1V2V3_withPhasemap.jpg');
saveas(figH(fig_counter),figname,'jpg');

%% just for fun we can also look at the eccentricity map
vw = viewSet(vw, 'display mode', 'map');
vw = setDisplayMode(vw, 'map');
vw.ui.ampMode=setColormap(vw.ui.ampMode,'hsvTbCmap');vw=refreshScreen(vw); vw = meshColorOverlay(vw);
vw = meshUpdateAll(vw);
vw = viewSet(vw, 'current mesh n', 1);
figH(fig_counter)=figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
figname=fullfile(subDir,'Images','lh_compare_handDrawnV1V2V3_withECCmap.jpg');
saveas(figH(fig_counter),figname,'jpg');

vw = viewSet(vw, 'current mesh n', 2);
figH(fig_counter)=figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
figname=fullfile(subDir,'Images','rh_compare_handDrawnV1V2V3_withECCmap.jpg');
saveas(figH(fig_counter),figname,'jpg');
