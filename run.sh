#!/usr/bin/env bash

#################################################################
# --------------- SCRIPT INIT
  # PS4='$LINENO: '
  # set -x
  RUNCMD=`realpath $0`
  RUNDIR=`dirname $RUNCMD`
  cd "$RUNDIR"
  LOGDIR="$RUNDIR/temp"
  RUNTIME=`jdate +%Y%m%d%H%M%S 2> /dev/null || date +%Y%m%d%H%M%S`
  LOGFILE="$LOGDIR/$RUNTIME.log"
  ERRFILE="$LOGDIR/$RUNTIME.err"
  mkdir -p "$LOGDIR"
  touch "$LOGFILE"
#  exec > >(tee -a "$LOGFILE") 2>&1

# --------------- SCRIPT VARS
  AGREE=N
  THEUSER="darren"
  DISABLESELINUX=1
  EXTRA=0
  GUI=1
  MMEDIA=1
  DESKENV=0
#################################################################
#---------------- General Functions
define_bash_color(){
    #
        emojis='
        ╔ ═ ╗ ║╚ ╝ ╦ ╩ ╠ ╣ ╬
        ✅ ❌ ⤫ ⚠️ 💡 💻 ❗️❓ Ⓜ️ 🏁 ❉ ❈ ❊ ❄ ❁
        ⦀
        💬 💭 🗯 🔔 🔕 ➜ 
        ➡️ ⬅️ ⬆️ ⬇️ ↘️ ↖️
        🔴 🟠 🟡 🟢 🔵 🟣 ⚫️ ⚪️ 🟤
        🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚 🕛 🕜 🕝 🕞 🕟 🕠 🕡 🕢 🕣 🕤 🕥 🕦 🕧
        📌👍🚜💾❗ab🔥🐳🔗🔎🌟👍🚜🔥🌐
        '
    # Normal
        export CLEAR='\033[0m'       # Text Reset
      # Regular Colors
        export Black='\033[0;30m'        # Black
        export Red='\033[0;31m'          # Red
        export Green='\033[0;32m'        # Green
        export Yellow='\033[0;33m'       # Yellow
        export Blue='\033[0;34m'         # Blue
        export Purple='\033[0;35m'       # Purple
        export Cyan='\033[0;36m'         # Cyan
        export White='\033[0;37m'        # White
      # Bold
        export BBlack='\033[1;30m'       # Black
        export BRed='\033[1;31m'         # Red
        export BGreen='\033[1;32m'       # Green
        export BYellow='\033[1;33m'      # Yellow
        export BBlue='\033[1;34m'        # Blue
        export BPurple='\033[1;35m'      # Purple
        export BCyan='\033[1;36m'        # Cyan
        export BWhite='\033[1;37m'       # White
    # Underline
        # \e[4m       make underline
        # \e[0m     remove underline
        export TUN="$(tput smul)"
        export TUND="$(tput rmul)"

    # Blinks
        export Blink="\e[5m"
        export BlinkDis="\e[25m"

    # Using tput
    export BOLD="$(tput bold)"
    export NORMAL="$(tput sgr0)"
    export BG_BLACK="$(tput    setab 0)"
    export BG_RED="$(tput      setab 1)"
    export BG_GREEN="$(tput    setab 2)"
    export BG_YELLOW="$(tput   setab 3)"
    export BG_BLUE="$(tput     setab 4)"
    export BG_MAGENTA="$(tput  setab 5)"
    export BG_CYAN="$(tput     setab 6)"
    export BG_WHITE="$(tput    setab 7)"

    export FG_BLACK="$(tput    setaf 0)"
    export FG_RED="$(tput      setaf 1)"
    export FG_GREEN="$(tput    setaf 2)"
    export FG_YELLOW="$(tput   setaf 3)"
    export FG_BLUE="$(tput     setaf 4)"
    export FG_MAGENTA="$(tput  setaf 5)"
    export FG_CYAN="$(tput     setaf 6)"
    export FG_WHITE="$(tput    setaf 7)"
    
}
timeprint(){
     echo -n " --- `jdate +%Y/%m/%d-%H:%M:%S 2> /dev/null || date +%Y/%m/%d-%H:%M:%S` --- "
}
info(){
    echo -e "`timeprint` : $@"
}
err(){
    echo -e "`timeprint` : $@"
}
log(){
    echo -e "`timeprint` : $@"
}
set_tui(){
  export MY_TUI1="$(tput setaf 7 setab 21 el ed bold)"
  export MY_TUI2="$(tput setaf 4 setab 21 el ed )"
  echo -e "${MY_TUI1}"
  clear
}
end(){
  tput sgr0 el ed
  echo -ne "${CLEAR}${NORMAL}"
  tput el ed
  exit $1
}
root_run(){
  if [ "$EUID" -ne 0 ]; then
  echo -e "Please run this script as root or using sudo.\n"
  end 1
  exit 1
  fi
}
wait_count(){
    for i in `seq -w $1 -1 0` ; do
        echo -ne " $i\r "
        read -N1 -s -t 0.9 TEMP
    done
}
get_term_size(){
    TERMLINES="$(tput lines)"
    TERMCOLNS="$(tput cols)"
    if [ "$TERMCOLNS" -lt "110" ] || [ "$TERMLINES" -lt "22" ] ; then
        clear
        echo -e "\n\n$BG_RED$FG_WHITE Warning: Terminal size [$TERMCOLNS x $TERMLINES] is not optimum for this script !"
        wain_count 5
        clear
    fi
}
mecho(){
    for i in `seq 1 1 "$1"`; do
        echo -en "$2"
    done
    echo
}
line_pr(){
    mecho `tput cols` "═"
}
#################################################################
#--------------- DEFINE SCRIPT FUNCTIONS
check_fedora(){
    OS=`cat /etc/os-release 2> /dev/null ;hostnamectl 2> /dev/null`
    if [ `echo "$OS" | grep -ic fedora` -lt 1 ]; then
        err "This script is written to be used for Fedora Linux distribution only."
        end 1
    fi
    HASDNF4=`which dnf 2> /dev/null | grep -ic dnf`
    HASDNF5=`which dnf5 2> /dev/null | grep -ic dnf5`
    let "FEDORAAAA=HASDNF4+HASDNF5"
    if [ "$FEDORAAAA" -lt "1" ] ; then
        err "This script is written to be used for a Fedora Linux distribution only."
        err "no dnf found."
        end 1
    fi 
}
define_repo_base(){
    enabled_repos=`dnf repolist --enabled`

    # setting up rpmfusion-free repo
    if [ "`echo "$enabled_repos" | grep -ic rpmfusion-free`" -lt "2" ] ; then
        dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    fi
    # setting up rpmfusion-nonfree repo
    if [ "`echo "$enabled_repos" | grep -ic rpmfusion-nonfree`" -lt "1" ] ; then
        dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi
}
define_repo_gui(){
    dnf install fedora-workstation-repositories -y
    dnf config-manager setopt google-chrome.enabled=1

    # setting up vscodium
    #rpmkeys --import "https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg"
    FILE="/etc/yum.repos.d/vscodium.repo"

    echo '[gitlab.com_paulcarroty_vscodium_repo] ' > $FILE
    echo 'name=download.vscodium.com ' >> $FILE
    echo 'baseurl=https://download.vscodium.com/rpms/ ' >> $FILE
    echo 'enabled=1 '  >> $FILE
    echo 'gpgcheck=1 ' >> $FILE
    echo 'repo_gpgcheck=0 ' >> $FILE
    echo 'gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg ' >> $FILE
    echo 'metadata_expire=1h ' >> $FILE
}
set_proxy(){
    COUNTRY=`curl -s ifconfig.io/country_code`
    if [ "$COUNTRY" == "IR" ] ; then
        echo -e '\nproxy=http://ir.linuxmirrors.ir:8080\n' >> /etc/dnf/dnf.conf
        mkdir -p /etc/systemd/system/docker.service.d
        FILE=/etc/systemd/system/docker.service.d/00-proxy.conf
        echo '[Service] ' > $FILE
        echo 'Environment="HTTP_PROXY=http://ir.linuxmirrors.ir:8080" ' >> $FILE
        echo 'Environment="HTTPS_PROXY=http://ir.linuxmirrors.ir:8080" ' >> $FILE
        echo 'Environment="NO_PROXY=localhost,127.0.0.1,registry.lab.loval,.corp" ' >> $FILE
    fi
}
base_config(){

    sed 's/^# %wheel/%wheel/' -i /etc/sudoers
    
    if [ "$DISABLESELINUX" -eq "1" ] ; then
        sed -i -e "s/^SELINUX=.*/SELINUX=disabled/" /etc/selinux/config ; setenforce 0
    fi

    BASHCONFIG_RAW='
    
        export SYSTEMD_PAGER=
        export HISTCONTROL=ignoreboth
        export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "
        export VISUAL=/usr/bin/vi
        export EDITOR="$VISUAL"
        export VAGRANT_DEFAULT_PROVIDER=libvirt
        shopt -s histappend

        PS1="\[\e[0;1m\]\u\[\e[0m\]@\[\e[0;1;38;5;160m\]\H\[\e[0m\][\[\e[0;1m\]\W\[\e[0m\]]\[\e[0m\]:\[\e[0m\](\[\e[0;1m\]$?\[\e[0m\])\[\e[0m\]\$ \[\e[0m\]"
        PS1="\[\e[38;5;160;1m\]\w\[\e[0m\] ➜ $ "
        export PS1="\[$(tput setaf 33)\]\u\[$(tput setaf 69)\]@\[$(tput setaf 105)\]\h \[$(tput setaf 141)\]\w \[$(tput sgr0)\] ➜ $ "

        # -------------------------- ALIASES
        # alias wget="wget --report-speed=bits " cause of the wget2 bug shows wrong speed
        alias mydnf="dnf update --best --allowerasing -y --refresh "
        alias mylogs1="journalctl --since \"10 min ago\""
        alias mylogs2="journalctl --since \"1 hour ago\""
        alias dig="dig +short "
        alias ll="ls -l --color=auto"
        alias lll="ls -ltrh --color=auto"
        alias llll="ls -ltrha --color=auto"
        alias lsblk="lsblk -f "
        alias date_dir="date +%Y_%m_%d_%H_%M_%S "
        alias jdate_dir="jdate +%Y_%m_%d_%H_%M_%S "
        alias grep="grep --color=never "
        alias pwgen="pwgen -sBnv1 40 | tee -a ~/PASSWORDS"
        alias tcpdump_file="tcpdump -nnnnvvvvvvv -s 65535 -w dump`date +%Y_%m_%d_%H_%M_%S`.pacp"
        alias s="sudo su "
        alias ping="ping -i 0.2 -W 0.2 -O -U "
        alias aria2c="aria2c --file-allocation=none "
        alias ipadd="ip -brief address"
        alias ww="~/.scripts/set.bg.pic.sh &> /dev/null"
        alias ssh_raw="ssh -o PubkeyAuthentication=no " 
        alias ssh-copy-id_raw="ssh-copy-id -o PubkeyAuthentication=no "
        alias k="kubectl "


        # -------------------------- FUNCTIONS
        function pic_reduce_30(){
        magick -limit memory 1 -limit map 1 -compress jpeg -quality 30  $1 -resize 1024 reduced.$1
        }
        
        function pic_reduce_50(){
        magick -limit memory 1 -limit map 1 -compress jpeg -quality 30  $1 -resize 1024 reduced.$1
        }
        
        dockerproxy(){
        echo "
        [Service]
        Environment="HTTP_PROXY=http://ir.linuxmirrors.ir:8080"
        Environment="HTTPS_PROXY=http://ir.linuxmirrors.ir:8080"
        Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
        " > /etc/systemd/system/docker.service.d/00-proxy.conf
        systemctl daemon-reload
        systemctl restart docker;
        }
        
        dockerproxy_disable(){
        echo '' > /etc/systemd/system/docker.service.d/00-proxy.conf
        systemctl daemon-reload
        systemctl restart docker;
        }
        
        rm -rf ~/.cache/mozilla/ ~/.mozilla/
        rm -rf ~/.cache/thumbnails/*
        
        
    '
    BASHCONFIG=`echo "$BASHCONFIG_RAW" | sed "s/^[[:space:]]*//g"`

    mkdir -p /root/.bashrc.d/
    echo "$BASHCONFIG" | sed "s/^[[:space:]]*//g" > /root/.bashrc.d/mybash

    if [ "$GUI" == "1" ] ; then
        mkdir -p /home/$THEUSER/.bashrc.d/
        echo "$BASHCONFIG" | sed "s/^[[:space:]]*//g" > /home/$THEUSER/.bashrc.d/mybash
    fi

    ### DNS CONFIG
    DNFCONF_RAW='[main]
    gpgcheck=1
    installonly_limit=3
    clean_requirements_on_remove=True
    best=True
    skip_if_unavailable=True
    ip_resolve=4
    fastestmirror=true
    max_parallel_downloads=20
    deltarpm=1
    keepcache=True
    timeout=20
    retries=20
    '
    DNFCONF=`echo "$DNFCONF_RAW" | sed "s/^[[:space:]]*//g"`
    echo "$DNFCONF" > /etc/dnf/dnf.conf

    ### SSH CONFIG
    SSH_SAMPLE_RAW='
        # -----TEMPLATE----
        Host host1 !host2
        ProxyJump host1
        LocalCommand echo -e "\n\n\x1b[30;31m------WARNING: You are on a PRODUCTIVE system! \x1b0------\n\n"
        PermitLocalCommand yes
        User root
        LocalForward 3306 127.0.0.1:33061
        StrictHostKeyChecking no
        IdentityFile ~/.ssh/mykey
        HostKeyAlgorithms +ssh-rsa,ssh-dss
        PubkeyAcceptedKeyTypes +ssh-rsa,ssh-dss
        KexAlgorithms +curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        Ciphers +aes256-cbc,aes128-cbc,3des-cbc
        HostbasedKeyTypes +ssh-rsa,ssh-dss
        IdentitiesOnly yes
        PubkeyAuthentication no
        PasswordAuthentication yes
        ControlMaster auto
        ControlPersist 10s
        '
    SSH_SAMPLE=`echo "$SSH_SAMPLE_RAW" | sed "s/^[[:space:]]*//g"`
    mkdir -p /root/.ssh/
    echo "$SSH_SAMPLE" > /root/.ssh/ssh.sample.config

    # NetworkManager connectivity
    NMCONNECT_RAW='[connectivity]
        enabled=true
        uri=http://nmcheck.gnome.org/check_network_status.txt
        interval=30
        response=NetworkManager'
    NMCONNECT=`echo "$NMCONNECT_RAW" | sed "s/^[[:space:]]*//g"`

    GROMITCFG_RAW='
        HOTKEY = "F9";
        UNDOKEY = "F8";

        # Tool definitions.
        "red Pen" = PEN ( size=15 color="red");
        "blue Pen" = "red Pen" (color="blue");
        "yellow Pen" = "red Pen" (color="yellow");
        "green Marker" = PEN (size=6 color="green" arrowsize=1);
        "Eraser" = ERASER (size = 75);
        "green Line" = LINE (color="green");
        "red Rectangle" = RECT (color="red");
        "red Smoothed" = SMOOTH (color="red" simplify=10 snap=30);
        "red Orthogonal" = ORTHOGONAL (color="red" size=5 simplify=15 radius=20 minlen=50 snap=40);

        # Tool mappings to input devices. Not all tools are mapped in this config.
        "default" = "red Pen";
        "default"[SHIFT] = "blue Pen";
        "default"[CONTROL] = "yellow Pen";
        "default"[ALT] = "yellow Pen";
        "default"[Button2] = "Eraser";
        "default"[Button3] = "blue Pen";
    '

    GROMITCFG=`echo "$GROMITCFG_RAW" | sed "s/^[[:space:]]*//g"`

    if [ "$GUI" == "1" ] ; then
        echo 'Sample Text' > /home/$THEUSER/Templates/new_text.txt
        echo '#!/usr/bin/env bash' > /home/$THEUSER/Templates/new_bash_script.sh
        echo '#!/usr/bin/env python3' > /home/$THEUSER/Templates/new_python_script.py

        chmod +x /home/$THEUSER/Templates/new_python_script.py /home/$THEUSER/Templates/new_bash_script.sh
        chown "$THEUSER:$THEUSER" -R /home/$THEUSER/

        # config ssh client sample
        mkdir -p "/home/$THEUSER/.ssh/"
        echo "$SSH_SAMPLE" > "/home/$THEUSER/.ssh/ssh.sample.config"

        # configure network manager 
        mkdir -p /etc/NetworkManager/conf.d/
        echo "$NMCONNECT" > /etc/NetworkManager/conf.d/20-connectivity.conf

        # config gromit
        echo "$GROMITCFG" > /home/$THEUSER/.config/gromit-mpx.cfg

    fi

}
pre_install(){
    GIT=`which git 2> /dev/null | grep -ic git`
    SCREEN=`which screen 2> /dev/null | grep -ic screen`
    DELTARPM=`rpm -ql deltarpm | grep -c bin.applydeltarpm`
    let "CHECK1=GIT+SCREEN+DELTARPM"
    if [ "$CHECK1" -lt "3" ] ; then
        dnf install -y deltarpm git screen
    fi
}
update_hw(){
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update -y
}
update_sw(){
    dnf clean all
    # dnf distro-sync -y
    dnf update --best --allowerasing -y --refresh
    pip install --upgrade pip
}
dnf_pkg_func(){
    dnf install -y --best --skip-unavailable --skip-broken --allowerasing $@
}
dnf_grp_func(){
    dnf group install --with-optional -y --skip-unavailable --skip-broken --best --allowerasing $@
}
define_packages(){
    SRV_BASE[0]="aria2 bc bash-color-prompt bash-completion bind-utils bwm-ng chrony cronie cryptsetup curl fdupes firewalld ftp GeoIP git htop hping3 iftop iotop iputils"
    SRV_BASE[1]="jcal jdupes jq lshw lsof mtr mmv netstat-nat net-tools NetworkManager NetworkManager-tui ngrep nload nmap nmap-ncat openssl p7zip p7zip-plugins pip plocate"
    SRV_BASE[2]="policycoreutils-python-utils procps procps-ng psmisc pwgen python3-devel python3-pip qemu-img qrencode setroubleshoot-server screen sshfs sshuttle sysstat" 
    SRV_BASE[3]="tcpdump telnet tmux traceroute unar unrar unzip util-linux vim wget whois wireguard-tools wireshark-cli"
    SRV_BASE_GRP[0]="core standard"
    ADMIN_TOOLS[0]="mysql mycli"
    DOCKER[0]="moby-engine sen podman podman-compose podman-tui"
    DOCKER[1]="buildah skopeo toolbox cri-tools lxc lxc-templates colin openscap-containers"
    SYSADMIN_GRP[0]="container-management mysql"
    KUBER[0]="kubernetes-client helm "
    GUI_BASE[0]="nautilus file-roller-nautilus gnome-terminal-nautilus tilix-nautilus chromium codium dconf dconf-editor engrampa evince fedora-workstation-repositories filezilla firefox geany gedit google-chrome-stable gparted ghostscript"
    GUI_BASE[1]="gnome-extensions-app gnome-shell-extension-appindicator gnome-shell-extension-apps-menu gnome-shell-extension-dash-to-dock gnome-shell-extension-dash-to-panel gnome-shell-extension-just-perfection "
    GUI_BASE[2]="gnome-terminal gnome-tweaks tilix mate-terminal tigervnc tor torbrowser-launcher qbittorrent octave "
    GUI_BASE[3]="minder leafpad nomacs openvpn putty remmina remmina-plugins-rdp telegram-desktop virt-manager virt-manager-common obs-studio "
    GUI_BASE[4]="NetworkManager-config-connectivity-fedora NetworkManager-fortisslvpn NetworkManager-fortisslvpn-gnome "
    GUI_BASE[5]="NetworkManager-l2tp NetworkManager-l2tp-gnome NetworkManager-openconnect NetworkManager-openconnect-gnome NetworkManager-openvpn NetworkManager-openvpn-gnome"
    GUI_BASE[6]="NetworkManager-ovs NetworkManager-ppp NetworkManager-pptp NetworkManager-pptp-gnome NetworkManager-ssh NetworkManager-ssh-gnome NetworkManager-sstp"
    GUI_BASE[7]="NetworkManager-sstp-gnome NetworkManager-tui NetworkManager-wifi NetworkManager-wwan network-manager-applet nm-connection-editor"
    GUI_BASE[8]="wine wine-common wine-mono winetricks wireshark xed xfce4-taskmanager xfce4-terminal xreader youtube-dl cloud-init libheif-freeworld"
    GUI_BASE[9]="adwaita-icon-theme la-capitaine-icon-theme paper-icon-theme luv-icon-theme We10X-icon-theme flatseal clutter "
    GUI_BASE[10]="overpass-fonts overpass-mono-fonts vazirmatn-fonts vazirmatn-vf-fonts liberation-fonts liberation-fonts-common "
    GUI_BASE[11]="rust cargo openssl-devel video-downloader gimp-2 gromit-mpx kdenlive thunderbird gh "
    GUI_BASE[12]="fastfetch persepolis remmina-plugins-* terminator xbacklight xournal"

    GUI_GRP_BASE[0]="vlc libreoffice multimedia vlc sound-and-video "
    # NetworkManager-dispatcher-routing-rules pdfmod kasts
    DESKTOPS_LIGHT[0]="xfce-apps xfce-desktop xfce-extra-plugins xfce-media xfce-office"
    DESKTOPS_LIGHT[1]="mate-desktop mate-applications compiz"
    DESKTOPS_LIGHT[2]="gnome-desktop"
    DESKTOPS_LIGHT[3]="cosmic-desktop cosmic-desktop-apps"
    DESKTOPS_LIGHT[4]="cinnamon-desktop"
    DESKTOPS_LIGHT[5]="budgie-desktop budgie-desktop-apps"
    MMEDIA_BASE[0]="ffmpeg HandBrake-gui soundconverter cozy celluloid libglvnd-glx libglvnd-opengl audacious audacious-plugins-freeworld* "
    MMEDIA_BASE[1]="vlc vlc-plugin-crystalhd vlc-plugins-base vlc-plugin-ffmpeg vlc-plugin-pipewire libavcodec-freeworld "
    MMEDIA_EXCLUDES=" --exclude=gstreamer1-plugins-bad-free-devel --exclude=lame-devel "
    MMEDIA_IGNORE="pulseaudio pavucontrol pulseaudio pulseaudio-utils vlc-plugin-pulseaudio "
    MMEDIA_OLD="pipewire pipewire-alsa pipewire-pulseaudio pipewire-gstreamer pipewire-libs pipewire-utils "
    VIRT_BASE="distrobox virt-manager libvirt-client virt-install bridge-utils"
    VIRT_GRP="virtualization vagrant "
    NVIDIA[0]="kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig "

    REMOVE[0]="dnfdragora mint-y-theme mint-y-icons mint-x-icons"

    # -- EXTRA
    SRV_EXTRA[0]="acpid axel chkrootkit clang cmake conntrack-tools dialog dkms dnsperf dnstop figlet fzf gcc golang info inxi iperf iptraf-ng kernel-devel kernel-headers"
    SRV_EXTRA[1]="lftp lolcat lynx macchanger make mc nethogs ntpcheck ntpsec rkhunter toilet vim-ansible vim-enhanced vnstat whatmask xml2 yamllint zsh"
    GUI_EXTRA[0]="akmod-nvidia apostrophe blackbox-terminal brightnessctl dos2unix drawing feh i3 i3lock i3status icecat "
    GUI_EXTRA[2]="papirus-icon-theme papirus-icon-theme-dark papirus-icon-theme-light numix-icon-theme numix-icon-theme-circle numix-icon-theme-square"
    GUI_EXTRA[3]="xscreensaver xscreensaver-extras"
    GUI_GRP_EXTRA[0]="mate-applications budgie-desktop budgie-desktop-apps cosmic-desktop cosmic-desktop-apps editors python-classroom system-tools sound-and-video window-managers"
    DESKTOPS_LIGHT_EXTRA[0]="i3 i3-extended window-managers swaywm swaywm-extended enlightenment-desktop " 
    DESKTOPS_LIGHT_EXTRA[1]="kde-apps kde-desktop kde-education kde-media kde-mobile kde-mobile-apps kde-office kde-pim kde-software-development kde-spin-initial-setup kf6-software-development"
    DESKTOPS_LIGHT_EXTRA[2]="lxde-apps lxde-desktop lxde-media lxde-office lxqt-apps lxqt-desktop lxqt-l10n lxqt-media lxqt-office"
    MMEDIA_EXTRA[0]="intel-media-driver libva-nvidia-driver gstreamer1-plugin-openh264 gstreamer1-libav gstreamer1-plugins* lame*"
    MMEDIA_EXTRA[1]="simplescreenrecorder easytag openshot mplayer sound-juicer rhythmbox gaupol " 
}

# install_packages_base(){
        # install srv base packages
#        dnf_pkg_func "${SRV_BASE[@]}"
#        dnf_grp_func "${SRV_BASE_GRP[@]}"
        # install srv extra packages
#        if [ "$EXTRA" -eq "1" ]; then
#            dnf_pkg_func "${SRV_EXTRA[@]}"
#        fi
# }

# install_packages_gui(){
#        if [ "$GUI" -eq "1" ] ; then
            # install gui base packages
#            dnf_pkg_func "${GUI_BASE[@]}"
#            dnf_grp_func "${GUI_GRP_BASE[@]}"
            # install lightweight desktop environment
#            if [ "$DESKENV" -eq "1" ]; then
#                dnf_grp_func "${DESKTOPS_LIGHT[@]}"
#            fi
            # INSTALL gui extra packages
#            if [ "$EXTRA" -eq "1" ]; then
#                dnf_pkg_func "${GUI_EXTRA[@]}"
#                dnf_grp_func "${GUI_GRP_EXTRA[@]}"
                # INSTALL lightweight desktop environment extra
#                if [ "$DESKENV" -eq "1" ]; then
#                    dnf_grp_func "${DESKTOPS_LIGHT_EXTRA[@]}"
#                fi
#            fi
#        fi
# }

# install_packages_gui_multimedia(){
        # install gui multimedia packages
#        if [ "$GUI" -eq "1" ] ; then
#        if [ "$MMEDIA" -eq "1" ]; then
#            dnf_pkg_func ${MMEDIA_BASE[@]} $MMEXCLUDES
#            dnf_grp_func ${MMGRPPKG[@]}
#            if [ "$EXTRA" -eq "1" ]; then
#            dnf_pkg_func "${MMEDIA_EXTRA[@]}" "$MMEXCLUDES"
#                fi
#                dnf swap ffmpeg-free ffmpeg --allowerasing -y
#        fi
#        fi
# }
install_packages(){
        # install srv base packages
        dnf_pkg_func "${SRV_BASE[@]}"
        dnf_grp_func "${SRV_BASE_GRP[@]}"

        # install srv extra packages
        if [ "$EXTRA" -eq "1" ]; then
            dnf_pkg_func "${SRV_EXTRA[@]}"
        fi

        if [ "$GUI" -eq "1" ] ; then
            # install gui base packages
            dnf_pkg_func "${GUI_BASE[@]}"
            dnf_grp_func "${GUI_GRP_BASE[@]}"

            # install lightweight desktop environment
            if [ "$DESKENV" -eq "1" ]; then
                dnf_grp_func "${DESKTOPS_LIGHT[@]}"
            fi

            # install gui extra packages
            if [ "$EXTRA" -eq "1" ]; then
                dnf_pkg_func "${GUI_EXTRA[@]}"
                dnf_grp_func "${GUI_GRP_EXTRA[@]}"
                # install lightweight desktop environment extra
                if [ "$DESKENV" -eq "1" ]; then
                    dnf_grp_func "${DESKTOPS_LIGHT_EXTRA[@]}"
                fi
            fi
        fi
        # install gui multimedia packages
        if [ "$MMEDIA" -eq "1" ]; then
            dnf_pkg_func ${MMEDIA_BASE[@]} $MMEXCLUDES
            dnf_grp_func ${MMGRPPKG[@]}
            if [ "$EXTRA" -eq "1" ]; then
                dnf_pkg_func "${MMEDIA_EXTRA[@]}" "$MMEXCLUDES"
            fi
            dnf swap ffmpeg-free ffmpeg --allowerasing -y
        fi
}
admintools(){
        # installing dbeaver-ce
        if [ "$GUI" -eq "1" ] ; then
            if [ "`dnf list --installed dbeaver-ce | grep -ic dbeaver-ce `" -lt "1" ] ; then
            dnf_pkg_func "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm"
            fi
        fi
        dnf_pkg_func ${ADMIN_TOOLS[@]} ${DOCKER[@]} ${KUBER[@]}
        dnf_grp_func ${SYSADMIN_GRP[@]}

        mkdir -p /etc/docker /usr/local/lib/docker/cli-plugins 
        echo -e "{\n\"bip\" : \"192.168.255.1/24\",\n\"data-root\": \"/data/docker-data/\"\n}\n" > /etc/docker/daemon.json

        # installing docker-compose
        if [ ! -f /usr/local/lib/docker/cli-plugins/docker-compose ] ; then
            # https://github.com/docker/compose/releases/latest
            GH_DP_COMPOSE=$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | jq -r '.assets[] | "\(.name) \(.browser_download_url)"')
            DLND_URL=$(echo "$GH_DP_COMPOSE" | grep "linux-x86_64 " | awk '{print $2}')
            curl -sSL "$DLND_URL" -o /usr/local/lib/docker/cli-plugins/docker-compose
            chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        fi

        # installing docker-buildx
        if [ ! -f /usr/local/lib/docker/cli-plugins/docker-buildx ] ; then
            # https://github.com/docker/buildx/releases/latest
            GH_DP_COMPOSE=$(curl -s "https://api.github.com/repos/docker/buildx/releases/latest" | jq -r '.assets[] | "\(.name) \(.browser_download_url)"')
            DLND_URL=$(echo "$GH_DP_COMPOSE" | grep "linux-amd64 " | awk '{print $2}')
            curl -sSL $DLND_URL -o /usr/local/lib/docker/cli-plugins/docker-buildx
            chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
        fi

        # configuring docker kuber for gui user
        if [ "$GUI" -eq "1" ] ; then
            usermod -a -G docker "$THEUSER"
            mkdir -p /home/$THEUSER/.docker
            echo '{"psFormat": "table {{.ID}}\\t{{.Image}}\\t{{.Status}}\\t{{.Names}}"}' > /home/$THEUSER/.docker/config.json
            kubectl completion bash > /etc/bash_completion.d/kubectl 
            mkdir -p "/home/$THEUSER/.kube/"
            touch "/home/$THEUSER/.kube/config"
        fi

        # configuring docker kuber for root user
        mkdir -p /root/.docker
        echo '{"psFormat": "table {{.ID}}\\t{{.Image}}\\t{{.Status}}\\t{{.Names}}"}' > /root/.docker/config.json
        kubectl completion bash > /etc/bash_completion.d/kubectl
        mkdir -p "/root/.kube/"
        touch "/root/.kube/conf"
}
nettools(){
    if [ "$GUI" -eq "1" ] ; then
        # installing gns3 for gui
        if [ `which pip 2> /dev/null | grep -ic pip` -lt "1" ] ; then 
            dnf_pkg_func python3-pip
        fi
        if [ "`pip list | grep -ci gns3-gui`" -ne "1" ] ; then
            pip install gns3-gui==2.2.51
        fi

        # installing winbox for gui
        if [ ! -f /opt/winbox/win/winbox64.exe  ] ; then
            dnf_pkg_func wine
            git clone https://github.com/darrenoshan/winbox_on_linux.git
            cd winbox_on_linux
            bash ./install.sh
            sudo wget -q https://mt.lv/winbox64 -O /usr/bin/winbox.exe
        fi
    fi
}
kvmtools(){
        dnf_pkg_func "$VIRT_BASE"
        dnf_grp_func "$VIRT_GRP"

        if [ "`grep -icw 'user = "root"' /etc/libvirt/qemu.conf`" -lt "0" ];then
            echo -e 'user = "root"' >> /etc/libvirt/qemu.conf
            echo -e 'group = "root"' >> /etc/libvirt/qemu.conf
        fi

        if [ "$GUI" -eq "1" ] ; then
            usermod -a -G libvirt "$THEUSER"
            NETS=`virsh net-list`
            if [ -f ./config_files/virt-net-default-isolate.xml ] ; then
                if [ "`echo "$NETS" | grep -ic Default-Isolate`" -lt "1" ] ; then
                    virsh net-define --file "./config_files/virt-net-default-isolate.xml"
                fi
            fi
            if [ -f ./config_files/virt-net-default-nat.xml ] ; then
                if [ "`echo "$NETS" | grep -ic Default-NAT`" -lt "1" ] ; then
                    virsh net-define --file ./config_files/virt-net-default-nat.xml
                fi
            fi
            virsh net-autostart --network Default-Isolate
            virsh net-start --network Default-Isolate
            virsh net-autostart --network Default-NAT
            virsh net-start --network Default-NAT
        fi
}
post_script(){
    rm -rf "/home/$THEUSER/.config/autostart/"
    rm -rf  /home/$THEUSER/.local/state/wireplumber/

    usermod -a -G wireshark "$THEUSER"
    chown -R "$THEUSER:$THEUSER" `su - $THEUSER -c 'printenv HOME'`

    # timedatectl set-timezone Asia/Tehran
    timedatectl set-timezone UTC

    git config --global init.defaultBranch main
    touch /etc/vimrc ; sed -i /etc/vimrc -e "s/set hlsearch/set nohlsearch/g"
    timedatectl set-ntp true
    resolvectl flush-caches 

    systemctl daemon-reload
    SERVICES="NetworkManager firewalld sshd sysstat vnstat vmtoolsd chronyd crond docker libvirtd"
    for SRV in $SERVICES  ; do
        systemctl enable --now  $SRV &> /dev/null
    done

    dnf remove "${REMOVE[@]}" -y
    rpm --rebuilddb

}
#################################################################
#--------------- RUNNING SCRIPT FUNCTIONS

# PHASE 0
check_fedora
define_bash_color
base_config
set_proxy
define_repo_base
define_repo_gui

# PHASE 1
pre_install
#update_hw
update_sw
define_packages
install_packages

# PHASE 2
admintools
nettools
# kvmtools

# PHASE 3
post_script

