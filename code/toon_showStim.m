function toon_showStim(path,stimFile)
%
% toon_showStim(path,stimFile)
% Shows the sequence of stimuli in the Wide Field Toonotopy experiment 
% designed by DF in 2018
% 
% Actual stimuli are in color and presented at a rate of 8Hz (2 secs/step)
%
% Inputs
% path      full path to stimFile
% stimFile  name of stim_file
%
% KGS & DF 2020

if notDefined('path')
    if isunix
     path=fullfile('/biac2','kgs','projects', 'lateralPRFs', 'data', 'toonRet', 'aj092118_ret' , 'Stimuli');
    else
       fprintf('Error: need to specify path..\n');
    end
    
end
if notDefined('stimFile')
    stimFile='8bars_images.mat';
end

paramFile = '8bars_params.mat';

%% load stimuli and params
file2load=fullfile(path,stimFile);
load(file2load);

load(fullfile(path,paramFile));

%% visualize stimuli
timing = stimulus.seqtiming;
rate = timing(2)-timing(1); %presentation rate

presentationOrder = stimulus.seq;
frames = length(presentationOrder); %num frames

[rows cols imgNum]=size(images);
figure('Color', [ 1 1 1]);
for frame=1:frames
    toShow = presentationOrder(frame);
    imshow (images(:,:,toShow)); pause (rate);
end
