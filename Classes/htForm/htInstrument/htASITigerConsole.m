%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htASITigerConsole
% Inherits: htInstrument
%
% A Class for communicating with...
%
% Examples in this document assume an instance of the class "asiConsole"
%
% Ideas: 
%
% To do: Functions to add - Filterwheel, speed, move, movrel, scan
%                           firmware, 
%        Disconnect method
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
        % Function: connect
        %
        % This method connects the computer with the ASI console for a 
        % given com port.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         comPort - A string which matches the virtual com port
        %           assigned to the device by windows.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          asiSerialObj - The ASI console object used to 
        %            communicate with the actual console via Matlab's 
        %            serial api.
        %
        % Example: [asiConsole, asiSerialObj] = asiConsole.connect('Com5');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, asiSerialObj] = Connect(obj, comPort)
            
            % Set the deviceID
            obj.deviceComPort = comPort{:};
            
            asiSerialObj = serial(comPort{:},'BaudRate',115200,'DataBits',8,'FlowControl','none','Parity','none','StopBits',1,'Terminator',{'CR/LF', 'CR'}); % Device is listed in Device Manager as Silicon Labs CP210x USB to UART Bridge in the Ports section

            fopen(asiSerialObj);
%             try
%                fopen(asiSerialObj);
%             catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
%                 button = questdlg(strcat('No ASI Tiger Console with the com port ''',comPort,''' can be found, continue anyway?'));
%                 if(strcmp(button,'Yes'))
%                     obj.iSuccessfulConnection = 0;
%                 else
%                     obj.iSuccessfulConnection = -1;
%                 end
%             end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: queryStagePosition
        %
        % This method returns the current position of the stage in units of
        % microns, rescaling mismatches between where the stage is in real 
        % space vs. where the stage thinks it is.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          positionVector - A 3-vector returning the x, y, and z
        %            position of the stage in microns.
        %
        % Example: [asiConsole, positionVector] = asiConsole.queryStagePosition(asiSerialObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, positionVector] = QueryStagePosition(obj, asiSerialObj)
            
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
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: RelativeMoveStage
        %
        % This method 
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        %         moveAxis - Char of the axis name.
        %         moveAmountMicrons - Int of the amount to move in microns
        %         maxSpeed1True0False - Int for moving at the maximum speed
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: asiConsole = asiConsole.RelativeMoveStage(asiSerialObj, 'X', 1000);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = RelativeMoveStage(obj, asiSerialObj, moveAxis, moveAmountMicrons, maxSpeed1True0False)
            
            if(logical(maxSpeed1True0False))
                queryCell = strcat({'SPEED '}, moveAxis, {'='}, obj.maximumStageSpeed);
                query(asiSerialObj, queryCell{:});
            end
            
            queryCell = strcat({'MOVREL '}, moveAxis, {'='}, num2str(moveAmountMicrons*10));
            query(asiSerialObj, queryCell{:});
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: prepareForFishDetection
        %
        % This method takes a number of "Fields of View" to move left by,
        % moves the stage over to that position, and flips the filter wheel
        % to the default value.
        %
        %                   --------------------------------- Scan range = numFieldsOfViewToSearch*currentCameraResolution*micronsPerPixel (not used here)
        %                  |        [Capillary]        |
        %             =======================================
        %                       |        |
        %  Detection Position --+        +-- Center
        %                       |________|---------[deltaXCenterDetectionUnitsFOV]
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         asiSerialObj - The ASI console object used to communicate
        %           with the actual console via Matlab's serial api.
        %         hamamatsuObj - 
        %         deltaXCenterToDetectionUnitsFOV - 
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: [asiConsole] = asiConsole.prepareForFishDetection(asiSerialObj, hamamatsuObj, 9);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = PrepareForFishDetection(obj, asiSerialObj, hamamatsuObj, deltaXCenterToDetectionUnitsFOV)
            
            % If the console is communicating, perpare stage by moving it
            if(obj.iSuccessfulConnection == 1)
                
                % Initialize variables
                micronsPerPixel = hamamatsuObj.micronsPerPixel;
                currentCameraResolution = hamamatsuObj.currentCameraResolution;
                
                % Determine stage position
                amountToMoveLeftRelativeToCenter = -obj.stageScalingFactorX * deltaXCenterToDetectionUnitsFOV * micronsPerPixel * currentCameraResolution; % Units of microns
                initialXPositionToMoveTo = obj.stageCenterXY(1) + amountToMoveLeftRelativeToCenter;
                
                % Set Filterwheel to default location
                query(asiSerialObj, obj.defaultFilterWheelPosition);
                
                % Set stage speed, position
                queryCell = strcat({'SPEED X='}, obj.maximumStageSpeed);
                query(asiSerialObj, queryCell{:});
                queryCell = strcat({'MOVE X='}, double2str(initialXPositionToMoveTo*10), ' Y=', double2str(obj.stageCenterXY(2)), ' Z=',  double2str(obj.stageCenterZ));
                query(asiSerialObj, queryCell{:});
                
                % Wait until stage has completed moving before returning
                htASITigerConsole.waitForStageToFinish(asiSerialObj);
                
            end
            
        end
        
        function Disconnect(obj, asiSerialObj)
            fclose(asiSerialObj);
            delete(asiSerialObj);
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
                if(strcmp('N',stageAnswer(2)))
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