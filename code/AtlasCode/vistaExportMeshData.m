function vistaExportMeshData(pth, dt, prfModel, fspath)

% Navigate and initialize session
if notDefined('pth'), pth =  '/Users/kalanit/Courses/psych224/data/TestSubject/TestSubject_190725/'; end
if notDefined('dt'),  dt =  'Averages'; end
if notDefined('prfModel'),  prfModel =  'retModel-cssFit-gFit.mat'; end
if notDefined('fspath')  
    fspath =  fullfile('.', '3DAnatomy', 'FreeSurferSegmentation_TestSubject'); 
end

% Navigate and open a hidden vista session
cd(pth);
meshImportFreesurferSurfaces(fspath);
vw = initHiddenGray;

vw = viewSet(vw, 'current dataTYPE', dt);

% Load the PRF model and set the view to map
vw = rmSelect(vw, 1, prfModel);

vw = viewSet(vw, 'display mode', 'map');

% specify files and field names for exporting pRF data
templateFile = fullfile(fspath, 'mri', 'orig.mgz');

meshNames = {'./3DAnatomy/Right/3DMeshes/Right_white.mat', ...
    './3DAnatomy/Left/3DMeshes/Left_white.mat'};

hemis     = {'rh' 'lh'};
fieldstr = {'eccentricity', 'polar-angle', 'sigma', 'variance explained'};
fnames   = {'eccen', 'theta', 'prfsize', 'varexp'};

% set up mesh properties
setpref('mesh', 'layerMapMode', 'layer1');
setpref('mesh', 'overlayLayerMapMode', 'mean');
setpref('mesh', 'dataSmoothIterations', 0);
meshPrefs = getpref('mesh');

% Loop over eccentricity, polar angle, pRF size, and variance explained

outpath = fullfile('.', '3DAnatomy', 'atlases', 'data');
if ~exist(outpath, 'dir'), mkdir(outpath); end

for ii = 1:length(fieldstr)
    
    thisfield = fieldstr{ii};
    
    vw = rmLoad(vw, [], thisfield, 'map');
    
    for jj = 1:2
        hemi = hemis{jj};
        fname = fullfile(outpath,  sprintf('%s.%s.mgz', hemi, fnames{ii}));
        meshExportSurface(vw, meshNames{jj}, meshPrefs, fname, templateFile);
    end
end

