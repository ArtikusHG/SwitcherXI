ARCHS = armv7 armv7s arm64
include /var/theos/makefiles/common.mk

TWEAK_NAME = SwitcherXI
SwitcherXI_FILES = Tweak.xm
SwitcherXI_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
