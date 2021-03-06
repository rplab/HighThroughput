%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class: htHamamatsu
% Inherits: htInstrument
%
% A Class for communicating with the Hamamatsu camera and triggering it for
% frames, possibly saving them too.
%
% Examples in this document assume an instance of the class "hamamatsu"
%
% Ideas: 
%
% To do:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef htHamamatsu < htInstrument
    
    properties
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Connect
        %
        % This method connects the computer with the camera, presumed in
        % this case to be the Hamamatsu, though any DCAM compatible camera
        % with the same settings should work (this is not true for many
        % other brands I think).
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         cameraName - A string which matches the name of the
        %           device available in Matlab's IMAQ configuration.
        % Outputs: obj - The instance of the class. Used to update
        %            instance properties.
        %          hamamatsuCameraObj - The created camera object which is
        %            used to control the camera.
        %
        % Example: [hamamatsu, hamamatsuCameraObj] = hamamatsu.Connect(infoWindow, 'hamamatsu');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [obj, hamamatsuCameraObj] = Connect(obj, infoWindow, cameraName)
            
            imaqreset;
            
            if(obj.iSuccessfulConnection ~= 1)
                
                try
                    
                    % Establish connections
                    hwInfo = imaqhwinfo(cameraName);
                    hamamatsuCameraObj = videoinput(hwInfo.AdaptorName,1,'MONO16_BIN2x2_1024x1024_FastMode'); % Fastest setting with 4x4 binning
                    vid_src = getselectedsource(hamamatsuCameraObj);
                    
                    % Set settings
                    triggerconfig(hamamatsuCameraObj,'manual')     % manual triggering, rather than trigger on "start"
                    set(hamamatsuCameraObj, 'FrameGrabInterval', 1);    % Grab every frame
                    set(hamamatsuCameraObj, 'FramesPerTrigger', 1);   % Grab one frame per trigger
                    set(hamamatsuCameraObj,'TriggerRepeat',Inf);     % Allow infinitely many triggers
                    set(vid_src, 'ExposureTime', 0.2); % Exposure time, unknown units, though related to seconds.
                    
                    % Start video object
                    start(hamamatsuCameraObj);
                    
                    htForm.PrintStringToWindow(infoWindow, '[htHamamatsu] Camera successfully connected.');
                    obj.iSuccessfulConnection = 1;
                    
                catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htHamamatsu] No Hamamatsu camera found; aborting connection attempt.');
                    button = questdlg(strcat('No camera with the name ''', cameraName, ''' can be found, continue anyway?'));
                    if(strcmp(button,'Yes'))
                        obj.iSuccessfulConnection = 0;
                    else
                        obj.iSuccessfulConnection = -1;
                    end
                    hamamatsuCameraObj = -1;
                end
            else
                htForm.PrintStringToWindow(infoWindow, '[htHamamatsu] Hamamatsu already successfully connected; skipping ''Connect'' command.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: triggerAndReturnImage
        %
        % This method triggers the Hamamatsu camera for an image then
        % returns that image.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         hamamatsuCameraObj - The camera object to shut down.
        % Outputs: imageToReturn - An array representative of the image
        %             obtained from the camera.
        %
        % Example: imageToReturn = hamamatsu.triggerAndReturnImage(hamamatsuCameraObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function imageToReturn = triggerAndReturnImage(obj, hamamatsuCameraObj)
            
            % Be sure not to print to the info window as this function may
            % be called often
            if(obj.iSuccessfulConnection == 1)
                trigger(hamamatsuCameraObj)
                imageToReturn = getdata(hamamatsuCameraObj,1);
            else
                imageToReturn = -1;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: triggerAndSaveAndReturnImage
        %
        % This method triggers the Hamamatsu camera for an image, saves the
        % image to a specified filename and filepath, then returns the
        % image.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         hamamatsuCameraObj - The camera object to shut down.
        %         saveNameWithFilePath - A string containing the complete
        %            filename and filepath to save the image to.
        % Outputs: imageToReturn - An array representative of the image
        %             obtained from the camera.
        %
        % Example: imageToReturn = hamamatsu.triggerAndSaveAndReturnImage(hamamatsuCameraObj, 'C:\IProbablyShouldntSaveDirectlyInTheCDir.tif');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function imageToReturn = triggerAndSaveAndReturnImage(obj, hamamatsuCameraObj, saveNameWithFilePath)
            
            % Be sure not to print to the info window as this function may
            % be called often
            if(obj.iSuccessfulConnection == 1)
                trigger(hamamatsuCameraObj)
                imageToReturn = getdata(hamamatsuCameraObj,1);
                imwrite(imageToReturn, saveNameWithFilePath);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function: Disconnect
        %
        % This method disconnects the computer from the Hamamatsu camera.
        %
        % Inputs: obj - The instance of the class. This argument is
        %            suppressed if called FROM the instance.
        %         infoWindow - A handle to the information window. Used to
        %           relay information to the user.
        %         hamamatsuCameraObj - The camera object to shut down.
        % Outputs: N/A
        %
        % Example: hamamatsu.Disconnect(infoWindow, hamamatsuCameraObj);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Disconnect(obj, infoWindow, hamamatsuCameraObj)
            
            if(obj.iSuccessfulConnection == 1)
                % Close connections: Camera
                stop(hamamatsuCameraObj)
                delete(hamamatsuCameraObj)
                clear hamamatsuCameraObj
            else
                if(obj.warningsVerbose)
                    htForm.PrintStringToWindow(infoWindow, 'Warning: [htHamamatsu] No Hamamatsu camera available; skipping disconnection.');
                end
            end
        end
        
    end
end