%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htKDSPump
% Inherits: htInstrument
%
% A Class for communicating with...
%
% Examples in this document assume an instance of the class "kdsPump"
%
% Ideas: 
%
% To do: Make sure the terminator is correct
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htKDSPump < htInstrument
    
    properties
        deviceComPort % This variable is set automatically with the function connect(). String which matches the virtual com port with which the pump is identified. Example: kdsPump.deviceComPort = 'Com5';
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: connect
        %
        % This method connects the computer with the pump for a given 
        % com port.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         comPort - A string which matches the virtual com port
        %           assigned to the device by windows.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          aotfSerialObj - The pump object used to communicate with
        %            the actual console via Matlab's serial api.
        %
        % Example: [kdsPump, kdsPumpSerialObj] = kdsPump.connect('Com19');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, kdsPumpSerialObj] = Connect(obj, comPort)
            
            % Set the deviceID
            obj.deviceComPort = comPort;
            
            kdsPumpSerialObj = serial(comPort,'BaudRate',115200,'DataBits',8,'FlowControl','none','Parity','none','StopBits',2,'Terminator','CR');

            try
               fopen(kdsPumpSerialObj);
            catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                button = questdlg(strcat('No pump with the com port ''', comPort, ''' can be found, continue anyway?'));
                if(strcmp(button,'Yes'))
                    obj.iSuccessfulConnection = 0;
                else
                    obj.iSuccessfulConnection = -1;
                end
            end
            
        end
    end
end