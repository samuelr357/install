#!/bin/bash
##CRIADO POR SAMUEL RODRIGUES##
##PARA NOTEBOOK LNV SETAR NA INICIALIZAÇÃO 'amixer -c 1 sset 'Headphone' 100'.

echo1="#########################################################################"

echo -e "\n$echo1\nAtualizando Sistema.\n$echo1\n"
sudo pacman -Syu --noconfirm

echo -e "\n$echo1\nDefinindo dependencias.\n$echo1\n"
dependencia=(curl wget  sed jq unzip chrome-gnome-shell net-tools gnome-tweak-tool git snapd)
pamac=(gimp vlc netbeans qbittorrent enpass stacer gnome-boxes timeshift gparted nautilus-share gnome-session-properties manjaro-settings-samba flatpak libpamac-flatpak-plugin)
pacaur=(google-chrome insync enpass binance onlyoffice-desktopeditors brave)
flatpak=(junction blanket)

##EXTENCOES GNOME - ADICIONAR NUMERO REFERENTE AO PROJETO  https://extensions.gnome.org/extension/"NUMBER"/projectname/
ext=(19 1160 104 1677 7 906 1503 4236)

appimg=("https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X-v4.0.1-x86_64.AppImage"
"https://github.com/balena-io/etcher/releases/download/v1.5.109/balenaEtcher-1.5.109-ia32.AppImage"
"https://github.com/kefir500/apk-editor-studio/releases/download/v1.4.0/apk-editor-studio_linux_1.4.0.AppImage"
"https://github.com/GitSquared/edex-ui/releases/download/v2.2.4/eDEX-UI-Linux-x86_64.AppImage"
"https://github.com/prateekmedia/appimagepool/releases/download/4.9.9/appimagepool-x86_64.AppImage"
)


##################################################################################
echo -e "\n$echo1\nHabilitando pacoter AUR\n$echo1\n"
sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf 

echo -e "\n$echo1\nHabilitando Downloads paralelos\n$echo1\n"
sudo sed -Ei '/ParallelDownload/s/^#//' /etc/pacman.conf

pamac install webtorrent-desktop --no-confirm
echo -e "\n$echo1\nInstalando extenções GNOME.\n$echo1\n"
sudo pacman -S wget curl jq unzip sed --noconfirm
rm -f ./install-gnome-extensions.sh; wget -N -q "https://raw.githubusercontent.com/cyfrost/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh && chmod +x install-gnome-extensions.sh
./install-gnome-extensions.sh --enable ${ext[@]}
rm -f ./install-gnome-extensions.sh

cd $(mktemp -d)

echo -e "\n$echo1\nConfigurando adaptador Wi-Fi RTL88x2BU\n$echo1\n"
sudo pacman -S dkms --noconfirm
git clone "https://github.com/RinCat/RTL88x2BU-Linux-Driver.git" /usr/src/rtl88x2bu-git
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="git"/g' /usr/src/rtl88x2bu-git/dkms.conf
sudo dkms add -m rtl88x2bu -v git
sudo dkms autoinstall
modprobe 88x2bu rtw_switch_usb_mode=1

echo -e "\n$echo1\nInstalando tema no GRUB\n$echo1\n"
wget https://github.com/samuelr357/install/raw/main/theme/grub.tar.xz
tar -Jxxvf grub.tar.xz
chmod +x install.sh
sudo ./install.sh

echo -e "\n$echo1\nOrganizando dash GNOME.\n$echo1\n"
wget https://raw.githubusercontent.com/BenJetson/gnome-dash-fix/master/appfixer.sh
chmod +x ./appfixer.sh
./appfixer.sh
rm -f ./appfixer.sh

echo -e "\n$echo1\nInstalando pacotes do reporitório.\n$echo1\n"
sudo pacman -Sy --noconfirm
sudo pacman -S ${dependencia[@]} --noconfirm
sudo pamac install ${pamac[@]} --no-confirm

echo -e "\n$echo1\nInstalando pacotes AUR.\n$echo1\n"
sudo pamac install ${pacaur[@]} --no-confirm

echo -e "\n$echo1\nInstalando pacotes FlatPak.\n$echo1\n"
sudo sed -Ei '/EnableFlatpak/s/^#//' /etc/pamac.conf
sudo flatpak install ${flatpak[@]} -y


echo -e "\n$echo1\nInstalando pacotes Snaps.\n$echo1\n"
sudo systemctl enable --now snapd.socket
sudo systemctl restart snapd.service
sudo sed -Ei '/EnableSnap/s/^#//' /etc/pamac.conf
sudo snap install spotify
sudo snap install onlyoffice-desktopeditors
sudo snap install --classic code

echo -e "\n$echo1\nBaixando e configurando APPIMAGE.\n$echo1\n"
#RESOLVENDO APPS IMAGE 
mkdir $HOME/Applications -p
cd $HOME/Applications
wget -nv -c ${appimg[@]}
chmod +x $HOME/Applications/
wget "https://github.com/AppImage/appimaged/releases/download/continuous/appimaged-x86_64.AppImage"
chmod +x *.AppImage
./appimaged-x86_64.AppImage --install

sudo sed -i 's/NoDisplay=true//g' /usr/share/applications/gnome-session-properties.desktop
##CONFIGURAR VPN PARA INICIAR COM SISTEMA
##echo -e "\n$echo1\nMOSTRAR "Advanced Network Configuration" NO GNOME.\n$echo1\n"
##sudo sed '13d' /usr/share/applications/nm-connection-editor.desktop > /home/samuel/.local/share/applications/nm-connection-editor.desktop 

echo -e "\n$echo1"; ##echo -e "\n$echo1"
echo -e "\n$echo1\nSISTEMA INSTALADO COM SUCESSO!!\n$echo2\n"
echo -e "\n$echo1"; ##echo -e "\n$echo1"
sleep 120
exit
