// Copyright 2016-present 650 Industries. All rights reserved.

#import "ABI28_0_0EXResourceLoader.h"
#import "ABI28_0_0EXScopedBridgeModule.h"
#import "ABI28_0_0EXScopedModuleRegistry.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const ABI28_0_0EXUpdatesEventName;
FOUNDATION_EXPORT NSString * const ABI28_0_0EXUpdatesErrorEventType;
FOUNDATION_EXPORT NSString * const ABI28_0_0EXUpdatesNotAvailableEventType;
FOUNDATION_EXPORT NSString * const ABI28_0_0EXUpdatesDownloadStartEventType;
FOUNDATION_EXPORT NSString * const ABI28_0_0EXUpdatesDownloadProgressEventType;
FOUNDATION_EXPORT NSString * const ABI28_0_0EXUpdatesDownloadFinishedEventType;

@protocol ABI28_0_0EXUpdatesScopedModuleDelegate

- (void)updatesModuleDidSelectReload:(id)scopedModule;
- (void)updatesModuleDidSelectReloadFromCache:(id)scopedModule;
- (void)updatesModule:(id)scopedModule
didRequestManifestWithCacheBehavior:(ABI28_0_0EXCachedResourceBehavior)cacheBehavior
              success:(void (^)(NSDictionary * _Nonnull))success
              failure:(void (^)(NSError * _Nonnull))failure;
- (void)updatesModule:(id)scopedModule
didRequestBundleWithManifest:(NSDictionary *)manifest
             progress:(void (^)(NSDictionary * _Nonnull))progress
              success:(void (^)(NSData * _Nonnull))success
              failure:(void (^)(NSError * _Nonnull))failure;

@end

@interface ABI28_0_0EXUpdates : ABI28_0_0EXScopedBridgeModule

- (void)sendEventWithBody:(NSDictionary *)body;

@end

ABI28_0_0EX_DECLARE_SCOPED_MODULE_GETTER(ABI28_0_0EXUpdates, updates)

NS_ASSUME_NONNULL_END
