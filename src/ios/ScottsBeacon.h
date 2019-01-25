#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ScottsBeacon : CDVPlugin<CLLocationManagerDelegate> {

}

@property (retain) CLLocationManager *locationManager;

@end
