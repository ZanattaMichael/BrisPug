'                              !!!!!!!!!!!!!PATCHED!!!!!!!!!!!!!!
'
'Written By Wogboy222
'Program: Messenger.vbs
'Email Address: 
'Usage: Messanger.vbs
'Version: 1.1
'Platform: Windows 2000 (Unknown) \XP (Recommended) \2003\Vista (XP or Higher)
'Year Created: 2007
'Encryption Engine Name: ZMI
'Encryption Engine Version: Version 1.0 
'Copyright (c) All Rights Reserved 2007. 
'Special Thanks to Clive Watson for his HEX to DEC Function.
'
'Functions Used:
'	****************
'	File          : HEXTODEC.VBS
'	Name          : Clive Watson.
'	Version     : V1.0 - Initial Version (9/Feb/1999) 
'
'	Summary     : Convert HEX values to DECimal.
'
'	****************
' 	Name : HEXTODEC
' 	Purpose: Converts a HEX value to DECimal.
' 	Inputs : <A valid HEX value>
' 	Returns: Result in Decimal
'
'
'Patch Description: Includes Encrytion for Users. Users can now have 
'private multiple converstations Taking place in the one file. 
'Uses basic encryption algorytem.
'
'Additional Notes: Use 5 to 8 Charachters for encryption. It's harder to crack.
'Approx Cracking time 1 hour.
' 
' User Comments: This is basic demonstration on how powerful Vbs really is.
'                This program is a basic Messenger Program. This program
'                is just an example, so everyone is allowed to do what they want to the code. I don't really care.
'                Just note that Z: drive has to be free for you to connect to the server. Also note
'                when creating a new "server" this can't be done on a SUBST virtual drive.
'                It MUST be run on the Hard Drive! Finally note that only 10 users can connect
'                to a single server. This prevents major lag.
'                Admin Privileges is recommended to connect, but you can use other accounts, just
'                make sure the security permissions are correct. To set up the server, Administrator
'                or Power User's privileges are recommended. 
' 
'                                     Have Fun!
'
'
'                WARNING: Do NOT Feed this program ASCII Numbers. I sent a carriage return
'                         and the program crashed. The reason why I won't patch it up, is
'                         purely because this is only a demonstration. Don't send Alt 13!
'                           
' Known Bugs:
'
' 1. Attempt to insert ASCII number, which could cause a connection error. Which will
'    Cause a cross communication error, on reconnection. Delete the .swp file on server to
'    solve the problem.
' 3. Cross Communication error. Last line might be -. Then viewer will think that it's ok and
'    continue reading. There is a problem with the File System Object, that I cannot fix.
' 4. Leaving any of the Cross Communication Reply or Display files open, when attempting to
'    delete leaves a fatal error. To fix. Shutdown the Wscript.exe processes and reboot the
'    computer. Then attempt to delete the files manually.   
' 5. Running this script under windows 95, 98 or ME.  
' 6. FSO Object will be inserting wired code into the cross communication text file.
'    If this happens. Disconnect manually        
'
'============================================
' Cross Communication Rules
'============================================
' 1 = User Disconnected.
' 2 = Dropping Connection due to bad lag or invalid connection..
' 3 = Lag is encountered, on your connection. Attempting to reconnect in 6 seconds
' 4 = The connection was lost. Disconnected...
'
'
'
'Edited by: Wogboy222 (Version 1.1)
'Edited by:
'
'===================================================
'
' This section checks weather the "Display"
' console has been activated. This is done
' by having the script run it's self as a wscript
' instead of a wscript. Then to determine wether
' if it's true, it checks to see of the -display
' argument has been applied.. If so. Then it activates
' the display console.
'

Const Argument_00 = "-display"
Const Argument_BLANK = ""	

Const SYSTEM_OBJECT_FSO = "Scripting.Filesystemobject"
Const SYSTEM_OBJECT_NETWORK = "Wscript.Network"    

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8
Const OverWriteFile = True
Const Windows = 0
Const PublicRead = 1
Const PublicWrite = 2

Const TristateUseDefault = -2
Const TristateTrue = -1
Const TristateFalse = 0

Const COMMUNICATION_Display_File = "Display.Dat"
Const COMMUNICATION_Reply_File = "Reply.Dat"
Const COMMUNICATION_Input_Display_Communicater = "CrossControl.crssc"

Const SYMBOL_BACKWARD_SLASH = "\"
Const SYMBOL_FOREWARD_SLASH = "/"
Const SYMBOL_AT = "@"
Const SYMBOL_COMMA = ","
Const SYMBOL_FULLSTOP = "."
Const SYMBOL_BLANK = ""

Const MSGBOX_BUTTON_YES_NO = 4
Const MSGBOX_BUTTON_YES_NO_CANCEL = 3
Const MSGBOX_BUTTON_ABORT_RETRY_IGNORE = 2
Const MSGBOX_BUTTON_OK_CANCEL = 1
 
Const MSGBOX_RESULT_VB_OK = 1
Const MSGBOX_RESULT_VB_CANCEL = 2
Const MSGBOX_RESULT_VB_ABORT = 3
Const MSGBOX_RESULT_VB_RETRY = 4
Const MSGBOX_RESULT_VB_IGNORE = 5
Const MSGBOX_RESULT_VB_YES = 6
Const MSGBOX_RESULT_VB_NO = 7

Const MESSAGEBOX_MESSAGE_00 = "Do you wish to setup a server?"
Const MESSAGEBOX_TITLE_00 = "Question?"


' ================================================
' This section just loads the global variables
' for the server setup and the messaging client.
' It also questions the viewer wether it want
' to create a server.
'
ArgumentHandler()


Dim WshShell, objNet, fso, objWMIService
Dim scriptFullName, scriptPath
Dim CaputuredFirstSecond
Dim ServerReaderFile, ReplyConfirm, CrossController
Dim DisplayMessage
Dim Computername, Username, Password
Dim objPing
Dim RunKill, TryMapDrive, WshNetwork
Dim ServerInfo, ReadServerFile
Dim ReadFile, Counter
Dim SafteySwapper, Conversation, TransferDataController
Dim TransController, WriteForReader
Dim MessengerName, Input
Dim ExitCounter, LagCounter
Dim X
Dim WRITEDATA, SW
Dim Reply
Dim Count
Dim MainArray
Dim Store()
     
Set WshShell = WScript.CreateObject("WScript.Shell")
Set objNet = WScript.CreateObject("WScript.Network")
Set fso = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

scriptFullName = WScript.ScriptFullName                          					 ' These two lines gather the File Path which the script is running on.
scriptPath = Left(scriptFullName, InstrRev(scriptFullName, SYMBOL_BACKWARD_SLASH))

DisplayConfigFile = scriptPath & SYMBOL_BACKWARD_SLASH & COMMUNICATION_Display_File   ' This holds the information for the display to connect to the service
ReplyConfirm = scriptPath & SYMBOL_BACKWARD_SLASH & COMMUNICATION_Reply_File         ' This file is used as a signal that the Display console has verified the information.
CrossController = scriptPath & SYMBOL_BACKWARD_SLASH & COMMUNICATION_Input_Display_Communicater  ' This file is used to signal the Display console to perform certain commands, due to error levels
                                                      								 ' on the messaging client.

If PromptUser(MESSAGEBOX_MESSAGE_00, MESSAGEBOX_TITLE_00, MSGBOX_BUTTON_YES_NO, MSGBOX_RESULT_VB_YES) = True Then
  Call SetupServer()
  CloseApplaction
End if  


'=======================================
' Attempts to connect to the server
'=======================================
'
' This section connects to the remote computer.
' This is done by mapping the Z: drive.
'
'

'Asks for Computername, Username & Password

Const INPUTBOX_MESSAGE_00 = "Please enter the computername you wish to connect to."
Const INPUTBOX_TITLE_01 = "Computername Required."

Computername = InputBox_String(INPUTBOX_MESSAGE_00, INPUTBOX_TITLE_01, INPUTBOX_TITLE_01)
If Computername = SYMBOL_BLANK Then
  WScript.Echo "Please input a value!"
  WScript.Quit
End If

Username = InputBox("Please enter the username your connecting into the remote computer with", "Username Needed")
If Username = "" Then
  WScript.Echo "Error No Value..."
End If	
Password = InputBox("Please enter your password to connect into the remote computer...", "Password needed..")

' Pings Server
Set objPing = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_PingStatus where address = '" & Computername & "'")
For Each objStatus in objPing
 If IsNull(objStatus.StatusCode) or objStatus.StatusCode <> 0 Then 
   WScript.Echo "The remote location cannot be reached."
  End if
Next

' Attempts connection on the server
		
On error resume Next
Err.Clear  
Set WshNetwork = WScript.CreateObject("WScript.Network")
RunKill = Wshshell.run("net use Z: /delete", True)
Wscript.Sleep 200
TryMapDrive = Err.Number = 0 
WshNetwork.MapNetworkDrive "Z:", "\\" & Computername & "\MessengerVer1.0$", True, Username, Password
If Err.Number <> 0 Then
  Wscript.echo "Error.. " & Err.Number & "  " & Err.Description
  Wshshell.run("net use Z: /delete")
  WScript.Quit
End if
On Error Goto 0


ENCRYPTIONID = InputBox("Please insert the encryption key (8 Digit Max) to access your area's of the file." & vbCrLf &_
"Please Note that if left blank, you will be redirected to the public board.." & vbCrLf _
, "Encryption ID Number Required.")
If ENCRYPTIONID = "" Then
	WScript.Echo "No ID number inputted... Rerouting to public encryption."
	ENCRYPTIONID = ""
	SndIDHex = 2
Else	
   If ENCRYPTIONID = "1" Or ENCRYPTIONID = "2" Then
   	 WScript.Echo "Error.. The Encryption Numbers 1 & 2 are specially reserved." & vbCrLf &_
   	 "You cannot use these two numbers to encrypt your conversation."
     Wshshell.run("net use Z: /delete")
     WScript.Quit   
   End if
	y = 0
	valLen = Len(ENCRYPTIONID)     ' length of the input
	If valLen > 8 Then
	   WScript.Echo "Error... You have inserted more then 8 charachters."
	   Wshshell.run("net use Z: /delete /y")
	   WScript.Quit
	End If
	For i = 1 to ValLen
	   ' Get each individual char (left to right) 
	   ValDec = Left(Mid(ENCRYPTIONID,i,1),i)
	   If Asc(ValDec) > 48 Then
	     If Asc(ValDec) > 57 Then
	       WScript.Echo "Error.. Invalid Encryption ID!" & vbCrLf & "Please insert numbers only."
	       Wshshell.run("net use Z: /delete /y")
	       WScript.Quit
	     End If
	   Else
	      WScript.Echo "Error.. Invalid Encryption ID!" & " Please insert numbers only."
	      Wshshell.run("net use Z: /delete /y")
	      WScript.Quit 
	   End if  
	   If y <> 4 Then
	     Ecypt = Int(ValDec + 20)
	     
	     SndID = SndID & Ecypt
	     StoreINMEM = SndID
	     SndID = ""
	     If Len(SndID) < 8 Then   ' Becuase the key is generated via the key. Sme time's it will exceed 8 chars.
	       For s = 1 To 8         ' Therefore, it will only take the first 8 chars for reading...
	          HexRead = Left(Mid(StoreINMEM,s,1),s) ' READ 1 CHR IN MEMORY
	          If SndID = "" Then
	            SndID = HexRead
	          Else  
	            SndID = SndID & HexRead
	          End if  
	       Next
	     End If
	   End If     
	Next     
	SndIDHex = Hex(SndID)


End if
' ERROR CHECK THE ID NUMBER AND ENSURE IT CAN BE CONVERTED TO HEX.


' =============================	
' Check server file integrty
' =============================

If Fso.FileExists(ReplyConfirm) Then
  Fso.DeleteFile(ReplyConfirm)
End If
If Fso.FileExists(CrossController) Then
  Fso.DeleteFile(CrossController)
End If

ServerInfo = "Z:\" & Computername & ".info"

If Not Fso.FileExists(ServerInfo) Then
  Wshshell.run("net use Z: /delete")
  WScript.Echo "Error... Cannot Locate Server File..."
  WScript.Quit
End If
	

Set ReadServerFile = fso.OpenTextFile(ServerInfo, ForReading)
Do While ReadServerFile.AtEndOfStream <> True
  For Counter = 1 To 4
	  ReadFile = ReadServerFile.ReadLine
	  If ReadServerFile.AtEndOfStream = True Then
	    If Counter <> 4 Then
	      WScript.Echo "An error has occured on the server. Cannot connect.."
	      ReadServerFile.Close
	      Wshshell.run("net use Z: /delete")
	      WScript.Quit
	    Else
	      ReadServerFile.Close
	      Exit Do
	    End If
	  End If
      If Counter = 1 Then
	     SafteySwapper = ReadFile
	  ElseIf Counter = 2 Then
	     Conversation = ReadFile
	  ElseIf Counter = 3 Then
	     TransferDataController = ReadFile      
	  End If  
   Next
Loop    


BindVaraible = Conversation
Call FileExistsTwo(UniqueVar)
BindVaraible = TransferDataController
Call FileExistsTwo(UniqueVar)

If Fso.FileExists(DisplayConfigFile) Then
   Fso.DeleteFile(DisplayConfigFile)
End if  

Set TransController = fso.CreateTextFile(CrossController, ForAppending, True)
TransController.WriteLine "~~~~"
TransController.Close

Set WriteForReader = fso.CreateTextFile(DisplayConfigFile, ForAppending, True)
WriteForReader.WriteLine TransferDataController
WriteForReader.Close


' =====================================================
' Activating Display & Confirm Handshake with Display
' =====================================================
WshShell.Run("%windir%\System32\Cscript.exe " & Chr(34) & scriptFullName & Chr(34) & " -display " & SndIDHex & " " & ENCRYPTIONID)
Reply = 0
For i = 0 To 200
  If Fso.FileExists(ReplyConfirm) Then
    Reply = 1
    Exit For
  End If
  WScript.Sleep 50
Next
If Reply = 0 Then
  
  WScript.Echo "ERROR! No Reply..."
  Wshshell.run("net use Z: /delete")
  WScript.Quit
  
End If



' =================================
' Messanger Input Engine
' =================================

MessengerName = InputBox("Please enter your chat name.." & vbCrLf &_
"Note: If the box is left blank, the name will be: " & Objnet.UserName , "Name required")
If MessengerName = "" Then
  MessengerName = objnet.UserName
End If

ExitCounter = 0
LagCounter = 0
Do Until X   ' THIS IS THE MESSENGER ENIGNE!
  Input = InputBox("Please enter the text you wish to send." & vbCrLf &_
  "Press cancel to terminate the session", "Text input required")              
  If Input = "" Then
     ExitCounter = 1
     Input = MessengerName & " has left the conversation at " & Time
  End If
  

  ' -------------------------------------
  '
  ' ENCRYPTS ENGINE.
  '
  '
  
  If Not ENCRYPTIONID = "" Then ' ID NUMBER INPUTTED. ENCRYPT LINE.
	 Total = ""  ' Set Everything back to nothing.
  	 ReadAdd = ""
     If fso.FileExists(scriptPath & LocalEncryption) Then  ' Clear's Temp files.
  	   fso.DeleteFile(scriptPath & LocalEncryption)
     End if	 
     Set DumpLocalData = fso.OpenTextFile(scriptPath & LocalEncryption, ForAppending, TristateTrue) ' Dump Message Data.
     DumpLocalData.WriteLine MessengerName & ": " & Input
     DumpLocalData.Writeline "EOF"
     DumpLocalData.Close
     
     ' ENCRYPT MESSAGE.
     '
     MainArray = 0
     x = 0
     EncryptDta = ""
     Break = 0
     Total = SndIDHex 
	 Set Encrypt = fso.OpenTextFile(scriptPath & LocalEncryption, ForReading) ' Open for reading.
     Num1 = CDbl(ENCRYPTIONID + 5) ' HALF IT ' ENCRYPTION ALGORYTHEMS
     Num2 = CDbl(Num1 + ENCRYPTIONID) 
     Num3 = CDbl((ENCRYPTIONID + 2) + Num1)
     Do While Encrypt.AtEndOfLine <> True
        ReadAdd = Asc(Encrypt.Read(1))   ' ENCRYPT LETTER.
		ConvertToInt = Int(ReadAdd)
		EncryptDta = Int((ConvertToInt + Num1) + Num2 - Num3)
     	ConvertToHex = Hex(EncryptDta)
     	Total = Total & ":" & ConvertToHex ' ADD TO TOTAL STRING.
     Loop
     Encrypt.Close	
     ConvertToNumeral = 0
     ConvertToHex = 0
  Else 
    SndIDHex = 2 ' WRITES PUBLIC AND ADD TO TOTAL STRING.
    Total = SndIDHex & ":" & MessengerName & ": " & Input
  End If
  
  '
  ' END OF ENGRYPTION ENGINE.
  ' ----------------------------------------

  
  For i = 0 To 500
	If Not fso.FileExists(SafteySwapper) Then
	  If fso.FileExists(Conversation) Then  ' NOTE: This makes sure the connection is still Alive
	    Set SW = fso.OpenTextFile(SafteySwapper, 8, True)     ' Opens the Saftey Swapper file. 
	    SW.Close                       
        Set WRITEDATA = fso.OpenTextFile(Conversation, 8, True)  ' Writes the user's input.
        WRITEDATA.WriteLine Total
        WRITEDATA.Close
        fso.DeleteFile(SafteySwapper)                            ' Deletes the Saftey Swapper
        Exit For
      Else
        Set CrossCon = fso.OpenTextFile(CrossController, 8, True, TristateTrue) ' Opens the Cross Controller
	    CrossCon.WriteLine "-"    ' Writes Infomation
        CrossCon.WriteLine "4"  
        CrossCon.Close
        WScript.Sleep 3000 ' Gives time for the display to disconnect!
        Wshshell.run("net use Z: /delete")   ' Disconnects!
        WScript.Quit
      End if  
	End If
	'
	'  This is the Lag Watcher. If it can't connect to the saftey swapper.
	'  Then this get's activated. It works by sending a signal to the display,
	'  warning of the error..
	'
	If i = 499 Then
	  If LagCounter = 3 Then
	    Set CrossCon = fso.OpenTextFile(CrossController, 8, True, TristateTrue)
	    CrossCon.WriteLine "-"
        CrossCon.WriteLine "2"
        CrossCon.Close
        WScript.Sleep 3000 ' Gives time for the display to disconnect!
        Wshshell.run("net use Z: /delete")
        WScript.Quit
	  Else
	  	Set CrossCon = fso.OpenTextFile(CrossController, 8, True, TristateTrue)
	  	CrossCon.WriteLine "-"
        CrossCon.WriteLine "3"
        CrossCon.Close
        LagCounter = LagCounter + 1
        i = 0
        WScript.Sleep 3000
	  End if
	End If
	WScript.Sleep 10
  Next	
  LagCounter = 0
  If ExitCounter = 1 Then  
    Set CrossCon = fso.OpenTextFile(CrossController, 8, True, TristateTrue)
    CrossCon.WriteLine "-"
    CrossCon.WriteLine "1"
    CrossCon.Close
    Exit Do
  End If 
  Lag = 0
loop    

WScript.Sleep 10000
Wshshell.run("net use Z: /delete")



Sub FileDelete()
    On Error Resume Next
	If Not fso.FileExists(BindVaraible) Then
	  If Err.Number <> 76 Then
	      WScript.Echo "Error cannot bind to the messenger service."
	      WScript.Echo "Please close any files that are conflicting..."
	      WScript.Echo "Please re-login & try again."
	      Wshshell.run("net use Z: /delete")
	      WScript.Quit 
	  End If
	End If
	BindVaraible = ""
	Err.Clear
	On Error Goto 0
End Sub


Sub ServerData()



CrossController = scriptPath & "\" & UniqueNumber & ".crssc"  ' This communicated between the Reader & tells that there is lag online.
KillFile = scriptPath & "\" & UniqueNumber & ".kill"   ' This file terminates the applactions.

End Sub


Sub ReadDataFromConversation()

	'
	'  Display side of the Script
	'

    Set WshShell = WScript.CreateObject("WScript.Shell") 
	Set objNet = WScript.CreateObject("WScript.Network")
	Set WshNetwork = WScript.CreateObject("WScript.Network")
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ReaderFso = CreateObject("Scripting.FileSystemObject")
	Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")   
	Const ForReading = 1, ForWriting = 2, ForAppending = 8
    Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
	scriptFullName = WScript.ScriptFullName
	scriptPath = Left(scriptFullName, InstrRev(scriptFullName, "\"))
	Drive = Left(scriptPath, InStrRev(scriptPath, ":")) & "\"
	   
    ' This section verify's all the data from the inputter and the server.
    
    WScript.Echo "(Display). Messenger.vbs Version 1.1 "
    WScript.Echo "Note Patched Version (Supports Encryption)"
    WScript.Echo "Written by Wogboy222"
    WScript.Echo "Copyright All Rights Reserved 2007." 
    WScript.Echo ""
    WScript.Echo ""
    
    WScript.Echo "Attempting to connect to messenger service..."
    WScript.Sleep 500
    DisplayConfigFile = scriptPath & "Display.Dat"   ' This holds the infomation for the display to connect to the service
    ReplyConfirm = scriptPath & "Reply.Dat"
    CancelSession = scriptPath & "Cancel.Cnc"
    CrossController = scriptPath & "CrossControl.crssc"
    
    UniqueVar = CrossController
    Call FileExists(UniqueVar)
    UniqueVar = DisplayConfigFile
    Call FileExists(UniqueVar)
    
    
    
    Set f = fso.OpenTextFile(DisplayConfigFile, ForReading, False, TristateTrue)
    fRead =  f.ReadLine
    f.Close
    WScript.Echo "Attempting to connect to:"
    WScript.Echo fRead & " : " & UniqueVar

    UniqueVar = fRead
    Call FileExists(UniqueVar)
       
	Set ReadServerFile = ReaderFso.OpenTextFile(fRead, ForReading)
	Do While ReadServerFile.AtEndOfStream <> True
	  For Counter = 1 To 4
		  ReadFile = ReadServerFile.ReadLine
		  If ReadServerFile.AtEndOfStream = True Then
		    If Counter <> 4 Then
		      WScript.Echo "An error has occured on the server. Cannot connect.."
		      ReadServerFile.Close
	          WScript.Sleep 2000
		      WScript.Quit
		    Else
		      ReadServerFile.Close
		      Exit Do
		    End If
		  End If
	      If Counter = 1 Then
		     SafteySwapper = ReadFile
		  ElseIf Counter = 2 Then
		     Conversation = ReadFile
		  ElseIf Counter = 3 Then
		     TransferDataController = ReadFile 
		  End If  
	   Next
	Loop  
	WScript.Echo "Verifying Files."
    UniqueVar = Conversation
    Call FileExists(UniqueVar)
    UniqueVar = TransferDataController
    Call FileExists(UniqueVar)

    Set Reply = fso.OpenTextFile(ReplyConfirm, ForAppending, True)
    Reply.Close
    
    ' Checks system is active...
       
    WScript.Echo "Connected to service..."
    WScript.Sleep 2000
    
    ' Displays the data in the chat file. Also gets the final line number. 

	Set DumpLineOfConversation = fso.OpenTextFile(Conversation, ForReading)
	Do While DumpLineOfConversation.AtEndOfStream <> True
	  Call Decrypt(DumpLineOfConversation.ReadLine)
	  'WScript.Echo DumpLineOfConversation.ReadLine
	  If DumpLineOfConversation.AtEndOfStream = True Then
	    Exit Do
	  Else
	    LineCounter = LineCounter + 1
	  End If 	  
	Loop
	DumpLineOfConversation.Close
	
	
	'===========================================================
    ' DISPLAY SERVCIE ENGINE
    '===========================================================
    '
    ' This service loops forever. It operates on a
    ' cross commumication file to know when the connection
    ' is having trouble and could be dropped. Just note
    ' The cross communication file still needs configuration becuase it
    ' can error, by inserting ASCII numbers rather then charachters.
    ' Just note that!
    ' 
  
    
    
    Set ReadConversation = fso.OpenTextFile(Conversation, ForReading, False) ' Opens the Conversation file.
    
    Do Until Forever   ' Enters the Infinte loop.

		On Error Resume Next
      '  Before reading the conversation, it opens up the Cross controller, to
      '  Check the connection status from the inputter.
      '
      '  Firstly it must read the bottom line to dertimne wether the connection is open.
	  h = 0
	  Set objFile = Fso.OpenTextFile(CrossController, ForReading, False, TristateTrue)
	  Do Until objFile.AtEndOfStream
	     Redim Preserve arrFileLines(h)
	     arrFileLines(h) = objFile.ReadLine
	     h = h + 1
	  Loop
	  objFile.Close
	  For l = Ubound(arrFileLines) to LBound(arrFileLines) Step -1  ' Reads bottom line.
	     If arrFileLines(l) = "1" Then   ' If 1, Service Disconnected.
	        ReadConversation.Close
	        WScript.Echo "Disconnected from service...."
            WScript.Sleep 2000
            If Fso.FileExists(CrossController) Then   ' Deletes cross controller.
               Fso.DeleteFile(CrossController)
            End If
            WScript.Quit
	     ElseIf arrFileLines(l) = "2" Then  ' If 2, Connection is suffering from heavy lag. Disconnecting.
	        ReadConversation.Close
	        WScript.Echo "Dropping the connection..."
	        WScript.Echo "Error 2... Dropped from a bad connection or heavy lag."
	        WScript.Echo "Please try again later.."
	        If Fso.FileExists(CrossController) Then
               Fso.DeleteFile(CrossController)
            End If
	        WScript.Sleep 10000
            WScript.Quit    
	     ElseIf arrFileLines(l) = "3" Then ' If 3, Conneciton is suffering from lag. Waiting for reconnection
	     	Set objFile = Fso.OpenTextFile(CrossController, ForAppending, True)
	        objFile.WriteLine "-"
	        objFile.Close
	        WScript.Echo "========================= WARNING ========================="
	        WScript.Echo "Your current connection is experiencing lag. Please wait..."
	        WScript.Echo "Attempting to reconnect in 3 seconds..."
	        WScript.Echo "==========================================================="
	        WScript.Sleep 3000
	     ElseIf arrFileLines(l) = "4" Then  ' If 4, Connection has been dropped.
	        ReadConversation.Close
	        WScript.Echo "Error 4... Connection Suddenly Dropped.. Closing Window..."
	        WScript.Echo "Please contact the administrator if this problem persists"
	        WScript.Echo "in the future.. Please try again later..."
	        If Fso.FileExists(CrossController) Then
               Fso.DeleteFile(CrossController)
            End If
            WScript.Sleep 10000
            WScript.Quit    
	     End If
	  Next
	  
  
	  If Not fso.FileExists(Conversation) Then   ' Before it opens the file, it's checks to make sure the host is alive..
	      WScript.Echo "Error 4... Connection Suddenly Dropped.. Closing Window..."
	      WScript.Echo "Please contact the administrator if this problem persists"
	      WScript.Echo "in the future.. Please try again later..."
	      ReadConversation.Close
	      If Fso.FileExists(CrossController) Then  ' Deletes cross controller.
             Fso.DeleteFile(CrossController)
          End If
          WScript.Sleep 10000
          WScript.Quit 
	  End if
	  
      Do While ReadConversation.AtEndOfStream <> True  ' This loop actually reads the infomation and displays it.
        WScript.Sleep 50
        LineRead = ReadConversation.ReadLine
        DumpCounter = DumpCounter + 1
        If DumpCounter > LineCounter Then
          Call Decrypt(LineRead)
          LineCounter = DumpCounter
        End If
        If ReadConversation.AtEndOfStream = True Then
          ReadConversation.Close
          DumpCounter = 0
          Set ReadConversation = fso.OpenTextFile(Conversation, ForReading, False)
          Exit Do
        End If  
      Loop
    loop  
    
    '========================================================
    '========================================================
    '========================================================

    WScript.Quit
End Sub

Sub Decrypt(LineRead)
  Commands = split(LineRead, ":", -1, 1)
  AddtoString = ""
  If Commands(0) = "1" Or Commands(0) = "2" Then
	WScript.Echo LineRead
  ElseIf Commands(0) = SndIDHex Then 
     Num1 = CDbl(ENCRYPTIONID + 5)
     Num2 = CDbl(Num1 + ENCRYPTIONID) 
     Num3 = CDbl((ENCRYPTIONID + 2) + Num1)
	  On Error Resume Next
	  z = 1
	  Do While Commands(z) <> True
	  	If Commands(z) = "" Then
	      Exit Do
	    End If
	    ReadHEXVALUE = HexToDec(Commands(z))
	    If BAD = 1 Then
	      Exit Do 
	    Else
	      DecVALUE = ReadHEXVALUE  	      
	      SUM = (DecVALUE - Num1) - Num2 + Num3
	      DecryptLetter = Int((DecVALUE - Num1) - Num2 + Num3)
	      If AddtoString = "" Then
	        AddtoString = Chr(DecryptLetter)
	      Else
	        AddtoString = AddtoString & Chr(DecryptLetter) 
	      End If
	      DecryptLetter = 0
	      DecVALUE = 0
	    End If
	    ReadHEXVALUE = 0
	    DecryptLetter = 0
	    z = z + 1
	  Loop  
	  On Error Goto 0
	  If BAD = 1 Then
	    WScript.Echo "Error.. Corrupted Line..."
	  Else
	    WScript.Echo AddtoString
	  End If	
  End if
End Sub

Sub FileExists(UniqueVar)
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not Fso.FileExists(UniqueVar) Then
       WScript.Echo "Critical Error... Cannot Locate the following file:"
       WScript.Echo UniqueVar
       WScript.Sleep 2000
       WScript.Quit
    End If
End Sub

Sub FileExistsTwo(UniqueVar)
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Fso.FileExists(UniqueVar) Then
       WScript.Echo "Critical Error... Cannot Locate the following file:"
       WScript.Echo UniqueVar
       WScript.Sleep 2000
       WScript.Quit
    End If
End Sub

Sub SetupServer()

	Set objNet = WScript.CreateObject("WScript.Network")
	Set fsoTwo = CreateObject("Scripting.FileSystemObject")

    ' 
    ' Disconnects the Share on the "Server" 
    '

	On Error Resume Next
	Set DelcolShares = objWMIService.ExecQuery("Select * from Win32_Share Where Name = 'MessengerVer1.0$'")
	For Each DelobjShare in DelcolShares
	  ErrRtrn = DelobjShare.Delete
	  If ErrRtrn <> 0 Then 
	     Err.Raise ErrRtrn
	     WScript.Echo "Error " & ErrRtrn & ".. " & Err.Description & VBCRLF & "Cannot Remove Share... " 
	     WScript.Quit
	   End If
	Next
	On Error Goto 0
     '
     ' Asks where is the location of the "Server" is:
     '
    
	Const WINDOW_HANDLE = 0
	Const NO_OPTIONS = 0
	Set objShell = CreateObject("Shell.Application")  
	On Error Resume next    
	Set objFolder = objShell.BrowseForFolder _
	(WINDOW_HANDLE, "Please select the folder where the server is stored:", NO_OPTIONS, "C:\Scripts")       
	If objFolder.Self = Null Then
	  WScript.Echo "Please select a folder!"
	  WScript.Quit
	End If
	On Error Goto 0
	Set objFolderItem = objFolder.Self   
	objPath = objFolderItem.Path

   '
   ' Removes files and folders.
   '	

	ReadServerFile = objPath & "\" & objnet.ComputerName & ".info"
	CaputuredFirstSecond = Second(NOW)
	If Fso.FileExists(ReadServerFile) Then
	  
		SafteySwapper = ""
		Conversation = ""
		TransferDataController = ""
		
		Set ReadServerFile = fso.OpenTextFile(ReadServerFile, ForReading)
		Do While ReadServerFile.AtEndOfStream <> True
		  For Counter = 1 To 4
			  ReadFile = ReadServerFile.ReadLine	  
			  FileLocation = Split(ReadFile, "\", -1, 1)
			  If ReadServerFile.AtEndOfStream = True Then
			    If Counter <> 4 Then
			      WScript.Echo "An error has occured. Please select the correct file."
			      ReadServerFile.Close
			      WScript.Quit
			    Else
			      ReadServerFile.Close
			      Exit Do
			    End If
			  End If
		      If Counter = 1 Then
			     SafteySwapper = FileLocation(1)
			  ElseIf Counter = 2 Then
			     Conversation = FileLocation(1)
			  ElseIf Counter = 3 Then
			     TransferDataController = FileLocation(1)
			  End If  
		   Next
		Loop  
	
		If fsoTwo.FileExists(objPath & "\" & SafteySwapper) Then
		   fsoTwo.DeleteFile(objPath & "\" & SafteySwapper)
		End If
		If fsoTwo.FileExists(objPath & "\" & Conversation) Then
		   fsoTwo.DeleteFile(objPath & "\" & Conversation)
		Else
		  WScript.Echo "Cannot Locate File...." & vbCrLf & Conversation
		End If
		If fsoTwo.FileExists(objPath & "\" & TransferDataController) Then
		   fsoTwo.DeleteFile(objPath & "\" & TransferDataController)
		Else
		  WScript.Echo "Cannot Locate File...." & vbCrLf & TransferDataController
		End if 
		If fso.FolderExists(objPath) Then
		   fso.DeleteFolder(objPath)
		End if   
		
		If fsoTwo.FolderExists(scriptPath & "MessengerVer1.0") Then
	      fsoTwo.DeleteFolder(scriptPath & "MessengerVer1.0")
	    End if  
	    
	Else
	  WScript.Echo "Cannot Locate File.... Creating New Server"  
	End If
	
	
	'
	' Generates New Key
	'
	
    UniqueCaculator = scriptPath & "\Unique.uni"                         
    UniqueNumber = CaputuredFirstSecond + Second(NOW) / Hour(NOW)
    Rounder = Round(UniqueNumber, 4)

   '
   ' Writes New Infomation
   '
    If Fso.FolderExists(scriptPath & "MessengerVer1.0") Then
      Fso.DeleteFolder(scriptPath & "MessengerVer1.0")      
    End if   
    Fso.CreateFolder(scriptPath & "MessengerVer1.0")
    
    SafteySwapper = scriptPath & "MessengerVer1.0\" & UniqueNumber & ".swp"            ' This is the file which controls the conversation. 
    Conversation = scriptPath & "MessengerVer1.0\" & UniqueNumber & ".con"             ' This file actually controlls the conversation.
    TransferDataController = scriptPath & "MessengerVer1.0\" & UniqueNumber & ".trans" ' This file holds all of the data, which is being sent. Between all of the parties.
    NewComputerFile = scriptPath & "MessengerVer1.0\" & objnet.ComputerName & ".info"  ' This is the prime connection file. Used when a computer connects.
    ServerLocation = scriptPath & "MessengerVer1.0\"

    Set WriteNewConversation = fso.CreateTextFile(Conversation, True)
    WriteNewConversation.WriteLine("1")
    WriteNewConversation.WriteLine("1:" & Conversation & " generated at " & Now & " by " & objnet.UserName)
    WriteNewConversation.WriteLine("1:--------------------------------------")
    WriteNewConversation.WriteLine("1:Written By Wogboy222")
    WriteNewConversation.WriteLine("1:Patched With Encryption...")
    WriteNewConversation.WriteLine("1:Copyright All Rights Reserved 2007")
    WriteNewConversation.WriteLine("1:--------------------------------------")
    WriteNewConversation.WriteLine("1")
    WriteNewConversation.WriteLine("1")
    WriteNewConversation.Close
    
    Set NewTransferDataController = fso.CreateTextFile(TransferDataController, True)
    NewTransferDataController.WriteLine("Z:\" & UniqueNumber & ".swp")
    NewTransferDataController.WriteLine("Z:\" & UniqueNumber & ".con")
    NewTransferDataController.WriteLine("Z:\" & UniqueNumber & ".trans")
    NewTransferDataController.WriteLine("~")
    NewTransferDataController.Close

    Set WriteComputerFile = fso.CreateTextFile(NewComputerFile, True)
    WriteComputerFile.WriteLine("Z:\" & UniqueNumber & ".swp")
    WriteComputerFile.WriteLine("Z:\" & UniqueNumber & ".con")
    WriteComputerFile.WriteLine("Z:\" & UniqueNumber & ".trans")
    WriteComputerFile.WriteLine("~")
    WriteComputerFile.Close
    
    ' Creates new share.
	On Error Resume Next
	Err.Clear	
    Set objNewShare = objWMIService.Get("Win32_Share")
    errReturn = objNewShare.Create(scriptPath & "MessengerVer1.0", "MessengerVer1.0$", 0, 25, "MessengerVer1.0 Share.")
    If errReturn <> 0 Then
      Err.Raise errReturn
      WScript.Echo "Error " & errReturn & ". " & Err.Description & vbCrLf & "Cannot Create the network share..."
      WScript.Quit
    End If
    WScript.Echo "Server Finished! Rerun this applaction & connect to: " & Objnet.ComputerName
    WScript.Quit 
End Sub

Function HexToDec (valHex)
  Dim valDec
  Dim BAD
  BAD = 0
  valLen = Len(valHex)     ' length of the input
  valLen2= len(valHex)     ' Second copy
  intPof = valLen          ' To the Power of (^)     
  Const conBase = 16
        ' Loop through each char in input string
     For i = 1 to ValLen    
      ' Get each individual char (left to right) 
      ValDec = Left(Mid(valHex,i,1),i)  
      ' Replace chars with the correct value
      If Instr(Ucase(valDec),"A") Then valDec = 10
      If Instr(Ucase(valDec),"B") Then valDec = 11
      If Instr(Ucase(valDec),"C") Then valDec = 12
      If Instr(Ucase(valDec),"D") Then valDec = 13
      If Instr(Ucase(valDec),"E") Then valDec = 14
      If Instr(Ucase(valDec),"F") Then valDec = 15
      ' Array of Valid HEX values
             isValid= "0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F"     
      If InStr(isValid,uCase(Left(valDec,1))) Then
           ' Good input 
             Else
              Wscript.Echo "Aborting, [" & uCase(valDec) & "] " _
              & "isn't a Valid HEX Value" & vbCRLF & vbCRLF _
              & "Valid Values are : " & isValid
              BAD = 1
             End if
            
      ' Depending on the input length
      ' calculate the required value.
      
      ' e.g 12345 is calculated as:
           ' 1*16^4 =65536
           ' 2*16^3 =8192
           ' 3*16^2 =768
           ' 4*16 =64
           ' 5 =5
           ' Total =74565

      If valLen2      >= 3 then
          rslt      = valDec * conBase ^ (intPof - i)
          valLen2      = valLen2 - 1
      ElseIf valLen2= 2 then
      rslt      = valDec * conBase
      valLen2      = valLen2 - 1
      ElseIf valLen2 = 1 Then
      rslt      = valDec
      End if
      ' Save the results & Add them together
      myRslt = myRslt + rslt
     Next
     HexToDec = myRslt
End Function

'====================================================================================================================
'
'	Sub BPWriteInfo(ByVal FileName, ByVal Data)
'
'   Use: Writes to the Log File. Places date and time for each line.
'
'==================================================================================================================== 
Private Sub BPWriteInfo(ByVal FileName, ByVal Data)
   
   Dim WritetoFileFSO
   Dim FileSystemObj
   Dim Description
   Dim WriteDateToFile
   Dim DateAndTime
   
   DateAndTime = Date() & SPACE_STRING & Time() & ":" & VBTAB
   
   On Error Resume Next
   Err.Clear
   
   
   Set WritetoFileFSO = CreateObject( "Scripting.FileSystemObject" )
      
   Err.Clear   
   Set WriteDataeToFile = WritetoFileFSO.OpenTextFile(FileName, ForAppending, TristateTrue)
   WriteDataeToFile.Writeline(DateAndTime & Data)
   WriteDataeToFile.Close
   
   If Err.Number <> 0 Then
      Display ERROR_MESSAGE03 & Err.Number & SPACE_STRING & Err.Description
   End If
   Err.Clear
   On Error Goto 0
   
   
   WritetoFileFSO = Empty
   FileSystemObj = vbEmpty
   Description = vbEmpty
   WriteDateToFile = vbEmpty
   
End Sub
'====================================================================================================================
'
' 	Function CheckCopyProtection()
' 
' 	Use: Program becomes obsolute when user expires or at certian date.
'
'====================================================================================================================
Private Function CheckCopyProtection()
 
	CheckCopyProtection = False
 
	Const ExpireyDay = 15
	Const ExpireyMonth = 06
	Const ExpireyYear = 2011
 
	If ExpireyDay <= Day(Now) And _
	   ExpireyMonth <= Month(Now) And _
	   ExpireyYear <= Year(Now) Then
 
		CheckCopyProtection = True
		Exit Function
	End if
 
End Function
'====================================================================================================================
'
' 	Function PromptUser(ByVal MsgboxMessage, _
'						ByVal MsgboxTitle, _
'						ByVal MsgboxButtonCode, _
'						ByVal MsgBoxResponseTrue)
' 
' 	Use: Display's a Message to the User.
'
'====================================================================================================================
Private Function PromptUser(ByVal MsgboxMessage, _
							ByVal MsgboxTitle, _
							ByVal MsgboxButtonCode, _
							ByVal MsgBoxResponseTrue)
	Dim DisplayedMessage
	DisplayedMessage = MsgBox(MsgboxMessage, MsgboxButtonCode, MsgboxTitle)
	If DisplayedMessage = MsgBoxResponseTrue Then
	   PromptUser = True
	Else
	   PromptUser = False
	End If
 
End Function
'====================================================================================================================
'
' 	Function TestPath(FolderPath)
' 
' 	Use: Test's directory path write.
'
'====================================================================================================================
Private Sub TestPath(FolderPath)
 
	Set fso2 = WScript.CreateObject(SYSTEM_OBJECT_FSO)
 
	On Error Resume Next	
	Err.Clear
 
	If Not Fso2.FolderExists(FolderPath) Then
	   Fso2.CreateFolder(FolderPath)
	   	If Err.Number <> 0 Then
	      Display ERROR_MESSAGE04
	      PAUSE_SCREEN
 	      WScript.Quit(Err.Number)
 	    End if
 
	End If
 
	On Error Resume Next	
	Err.Clear
 
	If fso2.FileExists(FolderPath & TEST_FILE) Then
	   fso2.DeleteFile(FolderPath & TEST_FILE)
 
	   	If Err.Number <> 0 Then
	      Display ERROR_MESSAGE04
	      PAUSE_SCREEN
 	      WScript.Quit(Err.Number)
 	    End if
 
	End If
 
	Err.Clear
 
	Set TestWrite = fso2.OpenTextFile(FolderPath & TEST_FILE, 8, True)
	TestWrite.WriteLine FolderPath
	If Err.Number <> 0 Then
	    Display ERROR_MESSAGE04
	    PAUSE_SCREEN
 	    WScript.Quit(Err.Number)
	End If
	TestWrite.Close
 
	fso2.DeleteFile(FolderPath & TEST_FILE)
	Err.Clear
	On Error Goto 0
 
 
End Sub
'====================================================================================================================
'
' 	Function PAUSE_SCREEN()
' 
' 	Use: Delay's Output for allocated time.
'
'====================================================================================================================
Private Sub PAUSE_SCREEN()
 
	WScript.Sleep(5000)
 
End Sub
'====================================================================================================================
'
' 	Function InputBox_String(MessageString, TitleString, DefaultUsername )
' 
' 	Use: Prompt User for Input.
'
'====================================================================================================================
Private Function InputBox_String(MessageString, TitleString, DefaultUsername )
 
  Dim TempVal
  Temp_Val = InputBox(MessageString, TitleString, DefaultUsername)
  InputBox_String = Temp_Val
 
End Function
'====================================================================================================================
'
' Determines which program is being used to run this script.
' Returns true if the script host is cscript.exe
'
'====================================================================================================================
function IsHostCscript()
 
    on error resume next
 
    dim strFullName
    dim strCommand
    dim i, j
    dim bReturn
 
    bReturn = false
 
    strFullName = WScript.FullName
 
    i = InStr(1, strFullName, ".exe", 1)
 
    if i <> 0 then
 
        j = InStrRev(strFullName, SYMBOL_BACKWARD_SLASH, i, 1)
 
        if j <> 0 then
 
            strCommand = Mid(strFullName, j+1, i-j-1)
 
            if LCase(strCommand) = "cscript" then
 
                bReturn = true
 
            end if
 
        end if
 
    end if
 
    if Err <> 0 then
 
        wscript.echo L_Text_Error_General01_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description
 
    end if
 
    IsHostCscript = bReturn
 
end Function
'====================================================================================================================
'
'	Sub Display(ByVal Data)
'
'   Use: Output an echo to the screen.
'
'====================================================================================================================
Public Sub Display(ByVal Data)
 
  WScript.Echo(DATA)
 
 
End Sub

Sub CloseApplaction()

End Sub


Public Sub ArgumentHandler()


	If WScript.Arguments.Count > 0 Then

		If WScript.Arguments.Item(0) = Argument_00 And WScript.Arguments.Item(0) <> Argument_BLANK Then
		
	 		If IsHostCscript <> True Then
	 		
	 		   CloseApplaction
	 		   
	 		End If
	   
	   		ReadDataFromConversation WScript.Arguments.Item(0), WScript.Arguments.Item(1)
	   		
	   	End If
	   		
	 End If

End Sub
