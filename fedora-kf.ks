# Kickstart file to build the appliance operating
# system for fedora.
# This is based on the work at http://www.thincrust.net
lang C
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --permissive
firewall --disabled
bootloader --timeout=1 --append="acpi=force"
network --bootproto=dhcp --device=eth0 --onboot=on
services --enabled=network

# Uncomment the next line
# to make the root password be thincrust
# By default the root password is emptied
#rootpw --iscrypted $1$uw6MV$m6VtUWPed4SqgoW6fKfTZ/

#
# Partition Information. Change this as necessary
# This information is used by appliance-tools but
# not by the livecd tools.
#
part / --size 1024 --fstype ext4 --ondisk sda

#
# Repositories
#
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch
repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch

#
# Add all the packages after the base packages
#
%packages --excludedocs --nobase
bash
kernel
grub
e2fsprogs
passwd
policycoreutils
chkconfig
rootfiles
yum
vim-minimal
acpid
#needed to disable selinux
lokkit

#Allow for dhcp access
dhclient
iputils

#
# Packages to Remove
#

# no need for kudzu if the hardware doesn't change
-kudzu
-prelink
-setserial
-ed

# Remove the authconfig pieces
-authconfig
-rhpl
-wireless-tools

# Remove the kbd bits
-kbd
-usermode

# these are all kind of overkill but get pulled in by mkinitrd ordering
-mkinitrd
-kpartx
-dmraid
-mdadm
-lvm2
-tar

# selinux toolchain of policycoreutils, libsemanage, ustr
-policycoreutils
-checkpolicy
-selinux-policy*
-libselinux-python
-libselinux

# Things it would be nice to loose
-fedora-logos
generic-logos
-fedora-release-notes
%end

#
# Add custom post scripts after the base post.
#
%post

%end

##.xinitrc
exec ck-launch-session /usr/local/bin/dwm-session

##.dwm/dwmrc
#!/bin/sh

while true; do
        xsetroot -name "`date`"
        sleep 1
done &

xrdb -merge ~/.Xresources
xset r rate 250 60

xsetroot -solid darkgrey
#feh --bg-center ${HOME}/bg.jpg

xbindkeys
pulseaudio -D
#dispwin -I $HOME/.color/bluish.icc
#emacs --daemon

exec thunar --daemon &
exec unclutter &
exec xautolock -detectsleep &
exec /usr/libexec/lxpolkit &

#exec (sleep 4s && ~/bin/nmgui) &

##/usr/local/bin/dwm-session
#!/bin/sh
DIR=${HOME}/.dwm
if [ -f "${DIR}"/dwmrc ]; then
        /bin/sh "${DIR}"/dwmrc &
else
        while true; do
                xsetroot -name "`date`"
                sleep 1
        done &
fi
exec /usr/bin/dwm

##.gtkrc-2.0
gtk-theme-name="Mist"
gtk-icon-theme-name="gnome"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="dmz-aa"
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
include "/home/gary/.gtkrc-2.0.mine"

##.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
  #exec startx
  # Could use xinit instead of startx
  exec xinit -- /usr/bin/X -nolisten tcp vt7
fi

##.Xresources
xterm*bellIsUrgent:     true
xterm*saveLines:        10000
xterm*scrollBar:        false
xterm*scrollTtyOutput:  false
xterm*jumpScroll:       true
xterm*fastScroll:       true
xterm*multiScroll:      true
xterm*cutNewline:       true
xterm*highlightSelection: true
xterm*trimSelection:    true
! match selection for URLs and emails on mouse-click
xterm*charClass: 33:48,37-38:48,45-47:48,64:48,58:48,126:48,61:48,63:48,43:48,35:38

! xautolock screen locker
xautolock.time: 5
xautolock.corners: 000+
xautolock.cornerdelay: 3
xautolock.locker: slock

###########################
# xbindkeys configuration #
###########################

# To specify a key, you can use 'xbindkeys --key' or
# 'xbindkeys --multikey' and put one of the two lines in this file.
#
# The format of a command line is:
#    "command to start"
#       associated key
#
# A list of keys is in /usr/include/X11/keysym.h and in
# /usr/include/X11/keysymdef.h
# The XK_ is not needed.
#
# List of modifier:
#   Release, Control, Shift, Mod1 (Alt), Mod2 (NumLock),
#   Mod3 (CapsLock), Mod4, Mod5 (Scroll).
#
#   Mod4 is the Windows meta key

"xbindkeys_show" 
  Control+Shift + q

# app launcher
"gmrun"
  Mod4+Shift + p

## screen session
##"gnome-terminal -e "bash -c 'screen -dRR -S $HOSTNAME'""
#"urxvtcd -e bash -c 'screen -dRR -S $HOSTNAME'"
#  Mod4 + s

# file manager
"thunar"
  Mod4 + e

# NetworkManager ui
"nmgui"
  Mod4 + n

# calculator
"xcalc"
  Mod4 + c

# web browser
"firefox"
  Mod4 + w

# web browser (private mode)
"surf "$( echo https://www.duckduckgo.com | dmenu )""
  Mod4+Shift + w

# pavucontrol
"pavucontrol"
  Mod4 + v

# screenshot
"scrot %Y%m%d-%H.%M.%S.png -t 280x175 -e 'mv $f $m ~/'"
  Print

# screenshot (delayed 5s)
"scrot %Y%m%d-%H.%M.%S.png -t 280x175 -d 5 -e 'mv $f $m ~/'"
  Shift + Print

# volume up
#"changevol --increase 6"
#  XF86AudioRaiseVolume

# volume down
#"changevol --decrease 6"
#  XF86AudioLowerVolume

# volume mute
#"changevol --toggle"
#  XF86AudioMute

# kill a client window
"xkill"
  Control+Shift+Mod1 + k

# lock screen
"slock"
  Control+Mod1 + l

# reboot
"sudo shutdown -r now"
  Control+Mod1 + Delete

# shutdown
"sudo shutdown -h now"
  Control+Mod1 + Insert
