% toon_plotResults
% This script loads a set of ROIs and then makes several plots
% 1) plots them on top of the phase, eccentricity and size maps of each
% hemisphere
% 2) plots pRF centers for each ROI in a separate fig
% 3) plots pRF coverage for each ROI in a separate fig
% 4) plots pRF size vs ecc of all ROIs (each hemisphere a separate figure)
% 
% To run this script you need to specify
% 1) the subject's directory (subDir) 
% 2) pRF model
% 3) ROIs
% 4) meshes and meshview settings
%
% Figures are saved under  SubDir/Images/pRFplots
% 
% The script uses a hiddenGray view which means that you will not see the
% mrVista GUI when you run this script; the hiddenGray is useful for
% scripting
%
% KGS 2/20

%% set session parameters
% set path
subDir='/share/kalanit/biac2/kgs/projects/Toonotopy/data/TestSubject2'; %/TestSubject_190725/';
cd(subDir);

% set data type and scan
dt =  'Averages'; scan=1;

% set pRF model
prfModel =  'retModel-cssFit-fFit.mat';
ROIs ={};
%{ 
set ROIs 
ROIs={
'ToonRet_CSS_lh_V1_kgs.mat',
'ToonRet_CSS_lh_V2v_kgs.mat',
'ToonRet_CSS_lh_V2d_kgs.mat',
'ToonRet_CSS_lh_V3v_kgs.mat',
'ToonRet_CSS_lh_V3d_kgs.mat',
'ToonRet_CSS_rh_V1_kgs.mat',
'ToonRet_CSS_rh_V2v_kgs.mat',
'ToonRet_CSS_rh_V2d_kgs.mat',
'ToonRet_CSS_rh_V3v_kgs.mat'
'ToonRet_CSS_rh_V3d_kgs.mat'};
%}
ROIs = {'toon_f_lh_V1.mat', ...
	'toon_f_lh_V2d.mat', 'toon_f_lh_V2v.mat', 'toon_f_lh_V3d.mat'...
	'toon_f_lh_V3v.mat','toonRet_CSS_LO1_lh_mr','toonRet_CSS_LO2_rh_mr', 'toonRet_CSS_TO1_rh_mr','toonRet_CSS_TO2_rh_mr',...
    'toon_f_rh_V1.mat', 'toon_f_rh_V2v.mat', 'toon_f_rh_V2d.mat'...
	'toon_f_rh_V3v.mat', 'toon_f_rh_V3d.mat',  'toonRet_CSS_LO1_rh_mr','toonRet_CSS_LO2_rh_mr','toonRet_CSS_TO1_rh_mr'...
    'toonRet_CSS_TO2_rh_mr'};

% set cothresh for thresholding pRF model
cothresh=0.1; % 10% variance explained

% create dir for images if this directory does not exist
if ~exist('./Images/pRFplots/','dir')
        !mkdir ./Images/pRFplots
end

fig_counter=1;

%% init hidden Gray with ret model, ROIs, and cothresh
vw=toon_initRM(prfModel, ROIs,cothresh, dt, scan);


%% load meshes and plot phase, ecc, and size maps

% define meshes
meshlh = fullfile('3DAnatomy', 'lh_inflated_200_1.mat');
meshrh = fullfile('3DAnatomy', 'rh_inflated_200_1.mat');

% define a mesh angle setting for each of your meshes in
% Gray->mesh view settings -> store mesh settings
% if you do not have such a setting, comment the next 2 lines
meshAngleSettinglh= 'lh_lateral';
meshAngleSettingrh= 'rh_lateral';

% plot maps & save figures
if notDefined('meshAngleSettinglh') || notDefined('meshAngleSettingrh')     
    toon_plotMaps(subDir,vw,meshlh, meshrh);
else    
    toon_plotMaps(subDir,vw,meshlh, meshrh,meshAngleSettinglh,meshAngleSettingrh);
end

%% plot pRF centers for all ROIs; 
cothresh=0.1; %cothresh:        threshold by variance explained in model
nrows=2;
ncols=length(ROIs)/nrows;
vw=toon_plotCenters(vw,cothresh,nrows,ncols);

%% plot pRF coverage for all ROIs; 
%
% I am setting plotting options for the coverage maps
% You can change then and additional plotting options, for details see rmPlotCoverage.m
method='sum'; %method: of computing coverage. I usually use 'sum' or 'max'
cothresh=0.1; %cothresh:        threshold by variance explained in model
nboot=100;    %  number of bootstraps; default is 50
nrows=2;
ncols=length(ROIs)/nrows;
prf_size=1 %     0 = plot pRF center; 1 = use pRF size
vw=toon_plotCoverage(vw, method, cothresh, prf_size, nboot,nrows,ncols);

%% plot pRF eccentricity vs size

lhROIs=[1:5]; lh_pRF_DATA = plot_MultiEccSigma(vw,lhROIs);
figname=fullfile(subDir,'Images', 'pRFplots', ['lh_SizeVsEcc.jpg']); saveas(gcf,figname,'jpg');

rhROIs=[6:10]; rh_pRF_DATA = plot_MultiEccSigma(vw,rhROIs);
figname=fullfile(subDir,'Images', 'pRFplots',  ['rh_SizeVsEcc.jpg']); saveas(gcf,figname,'jpg');
