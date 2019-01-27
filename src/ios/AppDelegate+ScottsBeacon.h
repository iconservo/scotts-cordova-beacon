#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate (ScottsBeacon) <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property UIBackgroundTaskIdentifier backgroundTaskIdentifier;

- (BOOL) xxx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
