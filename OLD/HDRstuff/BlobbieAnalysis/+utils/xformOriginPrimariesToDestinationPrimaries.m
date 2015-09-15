function destinationPrimaries = xformOriginPrimariesToDestinationPrimaries(originPrimaries, calStructOrigin, calStructDestination)
    sensorXYZ = PrimaryToSensor(calStructOrigin, originPrimaries);
    destinationPrimaries = utils.mapToGamut(SensorToPrimary(calStructDestination, sensorXYZ));
end
