#import "ScottsBeacon.h"

@implementation ScottsBeacon {

}

# pragma mark CDVPlugin

- (void)pluginInitialize
{
    NSLog(@"pluginInitialize");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self.locationManager requestAlwaysAuthorization];
    
    NSString *identifier = @"mg12beacon";
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"58a78bf8-e280-48a4-8668-b8d8cf947cf8"];

    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];

    [self.locationManager startMonitoringForRegion:region];
}

- (void)initializeScottsBeacon:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"didDetermineState: %i %@", state, region);

    if ([region isKindOfClass:[CLBeaconRegion class]] && state == CLRegionStateInside) {
        [self locationManager:manager didEnterRegion:region];
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion: %@", region);

    [self.locationManager startRangingBeaconsInRegion:region];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion: %@", region);

    [self.locationManager stopRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion: %@", region);

    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"didRangeBeacons: %@", region);

    for (CLBeacon* beacon in beacons) {
        NSLog(@"didRangeBeacons: beacon: %@", beacon);
    }
}

@end
