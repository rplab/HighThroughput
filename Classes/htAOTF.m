%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htAOTF
% Inherits: htInstrument
%
% A Class for communicating with and controlling the optoelectronics AOTF.
% As of February 2018, this AOTF controls the laser light sent to the
% chamber, with configureations 2 and 3 representing GFP and RFP,
% respectively.
%
% Examples in this document assume an instance of the class "aotf"
%
% Ideas: 
%
% To do:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htAOTF < htInstrument
    
    properties
        deviceComPort % This variable is set automatically with the function connect(). String which matches the virtual com port with which the AOTF is identified. Example: aotf.deviceComPort = 'Com5';
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Connect
        %
        % This method connects the computer with the AOTF for a given 
        % com port.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         comPort - A string which matches the virtual com port
        %           assigned to the device by windows.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        %
        % Example: [aotf, aotfSerialObj] = aotf.Connect(infoWindow, 'Com19');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, aotfSerialObj] = Connect(obj, infoWindow, comPort)
            
            % Set the deviceID
            if(obj.iSuccessfulConnection ~= 1)
            
                obj.deviceComPort = comPort;
                aotfSerialObj = serial(comPort,'BaudRate',19200,'DataBits',8,'FlowControl','none','Parity','none','StopBits',1,'Terminator','CR'); % Device is listed in Device Manager as USB Serial Port
                
                try
                    fopen(aotfSerialObj);
                    obj.iSuccessfulConnection = 1;
                    htForm.PrintStringToWindow(infoWindow, '[htAOTF] AOTF successfully connected.');
                    
                catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htAOTF] No AOTF found; aborting connection attempt.');
                    button = questdlg(strcat('No AOTF with the com port ''', comPort, ''' can be found, continue anyway?'));
                    if(strcmp(button,'Yes'))
                        obj.iSuccessfulConnection = 0;
                    else
                        obj.iSuccessfulConnection = -1;
                    end
                    aotfSerialObj = -1;
                end
            else
                htForm.PrintStringToWindow(infoWindow, '[htAOTF] AOTF already successfully connected; skipping ''Connect'' command.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: AOTFOutputNone
        %
        % This method sends a signal to the AOTF to block all laser light
        % from reaching the chamber.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: aotf = aotf.AOTFOutputNone(infoWindow, aotfSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = AOTFOutputNone(obj, infoWindow, aotfSerialObj)
            
            % See the AOTF manual for details on syntax. L2 and L3 refer to
            % lines 2 and 3, which as of Feb. 2018 are GFP and RFP, resp.
            if(obj.iSuccessfulConnection == 1)
                query(aotfSerialObj,'L2O0');
                query(aotfSerialObj,'L3O0');
                htForm.PrintStringToWindow(infoWindow, '[htAOTF] AOTF output changed to NONE.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htAOTF] No AOTF available; skipping AOTF output off.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: AOTFOutputGFP
        %
        % This method sends a signal to the AOTF to allow GFP laser light
        % to reach the chamber.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: aotf = aotf.AOTFOutputGFP(infoWindow, aotfSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = AOTFOutputGFP(obj, infoWindow, aotfSerialObj)
            
            % See the AOTF manual for details on syntax. L2 and L3 refer to
            % lines 2 and 3, which as of Feb. 2018 are GFP and RFP, resp.
            if(obj.iSuccessfulConnection == 1)
                query(aotfSerialObj,'L2O1');
                query(aotfSerialObj,'L3O0');
                htForm.PrintStringToWindow(infoWindow, '[htAOTF] AOTF output changed to GFP.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htAOTF] No AOTF available; skipping AOTF output to GFP.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: AOTFOutputRFP
        %
        % This method sends a signal to the AOTF to allow RFP laser light
        % to reach the chamber.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: aotf = aotf.AOTFOutputRFP(infoWindow, aotfSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = AOTFOutputRFP(obj, infoWindow, aotfSerialObj)
            
            % See the AOTF manual for details on syntax. L2 and L3 refer to
            % lines 2 and 3, which as of Feb. 2018 are GFP and RFP, resp.
            if(obj.iSuccessfulConnection == 1)
                query(aotfSerialObj,'L2O0');
                query(aotfSerialObj,'L3O1');
                htForm.PrintStringToWindow(infoWindow, '[htAOTF] AOTF output changed to RFP.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htAOTF] No AOTF available; skipping AOTF output to RFP.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: AOTFOutputGFPAndRFP
        %
        % This method sends a signal to the AOTF to allow GFP and RFP laser
        % light to reach the chamber.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %          aotfSerialObj - The AOTF object used to communicate with
        %            the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: aotf = aotf.AOTFOutputGFPAndRFP(infoWindow, aotfSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = AOTFOutputGFPAndRFP(obj, infoWindow, aotfSerialObj)
            
            % See the AOTF manual for details on syntax. L2 and L3 refer to
            % lines 2 and 3, which as of Feb. 2018 are GFP and RFP, resp.
            if(obj.iSuccessfulConnection == 1)
                query(aotfSerialObj,'L2O1');
                query(aotfSerialObj,'L3O1');
                htForm.PrintStringToWindow(infoWindow, '[htAOTF] AOTF output changed to both GFP and RFP.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htAOTF] No AOTF available; skipping AOTF output to both GFP and RFP.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Disconnect
        %
        % This method disconnects the computer from the AOTF.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         objSession - The AOTF session acquired from
        %            the connect method.
        % Outputs: N/A
        %
        % Example: asiConsole.Disconnect(infoWindow, aotfSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Disconnect(obj, infoWindow, aotfSerialObj)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                fclose(aotfSerialObj);
                delete(aotfSerialObj);
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htAOTF] No AOTF available; skipping AOTF disconnection.');
                end
            end
            
        end
    end
end