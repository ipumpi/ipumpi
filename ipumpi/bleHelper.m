//
//  bleHelper.m
//  pumpie
//
//  Created by Dave Scruton on 11/18/20.
//  Copyright © 2020 lpumpi. All rights reserved.
//

#import "bleHelper.h"

@implementation bleHelper

static bleHelper *sharedInstance = nil;

//=====(bleHelper)======================================================================
// Get the shared instance and create it if necessary.
+ (bleHelper *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}


//=====(bleHelper)======================================================================
-(instancetype) init
{
    if (self = [super init])
    {
        //Top level session stats : count / time
//        [self clear];
        //Set up central manager...
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _poweredOn = FALSE;
    }
    return self;
} //end init


//=====(bleHelper)======================================================================
-(void) scanForPeripherals
{
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
}


#pragma CBCentralManagerDelegate

//======<CBCentralManagerDelegate>================================================
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    _poweredOn = TRUE;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bleUpdatedState" object:nil
                                                      userInfo:nil];

}


//======<CBCentralManagerDelegate>================================================
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
     
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    NSDictionary *reportDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      peripheral.name,@"peripheralName", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bleDiscovered" object:nil userInfo:reportDictionary];


//    if (_discoveredPeripheral != peripheral) {
//        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
//        _discoveredPeripheral = peripheral;
//         
//        // And connect
//        NSLog(@"Connecting to peripheral %@", peripheral);
//        [_centralManager connectPeripheral:peripheral options:nil];
//    }
}
@end
