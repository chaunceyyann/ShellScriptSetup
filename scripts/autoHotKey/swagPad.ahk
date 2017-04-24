#InstallKeybdHook
#NoTrayIcon
#singleInstance force
SetTitleMatchMode 2
SendMode Input
LAlt & Left::SendInput {LCtrl down}{LWin down}{Right}{LCtrl up}{LWin up}
LAlt & Right::SendInput {LCtrl down}{LWin down}{Left}{LCtrl up}{LWin up}
