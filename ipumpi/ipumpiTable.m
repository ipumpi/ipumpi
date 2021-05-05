//                             _____     _     _
//   _ __  _   _ _ __ ___  _ _|_   _|_ _| |__ | | ___
//  | '_ \| | | | '_ ` _ \| '_ \| |/ _` | '_ \| |/ _ \
//  | |_) | |_| | | | | | | |_) | | (_| | |_) | |  __/
//  | .__/ \__,_|_| |_| |_| .__/|_|\__,_|_.__/|_|\___|
//  |_|                   |_|
//
//  pumpTable.m
//  ipumpi
//
//  Created by Dave Scruton on 5/3/21
//  Copyright © 2021 ipumpi. All rights reserved.
//
//  Accesses parse pumpTable, singleton!
//  NOTE sensor state / pump status are in ipumpiStatus
#import "ipumpiTable.h"

@implementation ipumpiTable

static ipumpiTable *sharedInstance = nil;

//=============(pumpTable)=====================================================
// Get the shared instance and create it if necessary.
+ (ipumpiTable *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

//=============(pumpTable)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        className       = @"pumpTable";
        _name           = EMPTYPUMP;
        _group          = EMPTYPUMP;
        _serialNumber   = EMPTYPUMP;
        _planter        = EMPTYPUMP;
        _pumpObjects    = [[NSMutableArray alloc] init];
        _pumpDict       = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//=============(pumpTable)=====================================================
-(void) getNewSerialNumber
{
    itemIdentifier = [[NSUUID alloc] init];
    _serialNumber = [NSString stringWithFormat:@"ipumpi_%@",[itemIdentifier UUIDString]];
}

//=============(pumpTable)=====================================================
-(void) fillFieldsFromIndex: (int) index
{
    if (index < 0 || index > _pumpObjects.count-1) return;
    PFObject *pfo = _pumpObjects[index];
    _name         = pfo[Pipumpi_group_key];
    _group        = pfo[Pipumpi_name_key];
    _serialNumber = pfo[Pipumpi_serialNumber_key];
    _planter      = pfo[Pipumpi_planter_key];
} //end fillFieldsFromIndex

//=============(pumpTable)=====================================================
// read by group or by individual pump name, set both to nil to read all
-(void) readFromParse: (NSString*) group : (NSString*) name
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    //User who created this record
    NSString *uname = @"empty";  //DHS 2/14 add username column
    if ([PFUser currentUser] != nil) uname = [PFUser currentUser].username;
    else return; //NO user! BAIL!
    // only for this user!
    [query whereKey:Pipumpi_userName_key equalTo:uname];
    if (group != nil) [query whereKey:Pipumpi_group_key equalTo:group];
    if (name  != nil) [query whereKey:Pipumpi_name_key  equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            [self->_pumpObjects removeAllObjects];  //remove/add new stuff...
            [self->_pumpDict removeAllObjects];
            for (PFObject *pfo in objects)
            {
                [self->_pumpObjects addObject:pfo]; //toss this?
                NSString *sn = pfo[Pipumpi_serialNumber_key];
                self->_pumpDict[sn] = pfo;
            }
            [self.delegate didReadPumpsFromParse];
         } //End !error
        else
        {
            NSLog(@" ERROR: reading pumps: %@",error.localizedDescription);
            [self.delegate errorReadingPumpsFromParse : error.localizedDescription];
        }
    }]; //End findobjects

} //end readFromParse

//=============(pumpTable)=====================================================
-(void) saveToParse
{
    PFObject *pfo = [PFObject objectWithClassName:className];
    // pack up pump properties...
    pfo[Pipumpi_name_key]          = _name;
    pfo[Pipumpi_group_key]         = _group;
    pfo[Pipumpi_serialNumber_key]  = _serialNumber;
    pfo[Pipumpi_planter_key]       = _planter;

    //User who created this record
    NSString *uname = @"empty";  //DHS 2/14 add username column
    if ([PFUser currentUser] != nil) uname = [PFUser currentUser].username;
    else return; //NO user! BAIL!
    pfo[Pipumpi_userName_key] = uname;

    [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            //if (self->debugMode) NSLog(@" ...batch updated[%@]->parse",self->_batchID);
            [self.delegate didSavePumpToParse:self->_serialNumber];
        }
        else
        {
            NSLog(@" ERROR: saving pump: %@",error.localizedDescription);
            [self.delegate errorSavingPumpToParse : error.localizedDescription];
        }
    }]; //End save
} //end saveToParse



@end
