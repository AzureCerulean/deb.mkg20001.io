#!/bin/bash

OUT="$PWD/ubuntu"
KEY="A35AD290"

. "$CONFDIR/_functions.sh"

# Init Repo
_init

# Configure Repo
PPA_ARCHS="amd64 arm64 armhf i386 ppc64el"
PPA_DISTS="xenial bionic cosmic disco"
for distro in $PPA_DISTS; do
  add_dist "$distro" "DEB-MKG-$distro" "mkgs Update Server"
  add_comp "$distro" main
  for a in $PPA_ARCHS; do
    add_arch "$distro" "$a"
  done
done

# Anydesk
for anydesk in $(curl -s https://anydesk.de/download?os=linux | grep '.deb"' | grep -o "https.*.deb"); do
  add_url_auto anydesk "$anydesk"
done

# Zoom
for arch in amd64 i386; do
  zoom=$(curl -sI https://zoom.us/client/latest/zoom_$arch.deb | grep "^Location: " | grep -o "https.*.deb")
  add_url_auto zoom "$zoom"
done

# Duniter
for type in desktop server; do
  url=$(curl --silent https://git.duniter.org/nodes/typescript/duniter/wikis/Releases | grep -o "https://git[a-z0-9/.-]*deb" | sort -r | grep "$type" | head -n 1)
  add_url_auto "duniter_$type" "$url"
done

# Openbazaar
for openb in $(curl -s https://openbazaar.org/download/ | grep -o "https://.*\.deb"); do
  add_url_auto openbazaar "$openb"
done

# Vagrant
for vagrant in $(curl -s https://www.vagrantup.com/downloads.html | grep -o "https.*deb"); do
  add_url_auto vagrant "$vagrant"
done

# Hashicorp Packer
rp_init packer "$(curl -s https://www.packer.io/downloads.html | grep linux_amd64 | grep -o "https.*\\.zip")"
if $RP_CONTINUE; then
  unzip "$RP_FILE"
  install -D packer usr/local/bin/packer
  RP_TAR=$(basename "$RP_FILE")
  RP_TAR=${RP_TAR/".zip"/".tar.gz"}
  tar cvfz "$RP_TAR" usr
  rp_finish
fi

# Mitmproxy.org
MITM_LATEST_VER=$(curl -s 'https://s3-us-west-2.amazonaws.com/snapshots.mitmproxy.org?delimiter=/&prefix=' | grep -o "<Prefix>[0-9.]*/</Prefix>" | grep -o "[0-9.]*" | sort -r | head -n 1)
rp_init mitmproxy "https://snapshots.mitmproxy.org/$MITM_LATEST_VER/$(curl -s "https://s3-us-west-2.amazonaws.com/snapshots.mitmproxy.org?delimiter=/&prefix=$MITM_LATEST_VER/" | grep -o "<Key>[0-9.]*/[a-z0-9.-]*</Key>" | grep -o "/[a-z0-9.-]*" | grep -o "[a-z0-9.-]*" | grep linux | grep mitmproxy)"
if $RP_CONTINUE; then
  mkdir m && cd m
  tar xfz "../$RP_FILE"
  for m in mitm*; do
    install -D "$m" "usr/local/bin/$m"
  done
  RP_TAR="$RP_FILE"
  tar cvfz "$RP_TAR" usr
  rp_finish
fi

# Siderus Orion
ORION_VERSION=$(curl "https://get.siderus.io/orion/latest-version")
ORION="https://get.siderus.io/orion/orion_${ORION_VERSION}_amd64.deb"
add_url_auto orion "$ORION"

# Stub (these pkgs will add own repo after install)
## Chrome
add_from_repo "https://dl.google.com/linux/chrome/deb" "stable" "main" "google-chrome-stable"
## Keybase
add_from_repo "https://prerelease.keybase.io/deb" "stable" "main" "keybase"
## Syncthing
add_from_repo "https://apt.syncthing.net" "syncthing" "stable" "syncthing"

# Clone (repos that I just cloned)
# TODO: full clone
## Gamehub
add_from_repo "http://ppa.launchpad.net/tkashkin/gamehub/ubuntu" "" "main" "com.github.tkashkin.gamehub"
## Node v10
add_from_repo "https://deb.nodesource.com/node_10.x" "" "main" "nodejs"
# small-cleanup-script
add_from_repo "http://ppa.launchpad.net/mkg20001/stable/ubuntu" "" "main" "small-cleanup-script"
# color picker
add_from_repo "http://ppa.launchpad.net/sil/pick/ubuntu" "" "main" "pick-colour-picker"
# virtualbox
add_from_repo "https://download.virtualbox.org/virtualbox/debian" "" "contrib" "virtualbox-5.2"
# x2go
# add_from_repo "http://ppa.launchpad.net/x2go/stable/ubuntu" "" "main" ""
# riot.im
add_from_repo "https://riot.im/packages/debian" "" "main" "riot-web"

# IDE
add_gh_pkg atom atom/atom

# P2P
add_gh_pkg lbry lbryio/lbry-desktop "" "" "amd64"
add_gh_pkg webtorrent webtorrent/webtorrent-desktop
add_gh_pkg ipfs-desktop ipfs-shipyard/ipfs-desktop
add_gh_pkg pathephone pathephone/pathephone-desktop
add_gh_pkg_any tribler tribler/tribler
add_gh_pkg bisq bisq-network/bisq

# Cloud
add_gh_pkg minikube kubernetes/minikube "" "" "amd64"

# Social media
add_gh_pkg akasha AkashaProject/Community
add_gh_pkg talenet talenet/talenet

# Other
add_url multimc "$(curl -s https://multimc.org/ | grep -o "https://files.*deb")" all
add_gh_pkg lanshare abdularis/lan-share
add_gh_pkg_any nuclear nukeop/nuclear

# Self-compiled stuff
for url in $(curl -s https://i.mkg20001.io/deb/ | grep -o './.*deb\"' | sed "s|./|https://i.mkg20001.io/deb/|g" | sed 's|"||g'); do
  add_url_auto "$(echo $url | sed -r "s|.*deb/([a-z0-9.-]+)_.*|\1|g")" "$url"
done

# And... release

fin
