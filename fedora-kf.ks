# fedora-kf
lang C
keyboard uk
timezone Europe/Jersey
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
bootloader --timeout=3 --append="acpi=force selinux=0"
#network --bootproto=dhcp --device=eth0 --onboot=on
services --enabled=NetworkManager,messagebus,rsyslog --disabled=crond,ip6tables,netfs,avahi-demon

# Partition set up
#clearpart --all
part / --size 4100 --fstype ext4 --ondisk sda
part swap --recommended

#
# Repositories
#
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch
repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch

#repo --name=rpmfusion-free --baseurl=http://download1.rpmfusion.org/free/fedora/releases/14/Everything/i386/os
#repo --name=rpmfusion-free-updates --baseurl=http://download1.rpmfusion.org/free/fedora/updates/14/i386
#repo --name=rpmfusion-non-free  --baseurl=http://download1.rpmfusion.org/nonfree/fedora/releases/14/Everything/i386/os
#repo --name=rpmfusion-non-free-updates --baseurl=http://download1.rpmfusion.org/nonfree/fedora/updates/14/i386

#repo --name=livna --baseurl=ftp://mirrors.tummy.com/pub/rpm.livna.org/repo/14/i386

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

# NetworkManager
dbus
NetworkManager
gnome-keyring
NetworkManager-gnome

# Install lxpolkit
-polkit-gnome
-polkit-kde
lxpolkit

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

## Remove the authconfig pieces
#-authconfig
#-rhpl
#-wireless-tools

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

# Remove sendmail
-sendmail

# use yum instead of gnome-packagekit
-gnome-packagekit
-kpackagekit

# make sure xfce4-notifyd is not pulled in
#notification-daemon
-xfce4-notifyd

# dictionaries are big
-aspell-*
-hunspell-*
-man-pages-*
-words

# save some space
-nss_db
-acpid
-kernel-PAE

# drop some system-config things
-system-config-boot
-system-config-language
-system-config-lvm
-system-config-network
-system-config-rootpassword
-system-config-services
-policycoreutils-gui
-gnome-disk-utility

#
# Desktop Packages
#

# Install Xorg

# Install basic X
xorg-x11-server-Xorg
xorg-x11-xinit
#xorg-x11-drivers

# Install only required drivers
xorg-x11-drv-evdev
xorg-x11-drv-keyboard
xorg-x11-drv-mouse

# Laptop
#xorg-x11-drv-intel
#xorg-x11-drv-synaptics

# Virtual box
xorg-x11-drv-vesa

# Install Window Manager
dwm
dmenu

# Internet
surf
firefox

# Office

# graphics
geeqie

# audio & video
alsa-plugins-pulseaudio
pavucontrol

# utils
unclutter
slock
stalonetray
lftp
conky
xorg-x11-utils
feh
xautolock
xbindkeys
perl-File-MimeInfo
scrot
xcalc
thunar
gmrun
nano

# themes
gnome-themes

# Repos
#rpmfusion-free-release
#rpmfusion-nonfree-release
#livna-release

%end

%post

# Disable Graphical boot
sed -i 's/rhgb//' /boot/grub/grub.conf
sed -i 's/quiet//' /boot/grub/grub.conf

# set Xorg keyboard
cat >>/etc/X11/xorg.conf << EOF
Section "InputClass"
    Identifier "Keyboard Defaults"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "gb"
EndSection
EOF

cat >>/usr/local/bin/dwm-session << EOF
#!/bin/sh
#DIR=${HOME}/.dwm
#if [ -f "${DIR}"/dwmrc ]; then
#        /bin/sh "${DIR}"/dwmrc &
#else
if [ -f ~/.dwm/dwmrc ]; then
        /bin/sh ~/.dwm/dwmrc &
        while true; do
                xsetroot -name "`date`"
                sleep 1
        done &
fi
exec /usr/bin/dwm
EOF

chmod +x /usr/local/bin/dwm-session

echo 'exec ck-launch-session /usr/local/bin/dwm-session' > /etc/skel/.xinitrc

##.dwm/dwmrc
mkdir /etc/skel/.dwm
cat >>/etc/skel/.dwm/dwmrc << EOF
#!/bin/sh

while true; do
        xsetroot -name "`date`"
        sleep 1
done &

xrdb -merge ~/.Xresources
xset r rate 250 60

xsetroot -solid darkgrey
#feh --bg-center ~/bg.jpg

xbindkeys
pulseaudio -D
#dispwin -I ~/.color/bluish.icc
#emacs --daemon

#exec thunar --daemon &
exec unclutter &
exec xautolock -detectsleep &
exec /usr/libexec/lxpolkit &

#exec (sleep 4s && ~/bin/nmgui) &
EOF

# startx X when logging into tty1
# Problem using DISPLAY variable need to look into
cat >>/etc/skel/.bash_profile << EOF
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
  #exec startx
  # Could use xinit instead of startx
  exec xinit -- /usr/bin/X -nolisten tcp vt7
fi
EOF

# set icon theme
cat >>/etc/skel/.gtkrc-2.0 << EOF
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
include "~/.gtkrc-2.0.mine"
EOF

# Set up xterm and xautolock
cat >>/etc/skel/.Xresources << EOF
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
EOF

# Set up keyboard shortcuts
cat >>/etc/skel/.xbindkeysrc << EOF
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
EOF

# Add nmgui script
cat >>/etc/skel/bin/nmgui<< EOF
#!/bin/sh
nm-applet --sm-disable > /dev/null 2>/dev/null &
stalonetray -geometry 1x1+35-530 > /dev/null 2>/dev/null
killall nm-applet
EOF

chmod +x /etc/skel/bin/nmgui

%end