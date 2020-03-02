function vw=toon_plotCenters(vw,cothresh,nrows,ncols);

% vw=toon_plotCenters(vw,  cothresh,nrows,ncols);
% plots centers of multiple ROIs loaded to a gray view (vw)
% 
% If not defined Defaults are as following:
% cothresh=0.1; % 10 variance explained
% nrows=2 
% ncols=nROIs/nrows
% 
%
% example:
% ROIs={lh_V1, rh_V1};prfModel = 'retModel-cssFit-fFit.mat';
% cothresh=0.2; 
% vw=toon_initRM(prfModel, ROIs,cothresh);
% toon_toon_plotCenters(vw,  cothresh,nrows,ncols);
%
% KGS 02/20


if isempty (vw.ROIs)
    display('Error there no ROIs to plot centers\n');
    return
end

if notDefined ('cothresh')
    cothresh=0.1; %cothresh:        threshold by variance explained in model
end

% setting the dimensions of the subplots in my subfigure
if notDefined ('nrows')
    nrows=2;
end
if notDefined ('ncols')
    ncols=length(vw.ROIs)/nrows;
end

for i=1:length(vw.ROIs)
    %set view to current ROI
    vw=viewSet(vw,'selectedroi',i);
    %rmPlotCoverage plots pRF coverage for each ROI; it has several
    %options, see rmCoverage
    [vw, figHandle(i)] = plotEccVsPhase(vw,'colored',1);
    ROIname=vw.ROIs(i).name;
%     figname=fullfile('./Images', 'pRFplots', [ROIname '_pRFcenters.jpg']);
%     saveas(figHandle(i),figname,'jpg');
end

% make nice figure with all ROIs & save it
% setting the dimensions of the subplots in my subfigure

sumFigH=figure('name','pRF centers','color','w','units','norm','Position', [ 0 0 .8 .8]);

for i=1:nrows*ncols
    currFig=figHandle(i);
    currSubplot=subplot_tight(nrows, ncols,i); % so there is no white space between plots
    copyobj(allchild(get(currFig,'CurrentAxes')),currSubplot);
    axis('image'); axis('off')
    ROIname=vw.ROIs(i).name;
    title(ROIname,'Fontsize',14,'interpreter','none');
end

figname=fullfile('./Images', 'pRFplots',  ['All_ROIs_centers.jpg']); 
saveas(sumFigH,figname,'jpg');
close(figHandle);