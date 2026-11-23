#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
DllCall("winmm\timeBeginPeriod", "UInt", 1)

; ==========================================
; 1. COORDONATE "STOP FISHING" SI TIMPI RAPIZI
; ==========================================
Stop_X := 1720
Stop_Y := 1219
CuloareStop := 0xB35757
TimpApasareE := 100

; ==========================================
; 2. MOTORUL EXACT CARE A MERS PERFECT (NEATINS)
; ==========================================
Sus_Y := 635
Jos_Y := 1250
MarjaCentru := 4
PauzaTeleport := 230
; ==========================================

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
        ToolTip, Macro RAPID + PERFECT: PORNIT, 50, 50
    } else {
        SetTimer, MinigamePescuit, Off
        ToolTip
    }
return

MinigamePescuit:
    ; 1. Cauta marginea de SUS a zonei galbene
    PixelSearch, , MargineSusY, 955, %Sus_Y%, 975, %Jos_Y%, 0xFFBF40, 40, Fast RGB
    if (ErrorLevel != 0) {
        ; Bara a disparut continuu 420ms -> AM PRINS PESTELE!
        if (InMinigame && (A_TickCount - UltimaVedereBara > 420)) {
            InMinigame := false
            PrimaVedereBara := 0
            Gosub, AnuleazaSiArunca
        } else if (!InMinigame && (A_TickCount - UltimaVedereBara > 100)) {
            PrimaVedereBara := 0
        }
        return
    }

    ; 2. Cauta marginea de JOS a zonei galbene
    PixelSearch, , MargineJosY, 955, %Jos_Y%, 975, %MargineSusY%, 0xFFBF40, 40, Fast RGB
    if (ErrorLevel != 0)
        return

    if (MargineJosY - MargineSusY < 6)
        return

    UltimaVedereBara := A_TickCount
    if (PrimaVedereBara = 0)
        PrimaVedereBara := A_TickCount

    if (!InMinigame && (A_TickCount - PrimaVedereBara >= 130)) {
        InMinigame := true
    }

    ; 3. Calculeaza centrul exact al zonei galbene
    MijlocY := Floor((MargineSusY + MargineJosY) / 2)
    Y_Sus := MijlocY - MarjaCentru
    Y_Jos := MijlocY + MarjaCentru

    ; 4. Cauta liniuta ALBA si da click fix pe mijloc (exact ca in varianta perfecta)
    PixelSearch, , LinY, 955, %Y_Sus%, 975, %Y_Jos%, 0xFFFFFF, 15, Fast RGB
    if (ErrorLevel = 0) {
        DllCall("Sleep", "UInt", 2)
        PixelSearch, , LinY2, 955, %Y_Sus%, 975, %Y_Jos%, 0xFFFFFF, 15, Fast RGB
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
    ; 1. Verifica butonul rosu Stop Fishing si apasa
    PixelSearch, , , 1715, 1214, 1725, 1224, %CuloareStop%, 35, Fast RGB
    if (ErrorLevel = 0) {
        MouseMove, %Stop_X%, %Stop_Y%, 0
        MouseMove, 1, 0, 0, R
        MouseMove, -1, 0, 0, R
        Click, Down
        DllCall("Sleep", "UInt", 25)
        Click, Up
    }

    ; 2. Muta cursorul la centru ca sa nu blocheze click-urile
    MouseMove, 1720, 700, 0

    ; 3. Apasa E rapid (130ms dupa Stop Fishing)
    DllCall("Sleep", "UInt", 130)
    Send, {e down}
    DllCall("Sleep", "UInt", TimpApasareE)
    Send, {e up}

    ; 4. Pauza scurta (300ms) si reia imediat
    DllCall("Sleep", "UInt", 300)
    InMinigame := false
    PrimaVedereBara := 0
return
