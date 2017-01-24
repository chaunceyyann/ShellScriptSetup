#NoTrayIcon
;If the script stops working:
;Change the following values to reflect your current desktop state and reload the script.
;Remember to change them back to 1 after reloading the script if you have it set to start with Windows

desktopcount := 3
currentdesktop := 1

;You can change the hotkeys for creating, closing, and switching desktops bellow.
;The current hotkeys are CTRL+WIN+D for new desktop, CTRL+WIN+F4 to close desktop
;and WIN+NUMBER for switching desktops.
;For example, to change the hotkey for new desktop replace ^#D bellow with the desired hotkey.
;Refer to the autohotkey documentation for a full list of symbols refering to modifier keys,
;as you can see ^ is CTRL and # is WIN key.
;If you wanted to change the switch desktop from WIN key to CTRL for example you would have
;to replace the # before each number to a ^

^#D::NewDesktop()
^#F4::CloseDesktop()
#1::SwitchDesktop(1)
#2::SwitchDesktop(2)
#3::SwitchDesktop(3)
#4::SwitchDesktop(4)
#5::SwitchDesktop(5)
#6::SwitchDesktop(6)
#7::SwitchDesktop(7)
#8::SwitchDesktop(8)
#9::SwitchDesktop(9)
#0::SwitchDesktop(10)
#'::MsgBox Desktop Count = %desktopcount%`nCurrent Desktop = %currentdesktop%

;Do not change anything after this line, unless you know what you are doing ;)
;-----------------------------------------------------------------------------------------------
SwitchDesktop(desktop)
{

    global desktopcount
    global currentdesktop
    desktopdiff := desktop - currentdesktop
    if (desktop > desktopcount)
    {
        return
    }
    if (desktopdiff < 0)
    {
        desktopdiff *= -1
        Loop %desktopdiff%
        {
        Send ^#{Left}
        }   
    }
    else if (desktopdiff > 0)
    {
        Loop %desktopdiff%
        {
        Send ^#{Right}
        }
    }
    currentdesktop := desktop
}

NewDesktop()
{
    global desktopcount
    global currentdesktop
    if (desktopcount > 9)
    {
        return
    }
    desktopcount ++
    currentdesktop := desktopcount
    Send ^#d
}

CloseDesktop()
{
    global desktopcount
    global currentdesktop
    desktopcount --
    if (currentdesktop != 1)
    {
        currentdesktop --
    }
    Send ^#{f4}
}