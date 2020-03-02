function vw = ROIanotb(vw, roiA, roiB, roiname, color, comments)
% create an ROI as the region in ROI A not included in ROIs B
% 
% vw = ROIanotb(vw, roiA, roiB, name, color, comments)
%  
% Example:
%   s = selectedVOLUME;
%   roiA = 'rV3v';
%   roiB =  {'rhV4', 'rV2v'};
%   roiname = 'RV3v-3and14deg';
%   color = 'g';
%   comments = sprintf('%s; drawn from pRFcompositeModel-3and14deg-Max', roiname);
% 
%   VOLUME{s} = ROIanotb(VOLUME{s}, roiA, roiB, roiname, color, comments);

% variable check
if notDefined('vw'),        vw  = getCurView; end
if notDefined('roiA'),      error('need a starting ROI'); end
if notDefined('roiname'),   roiname = roiA; end
if notDefined('color'),     color = 'b'; end
if notDefined('comments'), 
    comments = sprintf('%s; drawn from pRFcompositeModel-3and14deg-Max', roiname);
end

% combine the ROIs
vw = combineROIs(vw, [roiA roiB], 'AnotB', roiname, color, comments);

% delete old ROI
vw = deleteROI(vw, roiA);

% update the view struct
vw=refreshScreen(vw);

return