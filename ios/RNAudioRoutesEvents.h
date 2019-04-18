#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif
#import <React/RCTEventEmitter.h>

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RNAudioRoutesEvents : RCTEventEmitter <RCTBridgeModule>

@end
