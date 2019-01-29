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

        SEL originalDFLWOSelector = @selector(application:didFinishLaunchingWithOptions:);
        SEL swizzledDFLWOSelector = @selector(xxx_application:didFinishLaunchingWithOptions:);
        Method originalDFLWOMethod = class_getInstanceMethod(class, originalDFLWOSelector);
        Method swizzledDFLWOMethod = class_getInstanceMethod(class, swizzledDFLWOSelector);
        BOOL didAddMethodDFLWO = class_addMethod(class, originalDFLWOSelector, method_getImplementation(swizzledDFLWOMethod), method_getTypeEncoding(swizzledDFLWOMethod));
        if (didAddMethodDFLWO) {
            class_replaceMethod(class, swizzledDFLWOSelector, method_getImplementation(originalDFLWOMethod), method_getTypeEncoding(originalDFLWOMethod));
        } else {
            method_exchangeImplementations(originalDFLWOMethod, swizzledDFLWOMethod);
        }

        SEL originalAWEFSelector = @selector(applicationWillEnterForeground:);
        SEL swizzledAWEFSelector = @selector(xxx_applicationWillEnterForeground:);
        Method originalAWEFMethod = class_getInstanceMethod(class, originalAWEFSelector);
        Method swizzledAWEFMethod = class_getInstanceMethod(class, swizzledAWEFSelector);
        BOOL didAddMethodAWEF = class_addMethod(class, originalAWEFSelector, method_getImplementation(swizzledAWEFMethod), method_getTypeEncoding(swizzledAWEFMethod));
        if (didAddMethodAWEF) {
            class_replaceMethod(class, swizzledAWEFSelector, method_getImplementation(originalAWEFMethod), method_getTypeEncoding(originalAWEFMethod));
        } else {
            method_exchangeImplementations(originalAWEFMethod, swizzledAWEFMethod);
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

    if (wasLaunchedByLocationManager) {
        return TRUE;
    } else {
        return [self xxx_application:application didFinishLaunchingWithOptions:launchOptions];
    }
}

- (void)xxx_applicationWillEnterForeground:(UIApplication *)application {
    if (wasLaunchedByLocationManager) {
        NSLog(@"applicationWillEnterForeground: launched by location manager");
        wasLaunchedByLocationManager = FALSE;
        [self xxx_application:application didFinishLaunchingWithOptions:nil];
    } else {
        NSLog(@"applicationWillEnterForeground: not launched by location manager");
    }

    [self xxx_applicationWillEnterForeground:application];
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
