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
    methods
        
    end
end