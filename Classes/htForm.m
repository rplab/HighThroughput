%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htForm
% Inherits: None
%
% A Class for all high-throughput objects. Used to give all high-throughput
% objects certain properties and methods.
%
% Ideas:
%
% To do: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htForm
    properties
        warningsVerbose = false; % Boolean which permits printing minor warnings if true; Default false
        sequenceVerbose = true; % Boolean which permits printing to screen information regarding which step is currently performing; Default true
        uniqueNameString; % A string which identifies which class to instantiate from. Used during the automated for loop in the connectInstruments procedure.
    end
    methods(Static)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function (Static): PrintStringToWindow
        %
        % This method sends strings to a listbox given by the handle
        % infoWindow. As of February 2018, this is most useful for sending
        % messages to the htGui information window.
        %
        % Inputs: infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         stringToPrintToWindow - A string containing whatever
        %           message you want to add to the infoWindow. This also
        %           appears to work with the literals stored in variables.
        % Outputs: N/A
        %
        % Example: htForm.PrintStringToWindow(infowWindow, 'If possible, please refrain from swearing in the infoWindow.');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PrintStringToWindow(infoWindow, stringToPrintToWindow)
            lastIndex = size(get(infoWindow, 'String')', 2) + 1;
            set(infoWindow, 'String', [get(infoWindow, 'String')', stringToPrintToWindow], 'Value', lastIndex);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function (Static): Pause
        %
        % This method pauses for a given number of milliseconds. Note that
        % this function is latent and will not return until it is done
        % pausing.
        %
        % Inputs: infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         pauseTimeMilliseconds - A number representing the pause
        %           time in some units... figure it out yourself.
        % Outputs: N/A
        %
        % Example: htForm.Pause(infowWindow, 10000);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Pause(infoWindow, pauseTimeMilliseconds)
            pause(pauseTimeMilliseconds/1000);
            htForm.PrintStringToWindow(infoWindow, strcat({'Pausing for '}, num2str(pauseTimeMilliseconds), {' milliseconds'}));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function (Static): PrintTimestampToWindow
        %
        % This method prints the current time to the infoWindow.
        %
        % Inputs: infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        % Outputs: N/A
        %
        % Example: htForm.PrintTimestampToWindow(infowWindow);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PrintTimestampToWindow(infoWindow)
            htForm.PrintStringToWindow(infoWindow, datestr(datetime));
        end
    end
end