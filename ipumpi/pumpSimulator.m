//
//  pumpSimulator.m
//  ipumpi
//
//  Created by Dave Scruton on 5/4/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import "pumpSimulator.h"


@implementation pumpSimulator


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
        oldUuid          = EMPTYPUMPSIM;
        //DB hookups
        icmd = [[ipumpiCommand alloc] init];
        icmd.delegate = self;
        ista = [[ipumpiStatus  alloc] init];
        ista.delegate = self;
        lastCmdUuid = @"";
        lastStaUuid = @"";
        // we have multiple start commmands
        startCommands = @[PC_START1MIN,PC_START5MIN,PC_START10MIN];
    }
    return self;
}

//=============(pumpSimulator)=====================================================
-(pumpSimulator *) copy
{
    pumpSimulator *result = [[pumpSimulator alloc] init];
    result->className        = className;
    result.name        = _name;
    result.serialNumber        = _serialNumber;
    result.pumpState        = _pumpState;
    result.sensorState        = _sensorState;
    result.command        = _command;
    result.commandDate        = _commandDate;
    result.lastCommandDate        = _lastCommandDate;
    result.lastOnTime        = _lastOnTime;
    result.lastOffTime        = _lastOffTime;
    return result;
} //end copy


//=============(pumpSimulator)=====================================================
-(void) startPolling
{
    // we will look at our table repeatedly...
    commandTimer = [NSTimer scheduledTimerWithTimeInterval:POLLINGINTERVAL target:self selector:@selector(commandTick:)                                                 userInfo:nil repeats:YES];
}
//=============(pumpSimulator)=====================================================
-(void) stopPolling
{
    if (commandTimer == nil) return;
    [commandTimer invalidate];
}


//=============(pumpSimulator)=====================================================
// get new commands, on return check if we have a NEW command by looking at the uuid
-(void) getNextCommand
{
    icmd.serialNumber = _serialNumber; //send sn down to command...
    [icmd readFromParse];
}

//=============(pumpSimulator)=====================================================
- (void)commandTick:(NSTimer *)ltimer
{
    if (icmd.polling) return;
    //NSLog(@"self %@ cmd sn %@ ",self,_serialNumber);
    if ( [_serialNumber isEqualToString:EMPTYPUMPSIM] ) return; //bail on fail
    [self getNextCommand];
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
-(void) readPumpRecordFromParse
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
//            [self.delegate didReadPumpsFromParse];
         } //End !error
        else
        {
//            NSLog(@" ERROR: reading pumps: %@",error.localizedDescription);
//            [self.delegate errorReadingPumpsFromParse : error.localizedDescription];
        }
    }]; //End findobjects

} //end readPumpRecordFromParse

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
// set up vars to simulate a running pump
-(void) startPump
{
    NSLog(@" -------starting pump %@",_serialNumber);
    _timeLeft = 0;
    if ([_command isEqualToString:PC_START1MIN])
        _timeLeft = 60;
    else if ([_command isEqualToString:PC_START5MIN])
        _timeLeft = 300;
    else if ([_command isEqualToString:PC_START10MIN])
        _timeLeft = 600;
    
    
    if (runTimer != nil) [runTimer invalidate];
    runTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runTick:)                                                 userInfo:nil repeats:YES];
    _pumpState = PUMPSTATE_RUNNING; //Just reflect command for now in output state
    NSDate *rightNow = [NSDate date];
    _lastOnTime      = rightNow;
    _lastCommandDate = rightNow;
    // this is when we will finish
    _stopTime        = [rightNow dateByAddingTimeInterval:_timeLeft];

    NSDateFormatter *dformatter   =  [[NSDateFormatter alloc] init]; //9/11
    [dformatter setDateFormat:@"EEEE, MM/d/YYYY h:mm:ssa"];
    NSString *dstr1 = [dformatter stringFromDate:rightNow];
    NSString *dstr2 = [dformatter stringFromDate:_stopTime];
    NSLog(@" start/stop %@ %@",dstr1,dstr2);

    

} // end startPump

//=============(pumpSimulator)=====================================================
// set up vars to simulate a running pump
-(void) stopPump
{
    NSLog(@" -------stopping pump %@",_serialNumber);
    if (runTimer != nil) [runTimer invalidate];
    _timeLeft = 0;
    _pumpState = PUMPSTATE_STOPPED;
    NSDate *rightNow = [NSDate date];
    _lastOffTime     = rightNow;
    _lastCommandDate = rightNow;
} //end stopPump

//=============(pumpSimulator)=====================================================
// ticks off pump run time ...
- (void)runTick:(NSTimer *)ltimer
{
   _timeLeft--;
   if ( _timeLeft <= 0 || ![_pumpState isEqualToString:PUMPSTATE_RUNNING])
   {
       [self stopPump];   //Make sure pump is STOPPED
   }
   //NSLog(@" -------[%@] time[%d] %@",self,_timeLeft,_serialNumber );

} //end privateQueryTick


//=============(pumpSimulator)=====================================================
// sets internal vars to reflect command change.
//  also has to update DB to indicate command was accepted.
-(void) handleCommand
{
    NSString *stopit = PC_STOP; //FIX THIS!
    if ( _command.length < 3 || [_command isEqualToString:EMPTYPUMPSIM] ) return; //bogus command / typo? bail
    if ( [_uuid isEqualToString:oldUuid] ) return; //Dupe? no action
    if      ([startCommands indexOfObject:_command] != NSNotFound) //valid start commmand
        [self startPump];
    else if ([_command isEqualToString:PC_STOP])  [self stopPump];    //Stop pump
    _lastCommand = _command; //remember command...
    oldUuid = _uuid; //save uuid tracker
}


#pragma ipumpiCommandDelegate
//=============<ipumpiCommandDelegate>====================================================
- (void)didSendPumpCommandToParse : (NSString *)uuid
{
    
}

//=============<ipumpiCommandDelegate>====================================================
- (void)errorSendingPumpCommandToParse : (NSString *)uuid : (NSString *)err
{
    
}

//=============<ipumpiCommandDelegate>====================================================
// returned only when command objects sees a NEW command w/ new uuid!
- (void)didReadPumpCommandFromParse : (NSString *)uuid : (NSString *)Command
{
    //pass on to delegateVC...
    self->_command = Command;
    self->_uuid    = uuid;
    [self handleCommand];
}

//=============<ipumpiCommandDelegate>====================================================
- (void)errorReadingPumpCommandFromParse : (NSString *)uuid : (NSString *)err
{
}

//=============<ipumpiCommandDelegate>====================================================
- (void)didReadEmptyPumpCommandFromParse
{
    
}



@end
