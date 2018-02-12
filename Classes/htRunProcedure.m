%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htRunProcedure
% Inherits: htForm
%
% A class for handling program procedures, such as scanning fish, detecting
% shadows, etc. Assumes an instance of this class called runProcedure.
%
% Ideas: 
%
% To do:
%
% Procedures to make: Switch AOTF/Filterwheel
%                     Wait for fish trigger from camera
%                     Position fish
%                     Take movie
%                     InitializeDaqForStandardUse
%                     ToggleValve1, ToggleValve2, ToggleLED
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htRunProcedure < htForm
    
    properties
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: ConnectInstruments
        %
        % This method connects the computer with all instruments the user
        % selected to use.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         instrumentInstancesCellArray - A cell array containing N 
        %           instruments objects instantiated elsewhere.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          instrumentInstancesCellArray - A cell array containing N 
        %            instruments objects instantiated elsewhere.
        %          instrumentSessionsCellArray - A cell array containing
        %            the sessions for the N instruments.
        %
        % Example: [runProcedure, instrumentInstancesCellArray, instrumentSessionsCellArray] = runProcedure.ConnectInstruments(infoWindow, [{niDaq},{asiConsole}]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, instrumentInstancesCellArray, instrumentSessionsCellArray] = ConnectInstruments(obj, infoWindow, instrumentInstancesCellArray)
            
            numInstruments = size(instrumentInstancesCellArray, 2);
            instrumentSessionsCellArray = cell(1, numInstruments);
            
            for i=1:numInstruments
                if(instrumentInstancesCellArray{1, i}.userWantsToConnect == 1)
                    [instrumentInstancesCellArray{1, i}, instrumentSessionsCellArray{1, i}] = instrumentInstancesCellArray{1, i}.Connect(infoWindow, instrumentInstancesCellArray{1, i}.connectionChannelOrTypeString{:});
                else
                    instrumentInstancesCellArray{1, i}.iSuccessfulConnection = 0;
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: InitializeDAQForStandardHTUse
        %
        % This method initializes the high throughput instruments in a way
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, instrumentInstancesCellArray] = InitializeDAQForStandardHTUse(obj, infoWindow, htSettings, instrumentInstancesCellArray, niDaqSession)
            index = htRunProcedure.ReturnInstrumentIndex(htSettings, niDaqSession);
            instrumentInstancesCellArray{index} = instrumentInstancesCellArray{index}.InitializeDigitalChannels(infoWindow, niDaqSession, {'valve1', '1.1', true, 'valve2', '1.0', true, 'LEDIn', '1.2', false, 'LEDOut', '1.3', true});
        end
        
%         function obj = CaptureCurrentImageAndDisplay(obj, b, htSettings, instrumentInstancesCellArray, hamamatsuCameraObj)
%             index = htRunProcedure.ReturnInstrumentIndex(htSettings, hamamatsuCameraObj);
%             currentFrame = instrumentInstancesCellArray{index}.triggerAndReturnImage(hamamatsuCameraObj);
%             data = currentFrame(:,:,1);  % channel 1 only
%             imshow(data, [], 'Parent', b)
%         end
        
%         function [obj, instrumentInstancesCellArray] = ToggleValve1(obj, instrumentInstancesCellArray, niDaqSession)
%             instrumentInstancesCellArray{1, 1} = instrumentInstancesCellArray{1, 1}.ToggleDigitalOutputChannelStates(niDaqSession, {'Valve1'});
%         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: DebugDisplayMathOperations
        %
        % This method is used to test that the program is responsive, that
        % the infoWindow updates correctly, and gives the user something to
        % test alongside other functions while debugging or creating new
        % methods.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         num1 - A number to perform math on.
        %         num2 - A number to perform math on.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          numSum - The sum of the two numbers.
        %          numDifference - The difference of the two numbers.
        %          numProduct - The product of the two numbers.
        %
        % Example: [runProcedure, nSum, nDif, nProd] = runProcedure.DebugDisplayMathOperations(infoWindow, 5, 3);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, numSum, numDifference, numProduct] = DebugDisplayMathOperations(obj, infoWindow, num1, num2)
            numSum = num1 + num2;
            numDifference = num1 - num2;
            numProduct = num1*num2;
            htForm.PrintStringToWindow(infoWindow, strcat({'Sum is: '}, num2str(numSum)))
            htForm.PrintStringToWindow(infoWindow, strcat({'Difference is: '}, num2str(numDifference)))
            htForm.PrintStringToWindow(infoWindow, strcat({'Product is: '}, num2str(numProduct)))
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: DisconnectInstruments
        %
        % This method disconnects the computer from all instruments the
        % user selected to use.
        %
        % Inputs: obj - The instance of the class. This argument is
        %           suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         instrumentInstancesCellArray - A cell array containing N 
        %           instruments objects instantiated elsewhere.
        %         instrumentSessionsCellArray - A cell array containing
        %           the sessions for the N instruments.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %
        % Example: runProcedure = runProcedure.DisconnectInstruments(infoWindow, instrumentInstancesCellArray, instrumentSessionsCellArray);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = DisconnectInstruments(obj, infoWindow, instrumentInstancesCellArray, instrumentSessionsCellArray)
            
            numInstruments = size(instrumentInstancesCellArray, 2);
            
            for i=1:numInstruments
                if(instrumentInstancesCellArray{1, i}.userWantsToConnect == 1)
                    instrumentInstancesCellArray{1, i}.Disconnect(infoWindow, instrumentSessionsCellArray{1, i});
                end
            end
            
        end
        
    end
    
    methods(Static)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: ReturnInstrumentIndex
        %
        % This method is used to obtain the index a particular instrument
        % is located at in settings (and thus
        % instrumentInstancesCellArray). This is particularly useful for
        % procedures as they often require access to a variety of class
        % instances, all of which are housed under a single cell array (the
        % one I just mentioned).
        %
        % Inputs: settings - A large structure created at the start of
        %           either htStartGui or htGui, containing a variety of
        %           settings.
        %         instrumentSession - The instrument session object you are
        %           trying to find the corresponding index for in another
        %           structure (e.g. instrumentInstancesCellArray).
        % Outputs: index - An integer representing the index the instrument
        %            is located at in the settings and other structures
        %            (e.g. instrumentInstancesCellArray).
        %
        % Example: index = htRunProcedure.ReturnInstrumentIndex(settings, niDaqSession);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function index = ReturnInstrumentIndex(settings, instrumentSession)
            correspondingInstrumentString = inputname(2);
            indexBoolVector = strcmp(settings.instrumentSessionNames, correspondingInstrumentString);
            index = find(indexBoolVector);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: DebugAddMultAndReturnBothStatic
        %
        % This method is used to test that the program is responsive, that
        % the infoWindow updates correctly, and gives the user something to
        % test alongside other functions while debugging or creating new
        % methods. This static version is useful for making sure the eval
        % function works with both types of functions.
        %
        % Inputs: infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         num1 - A number to perform math on.
        %         num2 - A number to perform math on.
        % Outputs: numSum - The sum of the two numbers.
        %          numProduct - The product of the two numbers.
        %
        % Example: [nSum, nProd] = htRunProcedure.DebugAddMultAndReturnBothStatic(infoWindow, 5, 3);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [numSum, numProduct] = DebugAddMultAndReturnBothStatic(infoWindow, num1, num2)
            numSum = num1 + num2;
            numProduct = num1*num2;
            htForm.PrintStringToWindow(infoWindow, strcat({'Sum is: '}, num2str(numSum)))
            htForm.PrintStringToWindow(infoWindow, strcat({'Product is: '}, num2str(numProduct)))
        end
        
    end
end