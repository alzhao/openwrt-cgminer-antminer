#
# Author: Xiangfu Liu <xiangfu@openmobilefree.net>
# Address: 12h6gdGnThW385JaX1LRMA8cXKmbYRTP8Q
#
# This is free and unencumbered software released into the public domain.
# For details see the UNLICENSE file at the root of the source tree.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cgminer-ant
PKG_VERSION:=3.8.5
PKG_RELEASE:=1
PKG_INSTALL:=1


PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/cgminer-ant
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=cgminer (FPGA Miner)
	URL:=https://github.com/ckolivas/cgminer
	DEPENDS:=+libcurl +libpthread +jansson +udev +libncurses
endef

define Package/cgminer-ant/description
Cgminer is a multi-threaded multi-pool GPU, FPGA and CPU miner with ATI GPU
monitoring, (over)clocking and fanspeed support for bitcoin and derivative
coins. Do not use on multiple block chains at the same time!
endef

#CONFIGURE_ARGS += --disable-opencl --disable-adl --without-curses --enable-avalon
#CONFIGURE_ARGS += --disable-opencl --disable-adl --without-curses --enable-avalon --enable-bflsc --enable-icarus --enable-bmsc
CONFIGURE_ARGS += --enable-bmsc 
TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(call Build/Compile/Default)
	(cd $(PKG_BUILD_DIR) && \
	  $(TARGET_CC) -Icompat/jansson -Icompat/libusb-1.0/libusb \
	  api-example.c -o cgminer-api;)
endef


define Package/cgminer-ant/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgminer-api $(1)/usr/bin

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cgminer $(1)/usr/bin
	$(INSTALL_BIN) $(FILES_DIR)/cgminer-monitor       $(1)/usr/bin
	$(INSTALL_BIN) $(FILES_DIR)/cgminer.init          $(1)/etc/init.d/cgminer
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP)          $(FILES_DIR)/cgminer.config     $(1)/etc/config/cgminer
	$(CP)	-fr       $(FILES_DIR)/usr/lib/*	$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb/
#	$(CP)	$(FILES_DIR)/etc/hotplug.d/usb/30-cgminer $(1)/etc/hotplug.d/usb/
endef

$(eval $(call BuildPackage,cgminer-ant))
