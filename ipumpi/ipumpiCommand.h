//   _                             _  ____                                          _
//  (_)_ __  _   _ _ __ ___  _ __ (_)/ ___|___  _ __ ___  _ __ ___   __ _ _ __   __| |
//  | | '_ \| | | | '_ ` _ \| '_ \| | |   / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` |
//  | | |_) | |_| | | | | | | |_) | | |__| (_) | | | | | | | | | | | (_| | | | | (_| |
//  |_| .__/ \__,_|_| |_| |_| .__/|_|\____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|
//    |_|                   |_|
//
//  ipumpiCommand.h
//  ipumpi
//
//  Created by Dave Scruton on 5/3/21
//  Copyright © 2021 ipumpi. All rights reserved.
//  Accesses parse pumpCommand table

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ipumpiKeys.h"

@protocol ipumpiCommandDelegate;

#define EMPTYCOMMAND @"emptycommand"

//Immediate pump start commands, with time limits
static NSString *PC_START1MIN  = @"START1MIN";
static NSString *PC_START5MIN  = @"START5MIN";
static NSString *PC_START10MIN = @"START10MIN";

//Immediate pump stop
static NSString *PC_STOP  = @"STOP";

//Get sensor reading now
static NSString *READSENSORS  = @"readsensors";
//Load up new schedule from pump table
static NSString *NEWSCHEDULE  = @"newschedule";

@interface ipumpiCommand : NSObject
{
    NSString *className;
    NSUUID *itemIdentifier;
    NSString *lastUuid;
}

@property (nonatomic , strong) NSString* serialNumber;
@property (nonatomic , strong) NSString* command;
@property (nonatomic , strong) NSString* uuid;
@property (nonatomic, assign) BOOL polling;

@property (nonatomic, unsafe_unretained) id <ipumpiCommandDelegate> delegate;

-(void) readFromParse ;
-(void) sendCommandToParse : (NSString*) serialNum : (NSString *) newCommand;

@end


@protocol ipumpiCommandDelegate <NSObject>
@required
@optional
- (void)didSendPumpCommandToParse : (NSString *)uuid;
- (void)errorSendingPumpCommandToParse : (NSString *)uuid : (NSString *)err;
- (void)didReadPumpCommandFromParse : (NSString *)uuid : (NSString *)Command;
- (void)errorReadingPumpCommandFromParse : (NSString *)uuid : (NSString *)err;
- (void)didReadEmptyPumpCommandFromParse;
@end

