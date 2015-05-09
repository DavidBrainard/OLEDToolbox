function resetSettings(obj, ~,~, varargin)
   % get reset mode
   resetMode = varargin{1};
   
   switch (resetMode)
       case 'All'
           fprintf('Resetting all settings');
           % Initialize the displays
           obj.initDisplays();
           
           % init the visualization options
           obj.initVisualizationOptions();
           
           % Initialize the tone mapping params
           obj.initToneMapping();
            
           % init the processing options
           obj.initProcessingOptions();

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
   
    % Subsample image
    obj.subSampleInputImage();
    
    % Render the image
    obj.drawInputImage();
    
    % Do the work
    % force-recomputation of the inputLuminanceHistogram
    obj.data = rmfield(obj.data, 'inputLuminanceHistogram');
    obj.redoToneMapAndUpdateGUI(); 
end

