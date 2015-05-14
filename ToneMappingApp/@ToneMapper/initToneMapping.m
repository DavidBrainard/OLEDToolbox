% Method to initialize the tonemapping method
function initToneMapping(obj)

    % Default tonemap is linear scaling, i.e, no tone mapping 
    toneMapping = struct('name', 'LINEAR_SCALING', 'nominalMaxLuminance', 100.0);
    
    % save tone mapping methods
    obj.toneMappingMethods = containers.Map({'OLED', 'LCD'}, {toneMapping, toneMapping});
   
    % Update GUI
    obj.updateGUIWithCurrentToneMappingMethod('OLED');
    obj.updateGUIWithCurrentToneMappingMethod('LCD');
end

