#import "RNAudioRoutesEvents.h"

@implementation RNAudioRoutesEvents

API_AVAILABLE(ios(11.0))
AVRouteDetector *routeDetector;

RCT_EXPORT_MODULE(AudioRoutesEvents)

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"AudioRouteChange", @"deviceConnected"];
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



RCT_EXPORT_METHOD(initialize)
{

    // Add observer which will call "deviceChanged" method when audio outpout changes
    // e.g. headphones connect / disconnect
    if (@available(iOS 11.0, *)) {
        routeDetector = [[AVRouteDetector alloc] init];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector: @selector(routeDetector:)
         name:AVRouteDetectorMultipleRoutesDetectedDidChangeNotification
         object:routeDetector];

        // Also call sendEventAboutConnectedDevice method immediately to send currently connected device
        // at the time of startScan
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendEventAboutConnectedDevice];
        });
    } else {
        // Fallback on earlier versions
    }
}

RCT_EXPORT_METHOD(disconnect)
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)routeDetector:(NSNotification *)sender {
    // Get current audio output
    [self sendEventAboutConnectedDevice];
}

- (void) sendEventAboutConnectedDevice;
{
    if (@available(iOS 11.0, *)) {
        routeDetector.routeDetectionEnabled = YES;
        BOOL routeDetectionEnabled = routeDetector.routeDetectionEnabled;
        BOOL multipleRoutesDetected = routeDetector.multipleRoutesDetected;

        [self sendEventWithName:@"deviceConnected" body:@{@"routeDetectionEnabled": @(routeDetectionEnabled), @"multipleRoutesDetected": @(multipleRoutesDetected)}];
    } else {
        // Fallback on earlier versions
    }
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
