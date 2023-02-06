ARCHS = arm64 arm64e
TARGET = iphone:clang:15.3.1:13.0
PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/
SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Safecuts

Safecuts_FILES = Tweak.xm
Safecuts_CFLAGS = -fobjc-arc
Safecuts_USE_SUBSTRATE = 0
Safecuts_LOGOS_DEFAULT_GENERATOR = internal

include $(THEOS_MAKE_PATH)/tweak.mk
