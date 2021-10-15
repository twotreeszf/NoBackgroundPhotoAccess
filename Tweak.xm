//
//  Tweak.xm
//  Hack SpringBoard to fill Appstore password automatically
//
//  Created by twotrees on 2018/11/09.
//  Copyright © 2018 twotrees. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <AssetsLibrary/ALAsset.h>
#import <Photos/Photos.h>

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

void _debugMsg(NSString* msg) {
	NSLog(@"NoBackgroundPhotoAccess from %@-%d : %@", [NSProcessInfo processInfo].processName, [NSProcessInfo processInfo].processIdentifier, msg);
}

NSDictionary* _configDic() {
	return [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.twotrees.nobackgroundphotoaccessprefer.plist"];
}

BOOL _enabled() {
    NSDictionary *prefs = _configDic();
    BOOL enabled = [prefs[@"Enabled"] boolValue];
    _debugMsg([NSString stringWithFormat:@"tweak enabled: %d", enabled]);
    return enabled;
}

BOOL _shouldBlockAccess() {
    if (_enabled()) {  
        if ([NSProcessInfo processInfo].arguments.count) {
            NSString* exePath = [NSProcessInfo processInfo].arguments[0];
            if ([exePath hasPrefix:@"/var/containers/Bundle/Application"]) {
                _debugMsg(@"is user app");
                //UIApplicationStateBackground
                // UIApplicationStateActive
                if (UIApplicationStateBackground == [%c(UIApplication) sharedApplication].applicationState) {
                    return YES;
                }  
            }
            else
                _debugMsg(@"is system app");                
        }                    
    }


    return NO;
}

BOOL _sendAlertNotification() {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.badge = [NSNumber numberWithInt:1];
    content.title = @"💣 NoBackgroundPhotoAccess 💣";
    content.body = @"Found background photo fetch behavior, blocked!";
    content.sound = [UNNotificationSound defaultSound];
    UNTimeIntervalNotificationTrigger *trigger =  [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"NoBackgroundPhotoAccess" content:content trigger:trigger];
    [center addNotificationRequest:notificationRequest withCompletionHandler:nil];
}

BOOL _processBlock(NSString* requestName) {
    _debugMsg([NSString stringWithFormat:@"request access %@", requestName]);

    
    if (_shouldBlockAccess()) {
        _debugMsg(@"block access");
        _sendAlertNotification();
        return YES;
    } else {
        _debugMsg(@"enable access");
        return NO;
    }
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

%ctor {
	_debugMsg(@"launched");
}

%hook PHImageManager

- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset 
targetSize:(CGSize)targetSize 
contentMode:(PHImageContentMode)contentMode 
options:(PHImageRequestOptions *)options 
resultHandler:(void (^)(UIImage * result, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-requestImageForAsset:targetSize:contentMode:options:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, targetSize, contentMode, options, resultHandler);
}

- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset 
options:(PHImageRequestOptions *)options 
resultHandler:(void (^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-requestImageForAsset:options:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, options, resultHandler);
}

- (PHImageRequestID)requestImageDataAndOrientationForAsset:(PHAsset *)asset 
options:(PHImageRequestOptions *)options 
resultHandler:(void (^)(NSData * imageData, NSString * dataUTI, CGImagePropertyOrientation orientation, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-requestImageDataAndOrientationForAsset:options:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, options, resultHandler);
}

- (PHImageRequestID)requestLivePhotoForAsset:(PHAsset *)asset 
targetSize:(CGSize)targetSize 
contentMode:(PHImageContentMode)contentMode 
options:(PHLivePhotoRequestOptions *)options 
resultHandler:(void (^)(PHLivePhoto * livePhoto, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-rrequestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, targetSize, contentMode, options, resultHandler);
}

- (PHImageRequestID)requestPlayerItemForVideo:(PHAsset *)asset 
options:(PHVideoRequestOptions *)options 
resultHandler:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-requestPlayerItemForVideo:options:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, options, resultHandler);
}

- (PHImageRequestID)requestExportSessionForVideo:(PHAsset *)asset 
options:(PHVideoRequestOptions *)options 
exportPreset:(NSString *)exportPreset 
resultHandler:(void (^)(AVAssetExportSession * exportSession, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-requestExportSessionForVideo:options:exportPreset:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, options, exportPreset, resultHandler);
}

- (PHImageRequestID)requestAVAssetForVideo:(PHAsset *)asset 
options:(PHVideoRequestOptions *)options 
resultHandler:(void (^)(AVAsset * asset, AVAudioMix * audioMix, NSDictionary * info))resultHandler {
    BOOL result = _processBlock(@"PHImageManager-requestAVAssetForVideo:options:resultHandler:");
    if (result)
        return PHInvalidImageRequestID;
    else
        return %orig(asset, options, resultHandler);
}

%end

//--------------------------------------------------------------------------------------------------------------------------------------------------------------

%hook ALAsset

- (ALAssetRepresentation *)defaultRepresentation {
    BOOL result = _processBlock(@"ALAsset-defaultRepresentation");
    if (result)
        return nil;
    else
        return %orig;
}


- (ALAssetRepresentation *)representationForUTI:(NSString *)representationUTI {
    BOOL result = _processBlock(@"ALAsset-representationForUTI:");
    if (result)
        return nil;
    else
        return %orig(representationUTI);
}

%end