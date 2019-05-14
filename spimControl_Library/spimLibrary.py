"""Python function library for operating light sheet microscope.
	Functions:
		Scan - moves laser into focus and sweeps through the scan range.
		ContinuousScan - moves laser into focus and continuously sweeps through scan range.
		NoScanFocus - moves the laser to a specific offset and focus and allows changing these values with 
		    the arrow keys. Useful for alignment.
		aotfModScan - Modulates laser intensity during scan for structured illumination.
		galvoHiLoScan - Uses focusing galvo to create a structured illumination pattern - less useful than aotf version.

	To Do:
		DONE - Add function for continuous scanning, which is helpful when setting up samples
"""

import PyDAQmx as pydaq
import numpy as np
import time
import os
import sys

import kbhit as kbhit

def TestScanMultiFocus(focus, offset, exposure, slices, colors, timepoints, focusChannel="Dev1/ao0", scanChannel = "Dev1/ao1"):
	"""Testing added functionality to scan program --- each xy region can have its own focus setting. This will be built off of the scan program in which the camera triggers the galvo.

	Inputs:
		focus, offset, exposure (as previously)
		slices - number of z planes in a stack
		colors - number of channels in a stack
		timepoints - number of times each XY region will be scaned (in both colors)

	"""
	if (type(focus)==list):
		regions = len(focus)
	else:
		regions = 1

	if (regions > 5):
		print('Limit of 5 regions')
		return

	exposure = exposure/1000.
	images = slices*colors*timepoint


	analog_output = pydaq.Task()
	analog_output.CreateAOVoltageChan(focusChannel, "", -5.0,5.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(scanChannel, "", -5.0,5.0, pydaq.DAQmx_Val_Volts, None)

	samples = 10000
	sampllingRate = float(samples)/exposure
	analog_output.CfgSampClkTiming(None, samplingRate, pydaq.DAQmx_Val_Rising, pydaq.DAQmx_Val_FiniteSamps, samples)

	scan = np.linspace(-0.250, 0.250, samples) + offset
	focus = focus*np.ones((samples, regions))
	focus = np.transpose(focus)

	temp = (pydaq.c_byte*4)()
	actualWritten = pydaq.cast(temp, pydaq.POINTER(pydaq.c_long))

	analog_output.CfgDigEdgeStartTrig("PFI0", pydaq.DAQmx_Val_Rising)

	region = 0
	timepoint = 0

	"""There is surely a way to do this that is neutral with regards to the number of regions, but for now I'll write this explicitely and limit the number of regions to 5
	"""
	for timepoint in np.arange(0,timepoints):
		if (region==0):
			writeData = np.vstack((focus[0,:], scan))
			analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, none)
			for image in np.arange(0,slices*colors):
				analog_output.StartTask()
				analof_output.WaitUntilTaskIsDone(10.)
				analog_output.StopTask()
			region = np.mod(region+1, regions)

		elif (np.mod(image, 5) ==1):
			writeData = np.vstack((focus[1,:], scan))
			analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, none)
			for image in np.arange(0,slices*colors):
				analog_output.StartTask()
				analof_output.WaitUntilTaskIsDone(10.)
				analog_output.StopTask()
			region = np.mod(region+1, regions)
			
		elif (np.mod(image, 5) ==2):
			writeData = np.vstack((focus[2,:], scan))
			analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, none)
			for image in np.arange(0,slices*colors):
				analog_output.StartTask()
				analof_output.WaitUntilTaskIsDone(10.)
				analog_output.StopTask()
			region = np.mod(region+1, regions)

		elif (np.mod(image, 5) ==3):
			writeData = np.vstack((focus[3,:], scan))
			analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, none)
			for image in np.arange(0,slices*colors):
				analog_output.StartTask()
				analof_output.WaitUntilTaskIsDone(10.)
				analog_output.StopTask()
			region = np.mod(region+1, regions)

		elif (np.mod(image, 5) ==4):
			writeData = np.vstack((focus[4,:], scan))
			analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, none)
			for image in np.arange(0,slices*colors):
				analog_output.StartTask()
				analof_output.WaitUntilTaskIsDone(10.)
				analog_output.StopTask()
			region = np.mod(region+1, regions)

	return

def Scan(focus, offset, images, exposure, readout=10., focusChannel="Dev1/ao0", scanChannel="Dev1/ao1"):
	"""Function to scan galvo mirror across field of view, centered on offset voltage and with the focus set by the perpendicular galvo. This function is specific to a National Instruments DAQ card, used to send signals to the mirror galvonometers. A trigger (e.g. from the camera) is currently necessary on PFI0, if undesirable, change CfgDigEdgeStartTrig.
	
	***To Do:
	    - add error handling with Try/Except
	    - add scan signal bounds as an input. Not only does this vary a little with alignment, but needs to be different
	      for the visible laser galvos and enables an ROI.

	    Done - add a digital I/O channel to accept a trigger from the camera.
	    Done - figure out how to wait until sweep is done before exiting function (something better than timed delay?)

	Inputs:
	    focus - float, Voltage (in V) used by the off-axis galvo to bring the laser into focus.
	    offset - float, Voltage (in V) that steers the laser through the center of the scan range.
	    images - int, number of images in the scan
	    exposure - float/int, exposure time in milliseconds. The laser should take this long to cover the field of view.
	               *** In light sheet readout mode, the exposure time given to the camera refers to each 4 row block exposed in succession
		       So the number here should be equal to Vn/4 * Exp1 (total number of rows and camera's exposure time)
	    readout - float, readout time in milliseconds of the camera
	    
	    focusChannel - string, Hardware device and channel that controls the focus galvo, e.g. "Dev1/ao0"
	    scanChannel - string, Hardware device and channel that controls the scan galvo, e.g. "Dev1/ao1"
	"""
	print('Make sure that camera trigger is positive and set to Exposure\n otherwise behavior is unpredictable.')

	focus = float(focus)
	offset = float(offset)
	exposure = exposure/1000.
	readout = readout/1000.

	analog_output = pydaq.Task()
	analog_output.CreateAOVoltageChan(focusChannel, "", -10.0, 10.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(scanChannel, "", -10.0, 10.0, pydaq.DAQmx_Val_Volts, None)

	"""Create a timer that can be used to trigger the camera in light sheet readout mode (Hamamatus Orca Flash).
	There is a delay in the camera (see manual) of 1H*9, where 1H = HLN/(26600000) (HLN 2592 to 266*10^6 - refer to section 10-3-2 of the manual).
	The frame rate is calculated as 1/(Exp1 + (Vn+10)*1H), where Vn is the number of vertical lines and Exp1 can be varied from 9.7us to 10s
	"""
	HLN = 2592
	H1 = HLN/266000000.
	readout = 2048*H1
	#print(readout)
	timer = pydaq.Task()
	timer.CreateCOPulseChanTime("Dev1/Ctr0", "timer", pydaq.DAQmx_Val_Seconds, pydaq.DAQmx_Val_Low, 0.01, readout, exposure)
	timer.CfgImplicitTiming(pydaq.DAQmx_Val_FiniteSamps, images)
	
	"""For the time being, I am assuming that the field of view is (over)filled by sweeping through 600 milliVolts.
	At 40x with the Hamamatsu sCMOS, this should be about 333 microns, so there is a rough correspondence of 1.8mV to 
	1um. Since the NIR (bessel) beam has a FWHM of about 3um, I will move in 1mV (0.55um) steps, which should appear
	continuos. This means that the sampling rate should be set to samples/duration (where samples is 600)."""
	samples = 10000 + 1
	samplingRate = float(samples)/exposure
	analog_output.CfgSampClkTiming(None, samplingRate, pydaq.DAQmx_Val_Rising, pydaq.DAQmx_Val_FiniteSamps, samples)

	scan = np.linspace(-0.250, 0.250, samples) + offset
	#go back to starting value:
	scan = np.append(scan, scan[0])
	#print(str(scan[0]) + str(scan[-1]))
	focus = focus*np.ones(samples)
	#for debugging, go back to 0:
	#focus = np.append(focus, 0.0)
	#To minimize unnessecary sample exposure, move focus far away:
	#This is unnecessary if the AOTF is used as a shutter
	#focus = np.append(focus, -3.0 )
	focus = np.append(focus, focus[0])
	samples = samples + 1

	"""Since the analog out write function has an ouput that is the actual number of samples per channel successfully
	written to the buffer, create a variable to store those values: """
	temp = (pydaq.c_byte*4)()
	actualWritten = pydaq.cast(temp, pydaq.POINTER(pydaq.c_long))

	analog_output.CfgDigEdgeStartTrig("PFI0", pydaq.DAQmx_Val_Rising)


	if (focusChannel == "Dev1/ao0"):
		writeData = np.concatenate((focus, scan),1)
	else:
		writeData = np.concatenate((scan, focus),1)

	analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)
	
	timer.StartTask()

	for image in np.arange(0,images):
		analog_output.StartTask()

		done = pydaq.bool32()
		analog_output.IsTaskDone(pydaq.byref(done))
	
	#	while (done.value != 1):
	#		analog_output.IsTaskDone(pydaq.byref(done))
		
		analog_output.WaitUntilTaskDone(images*(exposure+readout))
		analog_output.StopTask()

	timer.WaitUntilTaskDone(-1)
	timer.StopTask()



	return



def ContinuousScan(focus, offset, duration=10. , extent=0.500 , focusChannel="Dev1/ao0", scanChannel="Dev1/ao1"):
	"""Function to continuously scan galvo mirror across field of view, centered on offset voltage and with the focus set by the perpendicular galvo. This function is specific to a National Instruments DAQ card, used to send signals to the mirror galvonometers. This function is useful when the camera is in free-runnung mode for, e.g. sample location, focus adjustment, etc.

	The main differences between this function and galvoScan are that 1. writing to the DAQ card occurs continuously in a loop and 2. writing starts immediately (there is no waiting for an external trigger).


	***To Do:
	    - add error handling with Try/Except


	Inputs:
	    focus - float, Voltage (in V) used by the off-axis galvo to bring the laser into focus.
	    offset - float, Voltage (in V) that steers the laser through the center of the scan range.
	    duration - float, Time (in ms) that the scan should take to completely sweep the field of view.
	    focusChannel - string, Hardware device and channel that controls the focus galvo, e.g. "Dev1/ao0"
	    scanChannel - string, Hardware device and channel that controls the scan galvo, e.g. "Dev1/ao1"
	"""
	duration = duration/1000.
	analog_output = pydaq.Task()
	analog_output.CreateAOVoltageChan(focusChannel, "", -10.0, 10.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(scanChannel, "", -10.0, 10.0, pydaq.DAQmx_Val_Volts, None)
	
	"""For the time being, I am assuming that the field of view is (over)filled by sweeping through 600 milliVolts.
	At 40x with the Hamamatsu sCMOS, this should be about 333 microns, so there is a rough correspondence of 1.8mV to 
	1um. Since the NIR (bessel) beam has a FWHM of about 3um, I will move in 1mV (0.55um) steps, which should appear
	continuos. This means that the sampling rate should be set to samples/duration (where samples is 600)."""
	samples = 10000
	samplingRate = float(samples)/duration
	analog_output.CfgSampClkTiming(None, samplingRate, pydaq.DAQmx_Val_Rising, pydaq.DAQmx_Val_ContSamps, samples)

	scan = np.linspace(-1*extent/2, extent/2, samples/2.) + offset
	"""Trace backward for less acceleration on the galvo (pyramid instead of sawtooth):
	"""
	scan = np.concatenate((scan,scan[::-1]),0)
	focus = focus*np.ones(samples)


	"""Since the analog out write function has an ouput that is the actual number of samples per channel successfully
	written to the buffer, create a variable to store those values: """
	temp = (pydaq.c_byte*4)()
	actualWritten = pydaq.cast(temp, pydaq.POINTER(pydaq.c_long))

	if (focusChannel == "Dev1/ao0"):
		writeData = np.concatenate((focus, scan),1)
	else:
		writeData = np.concatenate((scan, focus),1)

	analog_output.WriteAnalogF64(samples, True, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)

	kb = kbhit.KBHit()
	while(True):
		if kb.kbhit():
			try:
				k_in = kb.getarrow()
				analog_output.StopTask()
				if (k_in == 1):
					focus = focus + 0.001
					print('offset = %5.3f, focus = %5.3f' % (np.mean(scan), focus[0]))
				elif (k_in == 3):
					focus = focus - 0.001
					print('offset = %5.3f, focus = %5.3f' % (np.mean(scan), focus[0]))
				elif (k_in == 0):
					scan = scan + 0.001
					print('offset = %5.3f, focus = %5.3f' % (np.mean(scan), focus[0]))
				elif (k_in == 2):
					scan = scan - 0.001
					print('offset = %5.3f, focus = %5.3f' % (np.mean(scan), focus[0]))
				else:
					derp = "derr"
				writeData = np.concatenate((focus, scan),1)
				analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)
				analog_output.StartTask()

			except:
				Exit = raw_input("Want to exit?")
				if (Exit == 'y'):
					analog_output.StopTask()
					analog_output.ClearTask()
					return [np.median(scan), focus[0]]
				else:
					analog_output.StopTask()



	return


def NoScanFocus(focus, offset, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1"):
	"""Function to hold scan galvo mirror in middle of field of view (at offset voltage) and with the initial focus set by the perpendicular galvo. This function is specific to a National Instruments DAQ card, used to send signals to the mirror galvonometers. This function is used when the camera is in free-runnung mode for focus adjustment, taking keyboard input to adjust the focus voltage.


	***To Do:
	    - add error handling with Try/Except


	Inputs:
	    focus - float, Voltage (in V) used by the off-axis galvo to bring the laser into focus.
	    offset - float, Voltage (in V) that steers the laser through the center of the scan range.
	    focusChannel - string, Hardware device and channel that controls the focus galvo, e.g. "Dev1/ao0"
	    scanChannel - string, Hardware device and channel that controls the scan galvo, e.g. "Dev1/ao1"
	"""
	analog_output = pydaq.Task()
	analog_output.CreateAOVoltageChan(focusChannel, "", -10.0, 10.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(scanChannel, "", -10.0, 10.0, pydaq.DAQmx_Val_Volts, None)
	
	samples = 1000
	samplingRate = 1000.
	analog_output.CfgSampClkTiming(None, samplingRate, pydaq.DAQmx_Val_Rising, pydaq.DAQmx_Val_ContSamps, samples)

	scan = offset*np.ones(samples)
	focus = focus*np.ones(samples)

	"""Since the analog out write function has an ouput that is the actual number of samples per channel successfully
	written to the buffer, create a variable to store those values: """
	temp = (pydaq.c_byte*4)()
	actualWritten = pydaq.cast(temp, pydaq.POINTER(pydaq.c_long))

	"""Attempt to assign the correct channels to x and y galvos"""
	if (focusChannel == "Dev1/ao0"):
		writeData = np.concatenate((focus, scan),1)
	else:
		writeData = np.concatenate((scan, focus),1)

	analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)
	analog_output.StartTask()

	kb = kbhit.KBHit()
	while(True):
		if kb.kbhit():
			try:
				k_in = kb.getarrow()
				analog_output.StopTask()
				if (k_in == 1):
					focus = focus + 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 3):
					focus = focus - 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 0):
					scan = scan + 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 2):
					scan = scan - 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				else:
					derp = "derr"
				writeData = np.concatenate((focus, scan),1)
				analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)
				analog_output.StartTask()

			except:
				Exit = raw_input("Want to exit?")
				if (Exit == 'y'):
					analog_output.StopTask()
					analog_output.ClearTask()
					return [scan[0], focus[0]]
				else:
					analog_output.StopTask()




	return



def galvoHiLoScan(focus, offset, stripewidth, duration, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1"):
	"""Function that will scan the laser through the field of view, discontinuously jumping at certain intervals
	   in order to make excitation stripes. This could be used the do structured illumination with the IR laser,
	   which lacks a Pockels cell for intensity modulation.
	   At the moment, the visible galvo takes 0.45V (0.9V with IR lens) to traverse the field of view.
	"""

	analog_output = pydaq.Task()
	analog_output.CreateAOVoltageChan(focusChannel, "", -5.0, 5.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(scanChannel, "", -5.0, 5.0, pydaq.DAQmx_Val_Volts, None)
	
	#scan = np.linspace(-0.600, 0.600, samples) + offset
	temp = np.arange(0,75)
	temp = np.repeat(temp, np.floor(2048/75))
	y = np.linspace(0,1,len(temp))
	scan = (y+temp/75.)/2.*1.2 - 0.6 + offset
	focus = focus*np.ones(len(scan))
	"""."""
	samples = len(y)
	samplingRate = float(samples)/duration
	analog_output.CfgSampClkTiming(None, samplingRate, pydaq.DAQmx_Val_Rising, pydaq.DAQmx_Val_ContSamps, samples)
	
	

	"""Since the analog out write function has an ouput that is the actual number of samples per channel successfully
	written to the buffer, create a variable to store those values: """
	temp = (pydaq.c_byte*4)()
	actualWritten = pydaq.cast(temp, pydaq.POINTER(pydaq.c_long))

	if (focusChannel == "Dev1/ao0"):
		writeData = np.concatenate((focus, scan),1)
	else:
		writeData = np.concatenate((scan, focus),1)

	analog_output.WriteAnalogF64(samples, True, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)

	kb = kbhit.KBHit()
	while(True):
		if kb.kbhit():
			try:
				k_in = kb.getarrow()
				analog_output.StopTask()
				if (k_in == 1):
					focus = focus + 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 3):
					focus = focus - 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 0):
					scan = scan + 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 2):
					scan = scan - 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				else:
					derp = "derr"
				writeData = np.concatenate((focus, scan),1)
				analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)
				analog_output.StartTask()
				#print(k_in, k_in==1)
			#I currently can't figure out how to exit gracefully, this exception doesn't allow the function to be called again, as the task is still reserved (?)
	#		except KeyboardInterrupt:
	#			print("caught a keyboard interrupt!")
			except:
				Exit = raw_input("Want to exit?")
				if (Exit == 'y'):
					analog_output.StopTask()
					analog_output.ClearTask()
					return [np.median(scan), focus[0]]
					#sys.exit(0)
				else:
					analog_output.StopTask()




	return

def aotfModScan(focus, offset, duration, aomV, aomStripeWidth, phase=0, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1", aomChannel="Dev1/ao2"):
	"""Function to scan the visible laser and simultaneously modulate the AOTF in order to perform structured illumination,
	   e.g. for HiLo imaging. Currently, an 'aomStripeWidth' value of 7-10 looks good, but this will likely change as I 
	   figure out more appropriate scaling for this galvo.
	"""
	duration = duration/1000.

	analog_output = pydaq.Task()
	analog_output.CreateAOVoltageChan(focusChannel, "", -5.0, 5.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(scanChannel, "", -5.0, 5.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan(aomChannel, "", 0., 10.0, pydaq.DAQmx_Val_Volts, None)
	analog_output.CreateAOVoltageChan("Dev1/ao3", "", 0., 10.0, pydaq.DAQmx_Val_Volts, None)

	samples = 1000*2
	samplingRate = float(samples)/duration
#	samplingRate = 10000
	analog_output.CfgSampClkTiming(None, samplingRate, pydaq.DAQmx_Val_Rising, pydaq.DAQmx_Val_ContSamps, samples)

	scan = np.linspace(-1.800, 1.800, samples) + offset
#	scan = np.concatenate((scan,scan[::-1]),0)
	focus = focus*np.ones(samples)
	temp = np.concatenate((np.zeros(aomStripeWidth),aomV*np.ones(aomStripeWidth)),0)
	temp = np.tile(temp, samples/len(temp))
	aom = temp[0:samples+1]
#	aom = np.concatenate((aom, aom[::-1]),0)
	blank = 10*np.ones(samples)

	if (phase == 1):
		aom = np.roll(aom, int(aomStripeWidth/3))
	elif (phase == 2):
		aom = np.roll(aom, int(aomStripeWidth/3*2))

	

	"""Since the analog out write function has an ouput that is the actual number of samples per channel successfully
	written to the buffer, create a variable to store those values: """
	temp = (pydaq.c_byte*4)()
	actualWritten = pydaq.cast(temp, pydaq.POINTER(pydaq.c_long))

	if (focusChannel == "Dev1/ao0"):
		writeData = np.concatenate((focus, scan, aom, blank),1)
	else:
		writeData = np.concatenate((scan, focus, aom, blank),1)

	analog_output.WriteAnalogF64(samples, True, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)

	kb = kbhit.KBHit()
	while(True):
		if kb.kbhit():
			try:
				k_in = kb.getarrow()
				analog_output.StopTask()
				if (k_in == 1):
					focus = focus + 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 3):
					focus = focus - 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 0):
					scan = scan + 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				elif (k_in == 2):
					scan = scan - 0.001
					print('offset = %5.3f, focus = %5.3f' % (scan[0], focus[0]))
				else:
					derp = "derr"
				writeData = np.concatenate((focus, scan, aom, blank),1)
				analog_output.WriteAnalogF64(samples, False, -1, pydaq.DAQmx_Val_GroupByChannel, writeData, actualWritten, None)
				analog_output.StartTask()
				#print(k_in, k_in==1)
			#I currently can't figure out how to exit gracefully, this exception doesn't allow the function to be called again, as the task is still reserved (?)
	#		except KeyboardInterrupt:
	#			print("caught a keyboard interrupt!")
			except:
				Exit = raw_input("Want to exit?")
				if (Exit == 'y'):
					analog_output.StopTask()
					analog_output.ClearTask()
					return [np.median(scan), focus[0]]
					#sys.exit(0)
				else:
					analog_output.StopTask()






	return

#def spimSideSelect(diSPIMEnable=True):
	"""Function to coordinate the laser source between the ASI diSPIM and home-built setup. Requires one digital input, one user input, and two digital outputs. If the program can exit with the DAQ outputs staying where they are at, then it can be called and allowed to return (This depends on DAQ functionality, which I am unsure about).

	Inputs:
		diSPIMEnable - boolean, it True, laser will be guided to the left or right arm of the ASI setup, if False, to the home built setup.
	"""

#	digital_io = pydaq.Task()
#	digital_io.CreateDOChan("Dev1/port0/lines0:1", "switchPin1and2", pydaq.DAQmx_Val_ChanForAllLines)
#	digital_io.CreateDIChan("Dev1/port0/line2", "PLCpin4", pydaq.DAQmx_Val_ChanForAllLines)
#	
#	from PyDAQmx import Task
#	class CallBackTask(Task):
#		def __init__(self):
#			Task.__init__(self)
#			self.CreateDIChannel("Dev1/port0/line2", "PLCpin4", DAQmx_Val_ChanForAllLines)
#			self.CfgSampClkTiming("", 1000.0, DAQmx_Val_Rising, DAQmx_Val_ContSamps, 1000)
#			self.DAQmxRegisterSignalEvent("", DAQmx_Val_ChangeDetectionEvent, 0)
#			self.DAQmxRegisterDoneEvent(0)
#		def SignalEventCallback(self):
#



#	return



