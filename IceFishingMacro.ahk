#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
DllCall("winmm\timeBeginPeriod", "UInt", 1)

; =====================================================================
; ICE FISHING SIMULATOR - UNIVERSAL ULTRA-FAST MACRO (AHK v1.1)
; Works on ANY screen resolution (1920x1080, 2560x1440, 3440x1440, etc.)
; Press F1 to Start / Stop | Run as Administrator
; =====================================================================

CentruX := Floor(A_ScreenWidth / 2)
CentruY := Floor(A_ScreenHeight / 2)

; Auto-calculated vertical bar coordinates based on screen resolution
Bara_X1 := CentruX - Round(A_ScreenHeight * 0.53125)
Bara_X2 := CentruX - Round(A_ScreenHeight * 0.51736)
Sus_Y   := Round(A_ScreenHeight * 0.441)
Jos_Y   := Round(A_ScreenHeight * 0.868)

; Auto-calculated "Stop Fishing" button position (bottom center)
Stop_X  := CentruX
Stop_Y  := Round(A_ScreenHeight * 0.8465)

; Calibrated timings and colors (Stable Ultra-Fast profile)
CuloareGalben := 0xFFBF40
CuloareStop   := 0xB35757
MarjaCentru   := Max(3, Round(A_ScreenHeight * 0.0028))
PauzaTeleport := 230
TimpApasareE  := 120

activ := false
InMinigame := false
PrimaVedereBara := 0
UltimaVedereBara := 0
return

F1::
    activ := !activ
    InMinigame := false
    PrimaVedereBara := 0
    if (activ) {
        SetTimer, MinigamePescuit, 1
        ToolTip, Macro ULTRA-FAST: ON (F1 to Stop), 50, 50
    } else {
        SetTimer, MinigamePescuit, Off
        ToolTip
    }
return

MinigamePescuit:
    ; 1. Detect TOP edge of the yellow target zone
    PixelSearch, , MargineSusY, %Bara_X1%, %Sus_Y%, %Bara_X2%, %Jos_Y%, %CuloareGalben%, 40, Fast RGB
    if (ErrorLevel != 0) {
        ; Bar disappeared for 750ms -> Fish caught -> Cancel animation & recast
        if (InMinigame && (A_TickCount - UltimaVedereBara > 750)) {
            InMinigame := false
            PrimaVedereBara := 0
            Gosub, AnuleazaSiArunca
        } else if (!InMinigame && (A_TickCount - UltimaVedereBara > 100)) {
            PrimaVedereBara := 0
        }
        return
    }

    ; 2. Detect BOTTOM edge of the yellow target zone
    PixelSearch, , MargineJosY, %Bara_X1%, %Jos_Y%, %Bara_X2%, %MargineSusY%, %CuloareGalben%, 40, Fast RGB
    if (ErrorLevel != 0)
        return

    if (MargineJosY - MargineSusY < 5)
        return

    UltimaVedereBara := A_TickCount
    if (PrimaVedereBara = 0)
        PrimaVedereBara := A_TickCount

    if (!InMinigame && (A_TickCount - PrimaVedereBara >= 150)) {
        InMinigame := true
    }

    ; 3. Calculate exact center of the yellow zone (adapts to rare/tiny fish)
    MijlocY := Floor((MargineSusY + MargineJosY) / 2)
    Y_Sus := MijlocY - MarjaCentru
    Y_Jos := MijlocY + MarjaCentru

    ; 4. Detect white indicator line and click dead center
    PixelSearch, , LinY, %Bara_X1%, %Y_Sus%, %Bara_X2%, %Y_Jos%, 0xFFFFFF, 15, Fast RGB
    if (ErrorLevel = 0) {
        DllCall("Sleep", "UInt", 2)
        PixelSearch, , LinY2, %Bara_X1%, %Y_Sus%, %Bara_X2%, %Y_Jos%, 0xFFFFFF, 15, Fast RGB
        if (ErrorLevel = 0) {
            MouseMove, 1, 0, 0, R
            MouseMove, -1, 0, 0, R
            Click, Down
            DllCall("Sleep", "UInt", 20)
            Click, Up
            UltimaVedereBara := A_TickCount
            DllCall("Sleep", "UInt", PauzaTeleport)
        }
    }
return

AnuleazaSiArunca:
    ; 1. Verify red "Stop Fishing" button is visible and click it
    S_X1 := Stop_X - 5, S_Y1 := Stop_Y - 5
    S_X2 := Stop_X + 5, S_Y2 := Stop_Y + 5
    PixelSearch, , , %S_X1%, %S_Y1%, %S_X2%, %S_Y2%, %CuloareStop%, 35, Fast RGB
    if (ErrorLevel = 0) {
        MouseMove, %Stop_X%, %Stop_Y%, 0
        MouseMove, 1, 0, 0, R
        MouseMove, -1, 0, 0, R
        Click, Down
        DllCall("Sleep", "UInt", 30)
        Click, Up
    }

    ; 2. Move cursor back to screen center so it doesn't stay on Stop Fishing
    MouseMove, %CentruX%, %CentruY%, 0

    ; 3. Press E to cast rod immediately for the next fish
    DllCall("Sleep", "UInt", 200)
    Send, {e down}
    DllCall("Sleep", "UInt", TimpApasareE)
    Send, {e up}

    ; 4. Wait for bobber to land in water before scanning again
    DllCall("Sleep", "UInt", 1000)
    InMinigame := false
    PrimaVedereBara := 0
return
