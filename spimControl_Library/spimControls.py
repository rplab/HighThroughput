''' Parthasarathy lab - University of Oregon  https://pages.uoregon.edu/raghu/
    High Throughput LightSheet (HTLS) & simple LS setup LASER beam (galvo)
    alighnment and lightsheet paramters setup
    Leave code running once set for experiment, galvonometers lose settingson close
    of anaconda terminal.

    This script: spimControls :  Based on kbtest_0_0_3e.py that function [7] worked
     as did mike's old version

    Waringing kb.kbhit test arrorw keys with charater keys both acitve works on smoe OS and keybaords not others
        swithcing this code not to use main arrow keys and use number pad arrows,
        8: up
        2: down
        4: left
        6: right

To Do:
    - switch arrow keys to numpad Updated
    - feed [sacn[0],focus[0]] to Scan Function on select
    - copy Mikes Scan mode to scanMode2
        - add offset, scan, width adjust to scan mode'''

import numpy as np
import time
import os
import sys
import kbhit as kbhit
#print('imports done')
import spimLibraryX_0_2_4 as spim# version updated from Mike's spimLibrary, to add menu selections and stepsize options etc
t = 1 # time.sleep(1)

#<< Print to anaconda terminal window code Info  -------------------
print('Testing Keyboard response for galvo ctrl stuf, \n 1: 0n spimLibrary002')
#<< func: Print to anaconda terminal window code Info
def print_infoA():
    print('')
    print('*****************************************************')
    print('**  HTLS Galvo setup                               **')
    print('**    Based on spimLibrary.py   7th May 2019, mhd  **')
    print('**  _____________________________________________  **')
    print('**  Updated spimLibrary to run as whole program    **')
    print('**   call from blue anaconda cmd terminal window   **')
    print('**   to find paths and libraries, not bash terminal.*')
    print('***  _____________________________________________***')
    print('')
#    print('    .........................')
    print ('    press a defined Key at any time to change function:')
    print('     Functions:')
    print('       PRESS [1]  for spim.Library function call Test ONLY.')
    print('       PRESS [2]  to run galvo NoScanfoucs v2')
    print('       PRESS [3]  to run galvo NoScanfoucs (Mikes era version)')
    print('       PRESS [4]  to run galvo Scan for LightSheet experiment')
    print('       PRESS [5]  to run  spim.NoScanFocus2getarrowDEBUG')
    #print('       PRESS [6]  UNASSIGNED....')

    print('       PRESS [o]  to set offset')
    print('       PRESS [f]  to set focus')
    print('       PRESS [w]  to set light sheet width, (scan modes only).')
    print('        _____________________________________________')
    print('        When In NoScanFocus, reset stepSize of glavo offset and focus')
    #print('        press [fn1] through [fn4] to change NoScanfoucs stepsize')
    #print('          [fn1] [fn2] [fn3] [fn4]')
    print('        press [1] through [4] to change NoScanfoucs stepsize')
    print('          [1]    [2]    [3]   [4]')
    print('          0.001  0.01   0.1   1.0')
    print('          _______________________')
    print('')
    #____________________________________________________________
def print_info():
#    print('')
    print('**************************************************************************')
    print('**  HTLS Galvo setup,  Based on spimLibrary.py   7th May 2019, mhd      **')
#    print('**  _____________________________________________  **')
    print('**  Updated spimLibrary to run as whole program call from blue anaconda **')
    print('**  cmd terminal window to find paths and libraries, not bash terminal. **')
    print('***  __________________________________________________________________***')
#    print('')
#    print('    .........................')
#    print ('   press a defined Key at any time to change function:')
    print('   Functions (press [Key] [Enter] to run) :')
    print('       PRESS [q]  To move up one menu (exits if at main menu).')
    print('       PRESS [1]  for spim.Library function call Test ONLY.')
    print(' 1st-> PRESS [2]  to run galvo NoScanfoucs v2')
    print('       PRESS [3]  to run galvo NoScanfoucs (Mikes era version)')
    print(' 2nd-> PRESS [4]  to run galvo Scan for LightSheet experiment')
    print('       PRESS [5]  to run DEBUG mode of galvo NoScanfoucs v2')

#    print('       PRESS [5]  to run NoScanFocus2getarrowDEBUG, only arrow keys active')
#    print('       PRESS [6]  UNASSIGNED....')
#    print('       PRESS [7]  to runNoScanFocus2 all keyboard active')
#    print('       PRESS [8]  to runNoScanFocus2 in DEBUG mode, all keyboard active')
    #print('')
    print('   Set Specific Value:')
    print('       PRESS [o]  to set offset')
    print('       PRESS [f]  to set focus')
    print('       PRESS [w]  to set light sheet width(extent,  scan modes only).')
    print('       PRESS [d]  to set light sheet duration, (scan modes only).')
    #print('')
#    print('   Run a Debug mode function:')
#    print('       PRESS [5]  to run NoScanFocus2getarrowDEBUG, only arrow keys active')
#    print('       PRESS [8]  to run galvo NoScanFocus2 v2 in DEBUG mode, ALL keys active ')
    print('        _____________________________________________')
    print('        When In NoScanFocus, reset stepSize of glavo offset and focus')
    #print('        press [fn1] through [fn4] to change NoScanfoucs stepsize')
    #print('          [fn1] [fn2] [fn3] [fn4]')
    print('        press [z] through [v] to change NoScanfoucs stepsize')
    print('          [z]    [x]    [c]   [v]')
    print('          0.001  0.01   0.1   1.0')
    print('          _______________________')
    print('')

def writeup_location(SetOffset, SetFocus, stepSize, SetWidth):
    sys.stdout.write(' \r  |  offset = %5.3f, focus = %5.3f   |  step size = %5.3f   width = %5.3f  |\n' %(SetOffset, SetFocus, stepSize, SetWidth)) #scan, focus, stepSize))
    sys.stdout.flush()

def print_location(SetOffset, SetFocus, stepSize, SetWidth):
    print('  |  offset = %5.3f, focus = %5.3f   |  step size = %5.3f   width = %5.3f  |\n' %(SetOffset, SetFocus, stepSize, SetWidth)) #scan, focus, stepSize))
#>> ___________________________________________________________
# n = 5
#>> ___________________________________________________________
# n = 5
# while n > 0:
    # n -= 1
    # print(n)
n = 1

#print('start kb with n = ',n)
#kb = kbhit.KBHit()
#print('kb started')

# Default settings for galvo etc ------------------
stepSize=0.001
scan =0
focus=0
offsetGbl = 0
focusGbl = 0
SetOffset = 0 # galvo setting to ster beam left or right in sample chamber
SetFocus = 0 # galvo setting to ster beam +/- towards objective lens
SetWidth = 3. # Lightsheet width for scan mode, not used in NoScanFocus()
extent= 3.
duration = 10
def NoScanFocusKeyboadInputs(scan, focus,stepSize):
    print("press 'q' to exit NoScanFocus  and return to top menu")
    while(True):
    #    print('sleep for',t,' sec, with n =',n)
    #    time.sleep(1)
        if kb.kbhit():
            try:
                k_in = kb.getch()
                #k_in = kb.getarrow()
                ''' Returns an arrow-key code after kbhit() has been called. Codes are
                #kb.getarrow()
                    0 : up
                    1 : right
                    2 : down
                    3 : left
                      Should not be called in the same program as getch().
                #k_in = sys.stdin.read(1). up arrow key returns  ^[[A but only reads in the 'A'
                                            so on my linux system A,B,C,D works for arrow keys
                    A: up
                    B: down
                    C: ritght
                    D: left
                  'P': F1
                  'Q': F2
                  'R': F3
                  'S': F4'''
                #$analog_output.StopTask()
                if (k_in == 'q'):
                    break # return (False) # <-- might be python3 way, not working here in python2.7
                method ='new'
                if method == 'old':
                    if (k_in == 'A'): # 1):
                        focus = focus + 0.001
                        print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                    elif (k_in == 'B'): # 3):
                        focus = focus - 0.001
                        print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                    elif (k_in == 'C'): # 0):
                        scan = scan + 0.001
                        print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                    elif (k_in == 'D'): # 2):
                        scan = scan - 0.001
                        print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                if method == 'new':
                    if (k_in == 'A'): # 1):
                        focus = focus + 0.001
                        #print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    elif (k_in == 'B'): # 3):
                        focus = focus - 0.001
                        #print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    elif (k_in == 'C'): # 0):
                        scan = scan + 0.001
                        #print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    elif (k_in == 'D'): # 2):
                        scan = scan - 0.001
                       # print('offset = %5.3f, focus = %5.3f' % (scan, focus))
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()

                    # [keys 1 2 3 4] change stepSize -----------------------
                    elif k_in =='1': #'P':
                        #print('[F1] PRESSED')
                        stepSize = 0.1
                        #print('Step Size now = ', stepSize)
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    elif k_in =='2': #'Q':
                        #print('[F2] PRESSED')
                        stepSize = 0.01
                        #print('Step Size now = ', stepSize)
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    elif k_in =='3': # 'R':
                        #print('[F3] PRESSED')
                        stepSize = 0.1
                        #print('Step Size now = ', stepSize)
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    elif k_in =='4': # S':
                        #print('[F4] PRESSED')
                        stepSize = 1.0
                        #print('Step Size now = ', stepSize)
                        sys.stdout.write(' \roffset = %5.3f, focus = %5.3f   |step size = %5.3f     |' % (scan, focus, stepSize))
                        sys.stdout.flush()
                    else:
                        derp = "derr"

            except AttributeError:
               pass
               print('exiting NoScanFocus')
               time.sleep(0.1)
               break #exit()
    #return (scan, focus)
    return [scan, focus]
# ===================================================================

SelectFunction=0
#if SelectFunction =='1':
print ('Checking spimLibrary Improted...')
spim.functionTest()

def main():
    print(" :  ...")
    print('Anaconda Terminal Control for Thorlab Galvos Started...')

## Main init
if __name__ == "__main__": main()
print_info() # print info to terminal---------------------------
while SelectFunction != 'q':
    #import spimLibraryX_0_2_1 as spim# version updated from Mike's spimLibrary, to add menu selections and stepsize options etc
    #SelectFunction = raw_input('press [1] NoScanFocus, Press [2] to Scan,  [3] Exit :  ')
    print ('')
    time.sleep(0.1)
    SelectFunction = raw_input('press [key] then [Enter] to run that function.  : ')
    # To reset NoScanfocus values------------------------------
    if SelectFunction =='0':
        SetOffset = 0
        SetFocus = 0
        print ("Swithcing to NoScanFocus (Mike's era v1) set beam location to (0,0)...")
        print ('Keyboard arrows will be active to focus and adjust offset')
        DebugMode = 'Off' # when debug is Off, Runs the ni PyDAQmx hardware
                              #NoScanFocus2getch(focus, offset, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1", DebugMode):
        [SetOffset,SetFocus] = spim.NoScanFocus2getch(SetOffset, SetFocus, stepSize, SetWidth, DebugMode, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #spim.NoScanFocus2getch(SetOffset, SetFocus, stepSize, SetWidth, DebugMode, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
        #spim.NoScanFocus(offset=0,focus=0, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #NoScanFocus(offset=0,focus=0, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
    if SelectFunction =='o': # rest offset
        SetOffset = float(raw_input('Enter beam offset value :  '))
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
    if SelectFunction =='f': # rest focus
        SetFocus = float(raw_input('Enter beam focus value :  '))
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
    if SelectFunction =='w': # rest width
        SetWidth = float(raw_input('Enter LS width value (only used in LS mode, ~3. last good for 20x) :  '))
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
    if SelectFunction =='d': # rest width
        duration = float(raw_input('Enter LS duration value (only used in LS mode, 5(20x) to 10(40x)?)'))
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
        # To Start Function----------------------------------------
    if SelectFunction =='1':
        #print ('Checking spimLibrary Improted...')
        sys.stdout.write(' \rChecking spimLibrary Improted...') #scan, focus, stepSize))
        sys.stdout.flush()
        spim.functionTest()
        #sys.stdout.write(' \r  |  offset = %5.3f, focus = %5.3f   |  step size = %5.3f   width = %5.3f  |\n' %(SetOffset, SetFocus, stepSize, SetWidth)) #scan, focus, stepSize))
        #sys.stdout.flush()
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
        #print ('Offset = ', SetOffset, ' | Focus = ', SetFocus,'  | Width = ',SetWidth)
    if SelectFunction =='12':
        print ('Swithcing to NoScanFocus2getarrow...')
        print ('Keyboard arrows active to focus and adjust offset')
        #spim.functionTest()      SetOffset, SetFocus, stepSize, SetWidth
        spim.NoScanFocus2getarrow(SetOffset, SetFocus, stepSize, SetWidth, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #NoScanFocus(offset=0,focus=0, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
    if SelectFunction =='3':
        print ("Swithcing to NoScanFocus (Mike's era v1)...")
        print ('Keyboard arrows will be active to focus and adjust offset')
        #spim.functionTest()
        spim.NoScanFocus(offset=0,focus=0, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #NoScanFocus(offset=0,focus=0, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")

    if SelectFunction =='4':
        print ('Scan Galovs to run experiment,')
        #spim.functionTest()
        #print('please finsih testing the subroutine code to run this function...')
        # SetWidth => extent
        # duration is what ?
        extent= SetWidth #0.500 ,
        #[SetOffset,SetFocus] = spim.ContinuousScan2(SetOffset, SetFocus, stepSize,  duration=10. , extent=0.500 , focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        [SetOffset,SetFocus] = spim.ContinuousScan2(SetOffset, SetFocus, stepSize,  duration , extent , focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #[SetOffset,SetFocus] = spim.ContinuousScan2(SetOffset, SetFocus, stepSize,  duration=10. , SetWidth , focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")

    if SelectFunction =='15':
        print ('spim.NoScanFocus2getarrowDEBUG test function...')
        [SetOffset,SetFocus] =spim.NoScanFocus2getarrowDEBUG(SetOffset, SetFocus, stepSize, SetWidth, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #spim.functionTest()
        #print('returned scan = ', SetScan)
        #print('returned focus = ', SetFocus)
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
    if SelectFunction =='2':
        print ('spim.NoScanFocus2 all keyboard active...')
        DebugMode = 'Off' # when debug is Off, Runs the ni PyDAQmx hardware
                              #NoScanFocus2getch(focus, offset, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1", DebugMode):
        [SetOffset,SetFocus] = spim.NoScanFocus2getch(SetOffset, SetFocus, stepSize, SetWidth, DebugMode, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        #spim.NoScanFocus2getch(SetOffset, SetFocus, stepSize, SetWidth, DebugMode, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
    if SelectFunction =='5':
        DebugMode = 'On' # when debug is On, prevents Runing the ni PyDAQmx hardware calls in spimLibrary
        print ('Debug mode: NoScanFocus2 all keyboard active...')
                              #NoScanFocus2getch(focus, offset, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1", DebugMode):
        [SetOffset,SetFocus] = spim.NoScanFocus2getch(SetOffset, SetFocus, stepSize, SetWidth, DebugMode, focusChannel="Dev1/ao0", scanChannel="Dev1/ao1")
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
        pass
    if SelectFunction =='q':
        print ('Exiting spim terminal program...')
        break#delay(1)
        #spim.functionTest()
        writeup_location(SetOffset, SetFocus, stepSize, SetWidth)
        time.sleep(0.1)
    else:
        pass

# (scan,focus) = NoScanFocusKeyboadInputs(scan,focus,stepSize)
# print('')
# print('------------------------')
# print('scan, focus you left off at was : ',(scan,focus))
# print(scan,focus)
# print'scan, focus you left off at was : ',(scan,focus)
# print('scan and focus you left off at was : (',scan,',',focus,')')
# print(scan)
