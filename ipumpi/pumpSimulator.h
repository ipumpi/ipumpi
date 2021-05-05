//
//  pumpSimulator.h
//  ipumpi
//
//  Created by Dave Scruton on 5/4/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ipumpiCommands.h"
#import "ipumpiKeys.h"
@protocol pumpSimulatorDelegate;

#define EMPTYPUMPSIM @"empty"
#define POLLINGINTERVAL 10.0    //seconds
 
#define PUMPSTATE_STOPPED @"psStopped"
#define PUMPSTATE_RUNNING @"psRunning"
#define PUMPSTATE_ERROR   @"psError"

@interface pumpSimulator : NSObject
{
    NSString *className;
    NSTimer *pollTimer;
    BOOL isPolling;
//    NSUUID *itemIdentifier;
}

@property (nonatomic , strong) NSString* name;
@property (nonatomic , strong) NSString* serialNumber;
@property (nonatomic , strong) NSString* pumpState;
@property (nonatomic , strong) NSString* sensorState;
@property (nonatomic , strong) NSString* command;
@property (nonatomic , strong) NSDate*   commandDate;
@property (nonatomic , strong) NSString* lastCommand;
@property (nonatomic , strong) NSDate*   lastCommandDate;
@property (nonatomic , strong) NSDate*   lastOnTime;
@property (nonatomic , strong) NSDate*   lastOffTime;

@property (nonatomic, unsafe_unretained) id <pumpSimulatorDelegate> delegate;

+ (id)sharedInstance;
//-(void) fillFieldsFromIndex: (int) index;
//-(void) getNewSerialNumber;
//-(void) readFromParse: (NSString*) group : (NSString*) name;
//-(void) saveToParse;
//-(void) updateSensorState : (NSString*) serialNum : (NSString *) newState;

@end


@protocol pumpSimulatorDelegate <NSObject>
@required
@optional
//pumpSimulatorDelegate@end
@end
