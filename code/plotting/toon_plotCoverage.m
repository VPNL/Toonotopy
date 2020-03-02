
function vw=toon_plotCoverage(vw, method, cothresh, prf_size,nboot,nrows,ncols);
%
% function toon_plotCoverage(vw, method, cothresh, prf_size nboot, nrows, ncols);
% plots coverage of multiple ROIs loaded to a gray view (vw)
% 
% 
% if method, cothresh and nboot not defined Defaults are as following
% method='max'; 
% cothresh=0.1; % 10 variance explained
% nboot=100;  
% prf_size:  0 = plot pRF center; 1 = use pRF size
% nrows and ncols define the number of subplots in the figure
% if not defined, defaults"
% nrows=2 
% ncols=nROIs/nrows
% 
%
% example:
% ROIs={lh_V1, rh_V1};prfModel = 'retModel-cssFit-fFit.mat';
% cothresh=0.2; method='sum'; nboot=50; 
% vw=toon_initRM(prfModel, ROIs,cothresh);
% toon_plotCoverage(vw, method, cothresh, nboot)
%
% KGS 02/20
%

if isempty (vw.ROIs)
    display('Error there no ROIs to plot coverage\n');
    return
end

% set Defaults
if notDefined ('method')
    method='max'; %method: of computing coverage. I usually use 'sum' or 'max'
end
if notDefined ('cothresh')
    cothresh=0.1; %cothresh:        threshold by variance explained in model
end
if notDefined ('nboot')
    nboot=100;    %  number of bootstraps; default is 50
end
% setting the dimensions of the subplots in my subfigure
if notDefined ('nrows')
    nrows=2;
end
if notDefined ('ncols')
    ncols=length(vw.ROIs)/nrows;
end
if notDefined('prf_size')
    prf_size=1;
end
% create dir for images if this directory does not exist
if ~exist('./Images/pRFplots/','dir')
        !mkdir ./Images/pRFplots
end

for i=1:length(vw.ROIs)
    %set view to current ROI
    vw=viewSet(vw,'selectedroi',i);
    %rmPlotCoverage plots pRF coverage for each ROI;
    [RFcov, figHandleC(i), all_models, weight, data] = rmPlotCoverage(vw,'method',method,'cothresh',cothresh,'nboot',nboot,'prf_size',prf_size);% 'weight',weight
    ROIname=vw.ROIs(i).name;
    %figname=fullfile('./Images', 'pRFplots', [ROIname '_' method '_coverage.jpg']);
    %saveas(figHandleC(i),figname,'jpg');
end

% make nice figure with all ROIs & save it
sumFigC=figure('name','pRF coverage','color','w','units','norm','Position', [ 0 0 .8 .8]);

for i=1:nrows*ncols
    currFig=figHandleC(i);
    currSubplot=subplot_tight(nrows, ncols,i); % so there is no white space between plots
    copyobj(allchild(get(currFig,'CurrentAxes')),currSubplot);colormap('jet');colorbar;
    axis('image'); axis('off')
    ROIname=vw.ROIs(i).name;
    title(ROIname,'Fontsize',14,'interpreter','none');
    
end

figname=fullfile('./Images', 'pRFplots',  ['All_ROIs_coverage.jpg']); 
saveas(sumFigC,figname,'jpg');
close(figHandleC);