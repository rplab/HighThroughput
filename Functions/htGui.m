%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: htGui
%
% A function
%
% Ideas: Can you make a listbox only do something on double-click?
%
% To do: If you load a procedure stack with less entries than your current
%          clicked position, the window becomes invisible.
%        Remove ability to add procedures while program is running
%        Delete button checks if inputs to further functions rely on its
%          outputs. Same for reordering buttons.
%        Make procedure reordering buttons and edit button work.
%        Make outputs at position i in procedure window be used as
%          inputs at positions i+1...N.
%        Allow user to "eval" outputs too.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function htGui(htSettings)

%% Create instances using the instrument names and classes in settings
% If htGui is naively invoked, just autopopulate settings
if(nargin ~= 1)
    htSettings.positionGUI = [0, 95, 1280, 665];
    htSettings.useInstruments = [false, false, false, false, false];
    htSettings.instrumentNames =        {'DAQ: National Instruments 6343 HTDev1', 'Stage/Filter: ASI Tiger Console', 'Pump 1: KD Scientific Legato 111', 'Camera: Hamamatsu Orca Flash 4.0', 'AOTF: Optoelectronics AOTF'};
    htSettings.instrumentClasses =      {'htDaq',                                 'htASITigerConsole',               'htKDSPump',                        'htHamamatsu',                      'htAOTF'};
    htSettings.instrumentConnections =  {'HTDev1',                                'Com5',                            'Com25',                            'hamamatsu',                        'Com19'};
    htSettings.instrumentSessionNames = {'niDaqSession',                          'asiSerialObj',                    'kdsPumpSerialObj',                 'hamamatsuCameraObj',               'aotfSerialObj'};
    htSettings.saveDirectoryAndName = strcat(strcat('~', filesep, 'Documents', filesep, 'MATLAB'), filesep, 'mostRecentHTSettings');
    htSettings.defaultPath = strcat('~', filesep, 'Documents', filesep, 'MATLAB');
    htSettings.defaultFileName = 'htStartGuiSettings';
end

% Instantiate procedure/instrument classes
procedureInstance = htRunProcedure; % DO NOT CHANGE THIS NAME, it is called as a string later
numInstruments = size(htSettings.instrumentClasses, 2);
instrumentInstancesCellArray = cell(1,numInstruments); % DO NOT CHANGE THIS NAME, it is called as a string later
for instantiatingIndex=1:numInstruments
    instrumentInstancesCellArray{instantiatingIndex} = eval(htSettings.instrumentClasses{instantiatingIndex});
    instrumentInstancesCellArray{instantiatingIndex}.userWantsToConnect = logical(htSettings.useInstruments(instantiatingIndex));
    instrumentInstancesCellArray{instantiatingIndex}.connectionChannelOrTypeString = htSettings.instrumentConnections(instantiatingIndex);
end

% Initialize any variables you want access to here (even if defined below, use [])
infoWindow = [];

%% Variables to see in the "Add Procedure" panel (i.e. after clicking the arrow) should be defined prior to this
% Initialize variables to provide procedures
obj = 'obj'; %#ok since this is a dummy variable to help automate the autofilling processes of the add procedure buttons
currentLoopNumber = 1;
instrumentSessionsCellArray = [];
niDaqSession = []; %#ok Make sure these match the settings.InstrumentSessionNames
asiSerialObj = []; %#ok Make sure these match the settings.InstrumentSessionNames
kdsPumpSerialObj = []; %#ok Make sure these match the settings.InstrumentSessionNames
hamamatsuCameraObj = [];
aotfSerialObj = []; %#ok Make sure these match the settings.InstrumentSessionNames
unusedVariable1 = []; %#ok This is for the user to store temporary information when running the program
unusedVariable2 = []; %#ok This is for the user to store temporary information when running the program
unusedVariable3 = []; %#ok This is for the user to store temporary information when running the program
unusedVariable4 = []; %#ok This is for the user to store temporary information when running the program
unusedVariable5 = []; %#ok This is for the user to store temporary information when running the program
curVariables = who; % Get a list of all the available variables created above this line

%% Initialize variables
        
% Initialize procedure/instrument variables
metaClassMenuChoices = htSettings.instrumentNames;
metaClassMenuChoices = ['Procedures', metaClassMenuChoices];
metaClassNameCellArray = htSettings.instrumentClasses;
metaClassNameCellArray = ['htRunProcedure', metaClassNameCellArray];
procedureAndInstrumentSettings.finiteLoop = true;
procedureAndInstrumentSettings.finiteLoopNum = 10;

% Initialize handles to a few buttons
toAddEndButtonControl = [];
toAddLoopButtonControl = [];
toAddStartButtonControl = [];
runButtonControl = [];

% Initialize GUI variables
stopBool = false;
pauseBool = false;
previewBool = false;
isRunning = false;
positionGUI = htSettings.positionGUI;
widthGUI = positionGUI(3);
heightGUI = positionGUI(4);
colorGUIBackground = [0.9444, 0.9444, 0.9444];
% colorWindowEdge = [0.75, 0.75, 0.75];
% windowEdgeThickness = 0.75;
mainPanelInsetDistanceX = 1;
mainPanelInsetDistanceY = 3;
textSpacingBufferDX = 10;
textSpacingBufferDY = 5;
uiTitleTextHeight = 30;
uiTitleFontSize = 16;
uiTitleFontColor = [0.4, 0.4, 0.4];
htGuiMainFont = 'Arial'; % 'Apercu Mono', 'Arial', 'Helvetica', 'Garamond', 'Calibri', 'Futura', 'Brandon Grotesque', 'Neuzeit', 'Syntax'
htGuiMainFontWeight = 'Normal'; % 'Normal', 'Bold'
htGuiFontColor = [0.2, 0.2, 0.2];
htGuiConnectionBGColor = [0.5, 0.5, 0.5];
htGuiConnectionFontColor = [0.95, 0.95, 0.95];
htGuiFontSize = 14;
guiTitleHeight = 30;
checkboxLength = 20;
checkboxYOffset = 8;
popUpBGColor = [0.75, 0.75, 0.75];
popUpFontColor = [0.4, 0.4, 0.4];
pushButtonWidth = 125;
pushButtonHeight = 56;
smallPushButtonLength = 18;
smallPushButtonDeltaX = 3;
smallPushButtonBGColor = [0.5, 0.5, 0.5];
addProceduresButtonWidth = 30;
buttonFontSize = 12;
startButtonBGColor = [0.3, 0.6, 1];
startButtonFontColor = [0.95, 0.95, 0.95];
saveDefaultButtonBGColor = [0.4, 0.4, 0.4];
saveDefaultButtonFontColor = [0.95, 0.95, 0.95];
stopButtonBGColor = [0.7, 0.2, 0.2];
stopButtonFontColor = [0.95, 0.95, 0.95];
closeButtonBGColor = saveDefaultButtonBGColor;
closeButtonFontColor = saveDefaultButtonFontColor;
toAddMethodNumSelected = 1;
toRunMethodNumSelected = 1;
metaClassNumSelected = 1;
toRunProceduresWidth = 300;
toAddProceduresWidth = 200;
proceduresEndHeight = 75;
proceduresLoopHeight = 175;
proceduresStartHeight = 75;
procedureToRunDeltaXFromRightSide = 3*pushButtonWidth/4;
toRunProceduresEndPosition = [widthGUI - mainPanelInsetDistanceX - 2*textSpacingBufferDX - toRunProceduresWidth - procedureToRunDeltaXFromRightSide, mainPanelInsetDistanceY + 3*textSpacingBufferDY + pushButtonHeight, toRunProceduresWidth, proceduresEndHeight];
toRunProceduresLoopPosition = toRunProceduresEndPosition  + [0, textSpacingBufferDY + toRunProceduresEndPosition(4), 0, proceduresLoopHeight - toRunProceduresEndPosition(4)];
toRunProceduresStartPosition = toRunProceduresLoopPosition + [0, textSpacingBufferDY + toRunProceduresLoopPosition(4), 0, proceduresStartHeight - toRunProceduresLoopPosition(4)];
toAddProceduresPosition = [toRunProceduresLoopPosition(1) - toAddProceduresWidth - 2*textSpacingBufferDX - addProceduresButtonWidth, toRunProceduresEndPosition(2), toAddProceduresWidth, proceduresEndHeight + proceduresLoopHeight + proceduresStartHeight + 2*textSpacingBufferDY];
procedureButtonWidths = (toRunProceduresWidth - 2*textSpacingBufferDX)/3;
procedureButtonHeights = 3*pushButtonHeight/8;
proceduresSaveAsButtonPosition = [toRunProceduresStartPosition(1), toRunProceduresStartPosition(2) + proceduresEndHeight + textSpacingBufferDY, procedureButtonWidths, procedureButtonHeights];
proceduresSaveDefaultButtonPosition = [proceduresSaveAsButtonPosition(1) + textSpacingBufferDX + procedureButtonWidths, proceduresSaveAsButtonPosition(2), procedureButtonWidths, procedureButtonHeights];
proceduresLoadButtonPosition = [proceduresSaveDefaultButtonPosition(1) + textSpacingBufferDX + procedureButtonWidths, proceduresSaveDefaultButtonPosition(2), procedureButtonWidths, procedureButtonHeights];
metaClassDropDownBoxHeight = 40;
metaClassChoicePosition = [toAddProceduresPosition(1), toRunProceduresStartPosition(2) + proceduresStartHeight - 14, toAddProceduresWidth, metaClassDropDownBoxHeight];
addProceduresEndButtonPosition = [toRunProceduresLoopPosition(1) - textSpacingBufferDX - addProceduresButtonWidth, toRunProceduresEndPosition(2), addProceduresButtonWidth, proceduresEndHeight];
addProceduresLoopButtonPosition = [toRunProceduresLoopPosition(1) - textSpacingBufferDX - addProceduresButtonWidth, toRunProceduresLoopPosition(2), addProceduresButtonWidth, proceduresLoopHeight];
addProceduresStartButtonPosition = [toRunProceduresLoopPosition(1) - textSpacingBufferDX - addProceduresButtonWidth, toRunProceduresStartPosition(2), addProceduresButtonWidth, proceduresStartHeight];
proceduresEndTextLabelPosition = [toRunProceduresEndPosition(1) + toRunProceduresEndPosition(3) + textSpacingBufferDX, toRunProceduresEndPosition(2) + toRunProceduresEndPosition(4) - uiTitleTextHeight, procedureToRunDeltaXFromRightSide - textSpacingBufferDX, uiTitleTextHeight];
proceduresLoopTextLabelPosition = [proceduresEndTextLabelPosition(1), toRunProceduresLoopPosition(2) + toRunProceduresLoopPosition(4) - uiTitleTextHeight, proceduresEndTextLabelPosition(3), uiTitleTextHeight];
proceduresStartTextLabelPosition = [proceduresLoopTextLabelPosition(1), toRunProceduresStartPosition(2) + toRunProceduresStartPosition(4) - uiTitleTextHeight, proceduresEndTextLabelPosition(3), uiTitleTextHeight];

% Create metaclasses from all wanted
numMetaClasses = size(metaClassNameCellArray, 2);

% Instantiate classes
curMetaClass = meta.class.fromName(metaClassNameCellArray{1});
curMethods = {curMetaClass.MethodList.Name}';
curMethods(strcmp('empty',curMethods), :) = [];
curMethods(strcmp('htRunProcedure',curMethods), :) = [];
curMethodsToRunCells = cell(3, 1);

% Add procedure to run list variables;
% NOTE: IF YOU CHANGE THE STRUCTURE HERE, REMEMBER TO CHANGE IT IN generateProcedureStructureAndGUI
procedureVarsStructure = struct('Class', {'', '', ''}, 'Method', {'', '', ''}, 'DescriptionString', {'', '', ''},...
    'InputStructure', cell(1,1),...
    'OutputStructure', cell(1,1));
toAddStructure = procedureVarsStructure(1);
initialEmptyStruct = procedureVarsStructure;
toRunProceduresEndListbox = [];
toRunProceduresLoopListbox = [];
toRunProceduresStartListbox = [];
finiteLoopCheckboxControl = [];
loopNumControl = [];

%% Create GUI

% Create figure
f = figure('Visible','off','Position', positionGUI);
a = axes;
aa = axes;

% Stretch the axes over the whole figure.
set(a, 'Position', [0, 0, 1, 1]);

% Switch off autoscaling.
set(a, 'Xlim', [0, widthGUI], 'YLim', [0, heightGUI]);
set(a, 'XTick',[], 'YTick',[]);
set(a, 'FontName', htGuiMainFont)

% Stretch the axes over half(?) of the figure.
procedureWindowPosition = [toAddProceduresPosition(1) - textSpacingBufferDX, textSpacingBufferDY/2, widthGUI - (toAddProceduresPosition(1) - textSpacingBufferDX/2), proceduresStartTextLabelPosition(2) + proceduresStartTextLabelPosition(4) + 2*textSpacingBufferDY + procedureButtonHeights + uiTitleTextHeight];
cameraPreviewPosition = [textSpacingBufferDX/widthGUI, textSpacingBufferDY/heightGUI, (procedureWindowPosition(1) - 2*textSpacingBufferDX)/widthGUI, (procedureWindowPosition(1) - 2*textSpacingBufferDX)/heightGUI];
set(aa, 'Position', cameraPreviewPosition); % X component empirically determined
% Switch off autoscaling.
set(aa, 'Xlim', [0, widthGUI], 'YLim', [0, heightGUI]);
set(aa, 'XTick',[], 'YTick',[]);

% Make figure visible
f.Visible = 'on';
%undecorateFig(f); % Useful to remove the red x which shouldn't be pressed (as it can destroy handles to instruments being communicated with, leaving them orphaned, sometimes requiring restarts)

% Figure background
rectangle('Position', [0, 0, widthGUI, heightGUI], 'Curvature', 0, 'FaceColor', colorGUIBackground, 'Parent', a);

% Procedure Window
%rectangle('Position', procedureWindowPosition, 'Curvature', 0.025, 'FaceColor', colorGUIBackground, 'EdgeColor', colorWindowEdge, 'LineWidth', windowEdgeThickness, 'Parent', a);
uicontrol('Parent',f,'Style','text',...
            'String','PROCEDURE WINDOW',...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'HorizontalAlignment', 'Center',...
            'Position', [procedureWindowPosition(1) + textSpacingBufferDX, procedureWindowPosition(2) + procedureWindowPosition(4) - textSpacingBufferDY - uiTitleTextHeight, procedureWindowPosition(3) - 2*textSpacingBufferDX, uiTitleTextHeight]);

% Create controls
generateInformationPanel;
generateProcedurePanel;
generateExperimentButtonsPanel;

% Populate with initial settings
% Populate initial settings
rootDefaultPathName = 'htGuiSettings.mat';
defaultFilePathAndFile = strcat(htSettings.defaultPath, filesep, rootDefaultPathName);
possibleFile = dir(defaultFilePathAndFile);
if(~isempty(possibleFile))
    loadData(defaultFilePathAndFile);
else
    procedureWindowStartStrings = get(toRunProceduresStartListbox, 'String');
    procedureWindowLoopStrings = get(toRunProceduresLoopListbox, 'String');
    procedureWindowEndStrings = get(toRunProceduresEndListbox, 'String');
    save(defaultFilePathAndFile, 'procedureVarsStructure', 'procedureAndInstrumentSettings', 'procedureWindowStartStrings', 'procedureWindowLoopStrings', 'procedureWindowEndStrings', 'curMethodsToRunCells');
end

% Connect to instruments. This code isn't strictly necessary but is going
% to make a lot of people's lives easier.
[procedureInstance, instrumentInstancesCellArray, instrumentSessionsCellArray] = procedureInstance.ConnectInstruments(infoWindow, instrumentInstancesCellArray);
niDaqSession = instrumentSessionsCellArray{1, 1};
asiSerialObj = instrumentSessionsCellArray{1, 2};
kdsPumpSerialObj = instrumentSessionsCellArray{1, 3};
hamamatsuCameraObj = instrumentSessionsCellArray{1, 4};
aotfSerialObj = instrumentSessionsCellArray{1, 5};

% Create instrument control buttons
generateInstrumentControlButtons;

%% Functions

    function generateInformationPanel
        
        % Information Window
        infoWindowListboxPosition = procedureWindowPosition + [0, procedureWindowPosition(4) + textSpacingBufferDY, 0, heightGUI - 4*textSpacingBufferDY - 2*procedureWindowPosition(4) - uiTitleTextHeight];
        infoWindow = uicontrol('Parent', f,...
            'Style', 'listbox',...
            'Max', 1,...
            'String', {datestr(datetime)},...
            'ListboxTop', 1,...
            'backgroundcolor', [1, 1, 1],...
            'foregroundcolor', [0, 0, 0],...
            'Position', infoWindowListboxPosition);
        uicontrol('Parent',f,'Style','text',...
            'String','INFORMATION WINDOW',...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'HorizontalAlignment', 'Center',...
            'Position', [toAddProceduresPosition(1), infoWindowListboxPosition(2) + infoWindowListboxPosition(4) + textSpacingBufferDY, procedureWindowPosition(3) - 2*textSpacingBufferDX, uiTitleTextHeight]);
        
        % Buttons to save and load procedure settings
        infoWindowClearButtonPosition = [widthGUI - textSpacingBufferDX - procedureButtonWidths, infoWindowListboxPosition(2) + infoWindowListboxPosition(4) + 2*textSpacingBufferDY, procedureButtonWidths, procedureButtonHeights];
        infoWindowSaveButtonPosition = infoWindowClearButtonPosition - [procedureButtonWidths + textSpacingBufferDX, 0, 0, 0];
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Save as...',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',infoWindowSaveButtonPosition,...
            'Callback',{@infoWindowSaveAsButton_Callback});
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Clear Screen',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',infoWindowClearButtonPosition,...
            'Callback',{@infoWindowClearButton_Callback});
        
        function infoWindowSaveAsButton_Callback(~, ~)
            infoWindowLog = get(infoWindow, 'String'); %#ok since we save it as a string below
            [FileName, PathToFile] = uiputfile('infoWindowLog.mat','Save file name');
            if(PathToFile ~= 0)
                save(strcat(PathToFile, filesep, FileName), 'infoWindowLog');
            end
        end
        
        function infoWindowClearButton_Callback(~, ~)
            set(infoWindow, 'Value', 1);
            set(infoWindow, 'String', {datestr(datetime)});
        end
        
    end

    function generateProcedurePanel
        
        % Create procedure tables
        toAddProceduresListbox = uicontrol('Parent', f,...
            'Style', 'listbox',...
            'Max', 1,...
            'String', curMethods,...
            'ListboxTop', toAddMethodNumSelected,...
            'backgroundcolor', htGuiConnectionBGColor,...
            'foregroundcolor', htGuiConnectionFontColor,...
            'Position', toAddProceduresPosition,...
            'Callback', {@toAddProcedureListBox_Callback});
        
        toRunProceduresEndListbox = uicontrol('Parent', f,...
            'Style', 'listbox',...
            'Max', 1,...
            'String', curMethodsToRunCells{3},...
            'ListboxTop', toRunMethodNumSelected,...
            'backgroundcolor', htGuiConnectionBGColor,...
            'foregroundcolor', htGuiConnectionFontColor,...
            'Position', toRunProceduresEndPosition,...
            'Callback', {@toRunProcedureListBox_Callback});
        
        toRunProceduresLoopListbox = uicontrol('Parent', f,...
            'Style', 'listbox',...
            'Max', 1,...
            'String', curMethodsToRunCells{2},...
            'ListboxTop', toRunMethodNumSelected,...
            'backgroundcolor', htGuiConnectionBGColor,...
            'foregroundcolor', htGuiConnectionFontColor,...
            'Position', toRunProceduresLoopPosition,...
            'Callback', {@toRunProcedureListBox_Callback});
        
        toRunProceduresStartListbox = uicontrol('Parent', f,...
            'Style', 'listbox',...
            'Max', 1,...
            'String', curMethodsToRunCells{1},...
            'ListboxTop', toRunMethodNumSelected,...
            'backgroundcolor', htGuiConnectionBGColor,...
            'foregroundcolor', htGuiConnectionFontColor,...
            'Position', toRunProceduresStartPosition,...
            'Callback', {@toRunProcedureListBox_Callback});
        
        % Create label beside to run procedures listboxes
        secondRowDeltaY = 25 + textSpacingBufferDY;
        uicontrol('Parent',f,'Style','text',...
            'String','END',...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'HorizontalAlignment', 'left',...
            'Position', proceduresEndTextLabelPosition);
        uicontrol('Parent',f,'Style','text',...
            'String','LOOP',...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'HorizontalAlignment', 'left',...
            'Position', proceduresLoopTextLabelPosition);
        uicontrol('Parent',f,'Style','text',...
            'String','N',...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'HorizontalAlignment', 'center',...
            'Position', proceduresLoopTextLabelPosition - [0, secondRowDeltaY, proceduresLoopTextLabelPosition(3)/2, proceduresLoopTextLabelPosition(4) - uiTitleTextHeight]);
        uicontrol('Parent',f,'Style','text',...
            'String','START',...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'HorizontalAlignment', 'left',...
            'Position', proceduresStartTextLabelPosition);
        
        % Create controls beside to run procedures listboxes
        if(procedureAndInstrumentSettings.finiteLoop)
            enableBool = 'on';
        else
            enableBool = 'off';
        end
        finiteLoopCheckboxControl = uicontrol('Parent', f, 'Style', 'checkbox',...
            'Value', procedureAndInstrumentSettings.finiteLoop,...
            'backgroundcolor', colorGUIBackground,...
            'Position', [proceduresLoopTextLabelPosition(1) + checkboxLength + textSpacingBufferDX, proceduresLoopTextLabelPosition(2) + checkboxYOffset - secondRowDeltaY, checkboxLength, checkboxLength],...
            'Callback', {@finiteLoopCheckbox_Callback});
        loopNumControl = uicontrol('Parent', f, 'Style', 'edit',...
            'String', num2str(procedureAndInstrumentSettings.finiteLoopNum),...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor', colorGUIBackground,...
            'foregroundcolor', uiTitleFontColor,...
            'HorizontalAlignment', 'center',...
            'Enable', enableBool,...
            'Position', [proceduresLoopTextLabelPosition(1), proceduresLoopTextLabelPosition(2) - secondRowDeltaY - textSpacingBufferDY - uiTitleTextHeight, proceduresLoopTextLabelPosition(3) - textSpacingBufferDX, uiTitleTextHeight],...
            'Callback', {@finiteLoopNumCheckbox_Callback});
        
        % Create list modification buttons
        smallButtonRowPositions = [toRunProceduresStartPosition(2), toRunProceduresLoopPosition(2), toRunProceduresEndPosition(2)] + 3;
        smallButtonColumnPositions = proceduresStartTextLabelPosition(1) + [0, smallPushButtonLength + smallPushButtonDeltaX, 2*(smallPushButtonLength + smallPushButtonDeltaX), 3*(smallPushButtonLength + smallPushButtonDeltaX)];
        smallButtonWidths = smallPushButtonLength + [0, 0, 0, 3*smallPushButtonLength/4];
        textStrings = {char(10005), char(8593), char(8595), 'Edit'};
        for i=1:3
            for j=1:4
                if(j == 1)
                    enableBoolString = 'on';
                    bgColor = smallPushButtonBGColor;
                else
                    enableBoolString = 'off';
                    bgColor = smallPushButtonBGColor + 2*(1 - smallPushButtonBGColor)/3;
                end
                uicontrol('Parent', f, 'Style', 'pushbutton',...
                    'String',textStrings{j},...
                    'FontSize', buttonFontSize,...
                    'Enable', enableBoolString,...
                    'backgroundcolor', bgColor,...
                    'foregroundcolor', closeButtonFontColor,...
                    'Position',[smallButtonColumnPositions(j), smallButtonRowPositions(i), smallButtonWidths(j), smallPushButtonLength],...
                    'Callback',{@listModifier_Callback, i, j});
            end
        end
        
        % Popup to change classes
        uicontrol('Parent', f,...
            'Style', 'popupmenu',...
            'Max', numMetaClasses,...
            'String', metaClassMenuChoices,...
            'backgroundcolor', popUpBGColor,...
            'foregroundcolor', popUpFontColor,...
            'Position', metaClassChoicePosition,...
            'Callback', {@metaClassChoicePopUp_Callback});
        
        % Buttons to add toAddProcedures to toRunProcedure window
        toAddEndButtonControl = uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','->',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',addProceduresEndButtonPosition,...
            'Callback',{@addProceduresEndButton_Callback});
        toAddLoopButtonControl = uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','->',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',addProceduresLoopButtonPosition,...
            'Callback',{@addProceduresLoopButton_Callback});
        toAddStartButtonControl = uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','->',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',addProceduresStartButtonPosition,...
            'Callback',{@addProceduresStartButton_Callback});
        
        % Buttons to save and load procedure settings
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Save as...',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',proceduresSaveAsButtonPosition,...
            'Callback',{@proceduresSaveAsButton_Callback});
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Save as Default',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',proceduresSaveDefaultButtonPosition,...
            'Callback',{@proceduresSaveDefaultButton_Callback});
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Load...',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',proceduresLoadButtonPosition,...
            'Callback',{@proceduresLoadButton_Callback});
        
        function toAddProcedureListBox_Callback(hObject, ~)
            toAddMethodNumSelected = get(hObject,'Value');
        end
        
        function toRunProcedureListBox_Callback(hObject, ~)
            toRunMethodNumSelected = get(hObject,'Value');
        end
        
        function metaClassChoicePopUp_Callback(hObject, ~)
            metaClassNumSelected = get(hObject,'Value');
            curMetaClass = meta.class.fromName(metaClassNameCellArray{metaClassNumSelected});
            curMethods = {curMetaClass.MethodList.Name}';
            curMethods(strcmp('empty',curMethods), :) = [];
            curMethods(strcmp(curMetaClass.Name,curMethods), :) = [];
            set(toAddProceduresListbox, 'Value', 1, 'String', curMethods);
        end
        
        function finiteLoopCheckbox_Callback(hObject, ~)
            curState = get(hObject, 'Value');
            procedureAndInstrumentSettings.finiteLoop = logical(curState);
            if(curState)
                enableBool = 'on';
                stringToDisplay = num2str(procedureAndInstrumentSettings.finiteLoopNum);
                curBackgroundColor = htGuiConnectionBGColor;
            else
                enableBool = 'off';
                stringToDisplay = 'INF';
                curBackgroundColor = htGuiConnectionBGColor + 3*(1 - htGuiConnectionBGColor)/4;
                if(procedureAndInstrumentSettings.finiteLoopNum == 0)
                    procedureAndInstrumentSettings.finiteLoopNum = 1;
                end
            end
            set(loopNumControl, 'Enable', enableBool, 'String', stringToDisplay);
            set(toRunProceduresEndListbox, 'backgroundcolor', [1, 1, 1]); % This is necessary because Matlab won't update the color otherwise
            set(toRunProceduresEndListbox, 'Enable', enableBool, 'backgroundcolor', curBackgroundColor);
        end
        
        function finiteLoopNumCheckbox_Callback(hObject, ~)
            curNum = get(hObject, 'String');
            procedureAndInstrumentSettings.finiteLoopNum = str2double(curNum);
        end
        
        function listModifier_Callback(~, ~, ii, jj)
            
            % Determine which box we are modifying
            if(ii == 1)
                currentBoxSelected = toRunProceduresStartListbox;
            elseif(ii == 2)
                currentBoxSelected = toRunProceduresLoopListbox;
            else
                currentBoxSelected = toRunProceduresEndListbox;
            end
            
            % jj == 1 is delete, jj == 2 is move up, jj == 3 is move down,
            % jj== 4 is edit entry
            if(jj == 1)
                
                % Determine how to delete index
                toDeleteIndex = get(currentBoxSelected,'Value');
                if(size(procedureVarsStructure(ii).Class, 2) == 0)
                    
                    % Ignore, there were no entries
                    
                elseif(size(procedureVarsStructure(ii).Class, 2) == 1)
                    
                    % If the array only had one entry, set all to empty
                    procedureVarsStructure(ii) = initialEmptyStruct(ii);
                    curMethodsToRunCells{ii} = {};
                    set(currentBoxSelected, 'Max', 0, 'String', curMethodsToRunCells{ii});
                    
                else
                    
                    if(toDeleteIndex == 1)
                        
                        % If we are removing the first entry, just exclude it
                        toKeepVect = 2:size(procedureVarsStructure(ii).Class, 2);
                        
                    elseif(toDeleteIndex == size(procedureVarsStructure(ii).Class, 2))
                        
                        % If we are removing the last entry, just exclude it
                        toKeepVect = 1:(size(procedureVarsStructure(ii).Class, 2) - 1);
                        
                    else
                        
                        % If we are removing any other entry, just exclude.
                        % Note the previous conditions takes care of size =
                        % 1,2, or index = 1,end, which would fail with the 
                        % following vector
                        toKeepVect = [1:(toDeleteIndex - 1), (toDeleteIndex + 1):size(procedureVarsStructure(ii).Class, 2)];
                        
                    end
                    
                    curMethodsToRunCells{ii} = curMethodsToRunCells{ii}(toKeepVect);
                    curBoxValue = get(currentBoxSelected, 'Value');
                    if(curBoxValue > 1)
                        curBoxValue = curBoxValue - 1;
                    end
                    set(currentBoxSelected, 'Value', curBoxValue, 'String', curMethodsToRunCells{ii});
                
                    procedureVarsStructure(ii).Class = {procedureVarsStructure(ii).Class{toKeepVect}};
                    procedureVarsStructure(ii).Method = {procedureVarsStructure(ii).Method{toKeepVect}};
                    procedureVarsStructure(ii).DescriptionString = {procedureVarsStructure(ii).DescriptionString{toKeepVect}};
                    procedureVarsStructure(ii).InputStructure = {procedureVarsStructure(ii).InputStructure{toKeepVect}};
                    procedureVarsStructure(ii).OutputStructure = {procedureVarsStructure(ii).OutputStructure{toKeepVect}};
                    
                end
                
            elseif(jj == 2)
                
            elseif(jj == 3)
                
            else
                toRunIndex = get(currentBoxSelected, 'Value');
                generateProcedureStructureAndGUI(ii, toRunIndex, true);
            end
        end
        
        function addProceduresEndButton_Callback(~, ~)
            if(size(curMethodsToRunCells{3}, 1) == 0)
                toRunIndex = 0;
            else
                toRunIndex = get(toRunProceduresEndListbox, 'Value');
            end
            generateProcedureStructureAndGUI(3, toRunIndex, false);
        end
        
        function addProceduresLoopButton_Callback(~, ~)
            if(size(curMethodsToRunCells{2}, 1) == 0)
                toRunIndex = 0;
            else
                toRunIndex = get(toRunProceduresLoopListbox, 'Value');
            end
            generateProcedureStructureAndGUI(2, toRunIndex, false);
        end
        
        function addProceduresStartButton_Callback(~, ~)
            if(size(curMethodsToRunCells{1}, 1) == 0)
                toRunIndex = 0;
            else
                toRunIndex = get(toRunProceduresStartListbox, 'Value');
            end
            generateProcedureStructureAndGUI(1, toRunIndex, false);
        end
        
        function proceduresSaveAsButton_Callback(~, ~)
            [FileName, PathToFile] = uiputfile('myNewFavoriteProcedure.mat','Save procedures');
            if(PathToFile ~= 0)
                procedureWindowStartStrings = get(toRunProceduresStartListbox, 'String'); %#ok since we're defining it just to save it
                procedureWindowLoopStrings = get(toRunProceduresLoopListbox, 'String'); %#ok since we're defining it just to save it
                procedureWindowEndStrings = get(toRunProceduresEndListbox, 'String'); %#ok since we're defining it just to save it
                save(strcat(PathToFile, filesep, FileName), 'procedureVarsStructure', 'procedureAndInstrumentSettings', 'procedureWindowStartStrings', 'procedureWindowLoopStrings', 'procedureWindowEndStrings', 'curMethodsToRunCells');
            end
        end
        
        function proceduresSaveDefaultButton_Callback(~, ~)
            procedureWindowStartStrings = get(toRunProceduresStartListbox, 'String');
            procedureWindowLoopStrings = get(toRunProceduresLoopListbox, 'String');
            procedureWindowEndStrings = get(toRunProceduresEndListbox, 'String');
            save(defaultFilePathAndFile, 'procedureVarsStructure', 'procedureAndInstrumentSettings', 'procedureWindowStartStrings', 'procedureWindowLoopStrings', 'procedureWindowEndStrings', 'curMethodsToRunCells');
        end
        
        function proceduresLoadButton_Callback(~, ~)
            [FileName, PathToFile] = uigetfile('*.mat','Load procedures');
            if(PathToFile ~= 0)
                loadData(strcat(PathToFile, filesep, FileName));
            end
        end
        
    end

    function generateExperimentButtonsPanel
        
        stopButtonPosition = [toAddProceduresPosition(1), mainPanelInsetDistanceY + textSpacingBufferDY, pushButtonWidth, pushButtonHeight];
        
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Stop',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', stopButtonBGColor,...
            'foregroundcolor', stopButtonFontColor,...
            'Position',stopButtonPosition,...
            'Callback',{@stop_Callback});
        
        uicontrol('Parent', f, 'Style', 'togglebutton',...
            'String','Pause',...
            'FontSize', buttonFontSize,...
            'Position',stopButtonPosition + [textSpacingBufferDX + pushButtonWidth, 0, 0, 0],...
            'Callback',{@pause_Callback});
        
        runButtonControl = uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Run',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', startButtonBGColor,...
            'foregroundcolor', startButtonFontColor,...
            'Position',stopButtonPosition + 2*[textSpacingBufferDX + pushButtonWidth, 0, 0, 0],...
            'Callback',{@run_Callback});
        
        uicontrol('Parent', f, 'Style', 'pushbutton',...
            'String','Close',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',stopButtonPosition + [widthGUI - textSpacingBufferDX - pushButtonWidth - stopButtonPosition(1), 0, 0, 0],...
            'Callback',{@close_Callback});
        
        function run_Callback(~, ~)
            
            % Don't allow the user to press the button again while running!
            isRunning = true;
            set(runButtonControl, 'Enable', 'off');
            
            % Begin the START section of the procedure windows
            numProceduresToLoop = size(procedureVarsStructure(1).Class, 2);
            for j=1:numProceduresToLoop
                if(stopBool)
                    break;
                end
                set(toRunProceduresStartListbox, 'Value', j);
                ExecuteCurrentProcedure(1, j);
            end
            
            % Loop through the LOOP section of the procedure windows
            i = 0;
            currentLoopNumber = 1;
            while(~stopBool && i < procedureAndInstrumentSettings.finiteLoopNum)
                numProceduresToLoop = size(procedureVarsStructure(2).Class, 2);
                for j=1:numProceduresToLoop
                    if(stopBool)
                        break;
                    end
                    set(toRunProceduresLoopListbox, 'Value', j);
                    ExecuteCurrentProcedure(2, j);
                end
                if(procedureAndInstrumentSettings.finiteLoop)
                    i = i + 1;
                end
                while(pauseBool)
                    pause(1);
                end
                currentLoopNumber = currentLoopNumber + 1;
            end
            
            % End with the END section of the procedure window
            numProceduresToLoop = size(procedureVarsStructure(3).Class, 2);
            for j=1:numProceduresToLoop
                if(stopBool)
                    break;
                end
                set(toRunProceduresEndListbox, 'Value', j);
                ExecuteCurrentProcedure(3, j);
            end
            
            if(stopBool)
                stopBool = false;
            end
            
            set(runButtonControl, 'Enable', 'on');
            isRunning = false;
            
            function ExecuteCurrentProcedure(curWindow, loopNum)
                
                % Define our current variables
                currentClassName = procedureVarsStructure(curWindow).Class{loopNum}{1};
                currentMethodName = procedureVarsStructure(curWindow).Method{loopNum}{1};
                currentInputStructure = procedureVarsStructure(curWindow).InputStructure{loopNum};
                currentOutputStructure = procedureVarsStructure(curWindow).OutputStructure{loopNum};
                curNumInputs = size(currentInputStructure, 2);
                curNumOutputs = size(currentOutputStructure, 2);
                currentMetaClass = meta.class.fromName(currentClassName);
                currentMethodIndex = strcmp(currentMethodName, {currentMetaClass.MethodList.Name});
                
                % Determine the string representation of our function
                if(logical(currentMetaClass.MethodList(currentMethodIndex).Static))
                    
                    % If static, call class name
                    inputString = strcat(currentClassName, '.', currentMethodName, '(');
                    startingK = 1;
                    
                else
                    
                    % If not static, call instance name
                    if(strcmp(currentClassName, 'htRunProcedure'))
                        curInstanceName = 'procedureInstance';
                    else
                        currentInstrumentIndex = find(strcmp(currentClassName, htSettings.instrumentClasses));
                        curInstanceName = strcat('instrumentInstancesCellArray{', num2str(currentInstrumentIndex), '}');
                    end
                    inputString = strcat(curInstanceName, '.', currentMethodName, '(');
                    startingK = 2;
                    
                end
                
                % Add input arguments to the function call
                if(curNumInputs == 0)
                    inputString = strcat(inputString, ')');
                else
                    for k=startingK:curNumInputs
                        if(currentInputStructure(k).isUserDefined)
                            if(currentInputStructure(k).evaluate)
                                inputString = strcat(inputString, currentInputStructure(k).varName);
                            else
                                
                                if(currentInputStructure(k).isNumber)
                                    % If a number, write the number
                                    inputString = strcat(inputString, num2str(currentInputStructure(k).varName));
                                else
                                    % If a string, write the string
                                    inputString = strcat(inputString, '''', currentInputStructure(k).varName, '''');
                                end
                                
                            end
                        else
                            % If a variable, call the variable
                            inputString = strcat(inputString, currentInputStructure(k).varName);
                        end
                        % Either attach a comma or end parenthesis
                        if(k ~= curNumInputs)
                            inputString = strcat(inputString, ', ');
                        else
                            inputString = strcat(inputString, ')');
                        end
                    end
                end
                
                % Eval the string like a function call, assigning all
                % outputs to a temporary variable "outputs"
                outputs = [];
                if(logical(currentMetaClass.MethodList(currentMethodIndex).Static))
                    if(curNumOutputs == 0)
                        eval(inputString);
                    else
                        outputs = cell(1, curNumOutputs);
                        [outputs{:}] = eval(inputString);
                    end
                else
                    if(curNumOutputs == 0)
                        eval(inputString);
                    elseif(curNumOutputs == 1)
                        if(strcmp(currentClassName, 'htRunProcedure'))
                            procedureInstance = eval(inputString);
                        else
                            whichInstrument = strcmp(currentClassName, htSettings.instrumentClasses);
                            instrumentInstancesCellArray{whichInstrument} = eval(inputString);
                        end
                    else
                        outputs = cell(1, curNumOutputs - 1);
                        if(strcmp(currentClassName, 'htRunProcedure'))
                            [procedureInstance, outputs{:}] = eval(inputString);
                        else
                            whichInstrument = strcmp(currentClassName, htSettings.instrumentClasses);
                            [instrumentInstancesCellArray{whichInstrument}, outputs{:}] = eval(inputString);
                        end
                    end
                end
                
                % Assign 'outputs' to their correct variables, or save them
                % in OutputStructure if they are new
                indexOffset = 1;
                if(logical(currentMetaClass.MethodList(currentMethodIndex).Static))
                    indexOffset = 0;
                end
                for ii=1:size(outputs,2)
                    if(~currentOutputStructure(ii + indexOffset).isNewVariable)
                        % If we assigned to an existing variable in
                        % workspace, save it to that variable using eval
                        eval(strcat(procedureVarsStructure(curWindow).OutputStructure{loopNum}(ii + indexOffset).varName,' = outputs{ii}'));
                    else
                        % If we created a new variable, save that value to
                        % the corresponding varName in the OutputStructure
                        procedureVarsStructure(curWindow).OutputStructure{loopNum}(ii + indexOffset).Value = outputs{ii};
                    end
                end
                
            end
            
        end
        
        function close_Callback(~, ~)
            
            anyInstrumentsStillConnected = false;
            attemptDisconnect = true;
            dontClose = false;
            whichInstrumentsConnected = false(1, numInstruments);
            for i=1:numInstruments
                if(instrumentInstancesCellArray{i}.iSuccessfulConnection)
                    anyInstrumentsStillConnected = true;
                    whichInstrumentsConnected(i) = true;
                end
            end
            
            if(anyInstrumentsStillConnected)
                button = questdlg(strcat('WARNING: Some instruments are still connected. Should I attempt to disconnect them before closing?'));
                if(strcmp(button,'Yes'))
                    attemptDisconnect = true;
                elseif(strcmp(button,'No'))
                    attemptDisconnect = false;
                else
                    dontClose = true;
                end
            end
            
            if(attemptDisconnect)
                for i=1:numInstruments
                    if(whichInstrumentsConnected(i))
                        instrumentInstancesCellArray{i}.Disconnect(infoWindow, instrumentSessionsCellArray{i});
                    end
                end
            end

            if(~dontClose)
                close(f);
            end
        end
        
        function stop_Callback(~, ~)
            stopBool = true;
            isRunning = false;
            htForm.PrintStringToWindow(infoWindow, 'STOPPING EXPERIMENT (AFTER CURRENT COMMAND IS DONE EXECUTING)');
            set(runButtonControl, 'Enable', 'on');
        end
        
        function pause_Callback(hObject, ~)
            pauseBool = ~pauseBool;
            if(pauseBool)
                set(hObject, 'String', 'Resume');
                set(runButtonControl, 'Enable', 'off');
                htForm.PrintStringToWindow(infoWindow, 'PAUSING EXPERIMENT (AFTER CURRENT COMMAND IS DONE EXECUTING)');
            else
                set(hObject, 'String', 'Pause');
                if(~isRunning)
                    set(runButtonControl, 'Enable', 'on');
                end
                htForm.PrintStringToWindow(infoWindow, 'RESUMING EXPERIMENT');
            end
        end
        
    end

    % toRunWindowNum = 1 is start, 2 is loop, 3 is end
    function generateProcedureStructureAndGUI(toRunWindowNum, toRunIndex, editBool)
        
        % Obtain current procedure parameters
        if(editBool)
            curMethod = procedureVarsStructure(toRunWindowNum).Method{toRunIndex};
            numInputs = size(procedureVarsStructure(toRunWindowNum).InputStructure{toRunIndex}, 2);
            numOutputs = size(procedureVarsStructure(toRunWindowNum).OutputStructure{toRunIndex}, 2);
        else
            curMethods = {curMetaClass.MethodList.Name}';
            curMethodsWhole = curMetaClass.MethodList;
            curMethodsWhole(strcmp('empty',curMethods), :) = [];
            curMethodsWhole(strcmp(curMetaClass.Name,curMethods), :) = [];
            curMethods(strcmp('empty',curMethods), :) = [];
            curMethods(strcmp(curMetaClass.Name,curMethods), :) = [];
            curMethod = curMethodsWhole(toAddMethodNumSelected);
            numInputs = size(curMethod.InputNames, 1);
            numOutputs = size(curMethod.OutputNames, 1);
            set(toAddEndButtonControl, 'Enable', 'off');
            set(toAddLoopButtonControl, 'Enable', 'off');
            set(toAddStartButtonControl, 'Enable', 'off');
        end
        curInputVariables = unique([{'None'}; curVariables]);
        curOutputVariables = unique([{'None'}; curMethod.InputNames; curMethod.OutputNames; curVariables]);
        
        % Define GUI variables
        additionalSectionSpacing = 15;
        subGUIWidth = 1200;
        subGUIHeight = guiTitleHeight + 2*mainPanelInsetDistanceY + (4 + numInputs + numOutputs)*textSpacingBufferDY + (1 + numInputs + numOutputs)*uiTitleTextHeight + 4*additionalSectionSpacing + pushButtonHeight;
        subGUIPosition = [positionGUI(1) + positionGUI(3)/2 - subGUIWidth/2, positionGUI(2) + positionGUI(4)/2 - subGUIHeight/2, subGUIWidth, subGUIHeight];
        curMethodString = curMethods{toAddMethodNumSelected};
        textFractionSplit = 0.35;
        
        % Initialize structure to add to our larger Run Procedure structure
        if(editBool)
            toAddStructure.Class = procedureVarsStructure(toRunWindowNum).Class{toRunIndex};
            toAddStructure.Method = procedureVarsStructure(toRunWindowNum).Method{toRunIndex};
            toAddStructure.DescriptionString = procedureVarsStructure(toRunWindowNum).DescriptionString{toRunIndex};
            toAddStructure.InputStructure = procedureVarsStructure(toRunWindowNum).InputStructure{toRunIndex};
            toAddStructure.OutputStructure = procedureVarsStructure(toRunWindowNum).OutputStructure{toRunIndex};
        else
            toAddStructure.Class = curMetaClass.Name;
            toAddStructure.Method = curMethodString;
            toAddStructure.DescriptionString = curMethodString;
            if(numInputs == 0)
                toAddStructure.InputStructure = {};
            end
            for iii=1:numInputs
                boolArrayOfInputNameVariableNameMatch = strcmp(curMethod.InputNames{iii}, curInputVariables);
                if(sum(boolArrayOfInputNameVariableNameMatch) == 1)
                    curIsUserDefined = false;
                else
                    curIsUserDefined = true;
                end
                toAddStructure.InputStructure(iii).isUserDefined = curIsUserDefined;
                toAddStructure.InputStructure(iii).isNumber = false;
                toAddStructure.InputStructure(iii).evaluate = false;
                toAddStructure.InputStructure(iii).varName = curMethod.InputNames{iii};
            end
            if(numOutputs == 0)
                toAddStructure.OutputStructure = {};
            end
            for iii=1:numOutputs
                boolArrayOfOutputNameVariableNameMatch = strcmp(curMethod.OutputNames{iii}, curInputVariables); % curInputVariables is correct, we're just checking if isUserDefined or if the variable existed already
                if(sum(boolArrayOfOutputNameVariableNameMatch) == 1)
                    curIsUserDefined = false;
                else
                    curIsUserDefined = true;
                end
                toAddStructure.OutputStructure(iii).isNewVariable = curIsUserDefined;
                toAddStructure.OutputStructure(iii).isUserDefined = curIsUserDefined;
                toAddStructure.OutputStructure(iii).varName = curMethod.OutputNames{iii};
                toAddStructure.OutputStructure(iii).Value = [];
            end
        end
        
        % Create GUI
        g = figure('Visible','off','Position', subGUIPosition);
        b = axes;
        % Stretch the axes over the whole figure.
        set(b, 'Position', [0, 0, 1, 1]);
        % Switch off autoscaling.
        set(b, 'Xlim', [0, subGUIWidth], 'YLim', [0, subGUIHeight]);
        set(b, 'XTick',[], 'YTick',[]);
        set(gca, 'FontName', htGuiMainFont)
        textInputHandles = gobjects(1, numInputs + numOutputs);
        rectangle('Position', [0, 0, subGUIWidth, subGUIHeight], 'Curvature', 0, 'FaceColor', colorGUIBackground, 'Parent', b);
        
        % GUI Title
        uicontrol('Parent',g,'Style','text',...
            'String',curMethodString,...
            'FontName', htGuiMainFont,...
            'FontSize', uiTitleFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',uiTitleFontColor,...
            'Position',[mainPanelInsetDistanceX + textSpacingBufferDX, subGUIHeight - mainPanelInsetDistanceY - textSpacingBufferDY - guiTitleHeight, subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX, guiTitleHeight]);
        
        % Description
        descriptionPosition = [mainPanelInsetDistanceX + textSpacingBufferDX, subGUIHeight - mainPanelInsetDistanceY - 2*textSpacingBufferDY - guiTitleHeight - uiTitleTextHeight - additionalSectionSpacing, (subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX)*textFractionSplit - textSpacingBufferDX/2, uiTitleTextHeight];
        uicontrol('Parent',g,'Style','text',...
            'String','Decription',...
            'FontName', htGuiMainFont,...
            'FontSize', htGuiFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'HorizontalAlignment', 'left',...
            'backgroundcolor',colorGUIBackground,...
            'foregroundcolor',htGuiFontColor,...
            'Position', descriptionPosition);
        descriptionHandle = uicontrol('Parent',g,'Style','edit',...
            'String',curMethodString,...
            'FontName', htGuiMainFont,...
            'FontSize', htGuiFontSize,...
            'FontWeight', htGuiMainFontWeight,...
            'HorizontalAlignment', 'left',...
            'backgroundcolor',htGuiConnectionBGColor,...
            'foregroundcolor',htGuiConnectionFontColor,...
            'Position',[descriptionPosition(1) + descriptionPosition(3) + textSpacingBufferDX, descriptionPosition(2), (subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX)*(1 - textFractionSplit) - textSpacingBufferDX/2, uiTitleTextHeight],...
            'Callback',{@descriptionString_Callback});
        
        % Inputs
        firstInputPosition = descriptionPosition - [0, textSpacingBufferDY + additionalSectionSpacing + uiTitleTextHeight, 0, 0];
        curInputPosition = firstInputPosition;
        for i=1:numInputs
            curInputPosition = firstInputPosition - [0, (i - 1)*(textSpacingBufferDY + uiTitleTextHeight), 0, 0];
            boolArrayOfInputNameVariableNameMatch = strcmp(curMethod.InputNames{i}, curInputVariables);
            if(sum(boolArrayOfInputNameVariableNameMatch) == 1)
                defaultString = curInputVariables{boolArrayOfInputNameVariableNameMatch};
                whichIndexSet = find(boolArrayOfInputNameVariableNameMatch);
                inputEnable = 'off';
            else
                defaultString = '';
                whichIndexSet = 1;
                inputEnable = 'on';
            end
            uicontrol('Parent',g,'Style','text',...
                'String',sprintf('Input %i: %s', i, curMethod.InputNames{i}),...
                'FontName', htGuiMainFont,...
                'FontSize', htGuiFontSize,...
                'FontWeight', htGuiMainFontWeight,...
                'HorizontalAlignment', 'left',...
                'backgroundcolor',colorGUIBackground,...
                'foregroundcolor',htGuiFontColor,...
                'Position', curInputPosition);
            curTextInputPosition = curInputPosition + [textSpacingBufferDX + curInputPosition(3), 0, (subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX)*(1 - textFractionSplit)/2 - textSpacingBufferDX - firstInputPosition(3), 0];
            textInputHandles(i) = uicontrol('Parent',g,'Style','edit',...
                'String',defaultString,...
                'FontName', htGuiMainFont,...
                'FontSize', htGuiFontSize,...
                'FontWeight', htGuiMainFontWeight,...
                'HorizontalAlignment', 'left',...
                'Enable', inputEnable,...
                'backgroundcolor',htGuiConnectionBGColor,...
                'foregroundcolor',htGuiConnectionFontColor,...
                'Position', curTextInputPosition,...
                'Callback',{@inputString_Callback, i});
            curPopupPosition = curTextInputPosition + [textSpacingBufferDX + curTextInputPosition(3), 0, (subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX)*(1 - textFractionSplit)/2 - textSpacingBufferDX - firstInputPosition(3), 0];
            uicontrol('Parent', g,...
                'Style', 'popupmenu',...
                'Value', whichIndexSet,...
                'Max', 1,...
                'String', curInputVariables,...
                'backgroundcolor', popUpBGColor,...
                'foregroundcolor', popUpFontColor,...
                'Position', curPopupPosition,...
                'Callback', {@inputStringPopUp_Callback, i});
            uicontrol('Parent',g,'Style','text',...
                'String','Eval',...
                'FontName', htGuiMainFont,...
                'FontSize', htGuiFontSize - 4,...
                'FontWeight', htGuiMainFontWeight,...
                'HorizontalAlignment', 'center',...
                'backgroundcolor',colorGUIBackground,...
                'foregroundcolor',htGuiFontColor,...
                'Position', [curPopupPosition(1) + curPopupPosition(3) + textSpacingBufferDX - 2.5, curPopupPosition(2) + 2 + checkboxLength, checkboxLength + 5, checkboxLength]);
            % Create the checkbox for the ith input
            uicontrol('Parent', g, 'Style', 'checkbox',...
                'Value', false,...
                'backgroundcolor', htGuiConnectionBGColor,...
                'Position', [curPopupPosition(1) + curPopupPosition(3) + textSpacingBufferDX, curPopupPosition(2) + 7, checkboxLength, checkboxLength],...
                'Callback', {@evaluateCheckbox_Callback, i});
            
        end
        
        % Outputs
        firstOutputPosition = curInputPosition - [0, textSpacingBufferDY + additionalSectionSpacing + uiTitleTextHeight, 0, 0];
        for i=1:numOutputs
            curOutputPosition = firstOutputPosition - [0, (i - 1)*(textSpacingBufferDY + uiTitleTextHeight), 0, 0];
            boolArrayOfOutputNameVariableNameMatch = strcmp(curMethod.OutputNames{i}, curOutputVariables);
            if(sum(boolArrayOfOutputNameVariableNameMatch) == 1)
                defaultString = curOutputVariables{boolArrayOfOutputNameVariableNameMatch};
                whichIndexSet = find(boolArrayOfOutputNameVariableNameMatch);
                outputEnable = 'off';
            else
                defaultString = '';
                whichIndexSet = 1;
                outputEnable = 'on';
            end
            uicontrol('Parent',g,'Style','text',...
                'String',sprintf('Output %i: %s', i, curMethod.OutputNames{i}),...
                'FontName', htGuiMainFont,...
                'FontSize', htGuiFontSize,...
                'FontWeight', htGuiMainFontWeight,...
                'HorizontalAlignment', 'left',...
                'backgroundcolor',colorGUIBackground,...
                'foregroundcolor',htGuiFontColor,...
                'Position', curOutputPosition);
            curTextOutputPosition = curOutputPosition + [textSpacingBufferDX + curOutputPosition(3), 0, (subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX)*(1 - textFractionSplit)/2 - textSpacingBufferDX - firstOutputPosition(3), 0];
            textInputHandles(numInputs + i) = uicontrol('Parent',g,'Style','edit',...
                'String',defaultString,...
                'FontName', htGuiMainFont,...
                'FontSize', htGuiFontSize,...
                'FontWeight', htGuiMainFontWeight,...
                'HorizontalAlignment', 'left',...
                'Enable', outputEnable,...
                'backgroundcolor',htGuiConnectionBGColor,...
                'foregroundcolor',htGuiConnectionFontColor,...
                'Position',curTextOutputPosition,...
                'Callback',{@inputString_Callback, i});
            uicontrol('Parent', g,...
                'Style', 'popupmenu',...
                'Value', whichIndexSet,...
                'Max', 1,...
                'String', curOutputVariables,...
                'backgroundcolor', popUpBGColor,...
                'foregroundcolor', popUpFontColor,...
                'Position', curTextOutputPosition + [textSpacingBufferDX + curTextOutputPosition(3), 0, (subGUIWidth - 2*mainPanelInsetDistanceX - 2*textSpacingBufferDX)*(1 - textFractionSplit)/2 - textSpacingBufferDX - firstOutputPosition(3), 0],...
                'Callback', {@outputStringPopUp_Callback, i});
        end
        
        % Buttons
        uicontrol('Parent', g, 'Style', 'pushbutton',...
            'String','Accept',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', startButtonBGColor,...
            'foregroundcolor', startButtonFontColor,...
            'Position',[subGUIWidth - 2*textSpacingBufferDX - mainPanelInsetDistanceX - 2*pushButtonWidth, mainPanelInsetDistanceY + textSpacingBufferDY, pushButtonWidth, pushButtonHeight],...
            'Callback',{@acceptSubGUI_Callback});
        uicontrol('Parent', g, 'Style', 'pushbutton',...
            'String','Close',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',[subGUIWidth - textSpacingBufferDX - mainPanelInsetDistanceX - pushButtonWidth, mainPanelInsetDistanceY + textSpacingBufferDY, pushButtonWidth, pushButtonHeight],...
            'Callback',{@closeSubGUI_Callback});
        
        % Make figure visible
        g.Visible = 'on';
        
        % Callbacks
        function descriptionString_Callback(hObject, ~)
            toAddStructure.DescriptionString = get(hObject,'String');
        end
        
        function inputString_Callback(hObject, ~, ii)
            curString = get(hObject,'String');
            [~, isNum] = str2num(curString); %#ok since we need the second output which str2double does not provide
            toAddStructure.InputStructure(ii).isUserDefined = true;
            toAddStructure.InputStructure(ii).isNumber = isNum;
            toAddStructure.InputStructure(ii).varName = curString;
        end
        
        function inputStringPopUp_Callback(hObject, ~, ii)
            curIndex = get(hObject, 'Value');
            % The first variable name in the list is NONE, so if curIndex
            % is not 1, add the method name to list, otherwise let the user
            % define it.
            if(curIndex ~= 1)
                set(textInputHandles(ii), 'String', curInputVariables{curIndex}, 'Enable', 'off');
                toAddStructure.InputStructure(ii).isUserDefined = false;
                toAddStructure.InputStructure(ii).isNumber = false;
                toAddStructure.InputStructure(ii).varName = curInputVariables{curIndex};
            else
                set(textInputHandles(ii), 'Enable', 'on', 'backgroundcolor', [1, 1, 1], 'foregroundcolor', [1, 1, 1]);
                set(textInputHandles(ii), 'backgroundcolor', htGuiConnectionBGColor, 'foregroundcolor', htGuiConnectionFontColor);
                curString = get(textInputHandles(ii), 'String');
                [~, isNum] = str2num(curString); %#ok since we need the second output which str2double does not provide
                toAddStructure.InputStructure(ii).isUserDefined = true;
                toAddStructure.InputStructure(ii).isNumber = isNum;
                toAddStructure.InputStructure(ii).varName = curString;
            end
        end
        
        function evaluateCheckbox_Callback(hObject, ~, ii)
            toAddStructure.InputStructure(ii).evaluate = logical(get(hObject,'Value'));
        end
        
        function outputStringPopUp_Callback(hObject, ~, ii)
            curIndex = get(hObject, 'Value');
            % If the user choses an existing variable (1=new variable)
            if(curIndex ~= 1)
                set(textInputHandles(numInputs + ii), 'String', curOutputVariables{curIndex}, 'Enable', 'off');
                toAddStructure.OutputStructure(ii).isNewVariable = false;
                toAddStructure.OutputStructure(ii).isUserDefined = false;
                toAddStructure.OutputStructure(ii).varName = curOutputVariables{curIndex};
                toAddStructure.OutputStructure(ii).Value = [];
            else
                set(textInputHandles(numInputs + ii), 'Enable', 'on', 'backgroundcolor', [1, 1, 1], 'foregroundcolor', [1, 1, 1]);
                set(textInputHandles(numInputs + ii), 'backgroundcolor', htGuiConnectionBGColor, 'foregroundcolor', htGuiConnectionFontColor);
                curString = get(textInputHandles(numInputs + ii), 'String');
                toAddStructure.OutputStructure(ii).isNewVariable = true;
                toAddStructure.OutputStructure(ii).isUserDefined = true;
                toAddStructure.OutputStructure(ii).varName = curString;
                toAddStructure.OutputStructure(ii).Value = [];
            end
        end
        
        function acceptSubGUI_Callback(~, ~)
            
            % Increase the cell array size for the toRun listbox, adding in
            % the new procedure
            toRunIndex = toRunIndex + 1;
            if(toRunIndex > 1 && ~editBool)
                curMethodsToRunCells{toRunWindowNum}(toRunIndex:end + 1) = curMethodsToRunCells{toRunWindowNum}(toRunIndex - 1:end);
                % Populate the structure with the variables
                procedureVarsStructure(toRunWindowNum).Class(1, toRunIndex:(end + 1)) = procedureVarsStructure(toRunWindowNum).Class(1, (toRunIndex - 1):end);
                procedureVarsStructure(toRunWindowNum).Method(1, toRunIndex:(end + 1)) = procedureVarsStructure(toRunWindowNum).Method(1, (toRunIndex - 1):end);
                procedureVarsStructure(toRunWindowNum).DescriptionString(1, toRunIndex:(end + 1)) = procedureVarsStructure(toRunWindowNum).DescriptionString(1, (toRunIndex - 1):end);
                procedureVarsStructure(toRunWindowNum).InputStructure(1, toRunIndex:(end + 1)) = procedureVarsStructure(toRunWindowNum).InputStructure(1, (toRunIndex - 1):end);
                procedureVarsStructure(toRunWindowNum).OutputStructure(1, toRunIndex:(end + 1)) = procedureVarsStructure(toRunWindowNum).OutputStructure(1, (toRunIndex - 1):end);
            end
            
            % Build up a name consisting of the description and variables
            % to return
            descriptionString = get(descriptionHandle, 'String');
            descriptionString = strcat(descriptionString, ', input = (');
            for ii=1:numInputs
                descriptionString = strcat(descriptionString, get(textInputHandles(ii), 'String'));
                if(ii ~= numInputs)
                    descriptionString = strcat(descriptionString, ', ');
                end
            end
            descriptionString = strcat(descriptionString, '), output = (');
            for ii=(numInputs + 1):(numInputs + numOutputs)
                descriptionString = strcat(descriptionString, get(textInputHandles(ii), 'String'));
                if(ii ~= (numInputs + numOutputs))
                    descriptionString = strcat(descriptionString, ', ');
                end
            end
            descriptionString = strcat(descriptionString, ')');
            curMethodsToRunCells{toRunWindowNum}(toRunIndex) = {descriptionString};
            if(toRunWindowNum == 1)
                set(toRunProceduresStartListbox, 'String', curMethodsToRunCells{toRunWindowNum});
            elseif(toRunWindowNum == 2)
                set(toRunProceduresLoopListbox, 'String', curMethodsToRunCells{toRunWindowNum});
            else
                set(toRunProceduresEndListbox, 'String', curMethodsToRunCells{toRunWindowNum});
            end
            
            % Populate the structure with the variables
            procedureVarsStructure(toRunWindowNum).Class{toRunIndex} = {toAddStructure.Class};
            procedureVarsStructure(toRunWindowNum).Method{toRunIndex} = {toAddStructure.Method};
            procedureVarsStructure(toRunWindowNum).DescriptionString{toRunIndex} = {toAddStructure.DescriptionString};
            procedureVarsStructure(toRunWindowNum).InputStructure{toRunIndex} = [];
            procedureVarsStructure(toRunWindowNum).OutputStructure{toRunIndex} = [];
            procedureVarsStructure(toRunWindowNum).InputStructure{toRunIndex} = toAddStructure.InputStructure;
            procedureVarsStructure(toRunWindowNum).OutputStructure{toRunIndex} = toAddStructure.OutputStructure;
            
            % Reset the current toAddStructure as we'll use it later
            toAddStructure = [];
            
            % Select the next entry in the listbox
            if(toRunWindowNum == 1)
                curSelection = get(toRunProceduresStartListbox, 'Value');
                if(curSelection ~= size(curMethodsToRunCells{toRunWindowNum}, 2))
                    set(toRunProceduresStartListbox, 'Value', (curSelection + 1));
                end
            elseif(toRunWindowNum == 2)
                curSelection = get(toRunProceduresLoopListbox, 'Value');
                if(curSelection ~= size(curMethodsToRunCells{toRunWindowNum}, 2))
                    set(toRunProceduresLoopListbox, 'Value', (get(toRunProceduresLoopListbox, 'Value') + 1));
                end
            else
                curSelection = get(toRunProceduresEndListbox, 'Value');
                if(curSelection ~= size(curMethodsToRunCells{toRunWindowNum}, 2))
                    set(toRunProceduresEndListbox, 'Value', (get(toRunProceduresEndListbox, 'Value') + 1));
                end
            end
            
            % Close the window
            close(g);
            set(toAddEndButtonControl, 'Enable', 'on');
            set(toAddLoopButtonControl, 'Enable', 'on');
            set(toAddStartButtonControl, 'Enable', 'on');
            
        end
        
        % Close the window
        function closeSubGUI_Callback(~, ~)
            close(g);
            set(toAddEndButtonControl, 'Enable', 'on');
            set(toAddLoopButtonControl, 'Enable', 'on');
            set(toAddStartButtonControl, 'Enable', 'on');
        end
        
    end

    function loadData(pathAndFileName)
        varsToLoad = load(pathAndFileName);
        set(toRunProceduresStartListbox, 'String', varsToLoad.procedureWindowStartStrings);
        set(toRunProceduresLoopListbox, 'String', varsToLoad.procedureWindowLoopStrings);
        set(toRunProceduresEndListbox, 'String', varsToLoad.procedureWindowEndStrings);
        curMethodsToRunCells = varsToLoad.curMethodsToRunCells;
        procedureVarsStructure = varsToLoad.procedureVarsStructure;
        procedureAndInstrumentSettings = varsToLoad.procedureAndInstrumentSettings;
        set(finiteLoopCheckboxControl, 'Value', procedureAndInstrumentSettings.finiteLoop);
        if(procedureAndInstrumentSettings.finiteLoop)
            set(loopNumControl, 'String', procedureAndInstrumentSettings.finiteLoopNum, 'Enable', 'on');
            set(toRunProceduresEndListbox, 'Enable', 'on');
            curBackgroundColor = htGuiConnectionBGColor;
        else
            set(loopNumControl, 'String', 'INF', 'Enable', 'off');
            set(toRunProceduresEndListbox, 'Enable', 'off');
            curBackgroundColor = htGuiConnectionBGColor + 3*(1 - htGuiConnectionBGColor)/4;
        end
        set(toRunProceduresEndListbox, 'backgroundcolor', [1, 1, 1]); % This is necessary because Matlab won't update the color otherwise
        set(toRunProceduresEndListbox, 'backgroundcolor', curBackgroundColor);
    end

    function generateInstrumentControlButtons
        % instrumentInstancesCellArray
        % niDaqSession = instrumentSessionsCellArray{1, 1};
        % asiSerialObj = instrumentSessionsCellArray{1, 2};
        % kdsPumpSerialObj = instrumentSessionsCellArray{1, 3};
        % hamamatsuCameraObj = instrumentSessionsCellArray{1, 4};
        % aotfSerialObj = instrumentSessionsCellArray{1, 5};
        
        % Initialize DAQ
        [procedureInstance, instrumentInstancesCellArray] = procedureInstance.InitializeDAQForStandardHTUse(infoWindow, htSettings, instrumentInstancesCellArray, niDaqSession);
        
        % Trigger video to remove bad frame
        firstFrame = instrumentInstancesCellArray{4}.triggerAndReturnImage(hamamatsuCameraObj); %#ok used to remove bad frame
        
        % Display current image
        firstFrame = instrumentInstancesCellArray{4}.triggerAndReturnImage(hamamatsuCameraObj);
        data = firstFrame(:,:,1);  % channel 1 only
        imshow(data, [], 'Parent', aa)
        
        % Generate control variables
        previewButtonPosition = [textSpacingBufferDX, cameraPreviewPosition(4)*heightGUI + 2*textSpacingBufferDY, pushButtonWidth, pushButtonHeight];
        
        % Generate controls
        uicontrol('Parent', f, 'Style', 'togglebutton',...
            'String','Preview',...
            'FontSize', buttonFontSize,...
            'backgroundcolor', closeButtonBGColor,...
            'foregroundcolor', closeButtonFontColor,...
            'Position',previewButtonPosition,...
            'Callback',{@previewButton_Callback});
        
        % Callback functions
        function previewButton_Callback(hObject, ~)
            previewBool = ~previewBool;
            if(previewBool)
                set(hObject, 'String', 'Stop Preview');
                set(runButtonControl, 'Enable', 'off');
                htForm.PrintStringToWindow(infoWindow, 'Previewing camera.');
            else
                set(hObject, 'String', 'Preview');
                if(~isRunning)
                    set(runButtonControl, 'Enable', 'on');
                end
                htForm.PrintStringToWindow(infoWindow, 'Preview off.');
            end
            
            while( previewBool )
                
                currentFrame = instrumentInstancesCellArray{4}.triggerAndReturnImage(hamamatsuCameraObj);
                data = currentFrame(:,:,1);  % channel 1 only
                imshow(data, [], 'Parent', aa)
                
            end
        end
        
    end

end