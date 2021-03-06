%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htASITigerConsole
% Inherits: htInstrument
%
% A Class for communicating with the ASI Tiger console, which as of
% February 2018 controls the stage and filter wheel.
%
% Examples in this document assume an instance of the class "asiConsole"
%
% Ideas: 
%
% To do: Functions to add - Speed
%        Verbose warnings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htASITigerConsole < htInstrument
    
    properties
        deviceComPort % This variable is set automatically with the function connect(). String which matches the virtual com port with which the ASI stage is identified. Example: asiStage.deviceComPort = 'Com5';
        stageScalingFactorX = 4.0; % Sometimes the stage movement distance is off from the input movement distance by a constant factor. This fixes that.
        stageScalingFactorY = 4.0; % See fStageScalingFactorX comment
        stageScalingFactorZ = 2.5; % See fStageScalingFactorX comment
        maximumStageSpeed = '7.5'; % Units of mm/s
        stageCenterXY % Double vector set by the user in the GUI to represent the center of the capillary. This value is assumed to have already been corrected via stageScalingFactorX,Y
        stageInitAndFinalZ % Double vector set by the user in the GUI to represent the initial and final z for light-sheet scans. This value is assumed to have already been corrected via stageScalingFactorZ
        stageCenterZ % Double representing the center of the capillary, set automatically when the zebrafish search is started. This value is assumed to have already been corrected via stageScalingFactorZ
        defaultFilterWheelPosition = 'MP 0';
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Connect
        %
        % This method connects the computer with the ASI console for a 
        % given com port.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         comPort - A string which matches the virtual com port
        %           assigned to the device by windows.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          asiSerialObj - The ASI console object used to 
        %            communicate with the actual console via Matlab's 
        %            serial api.
        %
        % Example: [asiConsole, asiSerialObj] = asiConsole.Connect(infoWindow, 'Com5');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, asiSerialObj] = Connect(obj, infoWindow, comPort)
            
            if(obj.iSuccessfulConnection ~= 1)
                
                % Set the deviceID
                obj.deviceComPort = comPort;
                
                asiSerialObj = serial(comPort,'BaudRate',115200,'DataBits',8,'FlowControl','none','Parity','none','StopBits',1,'Terminator',{'CR/LF', 'CR'}); % Device is listed in Device Manager as Silicon Labs CP210x USB to UART Bridge in the Ports section
                
                try
                    fopen(asiSerialObj);
                    obj.iSuccessfulConnection = 1;
                    htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] ASI stage successfully connected.');
                    
                catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI Tiger Console found; aborting connection attempt.');
                    button = questdlg(strcat('No ASI Tiger Console with the com port ''',comPort,''' can be found, continue anyway?'));
                    if(strcmp(button,'Yes'))
                        obj.iSuccessfulConnection = 0;
                    else
                        obj.iSuccessfulConnection = -1;
                    end
                    asiSerialObj = -1;
                end
            else
                htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] Tiger Console already successfully connected; skipping ''Connect'' command.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: QueryStagePosition
        %
        % This method returns the current position of the stage in units of
        % microns, rescaling mismatches between where the stage is in real 
        % space vs. where the stage thinks it is.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          positionVector - A 3-vector returning the x, y, and z
        %            position of the stage in microns.
        %
        % Example: [asiConsole, positionVector] = asiConsole.QueryStagePosition(infoWindow, asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, positionVector] = QueryStagePosition(obj, infoWindow, asiSerialObj)
            
            % If the console is communicating, query all current positions
            if(obj.iSuccessfulConnection == 1)
                curXStringReturn = query(asiSerialObj,'WHERE X'); % Query current X position
                curXMicronNum = htASITigerConsole.ReturnNumberFromStageResult(curXStringReturn);
                curYStringReturn = query(asiSerialObj,'WHERE Y'); % Query current X position
                curYMicronNum = htASITigerConsole.ReturnNumberFromStageResult(curYStringReturn);
                curZStringReturn = query(asiSerialObj,'WHERE Z'); % Query current X position
                curZMicronNum = htASITigerConsole.ReturnNumberFromStageResult(curZStringReturn);
                positionVector = [curXMicronNum, curYMicronNum, curZMicronNum];
            else
                positionVector = -1;
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping stage position query.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: RelativeMoveStage
        %
        % This method 
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        %         moveAxis - Char of the axis name.
        %         moveAmountMicrons - Int of the amount to move in microns
        %         maxSpeed1True0False - Int for moving at the maximum
        %           speed. Uses current speed if false.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.RelativeMoveStage(infoWindow, asiSerialObj, 'X', 1000, 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = RelativeMoveStage(obj, infoWindow, asiSerialObj, moveAxis, moveAmountMicrons, maxSpeed1True0False)
            
            if(obj.iSuccessfulConnection == 1)
                if(logical(maxSpeed1True0False))
                    queryCell = strcat({'SPEED '}, moveAxis, {'='}, obj.maximumStageSpeed);
                    query(asiSerialObj, queryCell{:});
                end
                
                queryCell = strcat({'MOVREL '}, moveAxis, {'='}, num2str(moveAmountMicrons*10));
                query(asiSerialObj, queryCell{:});
                htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] Stage moving.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping relative stage movement.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: MoveStage
        %
        % This method 
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        %         moveAxis - Char of the axis name.
        %         movePositionMicrons - Int of the position to move to in microns
        %         maxSpeed1True0False - Int for moving at the maximum
        %           speed. Uses current speed if false.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.MoveStage(infoWindow, asiSerialObj, 'X', 1452.2, 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = MoveStage(obj, infoWindow, asiSerialObj, moveAxis, movePositionMicrons, maxSpeed1True0False)
            
            if(obj.iSuccessfulConnection == 1)
                if(logical(maxSpeed1True0False))
                    queryCell = strcat({'SPEED '}, moveAxis, {'='}, obj.maximumStageSpeed);
                    query(asiSerialObj, queryCell{:});
                end
                
                queryCell = strcat({'MOVE '}, moveAxis, {'='}, num2str(movePositionMicrons*10));
                query(asiSerialObj, queryCell{:});
                htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] Stage moving.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping stage movement.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SetSpeed
        %
        % This method 
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        %         speedAxis - Char of the axis name.
        %         speedUnitsOfMMPerSec - The speed of the stage in units of
        %           millimeters per second.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.MoveStage(infoWindow, asiSerialObj, 'X', 7.5);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SetSpeed(obj, infoWindow, asiSerialObj, moveAxis, speedUnitsOfMMPerSec)
            
            if(obj.iSuccessfulConnection == 1)
                queryCell = strcat({'SPEED '}, moveAxis, {'='}, num2str(speedUnitsOfMMPerSec));
                query(asiSerialObj, queryCell{:});
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping speed setting.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SwitchFilterWheelToEmpty
        %
        % This method flips the filterwheel to its default state, assumed
        % to be an empty filter.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.SwitchFilterWheelToEmpty(infoWindow, asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SwitchFilterWheelToEmpty(obj, infoWindow, asiSerialObj)
            
            if(obj.iSuccessfulConnection == 1)
                fprintf(asiSerialObj, obj.defaultFilterWheelPosition);
                htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] Filter wheel set to empty.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping filter wheel change to empty.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SwitchFilterWheelToGFP
        %
        % This method flips the filterwheel to its GFP state, assumed
        % to be 'MP 1'.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.SwitchFilterWheelToGFP(infoWindow, asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SwitchFilterWheelToGFP(obj, infoWindow, asiSerialObj)
            
            if(obj.iSuccessfulConnection == 1)
                fprintf(asiSerialObj, 'MP 1');
                htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] Filter wheel set to GFP.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping filter wheel change to GFP.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: SwitchFilterWheelToRFP
        %
        % This method flips the filterwheel to its RFP state, assumed
        % to be 'MP 2'.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.SwitchFilterWheelToRFP(infoWindow, asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SwitchFilterWheelToRFP(obj, infoWindow, asiSerialObj)
            
            if(obj.iSuccessfulConnection == 1)
                fprintf(asiSerialObj, 'MP 2');
                htForm.PrintStringToWindow(infoWindow, '[htASITigerConsole] Filter wheel set to RFP.');
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASI stage available; skipping filter wheel change to RFP.');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Disconnect
        %
        % This method disconnects the computer from the stage.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         asiSerialObj - The ASI stage session acquired from
        %            the connect method.
        % Outputs: N/A
        %
        % Example: asiConsole.Disconnect(infoWindow, asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Disconnect(obj, infoWindow, asiSerialObj)
            
            % If the DAQ session was started...
            if(obj.iSuccessfulConnection == 1)
                fclose(asiSerialObj);
                delete(asiSerialObj);
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htASITigerConsole] No ASIStage available; skipping ASIStage disconnection.');
                end
            end
            
        end
        
    end
    
    methods(Static)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function (Static): waitForStageToFinish
        %
        % Method which does not return until the stage confirms it is
        % finished moving. This is a latent function.
        %
        % Inputs: asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        % Outputs: 
        %
        % Example: htASITigerConsole.waitForStageToFinish(asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function WaitForStageToFinish(asiSerialObj)
            
            finished = false;
            pauseTime = 0.01;

            while(~finished)
                pause(pauseTime);
                stageAnswer = query(asiSerialObj,'/'); % This command is a rapid method for asking the controller if it is moving
                if(strcmp('N',stageAnswer(1)))
                    finished = true;
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function (Static): returnNumberFromStageResult
        %
        % This method takes a string returned from the stage (e.g. 
        % 'A: -1023') in units of tenths of microns and returns number 
        % representative of that string in units of microns.
        %
        % Inputs: returnedString - The string returned from the ASI console 
        %          object, possibly with non-numeric characters, in units 
        %          of tenths of microns.
        % Outputs: micronNum - A double representation of the numeric part
        %           of returnedString changed into units of microns.
        %
        % Example: micronNum = htASITigerConsole.returnNumberFromStageResult(':A -1024');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function micronNum = ReturnNumberFromStageResult(returnedString)
            
            numOnlyString = regexp(returnedString,'-?\d+\.?\d*|','match');
            if(iscell(numOnlyString))
                numOnlyString = numOnlyString{1, 1}; % Char array regexps return cells, string regexps return strings
            end
            numTenthsMicrons = str2double(numOnlyString);
            micronNum = numTenthsMicrons/10;
            disp(micronNum)
            
        end
        
    end
    
end