function readData(src, ~)
    sampleSize = 9600; 
    
    if(src.UserData.Count == 1)
        disp('sampling started'); 
    end 
    
    % Read the ASCII data from the serialport object.
    data = readline(src);

    % Convert the string data to numeric type and save it in the UserData
    % property of the serialport object.
    src.UserData.Data(end+1) = str2double(data);

    % Update the Count value of the serialport object.
    src.UserData.Count = src.UserData.Count + 1;

    % If 10001 data points have been collected from the Arduino, switch off the
    % callbacks and plot the data.
    if src.UserData.Count > sampleSize + 1
        configureCallback(src, "off");
        plot((src.UserData.Data(2:end)/4095)*3.3);
        disp(fprintf('Sample completed. %d data point recorded.',sampleSize)); 
    end
end

