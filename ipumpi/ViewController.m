//
//  ViewController.m
//  pumpie
//
//  Created by Dave Scruton on 11/17/20.
//  Copyright © 2020 lpumpi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//==========MainVC=========================================================================
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ( (self = [super initWithCoder:aDecoder]) )
    {
        // 7/11 moved here
//        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        ble = [bleHelper sharedInstance];

        bstatus = @"starting bluetooth...";
        pstatus = @"";

        [[NSNotificationCenter defaultCenter]
                         addObserver: self selector:@selector(bleUpdatedState:)
                                name: @"bleUpdatedState" object:nil];
        [[NSNotificationCenter defaultCenter]
                         addObserver: self selector:@selector(bleDiscovered:)
                                name: @"bleDiscovered" object:nil];

    }
    return self;
    
} //end initWithCoder


//==========MainVC=========================================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//==========MainVC=========================================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


//==========MainVC=========================================================================
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self testsaveToParse];
    [self updateView];
}

//====bleHelper notifications=====================================================
-(void) updateView
{
    _topLabel.text    = bstatus;
    _bottomLabel.text = pstatus;
}

//====bleHelper notifications=====================================================
// called when bleHelpers centralManagerDidUpdateState
- (void)bleUpdatedState:(NSNotification *)notification
{
    NSLog(@" bleUpdatedState...");
    if (ble.poweredOn)
    {
        NSLog(@" OK! bluetooth power on");
        bstatus = @"BlueTooth powered on";
        [ble scanForPeripherals]; //go get peripherals!
    }
    else
    {
        NSLog(@" ERROR: cannot connect to bluetooth");
        bstatus = @"BlueTooth ERROR";
    }
    [self updateView];
}


//====bleHelper notifications=====================================================
- (void)bleDiscovered:(NSNotification *)notification
{
    
    NSString *peripheralName = [[notification userInfo] objectForKey:@"peripheralName"];
    pstatus = peripheralName;
    [self updateView];
}

-(void) testsaveToParse
{
    PFObject *testRecord = [PFObject objectWithClassName:@"test"];

    
    testRecord[@"score"]   = [NSNumber numberWithInteger : 123];
    testRecord[@"name"]    = @"davesky";

    [testRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@" ok! saved");
        } else {
            NSLog(@" ERROR: saving to parse!");
        }
    }];
    
} //end saveToParse



@end
