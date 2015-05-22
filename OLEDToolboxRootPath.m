function rootPath = OLEDToolboxRootPath()
% Return the path to the root of the OLEDToolbox
%
% This function must reside in the directory at the base of the OLEDToolbox.  
% It is used to determine the location of various sub-directories.
% 
% Example:
% rootPath = which('isetbioRootPath', 'ToneMappingApp', 'SRGBimages');
    
[rootPath,~,~] = fileparts(which(mfilename()));

end

