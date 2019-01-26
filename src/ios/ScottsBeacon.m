#import "ScottsBeacon.h"

@implementation ScottsBeacon {

}

# pragma mark CDVPlugin

- (void)pluginInitialize {
    NSLog(@"pluginInitialize");
}

- (void)initializeScottsBeacon:(CDVInvokedUrlCommand*)command {
    NSLog(@"initializeScottsBeacon");

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
