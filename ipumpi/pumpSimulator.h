//
//  pumpSimulator.h
//  ipumpi
//
//  Created by Dave Scruton on 5/4/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ipumpiCommand.h"
#import "ipumpiStatus.h"
#import "ipumpiKeys.h"
@protocol pumpSimulatorDelegate;

#define EMPTYPUMPSIM @"empty"
#define POLLINGINTERVAL 10.0    //seconds
 
#define PUMPSTATE_STOPPED @"psStopped"
#define PUMPSTATE_RUNNING @"psRunning"
#define PUMPSTATE_ERROR   @"psError"

@interface pumpSimulator : NSObject <ipumpiCommandDelegate,ipumpiStatusDelegate>
{
    NSString *className;
    NSString *commandClassName;
    NSTimer *pollTimer;
    NSString *lastCmdUuid;
    NSString *lastStaUuid;
    // hooks to the DB
    ipumpiCommand *icmd;
    ipumpiStatus  *ista;
    BOOL statusRunning;
    BOOL wasPumpRunning;
    NSTimer *commandTimer;
    NSTimer *runTimer;
    NSTimer *statusTimer;
    int statusSubCount;
    NSString *oldUuid;
    NSArray* startCommands;
    NSString *internalSN;
//    NSUUID *itemIdentifier;
}

@property (nonatomic , strong) NSString* name;
@property (nonatomic , strong) NSString* serialNumber;
@property (nonatomic , strong) NSString* pumpState;
@property (nonatomic , strong) NSString* sensorState;
@property (nonatomic , strong) NSString* command;
@property (nonatomic , strong) NSString* uuid;
@property (nonatomic , strong) NSDate*   commandDate;
@property (nonatomic , strong) NSString* lastCommand;
@property (nonatomic , strong) NSDate*   lastCommandDate;
@property (nonatomic , strong) NSDate*   lastOnTime;
@property (nonatomic , strong) NSDate*   lastOffTime;
@property (nonatomic , strong) NSDate*   stopTime;

@property (nonatomic, assign) int timeLeft;

@property (nonatomic, unsafe_unretained) id <pumpSimulatorDelegate> delegate;

-(void) getNextCommand : (NSString *)sn;
-(void) startPolling;
-(void) startStatus;
-(void) stopPolling;
-(pumpSimulator *) copy;


@end


@protocol pumpSimulatorDelegate <NSObject>
@required
@optional
-(void) didReadPumpCommandFromSimulator: (NSString*) sn  : (NSString*) command;
@end
