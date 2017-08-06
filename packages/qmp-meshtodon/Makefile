#    Copyright (C) 2017 Meshtodon, http://sbmesh.net
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#    The full GNU General Public License is included in this distribution in
#    the file called "COPYING".
#
# Contributors:
#	Raymond Douglas
#


include $(TOPDIR)/rules.mk

PKG_NAME:=qmp-meshtodon
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+
meshtodon_REVISION:=$(shell git rev-parse HEAD)
meshtodon_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
meshtodon_BUILDDATE:=$(shell date +%Y%m%d_%H%M)

include $(INCLUDE_DIR)/package.mk

define Package/qmp-meshtodon
  SECTION:=utils
  CATEGORY:=qMp
  TITLE:=qMp Meshtodon Configuration
  MAINTAINER:=Meshtodon
  DEPENDS:=+nodogsplash \
	+qmp-small-node \
	+luci-ssl \
	+wget \
	+reghack \
	+curl \
	+6in4 \
	+kmod-ipt-conntrack-extra \
	+iptables-mod-conntrack-extra \
	+luci-app-wshaper
endef

define Package/qmp-meshtodon/description
 Configuration files for Meshtodon.
endef

define Build/Compile
endef

define Package/qmp-meshtodon/install
	 $(INSTALL_DIR) $(1)/etc/meshtodon
	 $(INSTALL_BIN) ./files/etc/meshtodon/meshtodon_initial_conf.sh $(1)/etc/meshtodon/meshtodon_initial_conf.sh
	 $(INSTALL_BIN) ./files/etc/meshtodon/meshtodon_configure.sh $(1)/etc/meshtodon/meshtodon_configure.sh
	 $(INSTALL_BIN) ./files/etc/meshtodon/meshtodon_startup.sh $(1)/etc/meshtodon/meshtodon_startup.sh
	 $(INSTALL_DIR) $(1)/etc/dropbear
	 $(INSTALL_DATA) ./files/etc/dropbear/authorized_keys $(1)/etc/dropbear/authorized_keys
	 $(INSTALL_DIR) $(1)/etc/init.d
	 $(INSTALL_DIR) $(1)/etc/rc.d
	 $(CP) ./files/etc/init.d/* $(1)/etc/init.d
	 $(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	 $(INSTALL_DATA) ./files/etc/hotplug.d/iface/95-nodog $(1)/etc/hotplug.d/iface/95-nodog
	 $(INSTALL_DIR) $(1)/etc/nodogsplash/htdocs
	 $(INSTALL_DATA) ./files/etc/nodogsplash/htdocs/splash.html $(1)/etc/nodogsplash/htdocs/splash.html
	 $(INSTALL_DATA) ./files/etc/meshtodon/meshtodon.banner $(1)/etc/meshtodon/meshtodon.banner
	 $(SED) 's,$$$$REVISION,$(meshtodon_REVISION),g' $(1)/etc/meshtodon/meshtodon.banner
	 $(SED) 's,$$$$BUILDDATE,$(meshtodon_BUILDDATE),g' $(1)/etc/meshtodon/meshtodon.banner
	 $(INSTALL_DATA) ./files/etc/meshtodon/meshtodon.release $(1)/etc/meshtodon/meshtodon.release
	 $(SED) 's,$$$$REVISION,$(meshtodon_REVISION),g' $(1)/etc/meshtodon/meshtodon.release
	 $(SED) 's,$$$$BUILDDATE,$(meshtodon_BUILDDATE),g' $(1)/etc/meshtodon/meshtodon.release
	 $(SED) 's,$$$$BRANCH,$(meshtodon_BRANCH),g' $(1)/etc/meshtodon/meshtodon.release
	 $(INSTALL_DIR) $(1)/etc/uci-defaults
	 $(CP) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,qmp-meshtodon))
