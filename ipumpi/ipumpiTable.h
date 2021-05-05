//                             _____     _     _
//   _ __  _   _ _ __ ___  _ _|_   _|_ _| |__ | | ___
//  | '_ \| | | | '_ ` _ \| '_ \| |/ _` | '_ \| |/ _ \
//  | |_) | |_| | | | | | | |_) | | (_| | |_) | |  __/
//  | .__/ \__,_|_| |_| |_| .__/|_|\__,_|_.__/|_|\___|
//  |_|                   |_|
//
//  ipumpiDB.h
//  ipumpi
//
//  Created by Dave Scruton on 5/3/21
//  Copyright © 2021 ipumpi. All rights reserved.
//  Accesses parse class pumpTable

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ipumpiKeys.h"

@protocol ipumpiTableDelegate;


#define EMPTYPUMP @"empty"

@interface ipumpiTable : NSObject
{
    NSString *className;
    NSUUID *itemIdentifier;
}

@property (nonatomic , strong) NSString* name;
@property (nonatomic , strong) NSString* group;
@property (nonatomic , strong) NSString* serialNumber;
@property (nonatomic , strong) NSString* planter;
@property (nonatomic , strong) NSMutableArray* pumpObjects; //REDUNDANT, remove ASAP
@property (nonatomic , strong) NSMutableDictionary* pumpDict;

@property (nonatomic, unsafe_unretained) id <ipumpiTableDelegate> delegate;

+ (id)sharedInstance;
-(void) fillFieldsFromIndex: (int) index;
-(void) getNewSerialNumber;
-(void) readFromParse: (NSString*) group : (NSString*) name;
-(void) saveToParse;

@end


@protocol ipumpiTableDelegate <NSObject>
@required
@optional
- (void)didSavePumpToParse : (NSString *)serialNum;
- (void)errorSavingPumpToParse : (NSString *)err;
- (void)didReadPumpsFromParse;
- (void)errorReadingPumpsFromParse : (NSString *)err;
//- (void)didCompleteBatch;
//- (void)didFailBatch;
@end

