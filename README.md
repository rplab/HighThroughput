# API Reference for High-Throughput code

I might be abusing the phrase 'API Reference,' but the point remains: this document exists to provide an overview of classes and syntax/uses of their properties and functions.

---

## Inheritance Tree

All classes are extended from the 'form' class.

- form
  - instrument
    - htDaq

## API Reference

### Form

Properties

- **bool warningsVerbose**: Boolean which will allow verbose printing of minor warnings to the command window if true.

  ```Example: formInstance.warningsVerbose = false```

Methods

### Instrument

Properties

- **handle**: Handle for whatever instrument is instantiated. If 0, no instrument was found but the user wants to continue anyway. If -1, no instrument was found and the user wants to quit.

  ```Example: instrumentInstance.handle```

Methods

### htDaq

Properties

- **string deviceID**: A string which identifies which DAQ the user wants to use. For example, if we wanted to use the NI-DAQ 6343, we open NI-MAX and find that it has been labeled with the ID 'HTDev1', so deviceID should be set to 'HTDev1'. This variable is set automatically with the function connect().

  ```Example: htDaqInstance.deviceID = 'HTDev1';```
  
- **cellArray(strings) channelNames**: A cell array of channel names (defined by user) associated with the channels initialized the in method 'initializeDigitalChannels' (see below). Order is important and must match the variables in the method 'initializeDigitalChannels'. This variable must be manually set by the user.

  ```Example: htDaqInstance.channelNames = {'Valve1', 'Valve2', 'Brightfield LED', 'LEDTriggerState'};```

Methods

- **connect(obj, NIMaxID)**: This method connects the computer with the DAQ, previously labeled with an ID via NI-MAX.
  Inputs: obj - The instance of the class.
          NIMaxID - A string which matches the device ID in NI-MAX (e.g. 'HTDev1')
  Outputs: N/A

  ```Example: htDaqInstance.connect(htDaqInstance, 'HTDev1');```
  
- **initializeDigitalChannels(obj, channels_CellArrayOfStrings, inputOutputStates_BoolVector)**:

- **setDigitalOutputChannelStates(obj, channelNamesWithStates_CellArray)**:

- **bool** channelState = **getDigitalInputChannelState(obj, channelName_String)**:

- **disconnect(obj)**:
