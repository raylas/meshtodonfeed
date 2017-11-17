meshtodonfeed
=============

Meshtodonfeed is a qMp + OpenWrt feed for the Santa Barbara Mesh project.

Build Notes
-----------

*All compiling has only—so far—been tested on Ubuntu/Trusty64*


Requirements
------------

* A Ubiquiti NanoStation M5 (XW) downgraded to airOS v5.5.10
* Ubuntu or Debian-based install or virtual machine
  * Configured for at least 4096MB of ram
  * Configured for 2 CPUs (potentially optional)


Vagrantfile (if you're using Vagrant):

```
Vagrant.configure(“2”) do |config|
  config.vm.box = “ubuntu/trusty64"

  config.vm.provider “virtualbox” do |v|
    v.memory = 4096
    v.cpus = 2
  end
end
```


Environment Prep
----------------

Install all necessary build tools:

```
sudo apt-get install git make gcc g++ zlib1g-dev libssl-dev wget subversion file python apt-utils binfmt-support \
vim apt-file xz-utils sudo subversion zlib1g-dev gawk flex unzip bzip2 gettext build-essential libncurses5-dev \
libncursesw5-dev libssl-dev binutils cpp psmisc docbook-to-man gcc-multilib g++-multilib
```

Configure:

```
export VERSION=3.2.1

git clone git://qmp.cat/qmpfw.git qmp-$VERSION
cd qmp-$VERSION
git fetch --tags
git checkout tags/v$VERSION
QMP_GIT_BRANCH=v$VERSION make checkout
cd build/qmp
git checkout -b v$VERSION
cd ../..
echo "src-git meshtodonfeed https://github.com/raylas/meshtodonfeed.git" >> ./build/openwrt/feeds.conf
./build/openwrt/scripts/feeds update -a
./build/openwrt/scripts/feeds install -a
```


Update netperf-2.7.0 Makefile
-----------------------------

Open the netperf Makefile:

`nano build/openwrt/package/feeds/packages/netperf/Makefile`

Replace the package source with:

`PKG_SOURCE_URL:=https://fossies.org/linux/misc/`

Save the file.


Build
-----

```
export TARGET=nsm5-xw

# select qmp-meshtodon from qmp submenu of this command:
make T=$TARGET menuconfig

make T=$TARGET J=2 build
```

Firmware images (**factory** and **sysupgrade**) will be in `images/`


Firmware flashing
-----------------

Once compiled follow our NanoStation M5 flashing instructions [on our website](https://sbmesh.net/join.html).
