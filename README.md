# API Reference for High-Throughput code

Overview of the classes for the high-throughput API developed for the Parthasarathy lab and provides syntax/uses of properties and functions.

---

## Inheritance Tree and Method Overview

All classes are extended from the 'htForm' class.

- **htForm**
  - (Static) PrintStringToWindow
  - (Static) Pause
  - (Static) PrintTimestampToWindow
  - **htInstrument**
    - **htAOTF**
      - Connect
      - AOTFOutputNone
      - AOTFOutputGFP
      - AOTFOutputRFP
      - AOTFOutputGFPAndRFP
      - Disconnect
    - **htASITigerConsole**
      - Connect
      - QueryStagePosition
      - RelativeMoveStage
      - MoveStage
      - SetSpeed
      - SwitchFilterWheelToEmpty
      - SwitchFilterWheelToGFP
      - SwitchFilterWheelToRFP
      - Disconnect
      - (Static) waitForStageToFinish
      - (Static) ReturnNumberFromStageResult
    - **htDaq**
      - Connect
      - InitializeDigitalChannels
      - SetDigitalOutputChannelStates
      - ToggleDigitalOutputChannelStates
      - GetDigitalInputChannelState
      - Disconnect
    - **htHamamatsu**
      - Connect
      - triggerAndReturnImage
      - triggerAndSaveAndReturnImage
      - Disconnect
    - **htKDSPump**
      - Connect
      - SetWithdrawRate
      - BeginWithdrawing
      - SetInfuseRate
      - BeginInfusing
      - StopInfusingAndOrWithdrawing
      - UpdatePumpParameters
      - Disconnect
  - **htRunProcedures**

# API Reference

---

## htForm

### Properties

- **bool warningsVerbose**: Boolean which will allow verbose printing of minor warnings to the command window if true; Default false.

  ```Example: formInstance.warningsVerbose = false;```
  
- **bool sequenceVerbose**: Boolean which permits printing to screen information regarding which step is currently performing; Default true

  ```Example: formInstance.sequenceVerbose = true;```
  
- **string uniqueNameString**: String which gives the instance a unique name. Currently unused.

  ```Example: formInstance.uniqueNameString = 'uniqueID';```

### Methods (Static)

- **PrintStringToWindow(infoWindow, stringToPrintToWindow)**: This method sends strings to a listbox given by the handle infoWindow. As of February 2018, this is most useful for sending messages to the htGui information window.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **string stringToPrintToWindow**: A string containing whatever message you want to add to the infoWindow. This also appears to work with the literals stored in variables.
  
  ```htForm.PrintStringToWindow(infowWindow, 'If possible, please refrain from swearing in the infoWindow.');```
  
- **Pause(infoWindow, pauseTimeMilliseconds)**: This method pauses for a given number of milliseconds. Note that this function is latent and will not return until it is done pausing.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **double pauseTimeMilliseconds**: A double representing the pause time in units of milliseconds.
  
  ```htForm.Pause(infowWindow, 10000);```
  
- **PrintTimestampToWindow(infoWindow)**: This method prints the current time to the infoWindow.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  
  ```htForm.PrintTimestampToWindow(infowWindow);```

---

## htInstrument

### Properties

- **int iSuccessfulConnection**: If 1, successful connection to instrument. If 0, no instrument was found but user wants to continue. If -1, no instrument was found and user wants to quit; Default 0.

  ```Example: instrumentInstance.iSuccessfulConnection = 1;```
  
- **bool userWantsToConnect**: If false, user doesn't want to use this instrument, true they do; Default true

  ```Example: instrumentInstance.userWantsToConnect = true```
  
- **string connectionChannelOrTypeString**: % A string which identifies which channel (for serial, e.g. 'COM4') or type (e.g. 'HTDev1' for DAQ).

  ```Example: instrumentInstance.connectionChannelOrTypeString = 'COM4';```
  
- **bool verboseTimestamp**: Currently unused; Default true.

  ```Example: instrumentInstance.verboseTimestamp = true;```

---

## htAOTF

### Properties

- **deviceComPort**: This variable is set automatically with the function connect(). String which matches the virtual com port with which the AOTF is identified.

  ```Example: aotf.deviceComPort = 'Com5';```
  

### Methods

- **[obj, aotfSerialObj] = Connect(obj, infoWindow, comPort)**: This method connects the computer with the AOTF for a given com port.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **comPort**: A string which matches the virtual com port assigned to the device by windows.
  - **aotfSerialObj**: The AOTF object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: [aotf, aotfSerialObj] = aotf.Connect(infoWindow, 'Com19');```
  
- **obj = AOTFOutputNone(obj, infoWindow, aotfSerialObj)**: This method sends a signal to the AOTF to block all laser light from reaching the chamber.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **aotfSerialObj**: The AOTF object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: aotf = aotf.AOTFOutputNone(infoWindow, aotfSerialObj);```
  
- **obj = AOTFOutputGFP(obj, infoWindow, aotfSerialObj)**: This method sends a signal to the AOTF to allow GFP laser light to reach the chamber.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **aotfSerialObj**: The AOTF object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: aotf = aotf.AOTFOutputGFP(infoWindow, aotfSerialObj);```
  
- **obj = AOTFOutputRFP(obj, infoWindow, aotfSerialObj)**: This method sends a signal to the AOTF to allow RFP laser light to reach the chamber.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **aotfSerialObj**: The AOTF object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: aotf = aotf.AOTFOutputRFP(infoWindow, aotfSerialObj);```
  
- **obj = AOTFOutputGFPAndRFP(obj, infoWindow, aotfSerialObj)**: This method sends a signal to the AOTF to allow GFP and RFP laser light to reach the chamber.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **aotfSerialObj**: The AOTF object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: aotf = aotf.AOTFOutputGFPAndRFP(infoWindow, aotfSerialObj);```
  
- **Disconnect(obj, infoWindow, aotfSerialObj)**: This method disconnects the AOTF from the computer.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **aotfSerialObj**: The AOTF object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: asiConsole.Disconnect(infoWindow, aotfSerialObj);```

---

## htASITigerConsole

### Properties

- **string deviceComPort**: This variable is set automatically with the function connect(). String which matches the virtual com port with which the ASI stage is identified.

  ```Example: asiStage.deviceComPort = 'Com5';```
  
- **double stageScalingFactorX**: Sometimes the stage movement distance is off from the input movement distance by a constant factor. This fixes that in the X direction; Default 4.0

  ```Example: asiStage.stageScalingFactorX = 4.0```
  
- **double stageScalingFactorY**: Sometimes the stage movement distance is off from the input movement distance by a constant factor. This fixes that in the Y direction; Default 4.0

  ```Example: asiStage.stageScalingFactorY = 4.0```
  
- **double stageScalingFactorZ**: Sometimes the stage movement distance is off from the input movement distance by a constant factor. This fixes that in the Z direction; Default 2.5

  ```Example: asiStage.stageScalingFactorZ = 4.0```
  
- **string maximumStageSpeed**: String of the maximum stage speed in units of mm/s; Default '7.5'

  ```Example: asiStage.maximumStageSpeed = '7.5'```
  
- **double[] stageCenterXY**: Double vector set by the user in the GUI to represent the center of the capillary. This value is assumed to have already been corrected via stageScalingFactorX,Y

  ```Example: asiStage.stageCenterXY = [0.0, 0.0]```
  
- **double[] stageInitAndFinalZ**: Double vector set by the user in the GUI to represent the initial and final z for light-sheet scans. This value is assumed to have already been corrected via stageScalingFactorZ

  ```Example: asiStage.stageInitAndFinalZ = [0.0, 1.0]```
  
- **double stageCenterZ**: Double representing the center of the capillary, set automatically when the zebrafish search is started. This value is assumed to have already been corrected via stageScalingFactorZ

  ```Example: asiStage.stageCenterZ = 0.5```
  
- **string defaultFilterWheelPosition**: String indicating default filter wheel position; Default 'MP 0'

  ```Example: asiStage.defaultFilterWheelPosition = 'MP 0'```

### Methods

- **[obj, asiSerialObj] = Connect(obj, infoWindow, comPort)**: This method connects the computer with the ASI console for a given com port.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **string comPort**: A string which matches the virtual com port assigned to the device by windows.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  
  ```Example: [asiConsole, asiSerialObj] = asiConsole.Connect(infoWindow, 'Com5');```
  
- **[obj, positionVector] = QueryStagePosition(obj, infoWindow, asiSerialObj)**: This method returns the current position of the stage in units of microns, rescaling mismatches between where the stage is in real space vs. where the stage thinks it is.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  - **double[] positionVector**: A 3-vector returning the x, y, and z position of the stage in microns.
  
  ```Example: [asiConsole, positionVector] = asiConsole.QueryStagePosition(infoWindow, asiSerialObj);```
  
- **obj = RelativeMoveStage(obj, infoWindow, asiSerialObj, moveAxis, moveAmountMicrons, maxSpeed1True0False)**: This method moves the stage from its current position in the moveAxis by moveAmountMicrons in units of microns, rescaling mismatches between where the stage is in real space vs. where the stage thinks it is.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  - **char moveAxis**: Char of the axis name.
  - **double moveAmountMicrons**: Double of the amount to move in microns.
  - **int maxSpeed1True0False**: Int for moving at the maximum speed. Uses current speed if 0.
  
  ```Example: asiConsole = asiConsole.RelativeMoveStage(infoWindow, asiSerialObj, 'X', 1000.0, 1);```
  
- **obj = MoveStage(obj, infoWindow, asiSerialObj, moveAxis, movePositionMicrons, maxSpeed1True0False)**: This method moves the stage in the moveAxis by moveAmountMicrons in global coordinates relative to (0,0) in units of microns, rescaling mismatches between where the stage is in real space vs. where the stage thinks it is.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  - **char moveAxis**: Char of the axis name.
  - **double movePositionMicrons**: Double of the amount to move in microns.
  - **int maxSpeed1True0False**: Int for moving at the maximum speed. Uses current speed if 0.
  
  ```Example: asiConsole = asiConsole.MoveStage(infoWindow, asiSerialObj, 'X', 1452.2, 1);```
  
- **obj = SetSpeed(obj, infoWindow, asiSerialObj, moveAxis, speedUnitsOfMMPerSec)**: This function sets the default speed to move the stage when calling other move commands.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  - **char moveAxis**: Char of the axis name.
  - **double speedUnitsOfMMPerSec**: The speed of the stage in units of millimeters per second.
  
  ```Example: asiConsole = asiConsole.SetSpeed(infoWindow, asiSerialObj, 'X', 7.5);```
  
- **obj = SwitchFilterWheelToEmpty(obj, infoWindow, asiSerialObj)**: This method flips the filterwheel to its default state, assumed to be an empty filter.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  
  ```Example: asiConsole = asiConsole.SwitchFilterWheelToEmpty(infoWindow, asiSerialObj);```
  
- **obj = SwitchFilterWheelToGFP(obj, infoWindow, asiSerialObj)**: This method flips the filterwheel to its GFP state, assumed to be 'MP 1'.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  
  ```Example: asiConsole = asiConsole.SwitchFilterWheelToGFP(infoWindow, asiSerialObj);```
  
- **obj = SwitchFilterWheelToRFP(obj, infoWindow, asiSerialObj)**: This method flips the filterwheel to its RFP state, assumed to be 'MP 2'.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  
  ```Example: asiConsole = asiConsole.SwitchFilterWheelToRFP(infoWindow, asiSerialObj);```
  
- **Disconnect(obj, infoWindow, asiSerialObj)**: This method disconnects the computer from the stage.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] asiSerialObj**: The ASI stage session acquired from the connect method.
  
  ```Example: asiConsole.Disconnect(infoWindow, asiSerialObj);```
  
### Methods (Static)
  
- **WaitForStageToFinish(asiSerialObj)**: Method which does not return until the stage confirms it is finished moving. This is a latent function.
  - **asiSerialObj**: The ASI console object used to communicate with the actual console via Matlab's serial api.
  
  ```Example: htASITigerConsole.waitForStageToFinish(asiSerialObj);```
  
- **micronNum = ReturnNumberFromStageResult(returnedString)**: This method takes a string returned from the stage (e.g. 'A: -1023') in units of tenths of microns and returns number representative of that string in units of microns.
  - **returnedString**: The string returned from the ASI console object, possibly with non-numeric characters, in units of tenths of microns.
  - **micronNum**: A double representation of the numeric part of returnedString changed into units of microns.
  
  ```Example: micronNum = htASITigerConsole.returnNumberFromStageResult(':A -1024');```

---

## htDaq

### Properties

- **string deviceID**: This variable is set automatically with the function connect(). String which matches the device ID in NI-MAX (e.g. HTDev1). 

  ```Example: niDaq.deviceID = 'HTDev1';```
  
- **CellArray channelNames**: Cell array of channel names initialized in method 'initializeDigitalChannels'.

  ```Example: niDaq.channelNames = {'valve1', 'testIn', 'valve2', 'LEDIn'};```
  
- **bool hasOutputs**: Bool for determining if the DAQ currently has any output channels; Default false.

  ```Example: niDaq.hasOutputs = false;```

### Methods

- **[obj, daqSession] = Connect(obj, infoWindow, NIMaxID)**: This method connects the computer with the DAQ, previously labeled with an ID (check the wanted instrument name in NI-MAX).
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **string NIMaxID**: A string which matches the device ID in NI-MAX (e.g. 'HTDev1').
  - **[session] daqSession**: The data acquisition session (see daq.createSession).
  
  ```Example: [niDaq, niDaqSession] = niDaq.Connect(infoWindow, 'HTDev1');```
  
- **obj = InitializeDigitalChannels(obj, infoWindow, niDaqSession, namesChannelsAndBoolStates_CellArray)**: This method initializes the digital channels we want to use and sets them to be either inputs or outputs.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] niDaqSession**: The data acquisition session acquired from the connect method.
  - **CellArray namesChannelsAndBoolStates_CellArray**: A cell array of alternating strings and booleans. First strings contain the defined name of the channel, the second numeric digital channels to use. For example, if we  want to use the channel PFI1.2 and call it LEDIn, the first two values in the cell array are {'LEDIn', '1.2'}. Booleans contain the input or output configuration for each channel initialized in the previous variable. False is input, true is output. From the example above, if we want PFI1.2 to be an input we pass {false}. See the example below.
  
  ```Example: niDaq = niDaq.InitializeDigitalChannels(infoWindow, niDaqSession, {'valve1', '1.1', true, 'testIn', '1.5', false, 'valve2', '1.0', true, 'LEDIn' '1.2', false});```

- **obj = SetDigitalOutputChannelStates(obj, infoWindow, niDaqSession, channelNamesWithStates_CellArray)**: This method changes the states for any/all digital outputs.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] niDaqSession**: The data acquisition session acquired from the connect method.
  - **CellArray channelNamesWithStates_CellArray**: A cell array of strings and booleans which alternate from string (channel name) to bool (what to set that channel to).
  
  ```Example: niDaq = niDaq.SetDigitalOutputChannelStates(infoWindow, niDaqSession, {'valve1', true, 'valve2', false});```
  
- **obj = ToggleDigitalOutputChannelStates(obj, infoWindow, niDaqSession, channelNames_CellArray)**: This method toggles the states for any/all digital outputs.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] niDaqSession**: The data acquisition session acquired from the connect method.
  - **CellArray channelNames_CellArray**: A cell array of strings of (channel name)s to toggle (invert state).
  
  ```Example: niDaq = niDaq.ToggleDigitalOutputChannelStates(infoWindow, niDaqSession, {'valve1', 'valve2'});```
  
- **[obj, channelState] = GetDigitalInputChannelState(obj, infoWindow, niDaqSession, channelName_String)**: This method obtains the states for any/all digital inputs.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] niDaqSession**: The data acquisition session acquired from the connect method.
  - **string channelName_String**: A string containing the channel name from which to acquire data.
  - **bool channelState**: A logical indicating whether or not the digital input is high (true) or low (false).
  
  ```Example: [niDaq, LEDState] = niDaq.GetDigitalInputChannelState(infoWindow, niDaqSession, 'LEDIn');```
  
- **Disconnect(obj, infoWindow, niDaqSession)**: This method disconnects the DAQ from the computer.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] niDaqSession**: The data acquisition session acquired from the connect method.
  
  ```Example: niDaq.Disconnect(infoWindow, niDaqSession);```

---

## htHamamatsu

### Properties

### Methods

- **[obj, hamamatsuCameraObj] = Connect(obj, infoWindow, cameraName)**: This method connects the computer with the camera, presumed in this case to be the Hamamatsu, though any DCAM compatible camera with the same settings should work (this is not true for many other brands I think).
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **string cameraName**: A string which matches the name of the device available in Matlab's IMAQ configuration.
  - **[session] hamamatsuCameraObj**: The created camera object which is used to control the camera.
  
  ```Example: [hamamatsu, hamamatsuCameraObj] = hamamatsu.Connect(infoWindow, 'hamamatsu');```
  
- **imageToReturn = triggerAndReturnImage(obj, hamamatsuCameraObj)**: This method triggers the Hamamatsu camera for an image then returns that image.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[session] hamamatsuCameraObj**: The created camera object which is used to control the camera.
  - **double[] imageToReturn**: The image obtained from the camera. NxMx3, where the last index is the RGB channel.
  
  ```Example: imageToReturn = hamamatsu.triggerAndReturnImage(hamamatsuCameraObj);```
  
- **imageToReturn = triggerAndSaveAndReturnImage(obj, hamamatsuCameraObj, saveNameWithFilePath)**: This method triggers the Hamamatsu camera for an image, saves the image to a specified filename and filepath, then returns the image.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[session] hamamatsuCameraObj**: The created camera object which is used to control the camera.
  - **string saveNameWithFilePath**: A string containing the complete filename and filepath to save the image to.
  - **double[] imageToReturn**: The image obtained from the camera. NxMx3, where the last index is the RGB channel.
  
  ```Example: imageToReturn = hamamatsu.triggerAndSaveAndReturnImage(hamamatsuCameraObj, 'C:\IProbablyShouldntSaveDirectlyInTheCDir.tif');```
  
- **Disconnect(obj, infoWindow, hamamatsuCameraObj)**: This method disconnects the computer from the Hamamatsu camera.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] hamamatsuCameraObj**: The camera object which is used to control the camera.
  
  ```Example: hamamatsu.Disconnect(infoWindow, hamamatsuCameraObj);```

---

## htKDSPump

### Properties

- **deviceComPort**: This variable is set automatically with the function connect(). String which matches the virtual com port with which the pump is identified.

  ```Example: kdsPump.deviceComPort = 'Com5';```
  
- **diameterSetString**: String defining the diameter of the syringe; Default 'diameter 14.43'.

  ```Example: kdsPump.diameterSetString = 'diameter 14.43';```
  
- **maxVolumeSetString**: String defining the volume of the syringe; Default 'svolume 10 ml'.

  ```Example: kdsPump.maxVolumeSetString = 'svolume 10 ml';```
  
- **infuseRateSetString**: String defining the infusion rate; Default 'irate 3.0 ml/min'.

  ```Example: kdsPump.infuseRateSetString = 'irate 3.0 ml/min';```
  
- **withdrawRateSetString**: String defining the withdrawal rate; Default 'wrate 1 ml/min'.

  ```Example: kdsPump.withdrawRateSetString = 'wrate 1 ml/min';```

### Methods

- **[obj, kdsPumpSerialObj] = Connect(obj, infoWindow, comPort)**: This method connects the computer with the pump for a given com port.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **string comPort**: A string which matches the virtual com port assigned to the device by windows.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  
  ```Example: [kdsPump, kdsPumpSerialObj] = kdsPump.Connect(infoWindow, 'Com19');```
  
- **obj = SetWithdrawRate(obj, infoWindow, kdsPumpSerialObj, rateNumber, rateUnits)**: This method sets the withdraw rate for the pump. Be careful with your syntax as the units need to match the pump's list of acceptable units.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  - **double rateNumber**: A double or float which represents the withdraw rate in units specified in the next variable.
  - **string rateUnits**: A string containing the units to use. Must match the units available with the pump.
  
  ```Example: kdsPump = kdsPump.SetWithdrawRate(infoWindow, kdsPumpSerialObj, 1, 'ml/min');```
  
- **obj = BeginWithdrawing(obj, infoWindow, kdsPumpSerialObj)**: This method tells the pump to begin withdrawing with its current parameters.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  
  ```Example: kdsPump = kdsPump.BeginWithdrawing(infoWindow, kdsPumpSerialObj);```
  
- **obj = SetInfuseRate(obj, infoWindow, kdsPumpSerialObj, rateNumber, rateUnits)**: This method sets the infuse rate for the pump. Be careful with your syntax as the units need to match the pump's list of acceptable units. 
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  - **double rateNumber**: A double or float which represents the withdraw rate in units specified in the next variable.
  - **string rateUnits**: A string containing the units to use. Must match the units available with the pump.
  
  ```Example: kdsPump = kdsPump.SetInfuseRate(infoWindow, kdsPumpSerialObj, 1.0, 'ml/min');```
  
- **obj = BeginInfusing(obj, infoWindow, kdsPumpSerialObj)**: This method tells the pump to begin infusing with its current parameters.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  
  ```Example: kdsPump = kdsPump.BeginInfusing(infoWindow, kdsPumpSerialObj);```
  
- **obj = StopInfusingAndOrWithdrawing(obj, infoWindow, kdsPumpSerialObj)**: This method tells the pump to stop any motion.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  
  ```Example: kdsPump = kdsPump.StopInfusingAndOrWithdrawing(infoWindow, kdsPumpSerialObj);```
  
- **obj = UpdatePumpParameters(obj, infoWindow, kdsPumpSerialObj)**: This method updates the parameters currently used by the pump. The updated parameters are the syringe diameter, the maximum volume, the infusion rate, and the withdraw rate. Note that the order these parameters are set matters!
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  
  ```Example: kdsPump = kdsPump.UpdatePumpParameters(infoWindow, kdsPumpSerialObj);```
  
- **Disconnect(obj, infoWindow, kdsPumpSerialObj)**: This method disconnects the computer from the pump.
  - **[instance] obj**: The instance of the class. This argument is suppressed if called FROM the instance.
  - **[handle] infoWindow**: A handle to the information window. Used to relay information to the user.
  - **[session] kdsPumpSerialObj**: The camera object which is used to control the pump.
  
  ```Example: kdsPump.Disconnect(infoWindow, kdsPumpSerialObj);```
