function stimulus = makeRetinotopyStimulus_bars(params)
% makeRetinotopyStimulus - make various retinotopy stimuli
%
% stimulus = makeRetinotopyStimulus_bars(params)
%
% Matlab code to generate various retinotopy stimuli
% Generates one full cycle, as well as the sequence for the entire scan.
%
% 99.09.15 RFD: I fixed the sequence generation algorithm so that
%   timing is now frame-accurate.  The algorithm now keeps track
%   of timing error that accumulates due to rounding to the nearest
%   frame and corrects for that error when it gets to be more than
%   half a frame.
%   The algorithm also randomely reverses the drift direction, rather
%   than reversing every half-an image duration.
% 2005.06.15 SOD: changed for OSX - stimulus presentation will now be
%                 time-based rather than frame based. Because of bugs
%                 with framerate estimations.
%
% April, 2010, JW: This code is getting long. Very hard to read / edit...

avail_imgs = 63; 
% various time measurements:
duration.stimframe          = 1./params.temporal.frequency./(params.temporal.motionSteps);
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

%% load matrix or make it
if ~isempty(params.loadMatrix),
    % we should really put some checks that the matrix loaded is
    % appropriate etc.
    load(params.loadMatrix);
    halfNumImages = params.numImages./2;
    fprintf('[%s]:loading images from %s.\n',mfilename,params.loadMatrix);
    %    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
    
   
    bk = params.display.backColorIndex;
    halfNumImages   = params.numImages./2;
    numMotSteps     = params.temporal.motionSteps;
else
    outerRad        = params.radius;
    %innerRad        = params.innerRad;
    ringWidth       = params.ringWidth;
    
    halfNumImages   = params.numImages./2;
    numMotSteps     = params.temporal.motionSteps;
    numSubRings     = params.numSubRings;
    
    %%% Set check colormap indices %%%
    %bk = findName(params.display.reservedColor,'background');
    %minCmapVal = max([params.display.reservedColor(:).fbVal])+1;
    %maxCmapVal = params.display.numColors-1;
     
    bk = params.display.backColorIndex;
    
    minCmapVal = min([params.display.stimRgbRange]);
    maxCmapVal = max([params.display.stimRgbRange]);
    
    if isfield(params, 'contrast')
        c = params.contrast;
        bg = bk; %(minCmapVal + maxCmapVal)/2;
        minCmapVal = round((1-c) * bg);
        maxCmapVal = round((1+c) * bg);
    end   
    
    %%% Initialize image template %%%
    m = round(2 * angle2pix(params.display, outerRad));
    n = round(2 * angle2pix(params.display, outerRad));
    
    % should really do something more intelligent, like outerRad-fix
    switch(lower(params.display.fixType))
        case 'left disk',
            [x,y]=meshgrid(linspace( 0,outerRad*2,n),linspace(outerRad,-outerRad,m));
            outerRad = outerRad.*2;
        case 'right disk',
            [x,y]=meshgrid(linspace(-outerRad*2,0,n),linspace(outerRad,-outerRad,m));
            outerRad = outerRad.*2;
        otherwise,
            [x,y]=meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));
    end;
    
    % here we crop the image if it is larger than the screen
    % seems that you have to have a square matrix, bug either in my or
    % psychtoolbox' code - so we make it square
    if m>params.display.numPixels(2),
        start  = round((m-params.display.numPixels(2))/2);
        len    = params.display.numPixels(2);
        y = y(start+1:start+len, start+1:start+len);
        x = x(start+1:start+len, start+1:start+len);
        m = len;
        n = len;
    end;
    fprintf('[%s]:size stimulus: %dx%d pixels.\n',mfilename,n,m);
    
    % r = eccentricity; 
    r = sqrt (x.^2  + y.^2);
        
    % loop over different orientations and make checkerboard
    % first define which orientations
    orientations = (0:45:360)./360*(2*pi); % degrees -> rad
    orientations = orientations([1 6 3 8 5 2 7 4]);
    remake_xy    = zeros(1,params.numImages)-1;
    remake_xy(1:length(remake_xy)/length(orientations):length(remake_xy)) = orientations;
    original_x   = x;
    original_y   = y;
    % step size of the bar
    step_nx      = duration.cycle.seconds./params.tr/8;
    step_x       = (2*outerRad) ./ step_nx;
    step_startx  = (step_nx-1)./2.*-step_x - (ringWidth./2);
    %[0:step_nx-1].*step_x+step_startx+ringWidth./2
    fprintf('[%s]:stepsize: %f degrees.\n',mfilename,step_x);
    
    % if we create colored bars we want to make the edges soft.
    softmask = ones(m);
    
    % Loop that creates the final images
    fprintf('[%s]:Creating %d images:',mfilename,halfNumImages);
    images=zeros(m,n,3,halfNumImages*params.temporal.motionSteps,'uint8');
    
    for imgNum=1:halfNumImages
        
        if remake_xy(imgNum) >=0,
            x = original_x .* cos(remake_xy(imgNum)) - original_y .* sin(remake_xy(imgNum));
            y = original_x .* sin(remake_xy(imgNum)) + original_y .* cos(remake_xy(imgNum));
            % Calculate checkerboard.
            % Wedges alternating between -1 and 1 within stimulus window.
            % The computational contortions are to avoid sign=0 for sin zero-crossings
            switch params.experiment
                case {'8 bars','8 bars with blanks','8 bars (slow)', '8 bars with blanks, fixed check size', '8 bars with blanks thin', '8 bars with blanks thick'}
                    wedges    = sign(round((cos((x+step_startx)*numSubRings*(2*pi/ringWidth)))./2+.5).*2-1);
                    posWedges = find(wedges== 1);
                    negWedges = find(wedges==-1);
                    rings     = zeros(size(wedges));
                    
                    checks    = zeros(size(rings,1),size(rings,2),params.temporal.motionSteps);
                    
                otherwise,
                    fprintf('[%s]:unknown experiment: %s.\n',mfilename,params.experiment);
                    return;
            end;
            
            % reset starting point
            loX = step_startx - step_x;
        end;
       
        potential_imgs = randperm(avail_imgs,numMotSteps);
        for ii=1:numMotSteps,
            
            % load image
            % update the image to be the same size
            filename = ['pic' mat2str(potential_imgs(ii)) '.jpg']; 
            newfile = imread(filename);
            cropped_img = newfile(1:m, 1:n,:); 
            
            toons(:,:,:,ii) = cropped_img; 

        end;
        
        switch params.type;
            case 'bar'
                loX   = loX + step_x;
                hiX   = loX + ringWidth;
            otherwise,
                error('Unknown stimulus type!');
                
        end
        % This isn't as bad as it looks
        % Can fiddle with this to clip the edges of an expanding ring - want the ring to completely
        % disappear from view before it re-appears again in the middle.
        
        % Can we do this just be removing the second | from the window
        % expression? so...        
        window = ( (x>=loX & x<=hiX) & r<outerRad);

        % yet another loop to be able to move the checks...
        switch params.experiment
            case {'8 bars','8 bars with blanks','8 bars (slow)', '8 bars with blanks, fixed check size', '8 bars with blanks thin', '8 bars with blanks thick'}
                
                tmpvar = zeros(m,n);
                tmpvar(window) = 1;
                tmpvar = repmat(tmpvar, [1 1 3]); 
                tmpvar = repmat(tmpvar,[1 1 1 numMotSteps]);
                window = tmpvar == 1;
                img         = bk*ones(size(toons));
                img(window) = toons(window);
                images(:,:,:,(imgNum-1).*numMotSteps+1:imgNum.*numMotSteps) = uint8(img); %#ok<*BDSCA>
            
        end
            
        fprintf('.');drawnow;
    end
    fprintf('Done.\n');
end;



%% Now we compile the actual sequence
% make stimulus sequence, make half and then add the rest as a flipped
% version of the first half
sequence = ...
    ones(round(duration.cycle.stimframes./2./halfNumImages),1)*...
    (1:params.temporal.motionSteps:params.temporal.motionSteps*halfNumImages);
sequence = sequence(:);
if params.insertBlanks.do,
    if params.insertBlanks.phaseLock, % keep 1 cycle and repeat
        completeCycle = sequence;
        sequence = [completeCycle;...
            completeCycle(1:round(end/2));...
            completeCycle;...
            completeCycle(1:round(end/2));...
            completeCycle;...
            completeCycle(1:round(end/2));...
            completeCycle;...
            completeCycle(1:round(end/2))];
    else
        sequence = repmat(sequence,params.ncycles,1);
    end;
else
    sequence = repmat(sequence,params.ncycles,1);
end;

% we make only half so we need to flip the rest
sep   = round(linspace(1,length(sequence)+1,5));
rev = [];
for n=1:4,
    rev = [rev; flipud(sequence(sep(n):sep(n+1)-1))]; %#ok<*AGROW>
end;
sequence = [sequence; rev];

%motion frames within wedges/rings - lowpass
nn=30; % this should be a less random choice, ie in seconds
motionSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
motionSeq = motionSeq(:)-0.5;
motionSeq = motionSeq(1:length(sequence));
motionSeq = cumsum(sign(motionSeq));

% wrap
above = find(motionSeq>params.temporal.motionSteps);
while ~isempty(above),
    motionSeq(above)=motionSeq(above)-params.temporal.motionSteps;
    above = find(motionSeq>params.temporal.motionSteps);
end;
below = find(motionSeq<1);
while ~isempty(below),
    motionSeq(below)=motionSeq(below)+params.temporal.motionSteps;
    below = find(motionSeq<1);
end;
sequence=sequence+motionSeq-1;

%% fixation dot sequence
% change on the fastest every 6 seconds
minsec = round(6./duration.stimframe);
fixSeq = ones(minsec,1)*round(rand(1,ceil(length(sequence)/minsec)));
fixSeq = fixSeq(:)+1;
% check that the sequence of fixations is at least as long as the sequence
% of stimuli. if not, pad the the fixation sequence.
if length(fixSeq) < length(sequence), fixSeq(end+1:length(sequence)) = 0; end
% if the fixation sequence is shorter, truncate it
fixSeq = fixSeq(1:length(sequence));
% force binary
fixSeq(fixSeq>2)=2;
fixSeq(fixSeq<1)=1;

%% direction
if params.seqDirection~=0
    sequence = flipud(sequence);
end

%% insert blanks (always off for 12 seconds)
blankImage = uint8(ones(size(images,1),size(images,2),3).*bk);

if params.insertBlanks.do,
    seq2      = zeros(size(sequence));
    oneCycle  = length(seq2)/params.insertBlanks.freq;
    offTime   = ceil(12./params.tr).*params.tr; % make sure it's a multiple of the tr
    offPeriod = ceil(offTime./duration.stimframe);
    if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
        offPeriod = oneCycle / 4;
    end
    onPeriod  = oneCycle-offPeriod;
    seq2      = repmat([zeros(onPeriod,1); ones(offPeriod,1)],params.insertBlanks.freq,1);
    blankInd  = size(images,4)+1;
    if isempty(params.loadMatrix),
        sequence(seq2==1) = blankInd;
        images(:,:,:,blankInd)   = blankImage;
    end;
    clear seq2;
    fprintf('[%s]:Stimulus on for %.1f and off for %.1f seconds.',...
        mfilename,onPeriod*duration.stimframe,offPeriod*duration.stimframe);
end;

%% Add prescsan
% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
numPrescanFrames = duration.prescan.stimframes;
preScanSequence = zeros(numPrescanFrames, 1);

if params.numCycles == 1
    % make prescan all blanks
    preScanSequence = preScanSequence + blankInd;
else
    % make prescan a copy of the end of the scan
    preScanSequence = sequence(length(sequence)+1-numPrescanFrames:end);
end

sequence = [preScanSequence; sequence];
timing   = (0:length(sequence)-1)'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];

%% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

%% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

