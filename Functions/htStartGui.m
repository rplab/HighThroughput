%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: htStartGui
%
% A function which allows you to define the instruments used in htGui.m,
% what their communication string is, and what GUI position settings you
% want to use. This function also sets default paths, saving files related
% to what defaults load.
%
% Ideas: Figure out how to distinguish cameras in the event multiple are
%           turned on.
%        Load Settings button/Save Settings button (as opposed to default).
%           (I probably won't implement this feature).
%
% To do: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function htStartGui

%% Add or remove instruments here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% instrumentConnections
%
% Examples:
% 1: Name of the NI 6343 DAQ as seen/modified in NIMax. As of 12-4-17, HTDev1.
% 2: ComPort of the ASI Tiger Console stage and filterwheel box. As of 12-4-17, Com5
% 3: ComPort of the KD Scientific Legato 111 pump. As of 12-4-17, Com25
% 4: Name from "imaqhwinfo" of the Hamamatsu Orca Flash 4.0 camera. As of 12-4-17, 'hamamatsu'. I'm not sure how this changes if multiple cameras are connected.
% 5: ComPort of the OptoElectronics AOTF. As of 12-4-17, Com19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
instrumentConnections = {'HTDev1',                         'Com5',                            'Com25',                          'hamamatsu',                        'Com19'};
instrumentNames =       {'DAQ: National Instruments 6343', 'Stage/Filter: ASI Tiger Console', 'Pump: KD Scientific Legato 111', 'Camera: Hamamatsu Orca Flash 4.0', 'AOTF: Optoelectronics AOTF'};
instrumentClasses =     {'htDaq',                          'htASITigerConsole',               'htKDSPump',                      'htHamamatsu',                      'htAOTF'};

%% Initialize variables
% Initialize GUI variables
startGUI = [50, 50]; % Starting position of the bottom left side of the GUI, [x,y]
widthGUI = 700;
heightGUI = 700;
colorGUIBackground = [0.9444, 0.9444, 0.9444];
mainPanelInsetDistanceX = 1;
mainPanelInsetDistanceY = 3;
textSpacingBufferDX = 10;
textSpacingBufferDY = 5;
uiTitleTextHeight = 30;
uiTitleFontSize = 20;
uiTitleFontColor = [0.4, 0.4, 0.4];
htStartGuiMainFont = 'Arial'; % 'Apercu Mono', 'Arial', 'Helvetica', 'Garamond', 'Calibri', 'Futura', 'Brandon Grotesque', 'Neuzeit', 'Syntax'
htStartGuiMainFontWeight = 'Normal'; % 'Normal', 'Bold'
htStartGuiFontSize = 16;
htStartGuiFontColor = [0.2, 0.2, 0.2];
htStartGuiConnectionBGColor = [0.5, 0.5, 0.5];
htStartGuiConnectionFontColor = [0.95, 0.95, 0.95];
checkboxLength = 20;
checkboxYOffset = 8;
textInputYOffset = 2;
guiSettingsFontSize = 14;
guiSettingsFontColor = [0.4, 0.4, 0.4];
pushButtonWidth = 125;
pushButtonHeight = 56;
buttonFontSize = 12;
startButtonBGColor = [0.3, 0.6, 1];
startButtonFontColor = [0.95, 0.95, 0.95];
saveDefaultButtonBGColor = [0.4, 0.4, 0.4];
saveDefaultButtonFontColor = [0.95, 0.95, 0.95];
closeButtonBGColor = saveDefaultButtonBGColor;
closeButtonFontColor = saveDefaultButtonFontColor;
mainPanelPosition = [mainPanelInsetDistanceX, mainPanelInsetDistanceY, widthGUI - 2*mainPanelInsetDistanceX, heightGUI - 2*mainPanelInsetDistanceY];
mainRectangleCurvature = 0;
mainRectangleColor = [0.9, 0.9, 0.9];
mainRectangleEdgeColor = 'none';
mainRectangleLightingIntensity = 0.4;
mainRectangleLightingAngle = 70; % Spans from 0 to 360, 0 being from the right
mainTitlePosition = [mainPanelInsetDistanceX + textSpacingBufferDX, heightGUI - mainPanelInsetDistanceY - textSpacingBufferDY - uiTitleTextHeight, widthGUI - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX, uiTitleTextHeight];
% rootDefaultPathDirectory = userpath; % Can't use this because apparently
% this computer is messed up somehow
rootDefaultPathDirectory = pwd;
rootDefaultPathName = 'htMostRecentDefaultPath.mat';
rootDefaultPathFileName = strcat(rootDefaultPathDirectory, filesep, rootDefaultPathName);
defaultFileName = 'mostRecentHTSettings';

% Table variables
rowDeltaY = 60 + 2*textSpacingBufferDY;
column1Width = 11*(widthGUI - 6*textSpacingBufferDX - 2*mainPanelInsetDistanceX)/18;
column1X = mainPanelInsetDistanceX + textSpacingBufferDX;
column2Width = (widthGUI - 6*textSpacingBufferDX - 2*mainPanelInsetDistanceX)/18;
column2X = column1X + column1Width + 2*textSpacingBufferDX;
column3Width = 6*(widthGUI - 6*textSpacingBufferDX - 2*mainPanelInsetDistanceX)/18;
column3X = column2X + column2Width + 2*textSpacingBufferDX;
row1Y = heightGUI - mainPanelInsetDistanceY - textSpacingBufferDY - 2*uiTitleTextHeight;
columnWidth5Columns = (widthGUI - 10*textSpacingBufferDX - 2*mainPanelInsetDistanceX)/5;

%% Create GUI
% Create figure
f = figure('Visible','off','Position', [startGUI(1), startGUI(2), widthGUI, heightGUI] );
a = axes;
% Stretch the axes over the whole figure.
set(a, 'Position', [0, 0, 1, 1]);
% Switch off autoscaling, remove ticks, change font
set(a, 'Xlim', [0, widthGUI], 'YLim', [0, heightGUI]);
set(a, 'XTick',[], 'YTick',[]);
set(gca, 'FontName', htStartGuiMainFont)

% Obtain parameters, either by a previously made file or by defining them
[settings, restartBool] = populateSettings(false);

% If the file structure doesn't match this code's structure, restart
if(restartBool)
    close(f);
    htStartGui;
    return;
end

% Initialize uicontrol handles
numInstrs = size(settings.useInstruments, 2);
useDAQConnectionControl = gobjects(1, numInstrs);

% Create colored regions
% rectangle(f, 'Position', [0, 0, widthGUI, heightGUI], 'Curvature', 0, 'FaceColor', colorGUIBackground, 'Parent', a);
rectangle('Position', [0, 0, widthGUI, heightGUI], 'Curvature', 0, 'FaceColor', colorGUIBackground, 'Parent', a);
shadowedRectangle(mainPanelPosition, mainRectangleCurvature, mainRectangleColor, mainRectangleEdgeColor, mainRectangleLightingIntensity, mainRectangleLightingAngle)

% Create Title
uicontrol('Parent',f,'Style','text',...
    'String','HIGH THROUGHPUT CONFIGURATION',...
    'FontName', htStartGuiMainFont,...
    'FontSize', uiTitleFontSize,...
    'FontWeight', htStartGuiMainFontWeight,...
    'backgroundcolor',mainRectangleColor,...
    'foregroundcolor',uiTitleFontColor,...
    'Position',mainTitlePosition);

% Create names, checkboxes, and connection strings for the instruments
for i=1:numInstrs
    
    % Create the lefthand labels for the ith instrument
    uicontrol('Parent', f, 'Style', 'text',...
    'String', settings.instrumentNames{i},...
    'FontName', htStartGuiMainFont,...
    'FontSize', htStartGuiFontSize,...
    'FontWeight', htStartGuiMainFontWeight,...
    'backgroundcolor', mainRectangleColor,...
    'foregroundcolor', htStartGuiFontColor,...
    'HorizontalAlignment', 'left',...
    'Position', [column1X, row1Y - (i - 1)*rowDeltaY - uiTitleTextHeight, column1Width, uiTitleTextHeight]);
    
    % Create the checkbox for the ith instrument
    uicontrol('Parent', f, 'Style', 'checkbox',...
        'Value', settings.useInstruments(i),...
        'backgroundcolor', mainRectangleColor,...
        'Position', [column2X + column2Width/2 - checkboxLength/2, row1Y - (i - 1)*rowDeltaY + checkboxYOffset - uiTitleTextHeight, checkboxLength, checkboxLength],...
        'Callback', {@useInstrumentCheckbox_Callback, i});
    
    % Determine if the user previously wanted to use the ith instrument
    if(settings.useInstruments(i))
        enableStr = 'on';
    else
        enableStr = 'off';
    end
    
    % Determine the connection string for the ith instrument
    useDAQConnectionControl(i) = uicontrol('Parent', f,...
    'Style', 'edit',...
    'String', settings.instrumentConnections{i},...
    'backgroundcolor', htStartGuiConnectionBGColor,...
    'foregroundcolor', htStartGuiConnectionFontColor,...
    'Enable', enableStr,...
    'Position', [column3X, row1Y - (i - 1)*rowDeltaY + textInputYOffset - uiTitleTextHeight, column3Width, uiTitleTextHeight],...
    'Callback', {@useDAQConnectionString_Callback, i});

end

% Create GUI attributes section labels
repeatString = {'Start X', 'Start Y', 'Width', 'Height'};
% Create label GUI
uicontrol('Parent', f, 'Style', 'text',...
    'String', 'GUI',...
    'FontName', htStartGuiMainFont,...
    'FontSize', htStartGuiFontSize,...
    'FontWeight', htStartGuiMainFontWeight,...
    'backgroundcolor', mainRectangleColor,...
    'foregroundcolor', htStartGuiFontColor,...
    'HorizontalAlignment', 'right',...
    'Position', [column1X, row1Y - i*rowDeltaY - uiTitleTextHeight, columnWidth5Columns, uiTitleTextHeight]);
for j=1:size(repeatString, 2)
    
    % Create label for jth position
    uicontrol('Parent', f, 'Style', 'text',...
        'String', repeatString{j},...
        'FontName', htStartGuiMainFont,...
        'FontSize', guiSettingsFontSize,...
        'FontWeight', htStartGuiMainFontWeight,...
        'backgroundcolor', mainRectangleColor,...
        'foregroundcolor', htStartGuiFontColor,...
        'HorizontalAlignment', 'center',...
        'Position', [column1X + j*columnWidth5Columns + 2*j*textSpacingBufferDX, row1Y - i*rowDeltaY - 2*uiTitleTextHeight, columnWidth5Columns, uiTitleTextHeight]);
    
    % Create input for the jth position
    uicontrol('Parent', f, 'Style', 'edit',...
        'String', num2str(settings.positionGUI(j)),...
        'FontName', htStartGuiMainFont,...
        'FontSize', guiSettingsFontSize,...
        'FontWeight', htStartGuiMainFontWeight,...
        'backgroundcolor', mainRectangleColor,...
        'foregroundcolor', guiSettingsFontColor,...
        'HorizontalAlignment', 'center',...
        'Position', [column1X + j*columnWidth5Columns + 2*j*textSpacingBufferDX, row1Y - i*rowDeltaY - uiTitleTextHeight, columnWidth5Columns, uiTitleTextHeight],...
        'Callback', {@guiSettings_Callback, j});
end

% Create save as default button
uicontrol('Parent', f, 'Style', 'pushbutton',...
    'String','Save As Default',...
    'FontSize', buttonFontSize,...
    'backgroundcolor', saveDefaultButtonBGColor,...
    'foregroundcolor', saveDefaultButtonFontColor,...
    'Position',[mainPanelInsetDistanceX + textSpacingBufferDX, mainPanelInsetDistanceY + textSpacingBufferDY, pushButtonWidth, pushButtonHeight],...
    'Callback',{@saveAsDefault_Callback});

% Create start button
uicontrol('Parent', f, 'Style', 'pushbutton',...
    'String','Start!',...
    'FontSize', buttonFontSize,...
    'backgroundcolor', startButtonBGColor,...
    'foregroundcolor', startButtonFontColor,...
    'Position',[(widthGUI - 2*textSpacingBufferDX - 2*mainPanelInsetDistanceX)/2 + textSpacingBufferDX + mainPanelInsetDistanceX - pushButtonWidth/2, mainPanelInsetDistanceY + textSpacingBufferDY, pushButtonWidth, pushButtonHeight],...
    'Callback',{@start_Callback});

% Create close button
uicontrol('Parent', f, 'Style', 'pushbutton',...
    'String','Close',...
    'FontSize', buttonFontSize,...
    'backgroundcolor', closeButtonBGColor,...
    'foregroundcolor', closeButtonFontColor,...
    'Position',[widthGUI - textSpacingBufferDX - mainPanelInsetDistanceX - pushButtonWidth, mainPanelInsetDistanceY + textSpacingBufferDY, pushButtonWidth, pushButtonHeight],...
    'Callback',{@close_Callback});

% Make figure visible
f.Visible = 'on';

%% Callback functions

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: useInstrumentCheckbox_Callback
    %
    % A function which creates a rectangle that appears to be floating and
    % casting a shadow.
    %
    % Inputs: hObject = Handle to the checkbox. Suppressed during call.
    %         eventData = Event data for the checkbox. Suppressed during
    %            call. Unused.
    %         i = The index that this particular checkbox is associated
    %            with for the other handle array useDAQConnectionControl
    % Outputs: 
    %
    % Example: ... 'Callback', {@useInstrumentCheckbox_Callback, 6},...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function useInstrumentCheckbox_Callback(hObject, ~, i)
        settings.useInstruments(i) = logical(get(hObject,'Value'));
        if(~settings.useInstruments(i))
            useDAQConnectionControl(i).set('Enable', 'off');
        else
            useDAQConnectionControl(i).set('Enable', 'on', 'backgroundcolor', [1, 1, 1], 'foregroundcolor', [1, 1, 1]);
            useDAQConnectionControl(i).set('backgroundcolor', htStartGuiConnectionBGColor, 'foregroundcolor', htStartGuiConnectionFontColor); % 'Bug' in Matlab makes this background not update correctly if the values match its previous setting.
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: useDAQConnectionString_Callback
    %
    % A function which sets the string used for determining the connection 
    % type for the ith instrument.
    %
    % Inputs: hObject = Handle to the checkbox. Suppressed during call.
    %         eventData = Event data for the checkbox. Suppressed during
    %            call. Unused.
    %         i = The index that this particular checkbox is associated
    %            with for the other string cell array 
    %            settings.instrumentConnections
    % Outputs: 
    %
    % Example: ... 'Callback', {@useDAQConnectionString_Callback, 6},...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function useDAQConnectionString_Callback(hObject, ~, i)
        settings.instrumentConnections{i} = get(hObject,'String');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: guiSettings_Callback
    %
    % A function which sets the jth position of the htGui.m position
    % vector.
    %
    % Inputs: hObject = Handle to the checkbox. Suppressed during call.
    %         eventData = Event data for the checkbox. Suppressed during
    %            call. Unused.
    %         j = The index that this particular checkbox is associated
    %            with for the htGui.m position vector
    % Outputs: 
    %
    % Example: ... 'Callback', {@guiSettings_Callback, 6},...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function guiSettings_Callback(hObject, ~, j)
        settings.positionGUI(j) = str2double(get(hObject,'String'));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: saveAsDefault_Callback
    %
    % A function which saves the current settings in a file given a
    % pathname stored withing the same setting variable.
    %
    % Inputs: hObject = Handle to the checkbox. Suppressed during call.
    %            Unused.
    %         eventData = Event data for the checkbox. Suppressed during
    %            call. Unused.
    % Outputs: 
    %
    % Example: ... 'Callback', {@saveAsDefault_Callback},...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function saveAsDefault_Callback(~, ~)
        try
            defaultPath = settings.defaultPath;
            defaultFileName = settings.defaultFileName;
            save(rootDefaultPathFileName, 'defaultPath', 'defaultFileName');
            save(strcat(defaultPath, filesep, defaultFileName), 'settings');
        catch ME1 %#ok
            waitfor(msgbox('The most recent settings were not saved correctly. Sorry but a new one will be made.', 'File unusable.', 'Error', 'error'));
            [settings, restartBool] = populateSettings(true);
            save(rootDefaultPathFileName, 'rootDefaultPathDirectory', 'rootDefaultPathFileName');
            save(strcat(rootDefaultPathDirectory, filesep, defaultFileName), 'settings');
            close(f);
            htStartGui;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: start_Callback
    %
    % A function which closes this gui and opens the htGui, passing the
    % parameters chosen in this gui.
    %
    % Inputs: hObject = Handle to the checkbox. Suppressed during call.
    %            Unused.
    %         eventData = Event data for the checkbox. Suppressed during
    %            call. Unused.
    % Outputs: 
    %
    % Example: ... 'Callback', {@start_Callback},...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function start_Callback(~, ~)
        close(f);
        htGui(settings);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: close_Callback
    %
    % A function which closes this gui.
    %
    % Inputs: hObject = Handle to the checkbox. Suppressed during call.
    %            Unused.
    %         eventData = Event data for the checkbox. Suppressed during
    %            call. Unused.
    % Outputs: 
    %
    % Example: ... 'Callback', {@close_Callback},...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function close_Callback(~, ~)
        close(f);
    end

%% Auxiliary functions

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: shadowedRectangle
    %
    % A function which creates a rectangle that appears to be floating and
    % casting a shadow.
    %
    % Inputs: SRPositionVect - See 'rectangle' property 'Position'
    %         SRCurvature - See 'rectangle' property 'Curvature'
    %         SRFaceColor - See 'rectangle' property 'FaceColor'
    %         SREdgeColor - See 'rectangle' property 'EdgeColor'
    %         SRLightIntensity - A number from 0 to 1 indicating how
    %           "harsh" the lighting should be, with larger numbers
    %           increasing contrast.
    %         SRLightingAngle - A number from 0 to 360 indicating the
    %           direction the lighting should come from, with 0 being a
    %           light source to the right of the screen.
    % Outputs: 
    %
    % Example: shadowedRectangle([50, 50, widthGUI - 100, heightGUI - 100], 0, [0.8, 0.8, 0.8], 'none', 0.6, 45);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function shadowedRectangle(SRPositionVect, SRCurvature, SRFaceColor, SREdgeColor, SRLightIntensity, SRLightingAngle)
        
        % Initialize variables
        numUnitsOffset = 3;
        brightColor = SRFaceColor + SRLightIntensity*(1 - SRFaceColor);
        darkColor = (1 - SRLightIntensity)*colorGUIBackground;
        
        % Define lighting/shading rectangle positions
        lightRectanglePosition = SRPositionVect;
        if(SRLightingAngle >= 0 && SRLightingAngle < 90)
            normalRectanglePosition = [SRPositionVect(1), SRPositionVect(2), SRPositionVect(3) - numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) - numUnitsOffset*sind(SRLightingAngle)];
            darkRectanglePosition = [SRPositionVect(1) - numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(2) - numUnitsOffset*sind(SRLightingAngle), SRPositionVect(3) + 0.5*numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) + 0.5*numUnitsOffset*sind(SRLightingAngle)];
        elseif(SRLightingAngle >= 90 && SRLightingAngle < 180)
            normalRectanglePosition = [SRPositionVect(1) - numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(2), SRPositionVect(3) + numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) - numUnitsOffset*sind(SRLightingAngle)];
            darkRectanglePosition = [SRPositionVect(1) - 0.5*numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(2) - numUnitsOffset*sind(SRLightingAngle), SRPositionVect(3) - 0.5*numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) + 0.5*numUnitsOffset*sind(SRLightingAngle)];
        elseif(SRLightingAngle >= 180 && SRLightingAngle < 270)
            normalRectanglePosition = [SRPositionVect(1) - numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(2) - numUnitsOffset*sind(SRLightingAngle), SRPositionVect(3) + numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) + numUnitsOffset*sind(SRLightingAngle)];
            darkRectanglePosition = [SRPositionVect(1) - 0.5*numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(2) - 0.5*numUnitsOffset*sind(SRLightingAngle), SRPositionVect(3) - 0.5*numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) - 0.5*numUnitsOffset*sind(SRLightingAngle)];
        else
            normalRectanglePosition = [SRPositionVect(1), SRPositionVect(2) - numUnitsOffset*sind(SRLightingAngle), SRPositionVect(3) - numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) + numUnitsOffset*sind(SRLightingAngle)];
            darkRectanglePosition = [SRPositionVect(1) - numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(2) - 0.5*numUnitsOffset*sind(SRLightingAngle), SRPositionVect(3) + 0.5*numUnitsOffset*cosd(SRLightingAngle), SRPositionVect(4) - 0.5*numUnitsOffset*sind(SRLightingAngle)];
        end

        % Create rectangles
        rectangle('Position', darkRectanglePosition, 'Curvature', SRCurvature, 'FaceColor', darkColor, 'EdgeColor', 'none', 'Parent', a); % Dark shadow
        rectangle('Position', lightRectanglePosition, 'Curvature', SRCurvature, 'FaceColor', brightColor, 'EdgeColor', SREdgeColor, 'Parent', a); % Lighting
        rectangle('Position', normalRectanglePosition, 'Curvature', SRCurvature, 'FaceColor', SRFaceColor, 'EdgeColor', 'none', 'Parent', a); % Base rectangle
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: populateSettings
    %
    % A function which either loads or creates the default settings which
    % populate the GUI.
    %
    % Inputs: forceNewSettings - A boolean which forces the program to
    %                            initialize new settings regardless of path
    %                            or setting contents.
    % Outputs: settings - A structure containing positionGUI,
    %                       useInstruments, instrumentNames,
    %                       instrumentClasses, instrumentConnections,
    %                       saveDirectoryAndName, defaultPath, and
    %                       defaultFileName.
    %          restartProgram -  A bool which informs the calling function
    %                            to close itself and restart the program.
    %
    % Example: [settings, restartProgram] = populateSettings(true)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [settings, restartProgram] = populateSettings(forceNewSettings)
        
        settingsLoadedCorrectlyBool = true;
        needToAskToReplace = false;
        restartProgram = false;
        
        % Either make or load the most recent settings
        if(~isempty(dir(rootDefaultPathFileName)) && ~forceNewSettings)
            try
                % Load settings from defined path in the root file
                defaultFileContents = load(rootDefaultPathFileName);
                defaultPath = defaultFileContents.defaultPath;
                defaultFileName = defaultFileContents.defaultFileName;
                defaultSettingsContents = load(strcat(defaultPath, filesep, defaultFileName));
                settings = defaultSettingsContents.settings;
                
                % Determine if the settings match characteristics of the current settings and if not allow user to restore default
                numInstruments = size(settings.useInstruments, 2);
                if(size(instrumentConnections, 2) ~= numInstruments)
                    needToAskToReplace = true;
                else
                    for ii=1:numInstruments
                        if(~strcmp(settings.instrumentNames{ii}, instrumentNames{ii}))
                            needToAskToReplace = true;
                        end
                    end
                end
                
            catch ME1 %#ok Leave this comment to keep the warning about not using the variable from popping up
                
                settingsLoadedCorrectlyBool = false;
                waitfor(msgbox('The most recent settings file was not saved with the correct structure, can''t be found, or is corrupted. A new one will be made.', 'File unusable.', 'Error', 'error'));

            end
        end
        
        if(needToAskToReplace)
            choice = questdlg('The code has been altered to include/remove/change the instrument choices. Would you like to use the new instruments choices (resets defaults)?', ...
                'Yes', 'No');
            if(strcmp(choice,'Yes'))
                forceNewSettings = true;
                restartProgram = true;
            end
        end
        
        if(~settingsLoadedCorrectlyBool || isempty(dir(rootDefaultPathFileName)) || forceNewSettings)
            % Create new default path file, save it
            if(~forceNewSettings && settingsLoadedCorrectlyBool)
                waitfor(msgbox(strcat({'The '}, rootDefaultPathName, {' file was either deleted or corrupted. A new one will be made.'}), 'Unusable Settings File'));
            end
            defaultPath = rootDefaultPathDirectory;
            save(rootDefaultPathFileName, 'defaultPath', 'defaultFileName');
            
            % Create settings, save it
            settings = [];
            settings.positionGUI = [0, 95, 1280, 665];
            settings.useInstruments = true(1,size(instrumentConnections,2));
            settings.instrumentNames = instrumentNames;
            settings.instrumentClasses = instrumentClasses;
            settings.instrumentConnections = instrumentConnections;
            settings.saveDirectoryAndName = strcat(defaultPath, filesep, defaultFileName);
            settings.defaultPath = defaultPath;
            settings.defaultFileName = defaultFileName;
            settings.defaultFrontPanelSettings.finiteLoop = true;
            settings.defaultFrontPanelSettings.finiteLoopNum = 10;
            save(strcat(defaultPath, filesep, defaultFileName), 'settings');
        end
    end

end