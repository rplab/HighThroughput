%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htRunProcedure
% Inherits: htForm
%
% A class for handling program procedures, such as scanning fish, detecting
% shadows, etc. Assumes an instance of this class called runProcedure
%
% Ideas: Instrument instances are procedure properties
%
% To do: 
%
% Procedures to make: Switch AOTF/Filterwheel
%                     Allow user to click and drag camera preview to move
%                       stage, buttons to move stage.
%                     IN HTGUI, run button actually just prompts for and
%                       opens a script.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htRunProcedure < htForm
    
    properties
        
    end
    
    properties (Access = protected)
        uniqueNIDAQName = 'NI6343DAQ';
        uniqueASIConsoleName = 'ASITigerConsole';
        uniqueAOTFName = 'AAOptoElectronicAOTF';
        uniqueKDScientificPumpName = 'KDScientificLegato111Pump';
        uniqueHamamatsuName = 'HamamatsuOrcaFlash4.0';
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: connectInstruments
        %
        % This method connects the computer with all instruments the user
        % selected to use.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         instrumentCellArray - A cell array containing N 
        %           instruments objects instantiated elsewhere.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          sessionCellArray- A cell array containing the sessions
        %            for the N instruments in instrumentCellArray,
        %            respectively.
        %
        % Example: [runProcedure, sessionCellArray] = runProcedure.connectInstruments([{niDaq},{asiConsole}]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, instrumentInstancesCellArray, instrumentSessionsCellArray] = ConnectInstruments(obj, instrumentInstancesCellArray)
            
            numInstruments = size(instrumentInstancesCellArray, 2);
            instrumentSessionsCellArray = cell(1, numInstruments);
            
            for i=1:numInstruments
                if(instrumentInstancesCellArray{1, i}.userWantsToConnect == 1)
                    [instrumentInstancesCellArray{1, i}, instrumentSessionsCellArray{1, i}] = instrumentInstancesCellArray{1, i}.Connect(instrumentInstancesCellArray{1, i}.connectionChannelOrTypeString);
                    instrumentInstancesCellArray{1, i}.iSuccessfulConnection = 1;
                else
                    instrumentInstancesCellArray{1, i}.iSuccessfulConnection = 0;
                end
            end
            
        end
        
        function obj = DisconnectInstruments(obj, instrumentInstancesCellArray, instrumentSessionsCellArray)
            
            numInstruments = size(instrumentInstancesCellArray, 2);
            
            for i=1:numInstruments
                if(instrumentInstancesCellArray{1, i}.userWantsToConnect == 1)
                    instrumentInstancesCellArray{1, i}.Disconnect(instrumentSessionsCellArray{1, i});
                end
            end
            
        end
        
        function [obj, instrumentInstancesCellArray] = InitializeDAQForStandardHTUse(obj, instrumentInstancesCellArray, niDaqSession)
            instrumentInstancesCellArray{1, 1} = instrumentInstancesCellArray{1, 1}.InitializeDigitalChannels(niDaqSession, {'valve1', '1.1', true, 'testIn', '1.5', false, 'valve2', '1.0', true, 'LEDIn' '1.2', false});
        end
        
        function [obj, instrumentInstancesCellArray] = ToggleValve1(obj, instrumentInstancesCellArray, niDaqSession)
            instrumentInstancesCellArray{1, 1} = instrumentInstancesCellArray{1, 1}.ToggleDigitalOutputChannelStates(niDaqSession, {'Valve1'});
        end
        
        function obj = DebugDisplayString(obj, str2Disp)
            disp(str2Disp);
        end
        
        function [obj, numSum, numDifference, numProduct] = DebugDisplayMathOperations(obj, num1, num2)
            numSum = num1 + num2;
            numDifference = num1 - num2;
            numProduct = num1*num2;
            disp(numSum);
            disp(numDifference);
            disp(numProduct);
        end
        
    end
    
    methods(Static)
        
        function DebugDisplayStringStatic(str2Disp)
            disp(str2Disp);
        end
        
        function [res1, res2] = DebugAddMultAndReturnBothStatic(num1, num2)
            res1 = num1 + num2;
            res2 = num1*num2;
            disp(res1)
            disp(res2)
        end
        
        function Pause(pauseTimeMilliseconds)
            pause(pauseTimeMilliseconds/1000);
        end
        
        function PrintTimestamp()
            datetime
        end
        
%         function RUN_SCRIPT(scriptStr)
%             disp(scriptStr);
%         end
        
    end
end