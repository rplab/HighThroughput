%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htAOTF
% Inherits: htInstrument
%
% A Class for communicating with...
%
% Examples in this document assume an instance of the class "aotf"
%
% Ideas: 
%
% To do: Make sure the terminator is correct
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htAOTF < htInstrument
    
    properties
        deviceComPort % This variable is set automatically with the function connect(). String which matches the virtual com port with which the AOTF is identified. Example: aotf.deviceComPort = 'Com5';
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: connect
        %
        % This method connects the computer with the AOTF for a given 
        % com port.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         comPort - A string which matches the virtual com port
        %           assigned to the device by windows.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        %
        % Example: [aotf, aotfSerialObj] = aotf.connect('Com19');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, aotfSerialObj] = Connect(obj, comPort)
            
            % Set the deviceID
            obj.deviceComPort = comPort;
            
            aotfSerialObj = serial(comPort,'BaudRate',19200,'DataBits',8,'FlowControl','none','Parity','none','StopBits',1,'Terminator','CR'); % Device is listed in Device Manager as USB Serial Port

            try
               fopen(aotfSerialObj);
            catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                button = questdlg(strcat('No AOTF with the com port ''', comPort, ''' can be found, continue anyway?'));
                if(strcmp(button,'Yes'))
                    obj.iSuccessfulConnection = 0;
                else
                    obj.iSuccessfulConnection = -1;
                end
            end
            
        end
    end
end