#import "ScottsBeacon.h"

@implementation ScottsBeacon {

}

# pragma mark CDVPlugin

- (void)pluginInitialize
{
    NSLog("pluginInitialize");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self.locationManager requestAlwaysAuthorization];
    
    NSString *identifier = "water_low";
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:"58A78BF8-E280-48A4-8668-B8D8CF947CF8"];
    double major = 1;
    double minor = 64;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];

    [self.locationManager.startMonitoringForRegion:region];
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog("didDetermineState: %@ %@", state, region);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog("didEnterRegion: %@", region);
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog("didExitRegion: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog("didStartMonitoringForRegion: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog("monitoringDidFailForRegion: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog("didRangeBeacons: %@", region);

    for (CLBeacon* beacon in beacons) {
        NSLog("didRangeBeacons: %@", beacon);
    }
}

@end
