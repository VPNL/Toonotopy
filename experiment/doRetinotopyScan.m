function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 11.09.15 JW added a check for modality. If modality is ECoG, then call
%           ShowScanStimulus with the argument timeFromT0 == false. See
%           ShowScanStimulus for details.

% defaults
if ~exist('params', 'var'), error('No parameters specified!'); end

% make/load stimulus
stimulus = retLoadStimulus(params);

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);

try
    % check for OpenGL
    AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    Screen('Preference','SkipSyncTests', 1);
    
    % Open the screen
    params.display                = openScreen(params.display);
    params.display.devices        = params.devices;
 
    % to allow blending
    Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Store the images in textures
    stimulus = createTextures(params.display,stimulus);

    % If necessary, flip the screen LR or UD  to account for mirrors
    % We now do a single screen flip before the experiment starts (instead
    % of flipping each image). This ensures that everything, including
    % fixation, stimulus, countdown text, etc, all get flipped.
    retScreenReverse(params, stimulus);
    
    % If we are doing ECoG, then add photodiode flash to every other frame
    % of stimulus. This can be used later for syncing stimulus to electrode
    % outputs.
    stimulus = retECOGtrigger(params, stimulus);
    
    if strcmp(params.display.fixType,'dot')
        params.display.windowPtr = 10;
        shipG = imread('/Users/vpnl/exp/vistadisp-kids/Images/green_ship_small30.jpeg');
        shipR = imread('/Users/vpnl/exp/vistadisp-kids/Images/red_ship_small30.jpeg');
        intro = imread('/Users/vpnl/exp/vistadisp-kids/Images/blastoff.png');
        endSlide = imread('/Users/vpnl/exp/vistadisp-kids/Images/landing.png');
                 [params.display.origup,fs]= audioread('/Users/vpnl/exp/vistadisp-kids/Sounds/up.mp3');
                 %[down,fs]= audioread('/Users/KGS/Experiments/vistadisp-master/Sounds/down.mp3');
                 params.display.up= audioplayer(params.display.origup,90000);
                 %params.display.down= audioplayer(down,fs);
        params.display.ship(1) = Screen('MakeTexture', params.display.windowPtr, shipG);
        params.display.ship(2) = Screen('MakeTexture', params.display.windowPtr, shipR);
        params.display.Etime=5;
        params.display.time=GetSecs;
        params.display.images(1) = Screen('MakeTexture', params.display.windowPtr, intro);
        params.display.images(2) = Screen('MakeTexture', params.display.windowPtr, endSlide);
        Screen('DrawTexture',params.display.windowPtr, params.display.images(1));
        Screen('Flip',params.display.windowPtr)
        play(params.display.up)
        pause(5)
    end
    
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        retResetColorMap(params);
        
        % wait for go signal
        onlyWaitKb = false;
        pressKey2Begin(params.display, onlyWaitKb, [], [], params.triggerKey);
        
        % ######### Eyelink Commands ######
        
        if isfield(params,{'eyelink'}) == 1;
            if params.eyelink == 1;
                
                % Trial ID will be 1
                Eyelink('Message', 'TRIALID %d', 1);
                % This supplies the title at the bottom of the eyetracker display
                Eyelink('command', 'record_status_message "Retinotopy"');
                % Before recording, we place reference graphics on the host display
                
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.05);
                Eyelink('StartRecording', 1, 1, 1, 1);
                % record a few samples before we actually start displaying
                % otherwise you may lose a few msec of data
                WaitSecs(0.1); %NOTE: this wait period and the one just above are not accounted for in timing below which was written before this line was added - real code should account for this 150ms lag
                % mark zero-plot time in data file
                Eyelink('Message', 'image_start');
                Eyelink('Message','!V FIXPOINT 255 255 255 0 0 0 %d %d %d 4',center(1),center(2),10);
            end
        end
        % If we are doing eCOG, then signal to photodiode that expt is
        % starting by giving a patterned flash
        retECOGdiode(params);
        
        % countdown + get start time (time0)
        [time0] = countDown(params.display,params.countdown,params.startScan, params.trigger);
        time0   = time0 + params.startScan; % we know we should be behind by that amount
        
        
        % go
        if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
            timeFromT0 = false;
        else timeFromT0 = true;
        end
        [response, timing, quitProg] = showScanStimulus(params.display,stimulus,time0, timeFromT0); %#ok<ASGLU>
        
        % reset priority
        Priority(0);
        
        % get performance
        %[pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        %fprintf('[%s]: percent correct: %.1f %%, reaction time: %.1f secs',mfilename,pc,rc);
        %fprintf(1, '[%s]: percent correct: %.1f %%, reaction time: %.1f secs',pc,rc);
        score = scoreRet(stimulus.fixSeq, response.keyCode);
        fprintf('The percent correct is: %.1f %%\n',score);

        
        
        
        if strcmp(params.display.fixType,'dot')
            Screen('DrawTexture',params.display.windowPtr, params.display.images(2));
            %score = round(score)
            %scoreText = ['You got a score of ' num2str(score)];
            %Screen('DrawText', params.display.windowPtr, scoreText ,800 ,800 ,white,[]);
            %DrawText(params.display.windowPtr, scoreText,'center','center',white);
            %str=['You got a score of ' num2str(score)];
            %Screen('TextSize', params.display.windowPtr ,60);
            %Screen('DrawText', params.display.windowPtr, str, 100, 0, [255, 255, 255, 255]);
            
            Screen('Flip', params.display.windowPtr)         
            pause(5)
        end
        
        
        % save
        if params.savestimparams,
            filename = ['~/Desktop/' datestr(now,30) '.mat'];
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.',mfilename,filename);
        end;
        
        % don't keep going if quit signal is given
        if quitProg, break; end;
        
    end;
    
   
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);
    
catch ME
    % clean up if error occurred
    Screen('CloseAll'); setGamma(0); Priority(0); ShowCursor;
    warning(ME.identifier, ME.message);
end;


return;








