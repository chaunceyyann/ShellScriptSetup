; KeypressOSD.ahk
;----------------------------------------------------------
; ChangeLog : v2.06 (2016-11-23) - Added more keys. Thanks to SashaChernykh.
;             v2.05 (2016-10-01) - Fixed not detecting "Ctrl + ScrollLock/NumLock/Pause". Thanks to lexikos.
;             v2.04 (2016-10-01) - Added NumpadDot and AppsKey
;             v2.03 (2016-09-17) - Added displaying "Double-Click" of the left mouse button.
;             v2.02 (2016-09-16) - Added displaying mouse button, and 3 settings (ShowMouseButton, FontSize, GuiHeight)
;             v2.01 (2016-09-11) - Display non english keyboard layout characters when combine with modifer keys.
;             v2.00 (2016-09-01) - Removed the "Fade out" effect because of its buggy.
;                                - Added support for non english keyboard layout.
;                                - Added GuiPosition setting.
;             v1.00 (2013-10-11) - First release.
;----------------------------------------------------------

#SingleInstance force
#NoEnv
SetBatchLines, -1
ListLines, Off

; Settings
	global TransN          := 200      ; 0~255
	global ShowSingleKey   := True     ; True or False
	global ShowMouseButton := True     ; True or False
	global DisplayTime     := 2000     ; In milliseconds
	global GuiPosition     := "Bottom" ; Top or Bottom
	global FontSize        := 50
	global GuiHeight       := 115

CreateGUI()
CreateHotkey()
return

OnKeyPressed:
	try {
		key := GetKeyStr()
		ShowHotkey(key)
		SetTimer, HideGUI, % -1 * DisplayTime
	}
return

; ===================================================================================
CreateGUI() {
	global

	Gui, +AlwaysOnTop -Caption +Owner +LastFound +E0x20
	Gui, Margin, 0, 0
	Gui, Color, Black
	Gui, Font, cWhite s%FontSize% bold, Arial
	Gui, Add, Text, vHotkeyText Center y20

	WinSet, Transparent, %TransN%
}

CreateHotkey() {
	Loop, 95
		Hotkey, % "~*" Chr(A_Index + 31), OnKeyPressed

	Loop, 24 ; F1-F24
		Hotkey, % "~*F" A_Index, OnKeyPressed

	Loop, 10 ; Numpad0 - Numpad9
		Hotkey, % "~*Numpad" A_Index - 1, OnKeyPressed

	Otherkeys := "WheelDown|WheelUp|WheelLeft|WheelRight|XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|Tab|Enter|Esc|BackSpace"
	           . "|Del|Insert|Home|End|PgUp|PgDn|Up|Down|Left|Right|ScrollLock|CapsLock|NumLock|Pause|sc145|sc146|sc046|sc123"
	Loop, parse, Otherkeys, |
		Hotkey, % "~*" A_LoopField, OnKeyPressed

	If ShowMouseButton {
		Loop, Parse, % "LButton|MButton|RButton", |
			Hotkey, % "~*" A_LoopField, OnKeyPressed
	}
}

ShowHotkey(HotkeyStr) {
	WinGetPos, ActWin_X, ActWin_Y, ActWin_W, ActWin_H, A
	if !ActWin_W
		throw

	text_w := ActWin_W
	GuiControl,     , HotkeyText, %HotkeyStr%
	GuiControl, Move, HotkeyText, w%text_w% Center

	if (GuiPosition = "Top")
		gui_y := ActWin_Y
	else
		gui_y := (ActWin_Y+ActWin_H) - 115 - 50

	Gui, Show, NoActivate x%ActWin_X% y%gui_y% h%GuiHeight% w%text_w%
}

GetKeyStr() {
	static modifiers := ["Ctrl", "Shift", "Alt", "LWin", "RWin"]

	for i, mod in modifiers {
		if GetKeyState(mod)
			prefix .= mod " + "
	}

	if (!prefix && !ShowSingleKey)
		throw

	key := SubStr(A_ThisHotkey, 3)
	if (key = " ") {
		key := "Space"
	} else if ( StrLen(key) = 1 ) {
		key := GetKeyChar(key, "A")
	} else if ( SubStr(key, 1, 2) = "sc" ) {
		key := SpecialSC(key)
	} else if (key = "LButton") && IsDoubleClick() {
		key := "Double-Click"
	}

	return prefix . key
}

SpecialSC(sc) {
	static k := {sc046: "ScrollLock", sc145: "NumLock", sc146: "Pause", sc123: "Genius LuxeMate Scroll"}
	return k[sc]
}

; by Lexikos -- https://autohotkey.com/board/topic/110808-getkeyname-for-other-languages/#entry682236
GetKeyChar(Key, WinTitle:=0) {
	thread := WinTitle=0 ? 0
		: DllCall("GetWindowThreadProcessId", "ptr", WinExist(WinTitle), "ptr", 0)
	hkl := DllCall("GetKeyboardLayout", "uint", thread, "ptr")
	vk := GetKeyVK(Key), sc := GetKeySC(Key)
	VarSetCapacity(state, 256, 0)
	VarSetCapacity(char, 4, 0)
	n := DllCall("ToUnicodeEx", "uint", vk, "uint", sc
		, "ptr", &state, "ptr", &char, "int", 2, "uint", 0, "ptr", hkl)
	return StrGet(&char, n, "utf-16")
}

IsDoubleClick(MSec = 300) {
	Return (A_ThisHotKey = A_PriorHotKey) && (A_TimeSincePriorHotkey < MSec)
}

HideGUI() {
	Gui, Hide
}