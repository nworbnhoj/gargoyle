
######################################################################################
# This Makefile downloads and builds Python software covered by the following license:
#
# https://docs.python.org/3/license.html
#
#===============================================================================
#
#	Python is distributed under this license:
#
# 1. This LICENSE AGREEMENT is between BeOpen.com ("BeOpen"), having an office at
#    160 Saratoga Avenue, Santa Clara, CA 95051, and the Individual or Organization
#    ("Licensee") accessing and otherwise using this software in source or binary
#    form and its associated documentation ("the Software").
#
# 2. Subject to the terms and conditions of this BeOpen Python License Agreement,
#    BeOpen hereby grants Licensee a non-exclusive, royalty-free, world-wide license
#    to reproduce, analyze, test, perform and/or display publicly, prepare derivative
#    works, distribute, and otherwise use the Software alone or in any derivative
#    version, provided, however, that the BeOpen Python License is retained in the
#    Software, alone or in any derivative version prepared by Licensee.
#
# 3. BeOpen is making the Software available to Licensee on an "AS IS" basis.
#    BEOPEN MAKES NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED.  BY WAY OF
#    EXAMPLE, BUT NOT LIMITATION, BEOPEN MAKES NO AND DISCLAIMS ANY REPRESENTATION OR
#    WARRANTY OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE
#    USE OF THE SOFTWARE WILL NOT INFRINGE ANY THIRD PARTY RIGHTS.
#
# 4. BEOPEN SHALL NOT BE LIABLE TO LICENSEE OR ANY OTHER USERS OF THE SOFTWARE FOR
#    ANY INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES OR LOSS AS A RESULT OF USING,
#    MODIFYING OR DISTRIBUTING THE SOFTWARE, OR ANY DERIVATIVE THEREOF, EVEN IF
#    ADVISED OF THE POSSIBILITY THEREOF.
#
# 5. This License Agreement will automatically terminate upon a material breach of
#    its terms and conditions.
#
# 6. This License Agreement shall be governed by and interpreted in all respects
#    by the law of the State of California, excluding conflict of law provisions.
#    Nothing in this License Agreement shall be deemed to create any relationship of
#    agency, partnership, or joint venture between BeOpen and Licensee.  This License
#    Agreement does not grant permission to use BeOpen trademarks or trade names in a
#    trademark sense to endorse or promote products or services of Licensee, or any
#    third party.  As an exception, the "BeOpen Python" logos available at
#    http://www.pythonlabs.com/logos.html may be used according to the permissions
#    granted on that web page.
#
# 7. By copying, installing or otherwise using the software, Licensee agrees to be
#    bound by the terms and conditions of this License Agreement.
#


include $(TOPDIR)/rules.mk

PKG_NAME:=plugin_gargoyle_python
PKG_VERSION:=2.7.11
PKG_RELEASE:=1

PKG_SOURCE:=Python-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://www.python.org/ftp/python/$(PKG_VERSION)
PKG_MD5SUM:=6b6076ec9e93f05dd63e47eb9c15728b
PKG_INSTALL:=1


PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/plugin-gargoyle-python
	SECTION:=admin
	CATEGORY:=Administration
	URL:=https://www.python.org
	TITLE:=python
	DEPENDS:=+gargoyle
	MAINTAINER:=Eric Bishop
	PKGARCH:=all
endef

define Package/plugin-gargoyle-python/description
	python support for Gargoyle plugins
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/plugin-gargoyle-python/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

define Package/plugin-gargoyle-python/postinst
endef

define Package/plugin-gargoyle-python/postrm
endef



$(eval $(call BuildPackage,plugin-gargoyle-python))
