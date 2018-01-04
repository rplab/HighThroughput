%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htForm
% Inherits: None
%
% A Class for all high-throughput objects.
%
% Ideas: Put a listbox which shows timestamps and sequenceVerbose
%
% To do: Make a folder structure which matches inheritance. Make separate
%          MD files for each directory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htForm
    properties
        warningsVerbose = false; % Boolean which permits printing minor warnings if true; Default false
        sequenceVerbose = true; % Boolean which permits printing to screen information regarding which step is currently performing; Default true
        uniqueNameString; % A string which identifies which class to instantiate from. Used during the automated for loop in the connectInstruments procedure.
    end
    methods(Static)
        
        function PrintStringToWindow(infoWindow, stringToPrintToWindow)
            lastIndex = size(get(infoWindow, 'String')', 2) + 1;
            set(infoWindow, 'String', [get(infoWindow, 'String')', stringToPrintToWindow], 'Value', lastIndex);
        end
        
        function Pause(infoWindow, pauseTimeMilliseconds)
            pause(pauseTimeMilliseconds/1000);
            htForm.PrintStringToWindow(infoWindow, strcat({'Pausing for '}, num2str(pauseTimeMilliseconds), {' milliseconds'}));
        end
        
        function PrintTimestampToWindow(infoWindow)
            htForm.PrintStringToWindow(infoWindow, datestr(datetime));
        end
    end
end