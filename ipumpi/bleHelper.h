//
//  bleHelper.h
//  pumpie
//
//  Created by Dave Scruton on 11/18/20.
//  Copyright © 2020 lpumpi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface bleHelper : NSObject < CBCentralManagerDelegate, CBPeripheralDelegate>
{
    
}

@property (nonatomic, assign) BOOL poweredOn;
@property (nonatomic, strong) CBCentralManager *centralManager;

- (instancetype)init;
+ (id)sharedInstance;

-(void) scanForPeripherals;


@end

