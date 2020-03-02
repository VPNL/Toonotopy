% toon_testsubjec22
% 
% % set session information  

baseDir='/biac2/kgs/projects/Toonotopy/'
expt    = 'data';
session  ='TestSubject22';
paramPath =fullfile('Stimuli','8bars_params.mat');
imgPath = fullfile('Stimuli','8bars_images.mat');

paramPath =fullfile('Stimuli','8bars_params.mat');
imgPath = fullfile('Stimuli','8bars_images.mat');


% Quality check initialization
% cd to subject's directory to initialize mrVista
subjectDir=fullfile(baseDir,expt,session);
cd(subjectDir)

%% run CSS pRF model


toon_prfRun(baseDir, expt, session, paramPath, imgPath)
