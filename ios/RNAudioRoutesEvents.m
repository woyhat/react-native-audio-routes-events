#import "RNAudioRoutesEvents.h"

@implementation RNAudioRoutesEvents

RCT_EXPORT_MODULE(AudioRoutesEvents)

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"AudioRouteChange"];
}

RCT_EXPORT_METHOD(configureNotifications)
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteHaveChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

- (void)audioRouteHaveChanged:(NSNotification *)notification
{
    NSNumber *routeChangeType = [notification.userInfo objectForKey:@"AVAudioSessionRouteChangeReasonKey"];
    NSUInteger routeChangeTypeValue = [routeChangeType unsignedIntegerValue];
    
    switch (routeChangeTypeValue) {
        case AVAudioSessionRouteChangeReasonUnknown:
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            if ([self checkAudioRoute:@[AVAudioSessionPortHeadsetMic] routeType:@"output"]) {
                [self sendEventWithName:@"AudioRouteChange" body:@{@"type": @"NewDeviceAvailableWiredHeadset"}];
            } else if ([self checkAudioRoute:@[AVAudioSessionPortBluetoothHFP] routeType:@"output"]) {
                [self sendEventWithName:@"AudioRouteChange" body:@{@"type": @"NewDeviceAvailableBluetooth"}];
            }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self sendEventWithName:@"AudioRouteChange" body: @{@"type": @"OldDeviceUnavailable"}];
            break;
        default:
            break;
    }
}

RCT_EXPORT_METHOD(currentRoute:(RCTResponseSenderBlock)callback)
{
    AVAudioSessionRouteDescription *currentRoute = [AVAudioSession sharedInstance].currentRoute;
    
    NSString *currentRouteString = @"Unknown";
    if (currentRoute != nil) {
        NSArray<AVAudioSessionPortDescription *> *routes = currentRoute.outputs;
        NSLog(@"All Routes: %@", routes);
        AVAudioSessionPortDescription *portDescription = routes.firstObject;
        if (portDescription != nil) {
            NSString *portType = portDescription.portType;
            if ([portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
                currentRouteString = @"BluetoothDevice";
            } else if ([portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
                currentRouteString = @"Speaker";
            } else if ([portType isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
                currentRouteString = @"Earpiece";
            } else if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
                currentRouteString = @"Headphones";
            }
        }
    }
    
    callback(@[[NSNull null], currentRouteString]);
}

- (BOOL)checkAudioRoute:(NSArray<NSString *> *)targetPortTypeArray
              routeType:(NSString *)routeType
{
    AVAudioSessionRouteDescription *currentRoute = [AVAudioSession sharedInstance].currentRoute;
    
    if (currentRoute != nil) {
        NSArray<AVAudioSessionPortDescription *> *routes = [routeType isEqualToString:@"input"]
        ? currentRoute.inputs
        : currentRoute.outputs;
        for (AVAudioSessionPortDescription *portDescription in routes) {
            if ([targetPortTypeArray containsObject:portDescription.portType]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
