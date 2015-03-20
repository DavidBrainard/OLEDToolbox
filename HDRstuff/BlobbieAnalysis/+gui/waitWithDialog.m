function cancelOperation = waitWithDialog(message)
    % Construct a questdlg with three options
    tryAgainString = upper('ColorShare1 now mounted. Try again.');
    choice = questdlg(message, upper(message), tryAgainString ,'Cancel','Cancel');
    % Handle response
    switch choice
        case tryAgainString
            cancelOperation = false;
        case 'Cancel'
            cancelOperation = true;
    end
end