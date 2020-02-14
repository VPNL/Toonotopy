function meshExportSurface(vw, meshName, meshPrefs, fname, templateFile)

if notDefined('meshPrefs'), else, mrmPreferences(meshPrefs); end

vw= meshLoad(vw, meshName, 0);

MSH = viewGet(vw, 'Mesh'); 
vertexGrayMap = mrmMapVerticesToGray( meshGet(MSH, 'initialvertices'), viewGet(vw, 'nodes'), viewGet(vw, 'mmPerVox'), viewGet(vw, 'edges') ); 
MSH = meshSet(MSH, 'vertexgraymap', vertexGrayMap); 
vw = viewSet(vw, 'Mesh', MSH); clear MSH vertexGrayMap 

[~, ~, ~, ~, ~, ~, data] = meshColorOverlay(vw);

mgz = MRIread(templateFile);
mgz.vol = NaN(1,1,length(data));
mgz.vol(1,1,:) = data;

MRIwrite(mgz, fname);

fprintf('File written as %s\n', fname);