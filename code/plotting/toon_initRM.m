function vw=toon_initRM(prfModel, ROIs,cothresh, dt, scan)

% function toon_initRM(pRFmodel, ROIs, dt, scan)
% Initializes an hiddenGray view and loads pRF model and ROIs if available
% 
% Inputs
% pRFmodel   : name of pRF model to load
% cothresh   : variance explained threshold for retiniotopic model;
%             default: 0.1
% ROIs       : cell array of ROI names; if no ROIs willl just load pRF model
% dt         : data type; default:'Averages'
% scan       : scan number in dt; default: 1
%
% Outputs
% vw   : hiddenGray view strucutre with retinotopic model loaded
%
% example:
% 
% prfModel =  'retModel-cssFit-fFit.mat';
% ROIs={ 'ToonRet_CSS_lh_V1_kgs.mat','ToonRet_CSS_rh_V1_kgs.mat'}
%
%ROIs = {'toonRet_f_rh_V3v.mat', 'toonRet_f_rh_V3d.mat',...
%'toonRet_f_rh_V2v.mat', 'toonRet_f_rh_V2d.mat', 'toonRet_f_rh_V1.mat',...
%'toonRet_f_lh_V2.mat', 'toonRet_f_lh_V2d.mat', 'toonRet_f_lh_V2v.mat',...
%'toonRet_f_lh_V3v.mat', 'toonRet_f_lh_V3d.mat'}

% vw=toon_initRM(prfModel, ROIs);
%
% kgs 02/20
%

  

if notDefined('prfModel')
       display('Error no pRF model is defined');
   return
end

if notDefined('dt')
    dt='Averages';
end

if notDefined('scan')
    scan=1;
end

% set cothresh for thresholding pRF model
if notDefined('cothres')
    cothresh=0.1; 
end

%% initilize HiddenGray view
if notDefined('ROIs')
    vw = initHiddenGray(dt,scan);
else
    vw = initHiddenGray(dt,scan, ROIs);
end

% set ROI drawing methods as perimeter
vw.ui.roiDrawMethod = 'perimeter';
vw = refreshScreen(vw);

%% Load the PRF model and set the cothresh
vw = rmSelect(vw, 1, prfModel);
vw=rmLoadDefault(vw);
% set cothresh
vw = viewSet(vw, 'cothresh', cothresh);