//   _                             _  ____                                          _
//  (_)_ __  _   _ _ __ ___  _ __ (_)/ ___|___  _ __ ___  _ __ ___   __ _ _ __   __| |
//  | | '_ \| | | | '_ ` _ \| '_ \| | |   / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` |
//  | | |_) | |_| | | | | | | |_) | | |__| (_) | | | | | | | | | | | (_| | | | | (_| |
//  |_| .__/ \__,_|_| |_| |_| .__/|_|\____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|
//    |_|                   |_|
//
//  ipumpiCommand.m
//  ipumpi
//
//  Created by Dave Scruton on 5/3/21
//  Copyright © 2021 ipumpi. All rights reserved.
//  Accesses parse pumpStatus table, singleton!
//  This is used both by pump simulator to READ and by main app to WRITE
#import "ipumpiCommand.h"

@implementation ipumpiCommand


//=============(ipumpiCommand)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        className       = @"pumpCommand";
        _serialNumber   = EMPTYCOMMAND;
        _command        = EMPTYCOMMAND;
        _uuid           = EMPTYCOMMAND;
        lastUuid        = EMPTYCOMMAND;
        _polling        = FALSE;
    }
    return self;
}

//=============(ipumpiCommand)=====================================================
// read one Command record for pump
-(void) readFromParse 
{
    //NSLog(@" ipumpCommand readfromParse");
    PFQuery *query = [PFQuery queryWithClassName:className];
    _polling = TRUE;
    [query whereKey:Pipumpi_serialNumber_key equalTo:_serialNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self->_polling = FALSE;
        if (!error) { //Query came back...
            if (objects.count == 0)
            {
                [self.delegate didReadEmptyPumpCommandFromParse];
            }
            else{
                PFObject *pfo = objects[0]; //get first object and pull out Command
                self->_command = pfo[Pipumpi_command_key];
                NSString *cmdUuid = pfo[Pipumpi_uuid_key];
                //NSLog(@" got command...");
                //OPTIONAL: handler for NEW UUID
                if (![cmdUuid isEqualToString:self->lastUuid]) //New UUID --> new command!
                {
                    self->_uuid = cmdUuid;
                    //NSLog(@" call didReadPumpCommandFromParse del %@",self.delegate);
                    [self.delegate didReadPumpCommandFromParse:self->_uuid:self->_command];
                    self->lastUuid = cmdUuid; //save for next time
                }
            }
            if (objects.count > 1)
            {
                NSLog(@" ERROR: pump status read duplicate records s/n %@",self->_serialNumber);
            }
         } //End !error
        else //indicate error if needed
            [self.delegate errorReadingPumpCommandFromParse:self->_uuid:error.localizedDescription];
    }]; //End findobjects
} //end readFromParse

//=============(ipumpiCommand)=====================================================
// saves status to parse...
-(void) sendOLDCommandToParse : (NSString*) serialNum : (NSString *) newCommand
{
    PFObject *pfo = [PFObject objectWithClassName:className];
    // produce UUID for this record...
    itemIdentifier = [[NSUUID alloc] init];
    _uuid = [NSString stringWithFormat:@"ipumpicommand_%@",[itemIdentifier UUIDString]];
    // pack up pump properties... NOTE pump S/N must be set up FIRST!!!
    pfo[Pipumpi_serialNumber_key]  = serialNum  ;
    pfo[Pipumpi_command_key]       = newCommand;
    pfo[Pipumpi_uuid_key]          = _uuid;

    [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self.delegate didSendPumpCommandToParse:self->_uuid];
        }
        else
        {
            [self.delegate errorSendingPumpCommandToParse:self->_uuid:error.localizedDescription];
        }
    }]; //End save
} //end sendCommandToParse


//=============(ipumpiCommand)=====================================================
// Find existing command if any, replace with new command
-(void) sendCommandToParse : (NSString*) serialNum : (NSString *) newCommand
{
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:Pipumpi_serialNumber_key equalTo:serialNum];
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
                pfo[Pipumpi_serialNumber_key] = serialNum; //only init once!
            }
            pfo[Pipumpi_command_key]      = newCommand;
            self->itemIdentifier = [[NSUUID alloc] init];
            self-> _uuid = [NSString stringWithFormat:@"ipumpicmd_%@",[self->itemIdentifier UUIDString]];
            pfo[Pipumpi_uuid_key]   = self->_uuid;
            // OK save back to table...
            [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [self.delegate didSendPumpCommandToParse:self->_uuid];
                }
                else
                {
                    [self.delegate errorSendingPumpCommandToParse:self->_uuid:error.localizedDescription];
                }
            }]; //End save
       
        //[self saveToParse];  //saveit!
    } //End !error
     else
     {
         [self.delegate errorSendingPumpCommandToParse:self->_uuid:error.localizedDescription];
    }
}]; //End findobjects

} //end sendCommandToParse


@end
