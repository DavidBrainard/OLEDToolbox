function resetSettings(obj, ~,~, varargin)
   % get reset mode
   resetMode = varargin{1};
   
   switch (resetMode)
       case 'All'
           fprintf('Resetting all settings');
           % Initialize the displays
           obj.initDisplays();
            
           % Initialize the tone mapping params
           obj.initToneMapping();
            
           % init the processing options
           obj.initProcessingOptions();
            
           % init the visualization options
           obj.initVisualizationOptions();
       
       case 'Displays'
           fprintf('Resetting display properties');
           % Initialize the displays
           obj.initDisplays();
           
       case 'Tone Mapping'
           % Initialize the tone mapping params
           obj.initToneMapping();
           
       case 'Processing Options'
           % init the processing options
           obj.initProcessingOptions();
           
       otherwise
           error('Unknown reset mode (''%s'')', resetMode);
   end
   
   % Do the work
   obj.redoToneMapAndUpdateGUI();
    
end

