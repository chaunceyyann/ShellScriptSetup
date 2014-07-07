# This is a project that simple setup the linux env cutomizely for user
# respect to the hardware is provided.
# 1. System report: parsing all avaliable usefull info from this hardware
# 	1. OS 2. Kernel 3. Shell/terminal type 4. coding env 5. hardware info
# 2. choose the customization level the user want.
# 3. Download the files from github then reboot if allowed.

#this script will parsing the info of the system and represent on the screen
# There will be another one for sync all my configure files.

# system report
type hostname >/dev/null 2>&1 || { echo >&2 "No hostname!"; exit 1; }
uname -a 
type uptime >/dev/null 2>&1 || { echo >&2 "No uptime!"; exit 1; }
echo $SHELL

