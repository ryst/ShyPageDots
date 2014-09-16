ARCHS := armv7 arm64
TARGET := iphone:clang::6.0

include theos/makefiles/common.mk

TWEAK_NAME = ShyPageDots
ShyPageDots_FILES = Tweak.xm
ShyPageDots_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
