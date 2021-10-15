ARCHS = armv7 arm64 arm64e
TARGET = iphone:latest:10.0
PACKAGE_VERSION = 1.1.1
DEBUG = 0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoBackgroundPhotoAccess
NoBackgroundPhotoAccess_CFLAGS = -fobjc-arc -w
NoBackgroundPhotoAccess_CCFLAGS = -std=c++11
NoBackgroundPhotoAccess_FILES = Tweak.xm
NoBackgroundPhotoAccess_FRAMEWORKS = UIKit UserNotifications
# NoBackgroundPhotoAccess_PRIVATE_FRAMEWORKS = 


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall SpringBoard"
SUBPROJECTS += prefer
include $(THEOS_MAKE_PATH)/aggregate.mk
