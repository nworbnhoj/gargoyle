
######################################################################################
# This Makefile downloads and builds obfsproxy software covered by the following license:
#
#===============================================================================
#
# Copyright 2013 George Kadianakis
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#
# * Neither the names of the copyright owners nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


include $(TOPDIR)/rules.mk

PKG_NAME:=plugin_gargoyle_obfsproxy
PKG_VERSION:=0.2.13
PKG_RELEASE:=1

PKG_SOURCE:=obfsproxy-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/o/obfsproxy
PKG_MD5SUM:=f596aeeda7bf03cdf0e78e68e6e7ac9f
PKG_INSTALL:=1


PKG_BUILD_DIR:=$(BUILD_DIR)/obfsproxy-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/plugin-gargoyle-obfsproxy
  SECTION:=net
  CATEGORY:=Network
	URL:=https://gitweb.torproject.org/pluggable-transports/obfsproxy.git/
	TITLE:=obfsproxy
	DEPENDS:=+gargoyle +plugin-gargoyle-python
	MAINTAINER:=Eric Bishop
	PKGARCH:=all
endef

define Package/plugin-gargoyle-obfsproxy/description
	obfsproxy is a tool that attempts to circumvent censorship, by transforming
	the Tor traffic between the client and the bridge. This way, censors, who
	usually monitor traffic between the client and the bridge, will see
	innocent-looking transformed traffic instead of the actual Tor traffic.

	It is written in Python and is compliant with the Tor pluggable transports
	specification, and its modular architecture allows it to support multiple
	pluggable transports.
endef

CONFIGURE_ARGS += \
	--with-libevent-dir="$(STAGING_DIR)/usr" \
	--with-ssl-dir="$(STAGING_DIR)/usr" \
	--disable-threads \
	--disable-gcc-hardening \
	--disable-asciidoc

CONFIGURE_VARS += \
	CROSS_COMPILE="yes"

# pass CFLAGS again to override -O2 set by configure
MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -fPIC -std=gnu99"



define Package/plugin-gargoyle-obfsproxy/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

define Package/plugin-gargoyle-obfsproxy/postinst
endef

define Package/plugin-gargoyle-obfsproxy/postrm
endef



$(eval $(call BuildPackage,plugin-gargoyle-obfsproxy))
