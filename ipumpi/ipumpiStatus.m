//   _                             _ ____  _        _
//  (_)_ __  _   _ _ __ ___  _ __ (_) ___|| |_ __ _| |_ _   _ ___
//  | | '_ \| | | | '_ ` _ \| '_ \| \___ \| __/ _` | __| | | / __|
//  | | |_) | |_| | | | | | | |_) | |___) | || (_| | |_| |_| \__ \
//  |_| .__/ \__,_|_| |_| |_| .__/|_|____/ \__\__,_|\__|\__,_|___/
//    |_|                   |_|
//
//  ipumpiStatus.m
//  ipumpi
//
//  Created by Dave Scruton on 5/3/21
//  Copyright © 2021 ipumpi. All rights reserved.
//  Accesses parse pumpStatus table, singleton!
//  This is used both by pump simulator to WRITE and by main app to READ
#import "ipumpiStatus.h"

@implementation ipumpiStatus

static ipumpiStatus *sharedInstance = nil;

//=============(ipumpiStatus)=====================================================
// Get the shared instance and create it if necessary.
+ (ipumpiStatus *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

//=============(ipumpiStatus)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        className       = @"pumpStatus";
        _serialNumber   = EMPTYSTATUS;
        _status         = EMPTYSTATUS;
        _uuid           = EMPTYSTATUS;
        _secondsLeft    = 0;
    }
    return self;
}


//=============(ipumpiStatus)=====================================================
// read one status record for pump
-(void) readFromParse  : (NSString*) sn
{
    PFQuery *query = [PFQuery queryWithClassName:className];
//    [query whereKey:Pipumpi_serialNumber_key equalTo:_serialNumber];
    [query whereKey:Pipumpi_serialNumber_key equalTo:sn];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            if (objects.count == 0)
            {
                [self.delegate didReadEmptyPumpStatusFromParse];
            }
            else{
                PFObject *pfo      = objects[0]; //get first object and pull out status
                self->_status      = pfo[Pipumpi_status_key];
                self->_sensorState = pfo[Pipumpi_sensorState_key];
                [self.delegate didReadPumpStatusFromParse:sn:self->_status:self->_sensorState];
            }
            if (objects.count > 1)
            {
                NSLog(@" ERROR: pump status read duplicate records s/n %@",self->_serialNumber);
            }
         } //End !error
        else //indicate error if needed
            [self.delegate errorReadingPumpStatusFromParse:self->_uuid:error.localizedDescription];
    }]; //End findobjects
} //end readFromParse

//=============(ipumpiStatus)=====================================================
// saves status to parse...
-(void) saveToParse
{
    PFObject *pfo = [PFObject objectWithClassName:className];
    // produce UUID for this record...
    itemIdentifier = [[NSUUID alloc] init];
    _uuid = [NSString stringWithFormat:@"ipumpistatus_%@",[itemIdentifier UUIDString]];
    // pack up pump properties... NOTE pump S/N must be set up FIRST!!!
    pfo[Pipumpi_serialNumber_key]  = _serialNumber;
    pfo[Pipumpi_status_key]        = _status;
    pfo[Pipumpi_sensorState_key]   = _sensorState;
    pfo[Pipumpi_uuid_key]          = _uuid;

    [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self.delegate didSavePumpStatusToParse:self->_uuid];
        }
        else
        {
            [self.delegate errorSavingPumpStatusToParse:self->_uuid:error.localizedDescription];
        }
    }]; //End save
} //end saveToParse

//=============(ipumpiStatus)=====================================================
// Find pump record, update, replace sensorState and/or status field
-(void) updateStatusAndSensorState : (NSString*) serialNum : (NSString *) newStatus : (NSString *) newSensorState
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:Pipumpi_serialNumber_key equalTo:_serialNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            PFObject *pfo;
            if (objects.count != 0) //must be something there to update...
            {
                pfo = objects[0]; //get first object and pull out status
            }
            else //nu8thin?
            {
                pfo = [PFObject objectWithClassName:self->className];
                pfo[Pipumpi_serialNumber_key] = self->_serialNumber; //only init once!
                pfo[Pipumpi_status_key]      = EMPTYSTATUS;
                pfo[Pipumpi_sensorState_key] = EMPTYSTATUS;
            }
            if (![newStatus isEqualToString:EMPTYSTATUS])  // update status if needed
                pfo[Pipumpi_status_key] = newStatus;
            if (![newSensorState isEqualToString:EMPTYSTATUS])  // update status if needed
                pfo[Pipumpi_sensorState_key] = newSensorState;
            NSLog(@"...dump status %@ sensor %@",pfo[Pipumpi_status_key],pfo[Pipumpi_sensorState_key]);
            self->itemIdentifier = [[NSUUID alloc] init];
            self-> _uuid = [NSString stringWithFormat:@"ipumpista_%@",[self->itemIdentifier UUIDString]];
            pfo[Pipumpi_uuid_key]   = self->_uuid;
            // OK save back to table...
            [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [self.delegate didUpdatePumpStatusAndSensorState:self->_uuid];
                }
                else
                {
                    [self.delegate errorUpdatingPumpStatusAndSensorState : self->_uuid : error.localizedDescription];
                }
            }]; //End save
       
        //[self saveToParse];  //saveit!
    } //End !error
     else
     {
        [self.delegate errorUpdatingPumpStatusAndSensorState  : self->_uuid : error.localizedDescription];
    }
}]; //End findobjects

} //end updateStatusAndSensorState


@end
