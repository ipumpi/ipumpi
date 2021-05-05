//   _                             _ ____  _        _
//  (_)_ __  _   _ _ __ ___  _ __ (_) ___|| |_ __ _| |_ _   _ ___
//  | | '_ \| | | | '_ ` _ \| '_ \| \___ \| __/ _` | __| | | / __|
//  | | |_) | |_| | | | | | | |_) | |___) | || (_| | |_| |_| \__ \
//  |_| .__/ \__,_|_| |_| |_| .__/|_|____/ \__\__,_|\__|\__,_|___/
//    |_|                   |_|
//
//  ipumpiStatus.h
//  ipumpi
//
//  Created by Dave Scruton on 5/3/21
//  Copyright © 2021 ipumpi. All rights reserved.
//  Accesses parse pumpStatus table

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ipumpiKeys.h"

@protocol ipumpiStatusDelegate;

#define EMPTYSTATUS @"emptystatus"

@interface ipumpiStatus : NSObject
{
    NSString *className;
    NSUUID *itemIdentifier;
}

@property (nonatomic , strong) NSString* serialNumber;
@property (nonatomic , strong) NSString* status;
@property (nonatomic , strong) NSString* sensorState;
@property (nonatomic , strong) NSString* uuid;

@property (nonatomic, unsafe_unretained) id <ipumpiStatusDelegate> delegate;

+ (id)sharedInstance;
-(void) readFromParse: (NSString*) group : (NSString*) name;
-(void) saveToParse;
-(void) updateStatusAndSensorState : (NSString*) serialNum : (NSString *) newStatus : (NSString *) newSensorState;

@end


@protocol ipumpiStatusDelegate <NSObject>
@required
@optional
- (void)didSavePumpStatusToParse : (NSString *)uuid;
- (void)errorSavingPumpStatusToParse : (NSString *)uuid : (NSString *)err;
- (void)didReadPumpStatusFromParse : (NSString *)uuid : (NSString *)status;
- (void)errorReadingPumpStatusFromParse : (NSString *)uuid : (NSString *)err;
- (void)didReadEmptyPumpStatusFromParse;
- (void)didUpdatePumpStatusAndSensorState : (NSString *)uuid;
- (void)errorUpdatingPumpStatusAndSensorState  : (NSString *)uuid : (NSString *)err;
@end

