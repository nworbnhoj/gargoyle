TOPDIR:=..
SCRIPT_DIR:=$(TOPDIR)/scripts
DL_DIR:=$(TOPDIR)/dl
CONFIG_LINUX_3_18:=y
all:
	if [ ! -e "$(DL_DIR)/$(PKG_SOURCE)" ] ; then $(SCRIPT_DIR)/download.pl $(DL_DIR) $(PKG_SOURCE) $(PKG_MD5SUM) $(PKG_SOURCE_URL) ; fi ; 
	cp $(DL_DIR)/$(PKG_SOURCE) . 
	tar xjf $(PKG_SOURCE)
	rm *.bz2
	mv iptables* iptables
	$(SCRIPT_DIR)/patch-kernel.sh iptables $(TOPDIR)/package/network/utils/iptables/patches/
	echo $(TOPDIR)/package/network/utils/iptables/patches/ > iptables-patch-dir
