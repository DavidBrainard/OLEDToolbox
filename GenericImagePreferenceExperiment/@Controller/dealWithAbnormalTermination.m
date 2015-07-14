function dealWithAbnormalTermination(obj, status, repIndex)
    obj.runAbortionStatus = status;
    obj.runAbortedAtRepetition = repIndex;
    saveData = lower(input('Save data collected so far ? [y/n] : ', 's'));
    if (strcmp(saveData, 'y'))
        % save the collected data together with other data from the cache file
        obj.saveData();
    end
end