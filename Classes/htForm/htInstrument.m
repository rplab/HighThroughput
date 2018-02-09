%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htInstrument
% Inherits: htForm
%
% A Class for handling instruments. Used to give all high-throughput
% instruments certain properties and methods.
%
% Ideas: 
%
% To do: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htInstrument < htForm
    properties
        iSuccessfulConnection = 0 % If 1, successful connection. If 0, no instrument was found but user wants to continue. If -1, no instrument was found and user wants to quit.
        userWantsToConnect = true % If false, user doesn't want to use this instrument, true they do
        connectionChannelOrTypeString % A string which identifies which channel (for serial, e.g. 'COM4') or type (e.g. 'HTDev1' for DAQ)
        verboseTimestamp = true % Currently unused
    end
    methods(Static)
        
    end
end