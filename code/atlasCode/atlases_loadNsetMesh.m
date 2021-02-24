function vw=atlases_loadNsetMesh (vw, meshName, L,  layerMapMode, meshAngleSetting)
%
% vw=atlases_loadNsetMesh (vw, meshName, L, meshAngleSetting);
% loads a mesh, sets its light and angle, and recomputes vertices
%
% input
% vw                gray view
% meshName          name of the mesh to be loaded
% L(optional)       lighting parameters to be applied; 
%                   if not defined defaults are: L.ambient=[.4 .4 .4];  L.diffuse=[.5 .5 .5];
% layerMapMode .    'all' or 'layer1'
% meshAngleSetting  mesh viewing settings
%
% KGS 2/2020

% define default lights
if notDefined('L')
    L.ambient=[.4 .4 .4];
    L.diffuse=[.5 .5 .5];
end
% set default layer map mode
if notDefined('layerMapMode')
    layerMapMode='all'
end

% set up mesh properties
setpref('mesh', 'layerMapMode', layerMapMode);
setpref('mesh', 'overlayLayerMapMode', 'mean');
setpref('mesh', 'dataSmoothIterations', 0);

% load mesh
[vw, OK] = meshLoad(vw, meshName, 1); if ~OK, error('Mesh server failure'); end
MSH = viewGet(vw, 'Mesh');
% set mesh angle
if exist('meshAngleSetting')
    [MSH, settings] = meshRetrieveSettings(MSH, meshAngleSetting);
end
% set lighting
vw = meshLighting(vw, MSH,L,1);
% rebuild vertex to gray mapping
vertexGrayMap = mrmMapVerticesToGray( meshGet(MSH, 'initialvertices'), viewGet(vw, 'nodes'), viewGet(vw, 'mmPerVox'), viewGet(vw, 'edges') );
MSH = meshSet(MSH, 'vertexgraymap', vertexGrayMap);
vw = viewSet(vw, 'Mesh', MSH);