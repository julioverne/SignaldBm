include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SignaldBm

$(TWEAK_NAME)_FILES = /mnt/d/codes/signaldbm/signaldbmhook/Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = CydiaSubstrate UIKit Foundation CoreGraphics CoreTelephony
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MobileWiFi
$(TWEAK_NAME)_LDFLAGS = -Wl,-segalign,4000
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

export ARCHS = armv7 armv7s arm64 arm64e
$(TWEAK_NAME)_ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk
