#InstallKeybdHook
#NoTrayIcon
#singleInstance force
SetTitleMatchMode 2
SendMode Input
<^<!<+Tab::
        SendInput {LCtrl down}{LWin down}{Right}{LCtrl up}{LWin up}
return
<^<!Tab::
        SendInput {LCtrl down}{LWin down}{Left}{LCtrl up}{LWin up}
return
