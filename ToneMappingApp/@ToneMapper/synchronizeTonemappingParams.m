function synchronizeTonemappingParams(obj, sourceLabel, source, destinationLabel, destination)
    
    sourceToneMapping = obj.toneMappingMethods(source);
    obj.toneMappingMethods(destination) = sourceToneMapping;
    
end

