// Copyright © 2018 650 Industries. All rights reserved.

#import "ABI26_0_0EXLocalNotificationRequester.h"
#import "ABI26_0_0EXUnversioned.h"

#import <UIKit/UIKit.h>
#import <ReactABI26_0_0/ABI26_0_0RCTUtils.h>

@interface ABI26_0_0EXLocalNotificationRequester ()

@property (nonatomic, strong) ABI26_0_0RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) ABI26_0_0RCTPromiseRejectBlock reject;
@property (nonatomic, weak) id<ABI26_0_0EXPermissionRequesterDelegate> delegate;

@end

@implementation ABI26_0_0EXLocalNotificationRequester

+ (NSDictionary *)permissions
{
  BOOL allowsSound = [ABI26_0_0EXLocalNotificationRequester notificationTypeIsAllowed:UIUserNotificationTypeSound];
  BOOL allowsAlert = [ABI26_0_0EXLocalNotificationRequester notificationTypeIsAllowed:UIUserNotificationTypeAlert];
  BOOL allowsBadge = [ABI26_0_0EXLocalNotificationRequester notificationTypeIsAllowed:UIUserNotificationTypeBadge];
  
  ABI26_0_0EXPermissionStatus status = ABI26_0_0EXPermissionStatusUndetermined;
  
  // If the user allowed alerts we say that notifications are allowed
  if (allowsAlert) {
    status = ABI26_0_0EXPermissionStatusGranted;
  } else if (!allowsBadge && !allowsSound) {
    // However, if none of the notification types is allowed, we say the permission has been denied
    status = ABI26_0_0EXPermissionStatusDenied;
  }

  return @{
           @"status": [ABI26_0_0EXPermissions permissionStringForStatus:status],
           @"allowsSound": @(allowsSound),
           @"allowsAlert": @(allowsAlert),
           @"allowsBadge": @(allowsBadge),
           @"expires": ABI26_0_0EXPermissionExpiresNever,
           };
}

+ (BOOL)notificationTypeIsAllowed:(UIUserNotificationType)type
{
  UIUserNotificationSettings *currentSettings = ABI26_0_0RCTSharedApplication().currentUserNotificationSettings;
  return (currentSettings.types & type) != 0;
}

- (void)requestPermissionsWithResolver:(ABI26_0_0RCTPromiseResolveBlock)resolve rejecter:(ABI26_0_0RCTPromiseRejectBlock)reject
{
  if (_resolve != nil || _reject != nil) {
    reject(@"E_AWAIT_PROMISE", @"Another request for the same permission is already being handled.", nil);
    return;
  }

  _resolve = resolve;
  _reject = reject;
  
  if ([ABI26_0_0EXLocalNotificationRequester notificationTypeIsAllowed:UIUserNotificationTypeAlert]) {
    // resolve immediately if already allowed
    [self _consumeResolverWithCurrentPermissions];
  } else {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleDidRegisterUserNotificationSettings:)
                                                 name:@"EXAppDidRegisterUserNotificationSettingsNotification"
                                               object:nil];
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    [ABI26_0_0RCTSharedApplication() registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
  }
}

- (void)setDelegate:(id<ABI26_0_0EXPermissionRequesterDelegate>)delegate
{
  _delegate = delegate;
}

- (void)_handleDidRegisterUserNotificationSettings:(__unused NSNotification *)notif
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self _consumeResolverWithCurrentPermissions];
}

- (void)_consumeResolverWithCurrentPermissions
{
  if (_resolve) {
    _resolve([[self class] permissions]);
    _resolve = nil;
    _reject = nil;
  }
  if (_delegate) {
    [_delegate permissionsRequester:self didFinishWithResult:nil];
  }
}

@end
