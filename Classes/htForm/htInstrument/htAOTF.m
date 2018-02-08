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
        % Example: [aotf, aotfSerialObj] = aotf.Connect('Com19');
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: AOTFOutputNone
        %
        % This method sends a signal to the AOTF and the ASIStage to not
        % allow laser light through and to change the filter wheel to be
        % empty.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        %          asiSerialObj - The ASI stage object used to communicate 
        %            with the actual console via Matlab's serial api. Used
        %            to control the filterwheel.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: aotf = aotf.AOTFOutputNone(aotfSerialObj, asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = AOTFOutputNone(obj, aotfSerialObj, asiSerialObj)
            
            % See the AOTF manual for details on syntax. L2 and L3 refer to
            % lines 2 and 3, which as of Feb. 2018 are GFP and RFP, resp.
            if(obj.iSuccessfulConnection == 1)
                query(aotfSerialObj,'L2O0');
                query(aotfSerialObj,'L3O0');
            end
            query(asiSerialObj,'MP 0');
            
        end
    end
end