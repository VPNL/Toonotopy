function toon_plotMaps(subDir,vw,meshlh, meshrh,meshAngleSettinglh,meshAngleSettingrh)

subDir='/share/kalanit/biac2/kgs/projects/Toonotopy/data/TestSubject2/';

%% load & set meshes

% default meshes
if notDefined('meshlh')
    meshlh = fullfile('3DAnatomy', 'lh_inflated_200_1.mat');
end
if notDefined('meshrh')    
    meshrh = fullfile('3DAnatomy', 'rh_inflated_200_1.mat');
end

% create dir for images if this directory does not exist
if ~exist('./Images/pRFplots/','dir')
        !mkdir ./Images/pRFplots
end

% 
% % define a mesh angle setting for each of your meshes in
% % Gray->mesh view settings -> store mesh settings
% % if you do not have such a setting, comment the next 2 lines
meshAngleSettinglh='lh_lateral';
 meshAngleSettingrh='rh_lateral';

% define lights
L.ambient=[.4 .4 .4];
L.diffuse=[.5 .5 .5];

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



%% Plot phase maps for left mesh & make figure
vw = viewSet(vw, 'display mode', 'ph');
vw = setDisplayMode(vw, 'ph');
vw = viewSet(vw, 'current mesh n', 1);
%vw=cmapSetLumColorPhaseMap(vw, 'right'); %Use this for Matlab2019
 vw=cmapSetLumColorPhaseMap(vw, 'left'); %Use this for 2014


vw=refreshScreen(vw); vw = meshColorOverlay(vw);

fig_counter=1;
figH(fig_counter)=figure('Color', 'w','name','LH phase map'); 
img{1}=imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
if exist('meshAngleSettinglh','var')
    figname=fullfile(subDir,'Images', 'pRFplots' ,[meshAngleSettinglh '_lh_Phasemap_css_fFit.jpg']);
else
    figname=fullfile(subDir,'Images', 'pRFplots' ,[lh_Phasemap_css_fFit.jpg'])
end
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;
    
% update rightt mesh with phase map & make figure
vw = viewSet(vw, 'current mesh n', 2);
 vw=cmapSetLumColorPhaseMap(vw, 'right'); %Use this for Matlab 2014
%vw=cmapSetLumColorPhaseMap(vw, 'left'); %Use this for Matlab 2019

vw=refreshScreen(vw); vw = meshColorOverlay(vw);

figH(fig_counter)=figure('Color', 'w','name','RH phase map');
img{4}=imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
if exist('meshAngleSettingrh','var')
    figname=fullfile(subDir,'Images', 'pRFplots' ,[meshAngleSettinglh '_rh_Phasemap_css_fFit.jpg']);
else
    figname=fullfile(subDir,'Images', 'pRFplots' ,[rh_Phasemap_css_fFit.jpg'])
end
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;

%% Plot the eccentricity maps
vw = viewSet(vw, 'display mode', 'map');
vw = setDisplayMode(vw, 'map');
vw.ui.ampMode=setColormap(vw.ui.ampMode,'hsvTbCmap');vw=refreshScreen(vw); vw = meshColorOverlay(vw);
vw = meshUpdateAll(vw);

% LH
vw = viewSet(vw, 'current mesh n', 1);
figH(fig_counter)=figure('Color', 'w', 'name','LH eccentricity map');
% take snapshot of mesh
img{2}=imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
if exist('meshAngleSettinglh','var')
    figname=fullfile(subDir,'Images', 'pRFplots' ,[meshAngleSettinglh '_lh_ECCmap_css_fFit.jpg']);
else
    figname=fullfile(subDir,'Images', 'pRFplots' ,['lh_Phasemap_ECCmap_css_fFit.jpg'])
end
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;

% RH
vw = viewSet(vw, 'current mesh n', 2);
figH(fig_counter)=figure('Color', 'w','name' ,'RH eccentricity map');
img{5}=imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
if exist('meshAngleSettinglh','var')
    figname=fullfile(subDir,'Images', 'pRFplots' ,[meshAngleSettinglh '_rh_ECCmap_css_fFit.jpg']);
else
    figname=fullfile(subDir,'Images', 'pRFplots' ,['rh_Phasemap_ECCmap_css_fFit.jpg'])
end
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;

%%  Plot the size Map
vw = viewSet(vw, 'display mode', 'amp');
vw = setDisplayMode(vw, 'amp');
vw.ui.ampMode=setColormap(vw.ui.ampMode,'hsvTbCmap');
% can change here the clip mode if needed now it's set to 1/2 of the
% stimulus size
vw.ui.ampMode.clipMode =[ 0 0.5*vw.rm.retinotopyParams.stim.stimSize]; 
vw=refreshScreen(vw); vw = meshColorOverlay(vw);
vw = meshUpdateAll(vw);

%LH
vw = viewSet(vw, 'current mesh n', 1);
figH(fig_counter)=figure('Color', 'w', 'name', 'LH size map');
img{3}=imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
if exist('meshAngleSettinglh','var')
    figname=fullfile(subDir,'Images', 'pRFplots' ,[meshAngleSettinglh '_lh_sizeMap_css_fFit.jpg']);
else
    figname=fullfile(subDir,'Images', 'pRFplots' ,['lh_Phasemap_sizeMap_css_fFit.jpg'])
end
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;

vw = viewSet(vw, 'current mesh n', 2);
figH(fig_counter)=figure('Color', 'w', 'name','RH size map');
img{6}=imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 
if exist('meshAngleSettinglh','var')
    figname=fullfile(subDir,'Images', 'pRFplots' ,[meshAngleSettinglh '_rh_sizeMap_css_fFit.jpg']);
else
    figname=fullfile(subDir,'Images', 'pRFplots' ,['rh_Phasemap_sizeMap_css_fFit.jpg'])
end
saveas(figH(fig_counter),figname,'jpg');
fig_counter=fig_counter+1;

%% make a nice figure with all the maps
figH(fig_counter)=figure('name','Retintopic Maps','color','w','units','norm','Position', [ 0 0 .8 .8]);
nrows=2; ncols=3;
for i=1:nrows*ncols
    subplot_tight(nrows, ncols,i);
    imagesc(img{i}.CData); axis('image'); axis('off')
end
figname=fullfile(subDir,'Images', 'pRFplots', 'Allmaps.jpg'); 
saveas(gcf,figname,'jpg');
fig_counter=fig_counter+1;


% close all meshes
vw = meshDelete(vw, inf); 