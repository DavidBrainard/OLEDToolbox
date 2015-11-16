function getDataFile(obj)
    
    rootDir = OLEDToolboxRootPath();
    cd(fullfile(rootDir, 'GenericImagePreferenceExperiment'));
    obj.rootDir = pwd;
    obj.dataDir = fullfile(obj.rootDir, 'Data');
    obj.pdfDir  = fullfile(obj.rootDir, 'Analysis', 'PDFfigs');
    
    [fileName,pathName] = uigetfile({'*.mat'},'Select a data file for analysis', obj.dataDir);
    obj.dataFile = fullfile(pathName, fileName);
    cd(obj.rootDir);
    
end