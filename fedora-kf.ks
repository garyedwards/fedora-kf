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
irssi
nmap
rtorrent

# Office

# graphics
geeqie

# audio & video
alsa-plugins-pulseaudio
pavucontrol

# Terminal
rxvt-unicode
screen

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
eject
pm-utils

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

# set Xorg keyboard layout
cat >/etc/X11/xorg.conf << EOF
Section "InputClass"
    Identifier "Keyboard Defaults"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "gb"
EndSection
EOF

# Set window manager
echo 'exec ck-launch-session dwm-session' > /etc/skel/.xinitrc

# Set up dwm status bar and autostart apps
mkdir /etc/skel/.dwm
curl -s -o  /etc/skel/.dwm/dwmrc https://github.com/garyedwards/fedora-kf/raw/master/dwmrc

# startx X when logging into tty1
curl https://github.com/garyedwards/fedora-kf/raw/master/.bash_profile_autologin >>/etc/skel/.bash_profile

# set icon theme
curl -s -o /etc/skel/.gtkrc-2.0 https://github.com/garyedwards/fedora-kf/raw/master/.gtkrc-2.0

# Thunar config
mkdir -p /etc/skel/.config/Thunar/
curl -s -o /etc/skel/.config/Thunar/thunarrc https://github.com/garyedwards/fedora-kf/raw/master/thunarrc

# Set up xterm and xautolock
curl -s -o /etc/skel/.Xresources https://github.com/garyedwards/fedora-kf/raw/master/.Xresources

# Set up keyboard shortcuts
curl -s -o /etc/skel/.xbindkeysrc https://github.com/garyedwards/fedora-kf/raw/master/.xbindkeysrc

# Add nmgui script
curl -s -o /usr/local/bin/nmgui https://github.com/garyedwards/fedora-kf/raw/master/nmgui
chmod +x /usr/local/bin/nmgui

# dwm session script
curl -s -o /usr/local/bin/dwm-session https://github.com/garyedwards/fedora-kf/raw/master/dwm-session
chmod +x /usr/local/bin/dwm-session

# urxvtd startup script
curl -s -o /usr/local/bin/urxvtcd https://github.com/thayerwilliams/msi-scripts/raw/master/urxvtcd
chmod +x /usr/local/bin/urxvtcd

%end
