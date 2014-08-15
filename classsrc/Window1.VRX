/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff
/* 
    user init 
*/
    call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
    call SysLoadFuncs

    registerwindow_id = 0 /* global variable */
    aboutwindow_id = 0 /* global variable */

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

    call listclasses

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary: procedure
    name = arg( 1 )

    window = VRLoad( VRWindow(), VRWindowPath(), name )
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
return window

/*:VRX         About_Close
*/
About_Close:
    window = VRInfo( "Object" )
    call VRDestroy window
    drop window
return
/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         listclasses
*/
listclasses:
    call SysQueryClassList "classes."
    ret = VRMethod("lista","Reset");
    ret = VRMethod("lista","AddStringList","classes.");
    drop classes.
    drop ret
return

/*:VRX         PB_10_Click
*/
PB_10_Click:
    ok = VRDestroy(aboutwindow_id)
return

/*:VRX         PB_1_Click
*/
PB_1_Click:
    call listclasses
return

/*:VRX         PB_2_Click
*/
PB_2_Click:
    classname = word(VRGet("lista","SelectedString"),1)

    buttons.0=1
    buttons.1="OK"
    
    if length(classname)>0 then 
    do
        if SysCreateObject(classname,classname,"<WP_DESKTOP>") then 
              ret= VRMessage("lista"," Success","","I","buttons.",1,)
        else  ret= VRMessage("lista"," Failure","","E","buttons.",1,)
    end
    drop buttons.
return

/*:VRX         PB_3_Click
*/
PB_3_Click:

    classname = word(VRGet("lista","SelectedString"),1)

    buttons.0=2
    buttons.1="YES"
    buttons.2="NO"
    
    ret = VRMessage("Object","Destroy " || classname ,"","Q","buttons.",2,,)
    if ret = 2 then return

    ret = SysDeregisterObjectClass(classname)

    call listclasses
return

/*:VRX         PB_4_Click
*/
PB_4_Click:
    registerwindow_id = VRLoadSecondary(RegisterWindow)
return

/*:VRX         PB_5_Click
*/
PB_5_Click:
    ok = VRDestroy(registerwindow_id)
return

/*:VRX         PB_6_Click
*/
PB_6_Click:

    filename = VRFileDialog("Object","","O","c:\","",,)
    call VRSet "DLL_NAME","Value",filename

return

/*:VRX         PB_7_Click
*/
PB_7_Click:
    dlldir    = VRGet("DLL_DIRECTORY","Value")
    if length(dlldir)=0 then return
    dllname   = VRGet("DLL_NAME","Value")
    if length(dllname)=0 then return
    classname = VRGet("CLASS_NAME","Value")
    if length(classname)=0 then return    

    buttons.0=1
    buttons.1="OK"
    
    destination = dlldir || "\*.*"
    /* copia del file nella directory dll */
    ok = VRCopyFile(dllname,destination)
    if ok = 0 then ret= VRMessage("lista"," Failure in copying dll ","","E","buttons.",1,)

    name = substr(dllname,lastpos("\",dllname)+1)  

    ok = SysRegisterObjectClass(classname,substr(name,1,lastpos(".",name)-1))
    if ok = 0 then ret= VRMessage("lista"," Failure in registering "|| name,"","E","buttons.",1,)

    ok = VRDestroy(registerwindow_id)
    call listclasses
return

/*:VRX         PB_8_Click
*/
PB_8_Click:
    exit
return

/*:VRX         PB_9_Click
*/
PB_9_Click:
    aboutwindow_id = VRLoadSecondary(About)
return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         RegisterWindow_Close
*/
RegisterWindow_Close:
    window = VRInfo( "Object" )
    call VRDestroy window
    drop window
return
/*:VRX         Window1_Close
*/
Window1_Close:
    call Quit
return

