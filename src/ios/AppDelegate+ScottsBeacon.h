#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate (ScottsBeacon) <CLLocationManagerDelegate>

@property UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (BOOL) xxx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
