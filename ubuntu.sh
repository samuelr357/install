#!/bin/bash
##CRIADO POR SAMUEL RODRIGUES##
##PARA NOTEBOOK LNV SETAR NA INICIALIZAÇÃO 'amixer -c 1 sset 'Headphone' 100'.

echo1=#########################################################################
echo2=#########################################################################

echo -e "\n$echo1\nRemovendo travas eventuais do apt.\n$echo2\n"
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock
set -e  ;

echo -e "\n$echo1\nAtualizando Sistema.\n$echo2\n"
sudo apt update --fix-missing ;
sudo apt full-upgrade -y  ;

echo -e "\n$echo1\nDefinindo dependencias.\n$echo2\n"
pacotes_dep=(curl wget  sed jq unzip chrome-gnome-shell net-tools gnome-tweak-tool git snapd build-essential default-jdk libssl-dev exuberant-ctags ncurses-term  silversearcher-ag fontconfig imagemagick libmagickwand-dev software-properties-common )
pacotes_apt=(gimp vlc libreoffice netbeans qbittorrent enpass stacer steam insync gnome-boxes timeshift openjdk-8-jdk-headless gparted)
pacotes_apt_recomendados=( wine-stable wine32 winetricks)

ppas=()

##EXTENCOES GNOME - ADICIONAR NUMERO REFERENTE AO PROJETO
ext=(19 1160 104 1677 7 906)

repos=(
"deb https://apt.enpass.io/ stable main"
)

deb=("https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
)

appimg=("https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X-v4.0.1-x86_64.AppImage"
"https://github.com/balena-io/etcher/releases/download/v1.5.109/balenaEtcher-1.5.109-ia32.AppImage"
"https://github.com/kefir500/apk-editor-studio/releases/download/v1.4.0/apk-editor-studio_linux_1.4.0.AppImage"
"https://github.com/GitSquared/edex-ui/releases/download/v2.2.4/eDEX-UI-Linux-x86_64.AppImage"
)

down_keys=(
"https://apt.enpass.io/keys/enpass-linux.key"
"https://dl.winehq.org/wine-builds/winehq.key"
)

keys=(enpass-linux.key winehq.key)

snaps=(spotify)
snaps_classic=(code android-studio)

libs_32bits=(gnutls30 ldap-2.4-2 gpg-error0 xml2 asound2-plugins sdl2-2.0-0 freetype6 dbus-1-3 sqlite3-0)


###################################################################################
echo -e "\n$echo1\nInstalando extenções GNOME.\n$echo2\n"
sudo apt -y install wget curl jq unzip sed
rm -f ./install-gnome-extensions.sh; wget -N -q "https://raw.githubusercontent.com/cyfrost/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh && chmod +x install-gnome-extensions.sh
./install-gnome-extensions.sh --enable ${ext[@]}
rm -f ./install-gnome-extensions.sh

cd $(mktemp -d)

echo -e "\n$echo1\nAdicionando Wallpaper gdm\n$echo\n"
wget https://raw.githubusercontent.com/samuelr357/install/main/theme/set-wallpaper-gdm
wget https://raw.githubusercontent.com/samuelr357/install/main/theme/wall.jpg
chmod +x set-wallpaper-gdm
sudo ./set-wallpaper-gdm wall.jpg

echo -e "\n$echo1\nOrganizando dash GNOME.\n$echo2\n"
wget https://raw.githubusercontent.com/BenJetson/gnome-dash-fix/master/appfixer.sh
chmod +x ./appfixer.sh
./appfixer.sh
rm -f ./appfixer.sh

echo -e "\n$echo1\nBaixando chaves e pacotes.\n$echo2\n"
wget -nv -c ${deb[@]}
wget -nv -c ${down_keys[@]}
sudo apt-key add ${keys[@]}
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C

echo -e "\n$echo1\nInsalando pacotes DEB externos.\n$echo2\n"
sudo apt install ./*.deb

echo -e "\n$echo1\nAdicionando arquitetura x86.\n$echo2\n"
sudo dpkg --add-architecture i386 
sudo apt update --fix-missing

echo -e "\n$echo1\nAdicionando repositório.\n$echo2\n"
sudo apt install -y software-properties-common
for repositorio in ${repos[@]}; do
  sudo apt-add-repository -y "$repos"
done
sudo apt-add-repository -y "deb https://dl.winehq.org/wine-builds/ubuntu/ focal main"
sudo apt-add-repository -y "deb http://apt.insync.io/ubuntu focal non-free contrib"
sudo apt-add-repository -y "deb https://apt.enpass.io/ stable main"

echo -e "\n$echo1\nAdicionando PPAs.\n$echo2\n"
for ppa in ${ppas[@]}; do
  sudo apt-add-repository "ppa:"$ppa  -y
done

echo -e "\n$echo1\nInstalando pacotes do reporitório.\n$echo2\n"
sudo apt update --fix-missing
sudo apt install  ${pacotes_apt[@]} -y
sudo apt install  ${pacotes_dep[@]} -y
sudo apt install --install-recommends  ${pacotes_apt_recomendados[@]} -y

echo -e "\n$echo1\nInstalando SNAPS.\n$echo2\n"
sudo snap install ${snaps[@]}
sudo snap install --classic ${snaps_classic[@]}

echo -e "\n$echo1\nInstalando Libs.\n$echo2\n"
echo "${libs_32bits[@]}" | tr ' ' '\n' | awk '{print "lib"$1":i386"}' | tr '\n' ' '
sudo apt install $(echo "${libs_32bits[@]}" | tr ' ' '\n' | awk '{print "lib"$1":i386"}' | tr '\n' ' ')

echo -e "\n$echo1\nBaixando e configurando APPIMAGE.\n$echo2\n"
#RESOLVENDO APPS IMAGE 
mkdir $HOME/Applications -p
cd $HOME/Applications
wget -nv -c ${appimg[@]}
chmod +x $HOME/Applications/
wget "https://github.com/AppImage/appimaged/releases/download/continuous/appimaged-x86_64.AppImage"
chmod +x *.AppImage
./appimaged-x86_64.AppImage --install

##CONFIGURAR VPN PARA INICIAR COM SISTEMA
echo -e "\n$echo1\nMOSTRAR "Advanced Network Configuration" NO GNOME.\n$echo2\n"
sudo sed '13d' /usr/share/applications/nm-connection-editor.desktop > /home/samuel/.local/share/applications/nm-connection-editor.desktop 

sudo apt dist-upgrade -y
sudo apt autoclean 

clear
echo -e "\n$echo1\nSISTEMA INSTALADO COM SUCESSO!!\n$echo2\n"
sleep 120
exit
