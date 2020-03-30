#include <Array.au3>
#include <WinAPIProc.au3>

Global $tag_SYSTEM_THREADS = "double KernelTime;" & _
        "double UserTime;" & _
        "double CreateTime;" & _
        "ulong  WaitTime;" & _
        "ptr    StartAddress;" & _
        "dword  UniqueProcess;" & _
        "dword  UniqueThread;" & _
        "long   Priority;" & _
        "long   BasePriority;" & _
        "ulong  ContextSwitchCount;" & _
        "long   State;" & _
        "long   WaitReason"

Global $tag_SYSTEM_PROCESSES = "ulong  NextEntryDelta;" & _
        "ulong  Threadcount;" & _
        "ulong[6];" & _              ; Reserved...
        "double CreateTime;" & _
        "double UserTime;" & _
        "double KernelTime;" & _
        "ushort Length;" & _                 ; unicode string length
        "ushort MaximumLength;" & _    ; also for unicode string
        "ptr    ProcessName;" & _                ; ptr to mentioned unicode string - name of process
        "long   BasePriority;" & _
        "ulong  ProcessId;" & _
        "ulong  InheritedFromProcessId;" & _
        "ulong  HandleCount;" & _
        "ulong[2];" & _              ;Reserved...
        "uint    PeakVirtualSize;" & _
        "uint    VirtualSize;" & _
        "ulong   PageFaultCount;" & _
        "uint    PeakWorkingSetSize;" & _
        "uint    WorkingSetSize;" & _
        "uint    QuotaPeakPagedPoolUsage;" & _
        "uint    QuotaPagedPoolUsage;" & _
        "uint    QuotaPeakNonPagedPoolUsage;" & _
        "uint    QuotaNonPagedPoolUsage;" & _
        "uint    PagefileUsage;" & _
        "uint    PeakPagefileUsage;" & _
        "uint64 ReadOperationCount;" & _
        "uint64 WriteOperationCount;" & _
        "uint64 OtherOperationCount;" & _
        "uint64 ReadTransferCount;" & _
        "uint64 WriteTransferCount;" & _
        "uint64 OtherTransferCount"

Func _WinAPI_GetHWNDFromPid($iPid)
    Local $aData = _WinAPI_EnumProcessWindows($iPid, 1)
    If @error Then Return SetError(1, 0, 0)
    Return $aData[1][0]
EndFunc

Func _WinAPI_GetProcessNameFromHWND($hWND, $bFullpath = False)
    Local $sResult = _WinAPI_GetWindowFileName($hWND)
    If @error Then Return SetError(1, 0, 0)
    If $bFullpath Then Return $sResult
    Return StringRegExpReplace($sResult, ".+\\(.+?)", "$1")
EndFunc

Func _WinAPI_EnumProcesses($sProcessName = "") ;http://www.autoitscript.com/forum/index.php?showtopic=88934
    Local $ret = DllCall("ntdll.dll", "int", "ZwQuerySystemInformation", "int", 5, "int*", 0, "int", 0, "int*", 0)
    Local $Mem = DllStructCreate("byte[" & $ret[4] & "]")
    Local $ret = DllCall("ntdll.dll", "int", "ZwQuerySystemInformation", "int", 5, "ptr", DllStructGetPtr($Mem), "int", DllStructGetSize($Mem), "int*", 0)
    Local $SysProc = DllStructCreate($tag_SYSTEM_PROCESSES, $ret[2])
    Local $SysProc_ptr = $ret[2]
    Local $SysProc_Size = DllStructGetSize($SysProc)
    Local $SysThread = DllStructCreate($tag_SYSTEM_THREADS)
    Local $SysThread_Size = DllStructGetSize($SysThread)
    Local $buffer, $i, $lastthread, $m = 0, $NextEntryDelta, $k, $temp, $space, $l
    Local $avArray[10000][2]
    While 1
        $buffer = DllStructCreate("char[" & DllStructGetData($SysProc, "Length") & "]", DllStructGetData($SysProc, "ProcessName"))
        For $i = 0 To DllStructGetData($SysProc, "Length") - 1 Step 2
            $avArray[$m][0] &= DllStructGetData($buffer, 1, $i + 1)
        Next
        $avArray[$m][1] = DllStructGetData($SysProc, "ProcessId")

        $NextEntryDelta = DllStructGetData($SysProc, "NextEntryDelta")
        If Not $NextEntryDelta Then ExitLoop
        $SysProc_ptr += $NextEntryDelta
        $SysProc = DllStructCreate($tag_SYSTEM_PROCESSES, $SysProc_ptr)
        If $sProcessName = "" Then
            $m += 1
        Else
            If $avArray[$m][0] = $sProcessName Then
                $m += 1
            Else
                $avArray[$m][0] = ""
            EndIf
        EndIf
    WEnd
    If $sProcessName <> "" Then $m -= 1
    ReDim $avArray[$m + 1][2]
    Return $avArray
EndFunc