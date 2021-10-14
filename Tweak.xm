//
//  Tweak.xm
//  Hack SpringBoard to fill Appstore password automatically
//
//  Created by twotrees on 2018/11/09.
//  Copyright © 2018 twotrees. All rights reserved.
//

#import <UIKit/UIKit.h>

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

void _debugMsg(NSString* msg) {
	NSLog(@"NoBackgroundPhotoAccess: %@", msg);
}

NSDictionary* _configDic() {
	return [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.twotrees.nobackgroundphotoaccessprefer.plist"];
}

BOOL _enabled() {
    NSDictionary *prefs = _cnfigDic();
    BOOL enabled = [prefs[@"Enabled"] boolValue];
    return enabled;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

%ctor {
	_dbugMsg([NSString stringWithFormat:@"launched pid: %d", [NSProcessInfo processInfo].processIdentifier]);
}

%hook PHImageManager

+ (PHImageManager *)defaultManager {
    if (UIApplicationStateBackground == [UIApplication sharedApplication].applicationState)
        return nil;
    else
        return %orig;
}
%end
