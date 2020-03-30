#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Iconsmind-Outline-Window-2.ico
#AutoIt3Wrapper_Outfile_x64=WinMove.Exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=2.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>
#include <GDIPlus.au3>
#include <WinAPIShellEx.au3>
#include <winHelp.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <Array.au3>
#include <Display_library_functions.au3>

;Read settings from ini file
$rescale=IniRead(@ScriptDir&"/src/settings.ini", "gui", "scale", 6)
$primaryOffsetX=IniRead(@ScriptDir&"/src/settings.ini", "desktop", "primaryOffsetX", 0)
$primaryOffsetY=IniRead(@ScriptDir&"/src/settings.ini", "desktop", "primaryOffsetY", 0)

$ignoreSeparator = IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "separator", ";")
$ignoreString = IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "ignoreTitles", "")
$ignoreNoClass = IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "ignorenoclass", "1")
$ignoreInvisible = IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "ignoreinvisible", "1")

$customSnapX=IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "customSnapX", 0)
$customSnapY=IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "customSnapY", 0)
$snapAllOffset=IniRead(@ScriptDir&"/src/settings.ini", "behaviour", "snapAllOffset", 0)

$ignoreList = StringSplit($ignoreString,$ignoreSeparator)

Dim $ignoreTitles[$ignoreList[0]]

For $i = 1 to $ignoreList[0]
	$ignoreTitles[$i-1]=$ignoreList[$i]
Next

;Initialize window
$totalDesktop = _GetTotalScreenResolution()
dim $primaryDesktop[2]

$primaryDesktop[0] = @DesktopWidth
$primaryDesktop[1] = @DesktopHeight

#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form
$Form1 = GUICreate("Window Mover", $totalDesktop[0]/$rescale, $totalDesktop[1]/$rescale+100, -1, -1, $WS_EX_TOPMOST)
GUISetBkColor("0xFBEBC8")
#EndRegion ### END Koda GUI section ###

$screens = _DisplayKeySettings(_NumberAndNameMonitors())

For $i = 1 to $screens[0][0]
	GUICtrlCreatePic(@ScriptDir&"/src/background.bmp", 0, $totalDesktop[1]/$rescale, $totalDesktop[0]/$rescale, 70, $WS_DISABLED)
	GUISetState(@SW_SHOW)
	if(BitAND($screens[$i][0],$DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) or BitAND($screens[$i][0],$DISPLAY_DEVICE_PRIMARY_DEVICE)) then
		GUICtrlCreatePic(@ScriptDir&"/src/screen.bmp", ($screens[$i][2]+$primaryOffsetX)/$rescale, ($screens[$i][3]+$primaryOffsetY)/$rescale, $screens[$i][4]/$rescale, $screens[$i][5]/$rescale, $WS_DISABLED)
		GUISetState(@SW_SHOW)
	endif
Next
$Button_Close = GUICtrlCreateButton("Exit", 10, $totalDesktop[1]/$rescale+10, 200, 50)
GUISetState(@SW_SHOW)

; Retrieve a list of window handles.
$aList = WinList()

Dim $winButtons[$aList[0][0]]

Dim $contextButtons[$aList[0][0]][4]

For $i = 0 to $aList[0][0]-1
	For $j = 0 to 3
		$contextButtons[$i][$j]=-12
	Next
Next

; Loop through the array displaying only visable windows with a title.
For $i = 1 To $aList[0][0]
	If $aList[$i][0] <> "" And (BitAND(WinGetState($aList[$i][1]), 2) or $ignoreInvisible=0) And (WinGetClassList($aList[$i][1])<>"" or $ignoreNoClass=0) And _ArraySearch($ignoreTitles,$aList[$i][0])=-1 Then
		$pos = WinGetPos($aList[$i][0])
		$file = _WinAPI_GetProcessNameFromHWND($aList[$i][1], True)
		ExtractIcon($file, @ScriptDir&"/tempicons/"&$i&".bmp")

		;If window is maximized, location is not saved correctly
		if(BitAND(WinGetState($aList[$i][0]),$WIN_STATE_MAXIMIZED)) then
			$winButtons[$i]=GUICtrlCreateButton($aList[$i][0], (0+$primaryOffsetX)/$rescale, (0+$primaryOffsetY)/$rescale, 50, 50, $BS_BITMAP)
		else
			$winButtons[$i]=GUICtrlCreateButton($aList[$i][0], ($pos[0]+$primaryOffsetX)/$rescale, ($pos[1]+$primaryOffsetY)/$rescale, $pos[2]/$rescale, $pos[3]/$rescale, $BS_BITMAP)
		EndIf
		GUICtrlSetImage($winButtons[$i], @ScriptDir&"/tempicons/"&$i&".bmp")
		$contextButtons[$i][0] = GUICtrlCreateContextMenu($winButtons[$i])
		$contextButtons[$i][1] = GUICtrlCreateMenuItem("Close window", $contextButtons[$i][0])
		$contextButtons[$i][2] = GUICtrlCreateMenuItem("Snap to origin", $contextButtons[$i][0])
		$contextButtons[$i][3] = GUICtrlCreateMenuItem("Snap to custom", $contextButtons[$i][0])
	EndIf
Next
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			FileDelete(@ScriptDir&"/tempicons")
			DirCreate(@ScriptDir&"/tempicons")
			Exit
		Case $GUI_EVENT_PRIMARYDOWN
            ; If the mouse button is pressed - get info about where
            $cInfo = GUIGetCursorInfo($Form1)
            ; Is it over a control
            $iControl = $cInfo[4]
            ; Work out offset of mouse on control
			$aPos = ControlGetPos($Form1, "", $iControl)
			$iSubtractX = $cInfo[0] - $aPos[0]
			$iSubtractY = $cInfo[1] - $aPos[1]
			; And then move the control until the mouse button is released
			$text = ControlGetText($Form1, "", $iControl)
			$winToMove = WinGetHandle($text)
			if(BitAND(WinGetState($text),$WIN_STATE_MAXIMIZED)) then WinSetState($text, "", @SW_RESTORE)
			$pos = WinGetPos($text)
			if not @error then
				ControlMove($Form1, "", $iControl, $cInfo[0] - $iSubtractX, $cInfo[1] - $iSubtractY, $pos[2]/$rescale, $pos[3]/$rescale)
			EndIf
			Do
				$cInfo = GUIGetCursorInfo($Form1)
				$aPos = ControlGetPos($Form1, "", $iControl)
				ControlMove($Form1, "", $iControl, $cInfo[0] - $iSubtractX, $cInfo[1] - $iSubtractY)
				WinMove($winToMove, "", $aPos[0]*$rescale-$primaryOffsetX, $aPos[1]*$rescale-$primaryOffsetY)
			Until Not $cInfo[2]
		#cs
		Case $Button_SnapAll
			Dim $pos[2]
			$pos[0]=1
			$pos[1]=0
			For $i = 1 To $aList[0][0]
				WinMove($aList[$i][1], "", $pos[0],$pos[1])
				WinActivate($aList[$i][1])
				$pos[0]+=$snapAllOffset
				$pos[1]+=$snapAllOffset
		Next
		#ce
		Case $Button_Close
			Exit
	EndSwitch
	For $i = 1 To $aList[0][0]-1
		;Close window
		if($nMsg=$contextButtons[$i][1]) Then
			WinKill($aList[$i][1])
			;Refreshes windows
			$aList[$i][0]=""
			GUICtrlDelete($winButtons[$i])
		EndIf
		;Snap window
		if($nMsg=$contextButtons[$i][2]) Then
			WinMove($aList[$i][1], "", 0,0)
		EndIf
		;Snap custom
		if($nMsg=$contextButtons[$i][3]) Then
			WinMove($aList[$i][1], "", $customSnapX,$customSnapY)
		EndIf
	Next
WEnd

Func _GetTotalScreenResolution()
	Local $aRet[2]
	Global Const $SM_VIRTUALWIDTH = 78
	Global Const $SM_VIRTUALHEIGHT = 79
	$VirtualDesktopWidth = DllCall("user32.dll", "int", "GetSystemMetrics", "int", $SM_VIRTUALWIDTH)
	$aRet[0] = $VirtualDesktopWidth[0]
	$VirtualDesktopHeight = DllCall("user32.dll", "int", "GetSystemMetrics", "int", $SM_VIRTUALHEIGHT)
	$aRet[1] = $VirtualDesktopHeight[0]
	Return $aRet
EndFunc


;ExtractIcon(@systemdir & "\notepad.exe", @ScriptDir & "\notepad.png")

Func ExtractIcon($file, $output)
    $hIcon = _WinAPI_ShellExtractIcon($file, 0, 32, 32)
    _GDIPlus_Startup()
    $pBitmap = _GDIPlus_BitmapCreateFromHICON($hIcon)
    _GDIPlus_ImageSaveToFileEx($pBitmap, $output, _GDIPlus_EncodersGetCLSID("bmp"))
    _GDIPlus_ImageDispose($pBitmap)
    _GDIPlus_Shutdown()
    _WinAPI_DestroyIcon($hIcon)
EndFunc