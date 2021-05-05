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

@interface ipumpiCommand : NSObject
{
    NSString *className;
    NSUUID *itemIdentifier;
}

@property (nonatomic , strong) NSString* serialNumber;
@property (nonatomic , strong) NSString* command;
@property (nonatomic , strong) NSString* uuid;

@property (nonatomic, unsafe_unretained) id <ipumpiCommandDelegate> delegate;

+ (id)sharedInstance;
-(void) readFromParse: (NSString*) group : (NSString*) name;
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

