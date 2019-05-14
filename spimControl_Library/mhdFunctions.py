# mhd Functions, notes at end of file.
#_ Clear the shell window's screen:__
import subprocess as sp
sp.call('clear',shell=True)
#=====================================

import inspect # also needed for lineno
import os, time # for os.getcwd() to find current DIR, and time for pause->time.sleep(1)#1sec pause
import sys
print '   ---'
print '  --'
print ''
print 'mhdFunctions imported'


#print 'main mhd Functions imported'
# mhd Functions List, set var name for use in other .py:::::::::::::::::
#   LineNumber = mhdFunctions.lineno()
#   BinnaryNum = mhdFunctions.leadingBitn(my_int)
#   SaveDirName = mhdFunctions.CreateDir()
#   Stackmsg = mhdFunctions.info(msg)# get info about py script that calls this functin module
#==============================================================


def lineno(): # get scripts line number where this is ran
    import inspect # also needed for lineno
    """Returns the current line number in our program."""
    return inspect.currentframe().f_back.f_lineno
# ------------------------------------------------------------
def info(msg): # get info about py script that calls this functin module
    frm = inspect.stack()[1]
    mod = inspect.getmodule(frm[0])
    print '[%s] %s' % (mod.__name__, msg)
# ------------------------------------------------------------
def leadingBitn(my_int):
    #print 'my_int =', my_int
    """ add a leading bit to value, 1 if negative, 0 if positive"""
    my_int=int(my_int)
    nmax=4096 # 12bit Et max
    if 0 <= my_int < nmax:
        return "{0:013b}".format(my_int) # by 13bit auto shove leading 0 for pos number on 12bit number
    elif my_int >= nmax:
        print 'n =',my_int,' > nmax of',nmax #4,000,000'
        return "0111111111111" # again leading 0 indicates positve number
    elif my_int <= -nmax:
        return "1111111111111" # again leading 1 indicates negativeitve number
    elif -nmax < my_int < 0:
        #print 'n < nmin of  -', nmax #4,000,000'
        return '1'+"{0:012b}".format(abs(my_int)) # add leading 1 indicates negativeitve number
# ------------------------------------------------------------
def BROKEN_caller_name():
    frame=inspect.currentframe()
    frame=frame.f_back.f_back
    code=frame.f_code
    return code.co_filename
    
#if CreateDir=='y':# 2) Create/Set Save Directory Folder__________________
def CreateDir():
   # self.EtUnits=EtUnits
    #if 0==0:
    #print 'inspect.stack()[1] = ',inspect.stack()[1]
    #print '   ---'
    #print '  --'
    #print ' -'
    #frm = inspect.stack()[1]
    #mod = inspect.getmodule(frm[0])
    #print 'mod.__name__ =', mod
    
    #curframe = inspect.currentframe()
    #calframe = inspect.getouterframes(curframe, 2)
    #print 'caller name:', calframe[1][3]
    
    # if run in top py, or in the one you want to set CurentDir and pyScriptNAme from/as:
    CurrentDir=os.getcwd() # print 'The Current working Directory is ',CurrentDir ## #dirfmt = "/root/%4d-%02d-%02d %02d:%02d:%02d" ## #dirfmt = "/%4d_%02d_%02d %02d-%02d-%02d"
    ThispyScriptName=__file__
    # else:
        # get name of calling py script from stack
    print 'caller name:', inspect.stack()[1][1]
    CallingpyScriptName=inspect.stack()[1][1]
    print 'CallingpyScriptName', CallingpyScriptName
    pyScriptNameBase=CallingpyScriptName[:-3] # Remove last 3 char, '.py'
    print 'pyScriptNameBase', pyScriptNameBase
    #dirfmt=str(CurrentDir+'/%4d_%02d_%02d-h%02d-m%02d-s%02d'+pyScriptNameBase) #dirfmt=str(CurrentDir+'/%4d_%02d_%02d-%02d-%02d-%02d')
    dirfmt=str(CurrentDir+'/%4d_%02d_%02d-h%02d-m%02d-s%02d'+pyScriptNameBase) #dirfmt=str(CurrentDir+'/%4d_%02d_%02d-%02d-%02d-%02d')
    SaveDirName = dirfmt % time.localtime()[0:6]
    #SaveDirName=SaveDirName # +'/' #SaveDirName = 'Test_Dir'
    print 'SaveDirName',SaveDirName
    SaveDirNameEtaValues=SaveDirName+'by_eta_values/'
    SaveDirNameEtaSlices=SaveDirName+'by_eta_Slices/'
    SaveDirNameChkTriplets=SaveDirName+'Usual_Triplets_for_chk/'
    try:
        os.mkdir(SaveDirName)
        #os.mkdir(SaveDirNameEtaValues)
        #os.mkdir(SaveDirNameEtaSlices)
        #os.mkdir(SaveDirNameChkTriplets)
        # print 'save to directory is ',SaveDirName
    except OSError:
        # print 'in except, either Dir already exhist or error'
        pass # already exists
    #else: # over rideds name all the time when in functioin file, comment out
    #    SaveDirName='HERE' # Just save to dir this .py ran from
    ###_ END :Create/Set Save Directory Folder=====================
    return SaveDirName

# ==================================================================
# ==================================================================

#Atom IDE,   UI theme Atom Dark
            #Syntax Theme, Ruby Blue
# numpy.savetxt("temp", a, fmt=fmt, header="SP,1,2,3", comments='')
