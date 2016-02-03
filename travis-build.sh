#!/bin/bash

GARGOYLE_VERSION:=1.9.X (Built $(shell echo "`date -u +%Y%m%d-%H%M` git@`git log -1 --pretty=format:%h`"))
TARGET = ar71xx
PROFILE = usb
V=0
FULL_BUILD=false
CUSTOM_TEMPLATE=ar71xx
CUSTOM_TARGET=ar71xx
JS_COMPRESS=true
TRANSLATION=internationalize
FALLBACK_LANG=English-EN
ACTIVE_LANG=English-EN
BUILD_THREADS=auto
#BUILD_THREADS=1
DISTRIBUTION=false

%:
	( \
		if [ ! -d "$${target}-src" ] || [ "$(FULL_BUILD)" = "1" -o "$(FULL_BUILD)" = "true" -o "$(FULL_BUILD)" = "TRUE" ] ; then \
			bash build.sh "$(TARGET)" "$(GARGOYLE_VERSION)" "$(V)" "$(CUSTOM_TARGET)" "$(CUSTOM_TEMPLATE)" "$(JS_COMPRESS)" "$(PROFILE)" "$(TRANSLATION)" "$(FALLBACK_LANG)" "$(ACTIVE_LANG)" "$(BUILD_THREADS)" "$(DISTRIBUTION)"; \
		else \
			bash rebuild.sh "$(TARGET)" "$(GARGOYLE_VERSION)" "$(V)" "$(JS_COMPRESS)" "$(PROFILE)" "$(TRANSLATION)" "$(FALLBACK_LANG)" "$(ACTIVE_LANG)" "$(BUILD_THREADS)" "$(DISTRIBUTION)"; \
		fi ; \
	)
