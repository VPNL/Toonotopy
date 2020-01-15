% toon workflow

% set session information  
baseDir='/Users/kalanit/Courses/psych224/data/'
expt    = 'TestSubject';
session  ='TestSubject_190725';
paramPath =fullfile('Stimuli','8bars_params.mat');
imgPath = fullfile('Stimuli','8bars_images.mat');

%% initialize session
toon_init(baseDir, expt, session);

% Quality check initialization
% cd to subject's directory to initialize mrVista
subjectDir=fullfile(baseDir,expt,session);
cd(subjectDir)
mrVista
% Using GUI: load mean map & check that functionals match Inplane anatomicals
% Best visualization: threshold mean map at around 500-1000 to see anatomical underlay

%% Align inplane anatomy to volume anatomy
rxAlign;

%% motion correct session
% TestSubject has been initialized and aligned; Start here
toon_motionCorrect(baseDir, expt, session);

%% install segmentation, transform tSeries to Gray, and average time series
toon_2gray(baseDir, expt, session)

%% run CSS pRF model
toon_prfRun(baseDir, expt, session, paramPath, imgPath)
