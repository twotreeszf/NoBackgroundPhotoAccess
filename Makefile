TARGET = iphone:latest:10.0
PACKAGE_VERSION = 1.1.0
DEBUG = 0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoBackgroundPhotoAccess
NoBackgroundPhotoAccess_CFLAGS = -fobjc-arc -w
NoBackgroundPhotoAccess_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall SpringBoard"
SUBPROJECTS += prefer
include $(THEOS_MAKE_PATH)/aggregate.mk
