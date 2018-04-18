# API Reference for High-Throughput code

Overview of the classes for the high-throughput API developed for the Parthasarathy lab and provides syntax/uses of properties and functions.

---

## Inheritance Tree and Method Overview

All classes are extended from the 'form' class.

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

### Methods

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

---

## htKDSPump

### Properties

### Methods

---

## htRunProcedures

Currently in progress

- **function**: Description
  - **variable**: Description
  
  ```Example: Words```
  
- **variable**: Description

  ```Example: Text```
