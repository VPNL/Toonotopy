function roiPrep(baseDir, expt, sessions, hems, ROIs, colors, combo, currPre, currPost, comment, newPre, backupPre)
%
% This function will iterate through ROIs drawn on the mesh,
% 1) remove overlap from ROIs in ascending heirarchical order
% 2) combine dorsal and ventral ROIs in retinotopy
% 3) rename ROIs in lab convention, adding nice alternating colors
% 4) include a comments field that will indicate who drew this ROI, and how.
%
% Default input values:
% baseDir  '/biac2/kgs/projects/'
% expt     '/Toonotopy/data/'
% session   session name, e.g. {'TestSubject/TestSubject_190725'}
% hems     {'rh', 'lh'};
% ROIs     {'V1', 'V2v', 'V2d', 'V3v', 'V3d'} % important - these should be in 'cleaning' order (e.g. voxels will be deleted in ROI #2 if the overlap with ROI #1, etc
% colors   {'k', 'b', 'b', 'g', 'g', 'y', 'm'} 
% combo    1 % toggle on/off - combining dorsal/ventral ROIs in retinotopy. will skip if irrelevant.
% currPre  % prefix to use for loading ROIs (if you've already named them as 'toonRet_f_', etc); if they are just 'hem_ROI', leave this blank
% currPost % (for Longi) to use for loading ROIs (if you've already named them as '03_1', etc); leave blank if no suffix
% comment  % struct for comment field information - session & anat will be
% auto-filled, can add comment.name and comment.expt (i.e. 
% comment.name = 'Dawn Finzi';
% comment.expt = 'toonotopy pRF mapping';
%
% Optional inputs:
% newPre   % preFix to add to the ROI name - usualling expt_f/a_. (if you've already named them as 'toonRet_f_', etc, leave this blank
% backupPre % if you named ROIs with multiple prefixes
%
% DF 2020 (adapted from code by JG & SP)

%% Inputs/Default params
if notDefined('baseDir')
    if isunix
        baseDir = fullfile('/share', 'kalanit', 'biac2', 'kgs', 'projects');
    else
        fprintf(1,'Error. You need to define base directory \n');
        return
    end
end
if notDefined('expt')
   expt = '/Toonotopy/data/';
end
if notDefined('sessions')    
   sessions = {'TestSubject/TestSubject_190725'};
end
if notDefined('hems')
   hems = {'rh', 'lh'};
end
if notDefined('ROIs')
   ROIs = {'V1', 'V2v', 'V2d', 'V3v', 'V3d'};
end
if notDefined('colors')
   colors = {'k', 'b', 'b', 'g', 'g', 'y', 'm'}; 
end
if notDefined('combo')
    combo = 1;
end
if notDefined('currPre')
    currPre = '';
end
if notDefined('currPost')
    currPost = '';
end
if notDefined('comment.name')
    comment.name = '';
end
if notDefined('comment.expt')
    comment.expt = expt;
end

%% Checks
% Check and validate inputs and path to vistasoft

if isempty(which('mrVista'))
    vista_path = 'https://github.com/vistalab/vistasoft';
    error(['Add vistasoft to your matlab path: ', vista_path]);
end

% standardize and validate session argument
exptDir = fullfile(baseDir, expt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start processing ROIs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s = 1:length(sessions)
    session = sessions{s}; 
    
    cd(fullfile(exptDir, session));
    outStr = []; % aggregate output information, display at end (since mrV output will disrupt readability)

    cd 3DAnatomy
    %%% finish comment formatting
    comment.sess = fullfile(exptDir, session);
    comment.anat = pwd;
    cd(fullfile(exptDir, session));

    comment.txt = sprintf('Session: %s\nExperiment: %s\nDrawn by: %s\nAnatomy: %s\n', comment.sess, comment.expt, comment.name, comment.anat);

    for h = 1:length(hems)

        % input and output ROI names for this hemisphere
        inROIs = strcat(currPre, hems{h}, '_', ROIs, currPost);
        
        if notDefined('newPre') %rename if needed
            outROIs = inROIs;
        else 
            outROIs = strcat(newPre, hems{h}, '_', ROIs, currPost);
        end
        
        outCols = colors; % reset this in each hem iteration

        % skip ROIs that don't exist for this subject - first pass
        toSkip = [];
        for r = 1:length(ROIs)
            if ~exist(fullfile('3DAnatomy', 'ROIs', [inROIs{r}, '.mat']))
                toSkip(end+1) = r;
            end
        end
        inROIs(toSkip) = [];
        
        % backup pass
        toSkip = [];
        if isempty(inROIs)
            inROIs = strcat(backupPre, hems{h}, '_', ROIs);
            for r = 1:length(ROIs)
                if ~exist(fullfile('3DAnatomy', 'ROIs', [inROIs{r}, '.mat']))
                    toSkip(end+1) = r;
                end
            end
        end
        inROIs(toSkip) = [];
        outROIs(toSkip) = [];
        outCols(toSkip) = [];

        % open a view and load first ROI to start
        vw = initHiddenGray('Averages');
        % load ROI
        vw = loadROI(vw, inROIs{1});
        % save ROI with new name, comment field
        vw.ROIs(end).name = outROIs{1};
        vw.ROIs(end).color = outCols{1};
        vw.ROIs(end).comment = comment.txt;
        % then, save it in shared folder
        [vw, ~, ~] = saveROI(vw, 'selected', 0, 1); % 1 = forceSave
        outStr = sprintf('%sUpdated %s to %s...\n', outStr, inROIs{1}, outROIs{1});

        % cleaning loop, which will remove overlap with previous ROIs
        for r = 2:length(inROIs)
            vw = loadROI(vw, inROIs{r});

            % current ROI
            roiA = vw.ROIs(end).name;

            % all prior ROIs
            roiB = {vw.ROIs(1:end-1).name};

            % now clean and rename, adding our comment text
            vw = combineROIs(vw, [roiA, roiB], 'AnotB', outROIs{r}, outCols{r}, [comment.txt, 'Cleaned from original via roiPrep.m']);

            % now we want to delete the old uncleaned ROI from the view
            vw = deleteROI(vw, find(strcmp(roiA, {vw.ROIs.name}), 1)); % now sensitive to the fact that ROI name does not necessarily differ between clean & unclean

            % now save this cleaned and renamed ROI in shared
            [vw, ~, ~] = saveROI(vw, 'selected', 0, 1); % 1 = forceSave
            outStr = sprintf('%sCleaned and saved %s as %s...\n', outStr, inROIs{r}, outROIs{r});
        end

        if combo % combine ventral/dorsal ROIs for V2 & V3 - can be made more felxible with a pattern variable (e.g. 'v'/'d', 'A'/'B')
            for r = 2:length(outROIs)
                v = outROIs{r};
                if strcmp(v(end), 'v') % if this ROI has a ventral component, find its dorsal counterpart
                    try
                        d = outROIs{ismember(outROIs, [v(1:end-1), 'd'])};
                        % load these ROIs into the hiddenGray
                        vw = initHiddenGray('Averages');
                        vw = loadROI(vw, v);
                        vw = loadROI(vw, d);

                        % combine the ROIs
                        vw = combineROIs(vw, {vw.ROIs(1).name, vw.ROIs(2).name}, 'union', v(1:end-1), outCols{r}, [comment.txt, 'Combined d/v via roiPrep.m']);

                        % now save the combined ROI in shared dir
                        [vw, status, forceSave] = saveROI(vw, 'selected', 0, 1);
                        outStr = sprintf('%sSuccessfully made joint %s!\n', outStr, v(1:end-1));
                    catch
                        outStr = sprintf('%sCould not make joint %s!\n', outStr, v(1:end-1));
                    end
                end
            end
        end
        mrvCleanWorkspace;
    end

    fprintf(['\n\n\n', outStr]);
end