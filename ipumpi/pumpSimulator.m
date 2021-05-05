//
//  pumpSimulator.m
//  ipumpi
//
//  Created by Dave Scruton on 5/4/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import "pumpSimulator.h"


@implementation pumpSimulator

static pumpSimulator *sharedInstance = nil;

//=============(pumpSimulator)=====================================================
// Get the shared instance and create it if necessary.
+ (pumpSimulator *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

//=============(pumpSimulator)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        className        = @"pumpTable";
        _name            = EMPTYPUMPSIM;
        _serialNumber    = EMPTYPUMPSIM;
        _pumpState       = PUMPSTATE_STOPPED;
        _sensorState     = EMPTYPUMPSIM;
        _command         = EMPTYPUMPSIM;
        _commandDate     = [NSDate date];
        _lastCommandDate = [NSDate date];
        _lastOnTime      = [NSDate date];
        _lastOffTime     = [NSDate date];
        isPolling        = FALSE;
        
        //DEBUG TEST
        _serialNumber = @"ipumpi_E324C1F6-DEE2-445A-89C8-9890940E69F3";
        //we will look at our table repeatedly...
        pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLLINGINTERVAL target:self selector:@selector(pollTick:)                                                 userInfo:nil repeats:YES];
    }
    return self;
}


//=============(pumpSimulator)=====================================================
- (void)pollTick:(NSTimer *)ltimer
{
    if (isPolling) return;

    if ( [_serialNumber isEqualToString:EMPTYPUMPSIM] ) return; //bail on fail
    isPolling = TRUE;
    [self readFromParse];
    NSLog(@" polling for pump %@",_serialNumber);
//    if (needLikeUpdates)
//    {
//        [self extractUIDsFromPFObjects];
//        [workActivity loadMyRecentLikesFromParse : fbc.fbid : publicUIDs : privateUIDs : fappDelegate.privateMode];
//    }
    
    
} //end privateQueryTick


//=============(pumpSimulator)=====================================================
-(void) fillFieldsFromIndex: (int) index
{
//    if (index < 0 || index > _pumpObjects.count-1) return;
//    PFObject *pfo = _pumpObjects[index];
//    _name         = pfo[Pipumpi_group_key];
//    _group        = pfo[Pipumpi_name_key];
//    _serialNumber = pfo[Pipumpi_serialNumber_key];
//    _planter      = pfo[Pipumpi_planter_key];
//    _sensorState  = pfo[Pipumpi_sensorState_key];
//    _onOff        = pfo[Pipumpi_onOff_key];
//    _command      = pfo[Pipumpi_command_key];
//    _commandDate  = pfo[Pipumpi_commandDate_key];
} //end fillFieldsFromIndex

//=============(pumpSimulator)=====================================================
//  read one record for this pump. note error if more than one record found!
-(void) readFromParse
{
    PFQuery *query  = [PFQuery queryWithClassName:className];
    //User who created this record
    NSString *uname = @"empty";
    if ([PFUser currentUser] != nil) uname = [PFUser currentUser].username;
    else return; //NO user! BAIL!
    // look up by username and serial number
    [query whereKey:Pipumpi_serialNumber_key equalTo:_serialNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            if (objects.count > 1)
            {
                NSLog(@" ERROR: pump simulator read duplicate records");
            }
            //we are looking for a command...
            PFObject *pfo = objects[0];
            self->_command = pfo[Pipumpi_command_key];
            NSLog(@" ...read command %@",self->_command);
            [self handleCommand];
//            [self.delegate didReadPumpsFromParse];
         } //End !error
        else
        {
//            NSLog(@" ERROR: reading pumps: %@",error.localizedDescription);
//            [self.delegate errorReadingPumpsFromParse : error.localizedDescription];
        }
        self->isPolling = FALSE;   //OK to poll again...
    }]; //End findobjects

} //end readFromParse

//=============(pumpSimulator)=====================================================
-(void) saveToParse
{
//    PFObject *pfo = [PFObject objectWithClassName:className];
//    // pack up pump properties...
//    pfo[Pipumpi_name_key]          = _name;
//    pfo[Pipumpi_group_key]         = _group;
//    pfo[Pipumpi_serialNumber_key]  = _serialNumber;
//    pfo[Pipumpi_planter_key]       = _planter;
//    pfo[Pipumpi_sensorState_key]   = _sensorState;
//    pfo[Pipumpi_onOff_key]         = _onOff;
//    pfo[Pipumpi_command_key]       = _command;
//    pfo[Pipumpi_commandDate_key]   = _commandDate;
//
//    //User who created this record
//    NSString *uname = @"empty";  //DHS 2/14 add username column
//    if ([PFUser currentUser] != nil) uname = [PFUser currentUser].username;
//    else return; //NO user! BAIL!
//    pfo[Pipumpi_userName_key] = uname;
//
//    [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded)
//        {
//            //if (self->debugMode) NSLog(@" ...batch updated[%@]->parse",self->_batchID);
//            [self.delegate didSavePumpToParse:self->_serialNumber];
//        }
//        else
//        {
//            NSLog(@" ERROR: saving pump: %@",error.localizedDescription);
//            [self.delegate errorSavingPumpToParse : error.localizedDescription];
//        }
//    }]; //End save
}

//=============(pumpSimulator)=====================================================
-(void) startPump
{
    
}


//=============(pumpSimulator)=====================================================
-(void) stopPump
{
    
}

//=============(pumpSimulator)=====================================================
// sets internal vars to reflect command change.
//  also has to update DB to indicate command was accepted.
-(void) handleCommand
{
    if ( _command.length < 3 || [_command isEqualToString:EMPTYPUMPSIM] ) return; //bogus command / typo? bail
    if      ([_command isEqualToString:Cipumpi_command_start]) [self startPump];   //Start pump
    else if ([_command isEqualToString:Cipumpi_command_stop])  [self stopPump];    //Stop pump
}

@end
