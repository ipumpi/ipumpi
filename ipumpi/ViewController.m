//                   _    __     ______
//   _ __ ___   __ _(_)_ _\ \   / / ___|
//  | '_ ` _ \ / _` | | '_ \ \ / / |
//  | | | | | | (_| | | | | \ V /| |___
//  |_| |_| |_|\__,_|_|_| |_|\_/  \____|
//
//  ViewController.m
//  pumpie
//
//  Created by Dave Scruton on 11/17/20.
//  Copyright © 2020 lpumpi. All rights reserved.
//
//  LINKS
//   https://stackoverflow.com/questions/27216003/working-with-bluetooth-in-objective-c
//
//  1/21 add navbar
// dimitrishein@gmail.com
//   Pumpie2020!

// Schedule format:
//   MON:04:30DUR60   =  monday 4:30 am for 60 seconds
//   FRI:13:00DUR180  =  friday 1:00 pm for 3 minutes
//   ALL:06:00DUR240  =  7 days a week 6 am for 4 minutes
//  maybe weekday / weekend too?
//  For pumpSimVC: make pumps last from session to session?
//     once that is done then its time for the front end to start/stop pumps
//  ALSO! dont forget that the simulators need to update the STATUS table too!!!

#import "AppDelegate.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


AppDelegate *appDelegate;

//==========MainVC=========================================================================
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ( (self = [super initWithCoder:aDecoder]) )
    {
        // 7/11 moved here
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        _sfx         = [soundFX sharedInstance];

        ble = [bleHelper sharedInstance];
        
        //stubbed serial numvers
        sns  = [stubSNs sharedInstance];

        pt  = [ipumpiTable sharedInstance]; //5/3 DB handle to ipumpiTable
        pt.delegate = self;
        
        bstatus = @"starting bluetooth...";
        pstatus = @"";
        
        //Simulator VC
        psvc = [[pumpSimVC alloc] init];
        psvc.modalPresentationStyle = UIModalPresentationFullScreen;

        //Control VC
        pcvc = [[pumpControlVC alloc] init];
        pcvc.modalPresentationStyle = UIModalPresentationFullScreen;

        NSString *snz = @"";
        for (int i=0;i<32;i++)
        {
            NSUUID *id = [[NSUUID alloc] init];
            NSString *sn = [NSString stringWithFormat:@"ipumpi_%@",[id UUIDString]];
            snz = [snz stringByAppendingString:sn];
            snz = [snz stringByAppendingString:@",\n"];
        }

        NSLog(@" snz %@",snz);
        

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
-(void) loadView
{
    [super loadView];
    
    
    NSLog(@" test 3");
    [self thisDeviceHasTopNotch];

  //  let mySceneDelegate = self.view.window.windowScene.delegate
    // have to do this HERE, appdelegate has no direct mainVC handle
    appDelegate.hasTopNotch = [self thisDeviceHasTopNotch];

    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
    
    int xi,yi,xs,ys;

    xi = 0;
    xs = viewWid;
    ys = 32;
    yi = viewHit - 80 - ys;
    //FUCK TOP NOTCH. cant get it at creat time for some reason
    if (1 || appDelegate.hasTopNotch) yi-=32; //account for notch / bottom microphone hole
    simLabel = [[UILabel alloc] initWithFrame:
                   CGRectMake(xi, yi , xs , ys)];
    [simLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size: 24.0]];
    [simLabel setTextColor:[UIColor blackColor]];
    [simLabel setBackgroundColor:[UIColor clearColor]];
    [simLabel setText:@"User Mode"];
    [simLabel setHidden:NO];
    simLabel.textAlignment = NSTextAlignmentCenter;
    [[self view] addSubview:simLabel];
    
    [self addNavBar];
    
    NSLog(@" test 4");
    [self thisDeviceHasTopNotch];

}


//==========MainVC=========================================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser] != nil && (PFUser.currentUser.objectId != nil)) //Logged in?
        NSLog(@" logged into parse...");
    else
        NSLog(@" NOT logged into parse...");
    NSLog(@" test2 %f",self.view.window.safeAreaInsets.top);

    // Do any additional setup after loading the view.
}

//==========MainVC=========================================================================
- (BOOL)thisDeviceHasTopNotch {
    if (@available(iOS 11.0, *)) {
        
    //    NSLog(@"%@", [[NSApplication sharedApplication] mainWindow]);
        SceneDelegate *sd = self.view.window.windowScene.delegate;
        BOOL hasTopNotch = sd.hasTopNotch;

        
        
        NSLog(@" test %f %d",self.view.window.safeAreaInsets.top,hasTopNotch);
        return self.view.window.safeAreaInsets.top > 20.0;
    }
    return  NO;
}


//==========MainVC=========================================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLoginButton];
}


//==========MainVC=========================================================================
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self testsaveToParse];
    [self updateView];
}


//==========MainVC=========================================================================
-(void) addNavBar
{
    CGRect rr   = _footerView.frame ;  //NAV bar fills footer
    rr.origin.x = 0;
    rr.origin.y = 0;
    //DHS 8/8 WTF?
    rr.size.width = viewWid;
    nav = [[NavButtons alloc] initWithFrameAndCount: rr : 4]; //four buttons!
    nav.delegate = self;
    [_footerView addSubview: nav];

    // Home / Menu Button...
    //int binset = 6;
    //Menu button...
    [nav setHotNot         : NNAV_MENU_BUTTON : [UIImage imageNamed:@"burgerHOT.jpg"]  :
                                                [UIImage imageNamed:@"burgerNOT.jpg"] ];
    [nav setLabelTextColor : NNAV_MENU_BUTTON   : [UIColor grayColor]];
    [nav setHidden         : NNAV_MENU_BUTTON   : FALSE];
    // 2 empty buttons...
    [nav setHotNot         : NNAV_BUTTON_1 : [UIImage imageNamed:@"avatar00"]  :
                                             [UIImage imageNamed:@"avatar00"] ];
    [nav setLabelTextColor : NNAV_BUTTON_1 : [UIColor grayColor]];
    [nav setHidden         : NNAV_BUTTON_1 : FALSE];

    [nav setHotNot         : NNAV_BUTTON_2 : [UIImage imageNamed:@"avatar01"]  :
                                             [UIImage imageNamed:@"avatar01"] ];
    [nav setLabelTextColor : NNAV_BUTTON_2 : [UIColor grayColor]];
    [nav setHidden         : NNAV_BUTTON_2 : FALSE]; //10/16 show create even logged out...

    //login button...
    UIImage *emptyUser = [UIImage imageNamed:@"emptyUser"];
    [nav setHotNot         : NNAV_LOGIN_BUTTON : emptyUser : emptyUser ];
//    [nav setCropped        : NNAV_LOGIN_BUTTON : 0.5];
//    [nav setButtonInsets   : NNAV_LOGIN_BUTTON : binset];
    [nav setLabelTextColor : NNAV_LOGIN_BUTTON : [UIColor grayColor]];
    [nav setHidden         : NNAV_LOGIN_BUTTON :FALSE];
    
    //Make footer match header background
    [nav setSolidBkgdColor : [UIColor clearColor] : 1]; //Color / alpha

    //REMOVE FOR FINAL DELIVERY
   // vn = [[UIVersionNumber alloc] initWithPlacement:UI_VERSIONNUMBER_TOPRIGHT];
   // [nav addSubview:vn];
} //end addNavBar


//==========MainVC=========================================================================
// shows logout, avatar change, etc choices
- (void)putUpMenuChoices
{
    NSString *title = @"ipumpi main menu";
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString: title];
    [tatString addAttribute : NSForegroundColorAttributeName value:[UIColor blackColor]
                       range:NSMakeRange(0, tatString.length)];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30]
                      range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(title,nil)
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];

    alert.view.tintColor = [UIColor blackColor];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"toggle Pump Simulation",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        BOOL dog = [self thisDeviceHasTopNotch];
                                appDelegate.isSimulatingPump = !appDelegate.isSimulatingPump;
                                NSLog(@" simulating pump %d",appDelegate.isSimulatingPump );
                                [self updateView];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create Generic Pumps",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self createGenericPumpsInDB];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"test3",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self test3];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"test4",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self test4];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                 [self->_sfx makeTicSoundWithPitch : 8 : 51];
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
    

} //end putUpMenuChoices

//==========MainVC=========================================================================
// shows logout, avatar change, etc choices
- (void)putUpUserChoices
{
    NSString *title = [NSString stringWithFormat:@"Logged in as %@",
                       PFUser.currentUser.username];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Logout",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  [PFUser logOut];
                                                  if ([PFUser currentUser] != nil)
                                                  {
                                                      NSLog(@"duh. no clear pfuser, is this a bug?");
                                                  }
                                                  [self updateLoginButton]; //12/10/18
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Change Your Avatar",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  if ([PFUser currentUser] != nil && (PFUser.currentUser.objectId != nil)) //Logged in?
                                                  {
                                                      self->loginVCMode = PL_AVATAR_MODE;
                                                      [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];
                                                  }
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                [self->_sfx makeTicSoundWithPitch : 8 : 51];
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
    

} //end putUpUserChoices

//==========MainVC=================================================================
// called if/when login status changes, had to redo to access new custom huename
// WOW how can all this be done outside mainVC??? sloppy!!!
-(void) updateLoginButton
{
    //NSLog(@" check if logged in...");
    //DHS 12/10/18
    if ([PFUser currentUser] != nil && (PFUser.currentUser.objectId != nil)) //Logged in?
    {
        PFUser *user = PFUser.currentUser;
        // Shit. we need to get full user refresh for custom field(s)...
        PFQuery *query= [PFUser query];
        NSString *emailString = [user valueForKey:@"email"];
        // 8/28 getting a crash here, null emailString!
        if (emailString == nil) //Should not happen? no email for this user?
        {
            [PFUser logOut]; //make sure we are logged out!
            return;         //and bail
        }
        [query whereKey:@"email" equalTo:emailString]; //DHS 6/18 use huename now!
        //[query whereKey:@"email" equalTo:[user valueForKey:@"email"]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object != nil) //Username available? goto next state...
            {
                PFFile *pff =      [object valueForKey:@"userPortrait"]; //replace with portraitkey at integrate time
                [pff getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                    UIImage *profileImage = [UIImage imageNamed:@"emptyUser"];
                    if (error)
                    {
                        NSLog(@" error fetching avatar...");
                    }
                    else
                    {
                        profileImage = [UIImage imageWithData:data];
                    }
                    NSString *uname = @""; //get first part of email...
                    NSArray *vjunk = [emailString componentsSeparatedByString:@"@"];
                    if (vjunk.count == 2)
                    {
                        uname = vjunk[0];
                    }
                    [self->nav setLabelText : NNAV_LOGIN_BUTTON : uname];
                    [self->nav setHotNot:NNAV_LOGIN_BUTTON : profileImage : profileImage];
                    [self->nav animateLogin:TRUE : profileImage];
                }];
            }
            else
            {
                NSLog(@" error querying for user");
                [self->nav setLabelText : NNAV_LOGIN_BUTTON : @"NAME"];
                [self->nav setHotNot:NNAV_LOGIN_BUTTON : [UIImage imageNamed:@"vangogh120"] : [UIImage imageNamed:@"vangogh120"]];
            }
        }];
    }
    else //Logged out?
    {
        UIImage *ii = [UIImage imageNamed:@"emptyUser"];
        [self->nav setHotNot    : NNAV_LOGIN_BUTTON :  ii: ii];
        [self->nav setCropped   : NNAV_LOGIN_BUTTON : 0.01 * PORTRAIT_PERCENT];
        [self->nav setLabelText : NNAV_LOGIN_BUTTON : @"login"];
    }
    [nav setNeedsDisplay];
} //end updateLoginButton


//====bleHelper notifications=====================================================
-(void) updateView
{
    _topLabel.text    = bstatus;
    _bottomLabel.text = pstatus;
    
    
    UIColor *tColor   = [UIColor blackColor];
    UIColor *bColor   = [UIColor clearColor];
    NSString *infoStr = @"User Mode";
    if (appDelegate.isSimulatingPump)
    {
        tColor  = [UIColor whiteColor];
        bColor  = [UIColor redColor];
        infoStr = @"Pump Simulation";
    }

    [simLabel setTextColor:tColor];
    [simLabel setBackgroundColor:bColor];
    simLabel.text = infoStr;
} //end updateView


-(void) createGenericPumpsInDB
{
    int numsns = (int)sns.snStrings.count;
    for (int i = 0;i<numsns;i++)
    {
        NSString *snw = sns.snStrings[i];
        pt.serialNumber = snw;
        pt.name = [NSString stringWithFormat:@"pump%2.2d",i];
        pt.planter = @"lilplanter";
        pt.group = [NSString stringWithFormat:@"group%2.2d",i/5];
        pt.planter = [NSString stringWithFormat:@"lilplanter %2.2d",i/3];
        [pt saveToParse];

    }
} //end createGenericPumpsInDB


-(void) test2
{
    NSLog(@" test2: save shit");
    [pt getNewSerialNumber];
    pt.name = @"lilpump";
    pt.planter = @"lilplanter";
    [pt saveToParse];
    
}

-(void) test3
{
    NSLog(@" test3: update shit");
    [pt readFromParse:@"atrium" :nil];


}

-(void) test4
{
    [pt fillFieldsFromIndex:0]; //get 0th pump
//    NSString *sn = pt.serialNumber;
//    [pt updateSensorState:sn :@"sensing"];
//    -(void) updateSensorState : (NSString*) serialNum : (NSString *) newState


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



- (IBAction)loginSelect:(id)sender {
    loginVCMode = PL_NO_MODE;
    [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];

}

- (IBAction)avatarSelect:(id)sender {
    loginVCMode = PL_AVATAR_MODE;
    if ([PFUser currentUser] != nil && (PFUser.currentUser.objectId != nil)) //Logged in?
        [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];
    else
        NSLog(@" NOT logged into parse...");

}

- (IBAction)logoutSelect:(id)sender
{
    [PFUser logOut];  
    NSLog(@" Logged out from Parse...");
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //NSLog(@" prepareForSegue: %@ sender %@",[segue identifier], sender);
    if([[segue identifier] isEqualToString:@"loginSegue"])
    {
        //Make sure we handle delegate returns!!
        LoginViewController *vc = (LoginViewController*)[segue destinationViewController];
        NSLog(@" prep4segue: loginVCMode %@",loginVCMode);

        vc.entryMode = loginVCMode;
    }
   
} //end prepareForSegue

#pragma mark - NavButtonsDelegate
//==========MainVC=========================================================================
-(void)  didSelectNavButton: (int) which
{
    [_sfx makeTicSoundWithPitch : 8 : 50 + which];
    
    //11/20 check status before loading...
//    isOnline = fappDelegate.networkStatus; //11/20 add online checking...

    if (which == NNAV_MENU_BUTTON) //menu...
    {
        NSLog(@" menu...");
        [self putUpMenuChoices];

    }
    else if (which == NNAV_BUTTON_1) //b1...
    {
        NSLog(@" pump sim");
        [self presentViewController:psvc animated:YES completion:nil];

    }
    else if (which == NNAV_BUTTON_2) //b2...
    {
        NSLog(@" pump control");
        [self presentViewController:pcvc animated:YES completion:nil];
    }
    else if (which == NNAV_LOGIN_BUTTON) //User login button?
    {
        NSLog(@" login...");
        if ([PFUser currentUser] != nil && (PFUser.currentUser.objectId != nil)) //already logged in?
            [self putUpUserChoices]; //DHS 8/30 use alert style to avoid apple crash
        else
        {
            loginVCMode = PL_NO_MODE;
            [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];
        }
    }
} //end didSelectNavButton

#pragma mark - ipumpiTableDelegate
//====<ipumpiTable delegate>=====================================================
- (void)didSavePumpToParse : (NSString *)serialNum
{
    NSLog(@" pt save OK %@",serialNum);
}

//====<ipumpiTable delegate>=====================================================
- (void)errorSavingPumpToParse : (NSString *)err
{
    NSLog(@" pt error %@",err);
}

@end
