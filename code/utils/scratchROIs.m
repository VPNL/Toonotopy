% Script for to construct non-overlapping ROIs 
%
% Script will 
%   1. Grab ROI from mesh 
%   2. Eliminate voxels that overlap with any existing ROI
%   3. Name and assign color to new ROI
%   4. Assign comments to ROI, including name of currently loaded
%           retinotopic model (if one exists)
%   5. Update mesh
%
%
% Notes: 
%   For gray view only.
%   A mesh must be open and selected.
%   An ROI should be drawn (and presumably filled) on the mesh
%   The ROI should not already be tranformed to VOLUME (e.g., with
%   meshROI2Volume), because the script does this.
%   Script does not save the ROI.

% name your new ROI
roiname = 'deletemeD' ;
color   = 'r';

% find the view struct
s = selectedVOLUME;
vw = VOLUME{s};

% get the ROI from the mesh
vw = meshROI2Volume(vw, 3);

msh = viewGet(vw,'currentmesh');
mrmRoi = mrmGet(msh,'curRoi');


% get the name of the current retinotopic model
rmFile = viewGet(vw,'rmFile');
if ~isempty(rmFile)
    [~, rmFile]  = fileparts(rmFile);
end

roiA = viewGet(vw, 'ROI name');
roiB =  setdiff(viewGet(vw, 'ROI names'), roiA);

% check whether an ROI with roiname already exists in the view struct
if ismember(roiname, viewGet(vw, 'ROI names'))
       prompt           = sprintf('ROI ''%s'' already exists. Please enter a new ROI name', roiname);
       name             = 'ROI name';
       numlines         = 1;
       defaultanswer    = {'New ROI'}; 
       roiname=inputdlg(prompt,name,numlines,defaultanswer);
       if iscell(roiname), roiname = roiname{1};end
end

% set other ROI fields
comments = sprintf('%s; %s', roiname, rmFile);

vw = ROIanotb(vw, roiA, roiB, roiname, color, comments);

vw = viewSet(vw,'selected ROI', roiname);

vw = meshColorOverlay(vw);

vw = roiSetVertIndsAllMeshes(vw); 
 
updateGlobal(vw);
