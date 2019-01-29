#import "AppDelegate+ScottsBeacon.h"
#import <objc/runtime.h>

@implementation AppDelegate (ScottsBeacon)

NSString * const key = @"com.scotts.beacon.locationmanager.key";

NSString * const water = @"com.scotts.beacon.mg12.water";
NSString * const pump = @"com.scotts.beacon.mg12.pump";

BOOL wasLaunchedByLocationManager = FALSE;

- (void)setLocationManager:(CLLocationManager *)locationManager {
    objc_setAssociatedObject(self, &key, locationManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CLLocationManager *)locationManager {
    return objc_getAssociatedObject(self, &key);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];

        SEL originalSelector = @selector(application:didFinishLaunchingWithOptions:);
        SEL swizzledSelector = @selector(xxx_application:didFinishLaunchingWithOptions:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (BOOL) xxx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    wasLaunchedByLocationManager = FALSE;

    if (launchOptions != nil) {
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            [self requestMoreBackgroundExecutionTime];
            wasLaunchedByLocationManager = TRUE;
        }
    }

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    if (wasLaunchedByLocationManager) {
        NSLog(@"didFinishLaunchingWithOptions: launched by location manager");
    } else {
        NSLog(@"didFinishLaunchingWithOptions: not launched by location manager");

        NSLog(@"didFinishLaunchingWithOptions: checking location authorization");
        [self.locationManager requestAlwaysAuthorization];

        NSLog(@"didFinishLaunchingWithOptions: checking notification authorization");
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:options completionHandler:nil];
    }

    NSLog(@"didFinishLaunchingWithOptions: start monitoring beacons");
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"58a78bf8-e280-48a4-8668-b8d8cf947cf8"];
    [self.locationManager startMonitoringForRegion:[[CLBeaconRegion alloc]
        initWithProximityUUID:uuid major:1 minor:64 identifier:water]];
    [self.locationManager startMonitoringForRegion:[[CLBeaconRegion alloc]
        initWithProximityUUID:uuid major:1 minor:32 identifier:pump]];

    return [self xxx_application:application didFinishLaunchingWithOptions:launchOptions];
}

- (UIBackgroundTaskIdentifier) backgroundTaskIdentifier {
    NSNumber *asNumber = objc_getAssociatedObject(self, @selector(backgroundTaskIdentifier));
    UIBackgroundTaskIdentifier  taskId = [asNumber unsignedIntValue];
    return taskId;
}

- (void)setBackgroundTaskIdentifier:(UIBackgroundTaskIdentifier)backgroundTaskIdentifier {
    NSNumber *asNumber = [NSNumber numberWithUnsignedInt:backgroundTaskIdentifier];
    objc_setAssociatedObject(self, @selector(backgroundTaskIdentifier), asNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) requestMoreBackgroundExecutionTime {

    UIApplication *application = [UIApplication sharedApplication];

    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"didDetermineState: %i %@", state, region);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion: %@", region);

    if (!wasLaunchedByLocationManager) {
        NSLog(@"Ignoring beacons.");
        return;
    }

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];

    if ([region.identifier isEqualToString:water]) {
        NSLog(@"Found WATER beacon.");
        content.title = @"Low Water Level";
        content.body = @"Please refill the water tank.";
    } else if ([region.identifier isEqualToString:pump]) {
        NSLog(@"Found PUMP beacon.");
        content.title = @"Pump Failure";
        content.body = @"Please check the pump.";
    }

    UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];

    UNNotificationRequest *notificationRequest =
        [UNNotificationRequest requestWithIdentifier:region.identifier content:content trigger:trigger];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removePendingNotificationRequestsWithIdentifiers: @[region.identifier]];
    [center addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"didEnterRegion: notification failed");
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion: %@", region);

    if ([region.identifier isEqualToString:water]) {
        NSLog(@"Lost WATER beacon.");
    } else if ([region.identifier isEqualToString:pump]) {
        NSLog(@"Lost PUMP beacon.");
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion: %@", region);

    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@", region);
}

@end
