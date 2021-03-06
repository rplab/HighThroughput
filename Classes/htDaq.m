%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htDaq
% Inherits: htInstrument
%
% A Class for communicating with, and changing input and output states for,
% Data Acquisition (DAQ) hardware. As of October 2017, this system controls
% LED states, valve states, and recieves the states of LED triggers.
%
% Examples in this document assume an instance of the class "niDaq"
%
% Ideas: Make channel name/states/ports/lines one structure rather than
%        separate variables. Or consider changing some other way.
%
% To do: Graceful exit when choosing NO when device isn't found (change in
%          calling function)
%        Set the protected variable currentDigitalStates (make sure all
%          functions do that)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htDaq < htInstrument
    
    properties
        deviceID % This variable is set automatically with the function connect(). String which matches the device ID in NI-MAX (e.g. HTDev1). Example: niDaq.deviceID = 'HTDev1';
        channelNames % Cell array of channel names initialized in method 'initializeDigitalChannels'. Example: niDaq.channelNames = {'valve1', 'testIn', 'valve2', 'LEDIn'};
        hasOutputs = false
    end
    
    properties (Access = protected)
        currentDigitalOutputStates % A boolean array of the current digital states which output. This variable should not be able to be changed manually.
        currentDigitalStates % A list of the current digital states for all channels. This variable should not be able to be changed manually.
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Connect
        %
        % This method connects the computer with the DAQ, previously
        % labeled with an ID (check the wanted instrument name in NI-MAX).
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         NIMaxID - A string which matches the device ID in NI-MAX
        %            (e.g. 'HTDev1').
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          daqSession - The data acquisition session (see
        %            daq.createSession).
        %
        % Example: [niDaq, niDaqSession] = niDaq.Connect(infoWindow, 'HTDev1');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, daqSession] = Connect(obj, infoWindow, NIMaxID)
            
            if(obj.iSuccessfulConnection ~= 1)
                
                % Initialize variables
                successBool = false;
                
                % Set the deviceID
                obj.deviceID = NIMaxID;
                
                % Obtain a list of devices
                d = daq.getDevices;
                
                % Go through the list to find the right DAQ
                for i=1:size(d,2)
                    
                    % If the right DAQ exists, create the session.
                    if(strcmp(d(i).ID, obj.deviceID))
                        daqSession = daq.createSession(d(i).Vendor.ID);
                        obj.iSuccessfulConnection = 1;
                        successBool = true;
                    end
                    
                end
                
                % If we didn't find the DAQ, let user decide if that is OK
                if(~successBool)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htDaq] No DAQ found; aborting connection attempt.');
                    button = questdlg(strcat('No DAQ with the ID ''',obj.deviceID,''' can be found, continue anyway?'));
                    if(strcmp(button,'Yes'))
                        obj.iSuccessfulConnection = 0;
                    else
                        obj.iSuccessfulConnection = -1;
                    end
                    daqSession = -1;
                else
                    htForm.PrintStringToWindow(infoWindow, '[htDAQ] DAQ successfully connected.');
                end
            else
                htForm.PrintStringToWindow(infoWindow, '[htDaq] DAQ already successfully connected; skipping ''Connect'' command.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: InitializeDigitalChannels
        %
        % This method initializes the digital channels we want to use and
        % sets them to be either inputs or outputs.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         objSession - The data acquisition session acquired from
        %            the connect method.
        %         namesChannelsAndBoolStates_CellArray - A cell array of
        %            alternating strings and booleans. First strings
        %            contain the defined name of the channel, the second
        %            numeric digital channels to use. For example, if we 
        %            want to use the channel PFI1.2 and call it LEDIn, the
        %            first two values in the cell array are {'LEDIn',
        %            '1.2'}. Booleans contain the input or output 
        %            configuration for each channel initialized in the 
        %            previous variable. False is input, true is output. 
        %            From the example above, if we want PFI1.2 to 
        %            be an input we pass {false}. See the example below.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Notes: If you want to change channels, remember to disconnect
        %        and then reconnect before calling this function again.
        %
        % Example: niDaq = niDaq.InitializeDigitalChannels(infoWindow, niDaqSession, {'valve1', '1.1', true, 'testIn', '1.5', false, 'valve2', '1.0', true, 'LEDIn' '1.2', false});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = InitializeDigitalChannels(obj, infoWindow, niDaqSession, namesChannelsAndBoolStates_CellArray)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                
                % Initialize variables
                obj.channelNames = namesChannelsAndBoolStates_CellArray(1:3:end);
                channels_CellArrayOfStrings = namesChannelsAndBoolStates_CellArray(2:3:end);
                inputOutputStates_BoolVector = [namesChannelsAndBoolStates_CellArray{3:3:end}];
                inputOrOutput = {'InputOnly','OutputOnly'};
                numChannels = length(inputOutputStates_BoolVector);
                obj.currentDigitalOutputStates = inputOutputStates_BoolVector;
%                 numOutputChannels = sum(uint8(inputOutputStates_BoolVector));
                
                % Initialize each digital channel
                for i=1:numChannels
                    
                    % Determine input or output and which port and line
                    curInputOrOutput = inputOrOutput{uint8(inputOutputStates_BoolVector(i)) + 1}; % E.g. If 'inputOutputStates_BoolVector(i) = false', false + 1 = 1, so that curInputOrOutput = inputOrOutput(1), true gives an index of 2
                    if(inputOutputStates_BoolVector(i))
                        obj.hasOutputs = true;
                    end
                    curPortLineNum = str2double(channels_CellArrayOfStrings{i});
                    if(~isnan(curPortLineNum))
                        % Convert user input into correct syntax
                        portNum = floor(curPortLineNum); % Port numbers are the 'integer part' of the num, that is, left of the decimal
                        decimalIndex = strfind(channels_CellArrayOfStrings{i},'.');
                        LineNum = str2double(channels_CellArrayOfStrings{i}((decimalIndex + 1):end)); % Line numbers are the 'fractional part' of the num, that is, right of the decimal
                        curPortAndLine = strcat('Port',num2str(uint16(portNum)),'/Line',num2str(uint16(LineNum)));
                        % Create the digital channel
                        addDigitalChannel(niDaqSession, obj.deviceID, curPortAndLine, curInputOrOutput);
                    else
                        htForm.PrintStringToWindow(infoWindow, sprintf('Warning: [htDaq] The string ''%s'' does not represent a DAQ port and line; this channel will be skipped.', channels_CellArrayOfStrings{i}));
                    end
                    
                end
                
                % Make the operation mode continuous
                niDaqSession.IsContinuous = true;
                
                % Set the states of all channels to false
                obj.currentDigitalStates = false(1, numChannels);
                htForm.PrintStringToWindow(infoWindow, sprintf('DAQ: Established %i digital channels', numChannels));
                
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htDaq] No DAQ available; skipping digital channel initialization.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SetDigitalOutputChannelStates
        %
        % This method changes the states for any/all digital outputs.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         objSession - The data acquisition session acquired from
        %            the connect method.
        %         channelNamesWithStates_CellArray - A cell array of
        %            strings and booleans which alternate from string
        %            (channel name) to bool (what to set that channel to).
        %            Example: {'Valve1', false, 'Valve3', true}
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: niDaq = niDaq.SetDigitalOutputChannelStates(infoWindow, niDaqSession, {'valve1', true, 'valve2', false});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SetDigitalOutputChannelStates(obj, infoWindow, niDaqSession, channelNamesWithStates_CellArray)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                % Break the cell array into two arrays, decoupling names from
                % states
                toChangeChannelNames = channelNamesWithStates_CellArray(1:2:end);
                toChangeChannelStates = channelNamesWithStates_CellArray(2:2:end);
                
                % Loop through all names to change to the new desired states
                for i=1:length(toChangeChannelNames)
                    whichActualChannelBoolVect = arrayfun(@(x)(strcmp(toChangeChannelNames{i},x)), obj.channelNames, 'UniformOutput', false); % Outputs a boolean vector pertaining to which channel is actually being changed (i.e. hardware doesn't name channel, it just gives it an index; we are finding that index)
                    obj.currentDigitalStates([whichActualChannelBoolVect{:}]) = toChangeChannelStates{i};
                    if(toChangeChannelStates{i})
                        setToString = 'high';
                    else
                        setToString = 'low';
                    end
                    stringToDisplay = strcat({'DAQ: Setting '}, toChangeChannelNames(i), {' to '}, {setToString});
                    htForm.PrintStringToWindow(infoWindow, stringToDisplay{:});
                end
                
                % Set all channels to the updated states, output scan only
                % for the output states
                digitalStateVector = obj.currentDigitalStates;
                outputVector = digitalStateVector(obj.currentDigitalOutputStates);
                outputSingleScan(niDaqSession, outputVector);
                
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htDaq] No DAQ available; skipping digital channel state change.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: ToggleDigitalOutputChannelStates
        %
        % This method toggles the states for any/all digital outputs.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         objSession - The data acquisition session acquired from
        %            the connect method.
        %         channelNames_CellArray - A cell array of strings of
        %            (channel name)s to toggle (invert state).
        %            Example: {'Valve1', 'Valve2'}
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: niDaq = niDaq.ToggleDigitalOutputChannelStates(infoWindow, niDaqSession, {'valve1', 'valve2'});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = ToggleDigitalOutputChannelStates(obj, infoWindow, niDaqSession, channelNames_CellArray)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                
                % Loop through all names to change to the new desired states
                for i=1:length(channelNames_CellArray)
                    whichActualChannelBoolVect = arrayfun(@(x)(strcmp(channelNames_CellArray{i},x)), obj.channelNames, 'UniformOutput', false); % Outputs a boolean vector pertaining to which channel is actually being changed (i.e. hardware doesn't name channel, it just gives it an index; we are finding that index)
                    obj.currentDigitalStates([whichActualChannelBoolVect{:}]) = ~obj.currentDigitalStates([whichActualChannelBoolVect{:}]);
                    stringToDisplay = strcat({'DAQ: Toggling '}, channelNames_CellArray(i));
                    htForm.PrintStringToWindow(infoWindow, stringToDisplay{:});
                end
                
                % Set all channels to the updated states, output scan only
                % for the output states
                digitalStateVector = obj.currentDigitalStates;
                outputVector = digitalStateVector(obj.currentDigitalOutputStates);
                outputSingleScan(niDaqSession, outputVector);
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htDaq] No DAQ available; skipping digital channel state change.');
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: GetDigitalInputChannelState
        %
        % This method changes the states for any/all digital outputs.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         objSession - The data acquisition session acquired from
        %            the connect method.
        %         channelName_String - A string containing the channel name
        %            from which to acquire data.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          channelState - A logical indicating whether or not the
        %             digital input is high (true) or low (false).
        %
        % Example: [niDaq, LEDState] = niDaq.GetDigitalInputChannelState(infoWindow, niDaqSession, 'LEDIn');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, channelState] = GetDigitalInputChannelState(obj, infoWindow, niDaqSession, channelName_String)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                
                % Obtain the state of all channels
                inputInfo = logical(inputSingleScan(niDaqSession));
                
                % Determine wanted channel
                whichActualChannelBoolVect = arrayfun(@(x)(strcmp(channelName_String,x)), obj.channelNames, 'UniformOutput', false); % Outputs a boolean vector pertaining to which channel is actually being changed (i.e. hardware doesn't name channel, it just gives it an index; we are finding that index)
                
                % Obtain the channel state, update currentDigitalStates
                whichInputArrayIndexBoolVector = [whichActualChannelBoolVect{~obj.currentDigitalOutputStates}];
                channelState = inputInfo(whichInputArrayIndexBoolVector);
                obj.currentDigitalStates([whichActualChannelBoolVect{:}]) = channelState;
                
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htDaq] No DAQ available; skipping digital channel input state acquisition.');
                end
                
                % If there is no DAQ, return false
                channelState = false;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Disconnect
        %
        % This method disconnects the computer from the DAQ.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         objSession - The data acquisition session acquired from
        %            the connect method.
        % Outputs: N/A
        %
        % Example: niDaq.Disconnect(infoWindow, niDaqSession);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Disconnect(obj, infoWindow, niDaqSession)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                
                % Turn off all outputs
                if(obj.hasOutputs)
                    digitalStateVector = false(1, length(obj.channelNames));
                    outputVector = digitalStateVector(obj.currentDigitalOutputStates);
                    outputSingleScan(niDaqSession, outputVector);
                end
                
                % Stop any continuing processes, if necessary
                stop(niDaqSession);
                
                % Release hardware
                release(niDaqSession);
                
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htDaq] No DAQ available; skipping DAQ disconnection.');
                end
            end
            
        end
        
    end
    
end