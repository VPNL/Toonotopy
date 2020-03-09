function data = plot_MultiEccSigma(vw, ROIlist)
% plot_MultiEccSigma(vw, [ROIlist])
%
% Wrapper to plot pRF sigma vs eccentricity for multiple ROIs
%
%   vw: mrVista view struct
%   ROIlist: list of ROIs (if blank, call menu; if 0, plot all ROIs)
%
%   note: need to have an rm model and at least one ROI loaded into the 
%           view.
%
% 2/2009 JW
% 2/20 .   KGS

%--------------------------
% VARIABLE CHECKS
%--------------------------
% check view struct
if notDefined('vw'), vw = getCurView; end

% check model
model = viewGet(vw, 'rmModel'); %#ok<NASGU>
if isempty('model'), vw = rmSelect(vw); end

% check ROIs
if (notDefined('ROIlist'))
    roiList=viewGet(vw, 'roinames');
    selectedROIs = find(buttondlg('ROIs to Plot',roiList));
elseif ROIlist == 0,
    selectedROIs = 1:length(viewGet(vw, 'ROIs'));
else
    selectedROIs=ROIlist;
end

nROIs=length(selectedROIs);
if (nROIs==0), error('No ROIs selected'); end

%--------------------------
% PLOT
%--------------------------
% set up plot
figure('Color', 'w');
hold on;
c = jet(nROIs); % set colors

% initialize a legend
legendtxt = cell(1,nROIs);

% initialize data struct
data = cell(1, nROIs); 

% suppress individual plots from calls to rmPlotEccSigma
plotFlag = false; 

% loop thru ROIs
for ii = 1:nROIs
    vw = viewSet(vw, 'curroi', selectedROIs(ii));
    data{ii} = rmPlotEccSigma(vw, [], [], [], plotFlag);
    data{ii}.roi = viewGet(vw, 'roiname');
    legendtxt{ii} = data{ii}.roi;
    % plot the fit lines for each ROI (so we have one series per ROI to
    % make the legend nicer)
    plot(data{ii}.xfit, data{ii}.yfit, '-', 'color', c(ii,:), 'LineWidth', 3)
end
set(gca,'FontSize',12)

% add the data points for each plot
for ii = 1:nROIs   
    errorbar(data{ii}.x,data{ii}.y,data{ii}.ysterr, 'x', 'color', c(ii,:));    
end
axis('equal')
legend(legendtxt,'box','off','Location','NorthWest','Interpreter', 'none','FontSize',10);

ylabel('pRF size (sigma, deg)','FontSize',14);
xlabel('Eccentricity (deg)','FontSize',14);

data = cell2mat(data);

return
