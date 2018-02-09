%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htKDSPump
% Inherits: htInstrument
%
% A Class for communicating with the KD Scientific Legato series pumps.
%
% Examples in this document assume an instance of the class "kdsPump"
%
% Ideas: 
%
% To do:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htKDSPump < htInstrument
    
    properties
        deviceComPort % This variable is set automatically with the function connect(). String which matches the virtual com port with which the pump is identified. Example: kdsPump.deviceComPort = 'Com5';
        diameterSetString = 'diameter 14.43';
        maxVolumeSetString = 'svolume 10 ml';
        infuseRateSetString = 'irate 3.0 ml/min';
        withdrawRateSetString = 'wrate 1 ml/min';
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Connect
        %
        % This method connects the computer with the pump for a given 
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
        %          kdsPumpSerialObj - The pump object used to communicate with
        %            the actual console via Matlab's serial api.
        %
        % Example: [kdsPump, kdsPumpSerialObj] = kdsPump.Connect(infoWindow, 'Com19');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, kdsPumpSerialObj] = Connect(obj, infoWindow, comPort)
            
            if(obj.iSuccessfulConnection ~= 1)
                % Set the deviceID
                obj.deviceComPort = comPort;
                
                kdsPumpSerialObj = serial(comPort,'BaudRate',115200,'DataBits',8,'FlowControl','none','Parity','none','StopBits',2,'Terminator','CR');
                
                try
                    % Establish connections
                    fopen(kdsPumpSerialObj);
                    htForm.PrintStringToWindow(infoWindow, '[htKDSPump] KDS pump successfully connected.');
                    
                    % Set pump to default settings
                    obj = obj.UpdatePumpParameters(infoWindow);
                    
                catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump found; aborting connection attempt.');
                    button = questdlg(strcat('No pump with the com port ''', comPort, ''' can be found, continue anyway?'));
                    if(strcmp(button,'Yes'))
                        obj.iSuccessfulConnection = 0;
                    else
                        obj.iSuccessfulConnection = -1;
                    end
                end
            else
                htForm.PrintStringToWindow(infoWindow, '[htKDSPump] KDS pump already successfully connected; skipping ''Connect'' command.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SetWithdrawRate
        %
        % This method sets the withdraw rate for the pump. Be careful with
        % your syntax as the units need to match the pump's list of
        % acceptable units.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         rateNumber - An integer or float which represents the
        %           withdraw rate in units specified in the next variable.
        %         rateUnits - A string containing the units to use. Must
        %           match the units available with the pump.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: kdsPump = kdsPump.SetWithdrawRate(infoWindow, 1, 'ml/min');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SetWithdrawRate(obj, infoWindow, rateNumber, rateUnits)
            
            if(obj.iSuccessfulConnection == 1)
                stringToUpdateCell = strcat({'wrate '}, {num2str(rateNumber)}, {' '}, {rateUnits});
                printf(serialPumpObj, stringToUpdateCell{:});
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping the set withdraw rate command.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: BeginWithdrawing
        %
        % This method tells the pump to begin withdrawing with its current
        % parameters.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: kdsPump = kdsPump.BeginWithdrawing(infoWindow);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = BeginWithdrawing(obj, infoWindow)
            
            if(obj.iSuccessfulConnection == 1)
                printf(serialPumpObj,'wrun');
                htForm.PrintStringToWindow(infoWindow, '[htKDSPump] The pump is now withdrawing.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping withdraw command.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SetInfuseRate
        %
        % This method sets the infuse rate for the pump. Be careful with
        % your syntax as the units need to match the pump's list of
        % acceptable units. 
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         rateNumber - An integer or float which represents the
        %           withdraw rate in units specified in the next variable.
        %         rateUnits - A string containing the units to use. Must
        %           match the units available with the pump.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: kdsPump = kdsPump.SetInfuseRate(infoWindow, 1.0, 'ml/min');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SetInfuseRate(obj, infoWindow, rateNumber, rateUnits)
            
            if(obj.iSuccessfulConnection == 1)
                stringToUpdateCell = strcat({'irate '}, {num2str(rateNumber)}, {' '}, {rateUnits});
                printf(serialPumpObj, stringToUpdateCell{:});
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping the set infusion rate command.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: BeginInfusing
        %
        % This method tells the pump to begin infusing with its current
        % parameters.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: kdsPump = kdsPump.BeginInfusing(infoWindow);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = BeginInfusing(obj, infoWindow)
            
            if(obj.iSuccessfulConnection == 1)
                printf(serialPumpObj,'irun');
                htForm.PrintStringToWindow(infoWindow, '[htKDSPump] The pump is now infusing.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping infuse command.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: StopInfusingAndOrWithdrawing
        %
        % This method tells the pump to stop any motion.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: kdsPump = kdsPump.StopInfusingAndOrWithdrawing(infoWindow);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = StopInfusingAndOrWithdrawing(obj, infoWindow)
            
            if(obj.iSuccessfulConnection == 1)
                printf(serialPumpObj,'stop');
                htForm.PrintStringToWindow(infoWindow, '[htKDSPump] The pump has stopped.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping the stop command.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: UpdatePumpParameters
        %
        % This method updates the parameters currently used by the pump.
        % The updated parameters are the syringe diameter, the maximum
        % volume, the infusion rate, and the withdraw rate. Note that the
        % order these parameters are set matters!
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: kdsPump = kdsPump.UpdatePumpParameters(infoWindow);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = UpdatePumpParameters(obj, infoWindow)
            
            if(obj.iSuccessfulConnection == 1)
                fprintf(kdsPumpSerialObj, obj.diameterSetString);
                fprintf(kdsPumpSerialObj, obj.maxVolumeSetString);
                fprintf(kdsPumpSerialObj, obj.infuseRateSetString);
                fprintf(kdsPumpSerialObj, obj.withdrawRateSetString);
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping update of pump parameters.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Disconnect
        %
        % This method disconnects the computer from the pump.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         kdsPumpSerialObj - The KDS Pump session acquired from
        %            the connect method.
        % Outputs: N/A
        %
        % Example: kdsPump.Disconnect(infoWindow, kdsPumpSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Disconnect(obj, infoWindow, kdsPumpSerialObj)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                fclose(kdsPumpSerialObj);
                delete(kdsPumpSerialObj);
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htKDSPump] No KDS pump available; skipping pump disconnection.');
                end
            end
            
        end
    end
end