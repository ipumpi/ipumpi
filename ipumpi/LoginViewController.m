//
//  LoginViewController.m
//  PixLogin
//
//  Created by Dave Scruton on 1/6/21
//  Copyright © 2021 ipumpi. All rights reserved.
//
//  Sashido email templates:
//   https://blog.sashido.io/emails-and-custom-user-facing-pages/
//  NOTE third page is for avatar choice, NOT username handle!
//    also NO huename now
//  ALSO: now we change the login state from signup to login if user chooses login button
// BUGS: avatar update doesnt work w/ photo chooser!
//  havent checked out email reset yet!


#import "LoginViewController.h"

#define DONOT_IGNOREUSEREVENTS
@implementation LoginViewController

//Remove at integration time (use plixaKeys)
//NSString *const _PhueNameKey = @"hueName"; // 6/18
NSString *const _PuserPortraitKey       = @"userPortrait";


//----LoginViewController---------------------------------
-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
    {
        lastPage    = 4;
        animSpeed   = 0.5;
        avatarNum   = 0; //Unselected...
        avatarImage = nil;
//        bkgdTropo   = [UIImage imageNamed:@"intermed2.jpg"];
        bkgdGradient   = [UIImage imageNamed:@"pixlogin_bkgd"];
        needPwReset = false;

        state = 1; //Initial state...
        //These are the pages we will switch between while creating an account
        //NOTE: state 0 DOES NOT EXIST, states are from 1 to 11!
        for (int i=0;i<=7;i++) createAccountStates[i] = i;
        //Login state , points to page 4 1/8/21
        loginState = 4;
        //States for resetting the password
        for (int i=9;i<=10;i++) resetPasswordStates[i] = i;
        //Skip account setup
        skipState = 11;
        DBBeingAccessed = FALSE;
        //anal = [Analytics sharedInstance];
    }
    return self;
    
} //end initWithCoder



//----LoginViewController---------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    //  7/7 add tap testure recog. to dismiss KB if up
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveGestureOnText:)]];
    //5/27
    _topTextField.delegate    = self;
    _bottomTextField.delegate = self;
    
    //1/4/20 localize storyboard items:
    [_uploadButton setTitle:NSLocalizedString(@"Upload my portrait",nil) forState:UIControlStateNormal];
    [_LSTopButton setTitle:NSLocalizedString(@"Login",nil) forState:UIControlStateNormal];
    [_LSBottomButton setTitle:NSLocalizedString(@"Create Account",nil) forState:UIControlStateNormal];
    _chooseLabel.text = NSLocalizedString(@"Upload your portrait\nor choose from below",nil); //1/7/21
    _orLabel.text = NSLocalizedString(@"or",nil);
    [_forgotButton setTitle:NSLocalizedString(@"forgot password?",nil) forState:UIControlStateNormal];
    [_anonymousButton setTitle:NSLocalizedString(@"skip and play as HueGogh",nil) forState:UIControlStateNormal];
} //end viewDidLoad


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}



//----LoginViewController---------------------------------
// Handles tap outside KB to dismiss...
-(void)didReceiveGestureOnText:(UITapGestureRecognizer*)recognizer
{
    [self.view endEditing:TRUE];
}



//----LoginViewController---------------------------------
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    //Its easier to just make a rounded portrait in code...
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
    _portraitImage.clipsToBounds = TRUE;
    _portraitImage.layer.cornerRadius = _portraitImage.frame.size.width * 0.01 * PORTRAIT_PERCENT;

    //1/7/21 add border to upload button for clarity
    _uploadButton.layer.borderWidth   = 2;
    _uploadButton.layer.borderColor   = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
    //Spinning activity view
    spv = [[spinnerView alloc] initWithFrame:CGRectMake(0, 0, viewWid, viewHit)];
    [self.view addSubview:spv];

}


//----LoginViewController---------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //if (!returningFromPhotoPicker)
    [self reset];
}

//----LoginViewController---------------------------------
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
        state = 1; //Initial state...
        [self getPageForState];
        [self gotoNthPage];
}



//----LoginViewController---------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----LoginViewController---------------------------------
-(void) reset
{
    page = 0;
    _obscura.hidden      = true;
    _obscura.alpha       = 0;
    [self setControlAlphasToZero];
}  //end reset

//----LoginViewController---------------------------------
-(void) setControlAlphasToZero
{
    _portraitImage.alpha = 0;
    _lsButtonView.alpha  = 0;
    _userPwView.alpha    = 0;
    _faceView.alpha      = 0;
    _chooseLabel.alpha   = 0;
    _bottomButtonView.hidden = TRUE; //Does this get alphad in?
    _topLabel.hidden = TRUE;
    _bottomLabel.hidden = TRUE;
    _uploadButton.hidden = TRUE;
    _emailConfLabel.hidden = TRUE;
}  //end setControlAlphasToZero

//----LoginViewController---------------------------------
-(void)gotoPageForState : (int)s
{
    state = s;
    [self getPageForState];
    [self gotoNthPage];
}

//----LoginViewController---------------------------------
-(void) getPageForState
{
    NSLog(@" loginVC: entrymode %@",_entryMode);
    PFUser *user = PFUser.currentUser;
    if ([_entryMode containsString : PL_NO_MODE]) //1/8/21 Login OR signup?
    {
        page = 1;
    }
    else if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        page = createAccountStates[state];
    }
    else if ([_entryMode containsString : PL_AVATAR_MODE])  //Change user avatar?
    {
        page = 3; // 1/8/21 fit into new pages
    }
    else if ([_entryMode containsString : PL_LOGIN_MODE])  //Login for returning user?
    {
        page = loginState;
    }

} //end getPageForState

//----LoginViewController---------------------------------
// This populates custom fields...
-(void) queryForUser : (NSString *)emailString
{
    PFQuery *query= [PFUser query];
    DBBeingAccessed = TRUE;
    [query whereKey:@"email" equalTo:emailString]; //DHS 6/18 use huename now!
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object == nil) //Username available? goto next state...
        {
//NO HUENAME!            self->_hueName = [object valueForKey:@"hueName"];
        }
        else
            NSLog(@" error querying for user");
        self->DBBeingAccessed = FALSE;
    }];

} //end queryForUser

//----LoginViewController---------------------------------
-(void) sendErrorAnalytics : (NSString *)errstr
{
//    [self->anal newEventWithBasicFields];
//    [self->anal addStringField:@"type"   : @"saveUserLogin"];
//    [self->anal addStringField:@"userid" : _emailString];
//    [self->anal addStringField:@"message": errstr];
//    [self->anal sendEventToEveryone : @"error" : 1];
} //end sendErrorAnalytics



//----LoginViewController---------------------------------
-(void) gotoNthPage
{
    switch(page)
    {
        case 1: [self firstPage];   break;
        case 2: [self secondPage];  break;
        case 3: [self thirdPage];   break;
        case 4: [self fourthPage];  break;
        case 5: [self fifthPage];   break;
        case 6: [self sixthPage];   break;
    }
} //end gotoNthPage


//----LoginViewController---------------------------------
// Direction 0 = animate out, 1 = animate in...
-(void) animateInOut : (id) child : (int) dir : (float) dtime : (float) atime
                     : (NSUInteger) options : (BOOL) clearAnimFlag
{
    if( [child isKindOfClass:[UIView class]])
    {
        dtime*=animSpeed;
        atime*=animSpeed;
        
        UIView* uie = (UIView *) child;
        float startAlpha = 1.0; //Assume animate out by default
        float endAlpha   = 0.0;
        if (dir == 1)  //Animate in?
        {
            startAlpha = 0.0;
            endAlpha   = 1.0;
        }
        uie.alpha = startAlpha;
        [UIView animateWithDuration:atime
                              delay:dtime
                            options:options
                         animations:^{
                             uie.alpha = endAlpha;
                         }
                         completion:^(BOOL finished){
                             if (clearAnimFlag) self->animating = FALSE;
                         }
         ];
    }
} //end animateIn

//----LoginViewController---------------------------------
-(void) loadCurrentUserInfo
{
    PFUser *user = PFUser.currentUser;
    //_hueName     = user[_PhueNameKey] ; //Make sure username is set up!
    avatarImage  = [UIImage imageNamed:@"vangogh120"];
    PFFile *pff  = user[@"userPortrait"]; //replace with portraitkey at integrate time
    [pff getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@" error fetching avatar...");
        }
        else
        {
//            self->_topLabel.text = [NSString stringWithFormat:@"%@\n",self->_hueName]; //set top label
            self->avatarImage = [UIImage imageWithData:data];
        }
        self->_portraitImage.image = self->avatarImage;
    }];
    
} //end loadCurrentUserInfo

//----LoginViewController---------------------------------
-(void) signupOrUpdateUserAvatar
{
    // 7/3 at this point either signup user or juat update avatar
    if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        [self signupUser];
        return;
    }
    //Avatar mode? Update avatar only...
    PFUser *user = PFUser.currentUser;
    NSData *avatarData = UIImagePNGRepresentation(avatarImage);
    PFFile *avatarImageFile = [PFFile fileWithName : @"avatarImage.png" data:avatarData];
    user[_PuserPortraitKey] = avatarImageFile;
    //user[_PhueNameKey]      = _hueName; //6/26 update huename here too...
    [spv start : NSLocalizedString(@"Updating profile",nil)];
    DBBeingAccessed = FALSE;

#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self->spv stop];
        self->DBBeingAccessed = FALSE;
        if (succeeded) //Done? Dismiss!
        {
            [self dismissViewControllerAnimated : YES completion:nil];
        }
        else
        {
            [self pixAlertDEBUG:self : @"Could not save Avatar" : error.localizedDescription :false];
            [self sendErrorAnalytics : @"failed to save Avatar"];
        }
#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif

    }];
    
} //end signupOrUpdateUserAvatar



//----LoginViewController---------------------------------
// Opener...
-(void) firstPage
{
    
    //First, hide fields we don't need...
    _portraitImage.hidden   = TRUE;
    _userPwView.hidden      = TRUE;
    _faceView.hidden        = TRUE;
    _uploadButton.hidden    = TRUE;
    _bottomLabel.hidden     = TRUE;
    _emailConfLabel.hidden  = TRUE; //DO I need this?
    _forgotButton.hidden    = TRUE;

    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _bottomButtonView.hidden = FALSE;
    _anonymousButton.hidden  = FALSE;
    _orLabel.hidden          = FALSE;
    _LSBottomButton.hidden   = FALSE;
    needToVerifyEmail = FALSE; //Make sure email verify prompt appears...

    //Clear all user login fields...
    avatarImage  = [UIImage imageNamed:@"emptyUser"];
    //_hueName     = @"";
    _password    = @"";
    _emailString = @"";

    //Set text fields...
    _topLabel.text = NSLocalizedString(@"Ipumpi Login\n ",nil);
    _topSmallLabel.text = NSLocalizedString(@"Login or create\nan account if you are new",nil);
    //1/1/20
    [_LSTopButton setTitle:NSLocalizedString(@"Login",nil) forState:UIControlStateNormal];

    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
} //end firstPage

//----LoginViewController---------------------------------
// Get email and password strings...
-(void) secondPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden   = TRUE;
    _faceView.hidden        = TRUE;
    _uploadButton.hidden    = TRUE;
    _bottomLabel.hidden     = TRUE;
    _orLabel.hidden         = TRUE;
    _LSBottomButton.hidden  = TRUE;
    _emailConfLabel.hidden  = TRUE; //DO I need this?
    _topTextLabel.hidden    = TRUE;
    _bottomTextLabel.hidden = TRUE;
    _bottomButtonView.hidden= TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    _topTextField.hidden     = FALSE;
    _bottomTextField.hidden  = FALSE;
    //Set text fields...
    _topTextField.text         = _emailString;   //7/3
    _topSmallLabel.text        = NSLocalizedString(@"password must be\n8 characters or more\n",nil);
    _topTextField.placeholder  = NSLocalizedString(@"enter email",nil);
    _topTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _bottomTextField.text        = @"";
    _bottomTextField.placeholder = NSLocalizedString(@"choose a password",nil);
    //1/1/20
    [_LSTopButton setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];
    
    needToVerifyEmail = TRUE; //Make sure email verify prompt appears...

    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
} //end secondPage




//----LoginViewController---------------------------------
// Avatar Time...
-(void) thirdPage
{
    //First, hide fields we don't need...
    _topSmallLabel.hidden    = TRUE;
    _userPwView.hidden       = TRUE;
    _emailConfLabel.hidden   = TRUE;
    _bottomButtonView.hidden = TRUE;
    _topTextField.hidden     = TRUE;
    _bottomLabel.hidden      = TRUE;
    _LSTopButton.hidden      = TRUE; //Hidden initially, shown later
    _LSBottomButton.hidden   = TRUE;
    _orLabel.hidden          = TRUE;

    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _portraitImage.hidden    = FALSE;
    _chooseLabel.hidden      = FALSE;
    _faceView.hidden         = FALSE;
    _uploadButton.hidden     = FALSE;
    _lsButtonView.hidden     = FALSE;
    
    //1/7/21 show email at top...
//    _topLabel.text = [NSString stringWithFormat:@"%@\n",self->_emailString];
    _topLabel.text = @"choose avatar\n";
    _portraitImage.image = [UIImage imageNamed:@"emptyUser"];
    
    
    [_LSTopButton setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];

    if ([_entryMode containsString : PL_AVATAR_MODE])
    {
       [self loadCurrentUserInfo];
    }
    else //Do I need to do something in signup mode?
    {
    }
    
    animating = TRUE;

    //This animates obscura OUT...
    [self animateInOut:_obscura       : 0 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    //These get animated IN...
    [self animateInOut:_portraitImage : 1 : 0.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_chooseLabel   : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView  : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_faceView      : 1 : 0.9 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
    

} //end fourthPage



//----LoginViewController---------------------------------
// Login Entry point...
-(void) fourthPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden   = TRUE;
    _faceView.hidden        = TRUE;
    _uploadButton.hidden    = TRUE;
    _bottomLabel.hidden     = TRUE;
    _orLabel.hidden         = TRUE;
    _chooseLabel.hidden     = TRUE;   //6/18
    _LSBottomButton.hidden  = TRUE;
    _emailConfLabel.hidden  = TRUE; //DO I need this?
    _topTextLabel.hidden    = TRUE;
    _bottomTextLabel.hidden = TRUE;
    _anonymousButton.hidden = TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _forgotButton.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    _topTextField.hidden     = FALSE;
    _bottomTextField.hidden  = FALSE;
    _bottomButtonView.hidden = FALSE;
    
    //Set text fields...
    _topLabel.text = NSLocalizedString(@"ipumpi login ",nil);
    _topSmallLabel.text = NSLocalizedString(@"enter email and password\n\n",nil);
    _topTextField.text = @"";
    _topTextField.placeholder  = NSLocalizedString(@"email",nil);
    _topTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _bottomTextField.text = @"";
    _bottomTextField.placeholder = NSLocalizedString(@"password",nil);
    [_LSTopButton setTitle:NSLocalizedString(@"Login",nil) forState:UIControlStateNormal];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];
    //if ([_entryMode containsString : PL_SIGNUP_MODE]) //Signup? user needs to verify first
    if (needToVerifyEmail)
        [self emailVerifyAlert]; //We need an alert over this page!

} //end fourthPage

//----LoginViewController---------------------------------
// Password Reset...
// 1/12/21 BUG: return key seemed sticky entering email,
//           and reset password button isnt working
-(void) fifthPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden    = TRUE;
    _faceView.hidden         = TRUE;
    _uploadButton.hidden     = TRUE;
    _bottomLabel.hidden      = TRUE;
    _orLabel.hidden          = TRUE;
    _LSBottomButton.hidden   = TRUE;
    _emailConfLabel.hidden   = TRUE;
    _topTextLabel.hidden     = TRUE;
    _bottomTextLabel.hidden  = TRUE;
    _bottomTextField.hidden  = TRUE;
    _bottomButtonView.hidden = TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _topTextField.hidden     = FALSE;
    _userPwView.hidden       = FALSE;
    
    //Set text fields...
    _topLabel.text      = NSLocalizedString(@"what\'s\nyour email? ",nil);
    _topSmallLabel.text = NSLocalizedString(@"Login not working? No Worries!\n",nil);
    _topTextField.text  = @"";
    _topTextField.placeholder = NSLocalizedString(@"enter email",nil);
    _topTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [_LSTopButton setTitle:NSLocalizedString(@"reset password",nil) forState:UIControlStateNormal];
    [_LSTopButton setEnabled:FALSE];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end sixthPage

//----LoginViewController---------------------------------
// Skip page...
-(void) sixthPage
{
    //First, hide fields we don't need...
    _portraitImage.hidden    = TRUE;
    _faceView.hidden         = TRUE;
    _userPwView.hidden       = TRUE;
    _uploadButton.hidden     = TRUE;
    _orLabel.hidden          = TRUE;
    _LSBottomButton.hidden   = TRUE;
    _emailConfLabel.hidden   = TRUE; //DO I need this?
    _topTextLabel.hidden     = TRUE;
    _bottomTextLabel.hidden  = TRUE;
    _bottomTextField.hidden  = TRUE;
    _bottomButtonView.hidden = TRUE;
    
    //Now show fields we DO need...
    _topLabel.hidden         = FALSE;
    _topSmallLabel.hidden    = FALSE;
    _lsButtonView.hidden     = FALSE;
    _bottomLabel.hidden      = FALSE;

    //Set text fields...
    _topLabel.text      = NSLocalizedString(@"test1\n",nil);
    _topSmallLabel.text = NSLocalizedString(@"test2",nil);
    _bottomLabel.text = NSLocalizedString(@"test3",nil);
    [_LSTopButton setTitle:NSLocalizedString(@"play anyway",nil) forState:UIControlStateNormal];
    
    animating = TRUE;
    //These only get animated in ONCE...
    [self animateInOut:_topLabel          : 1 : 0.5 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_topSmallLabel     : 1 : 0.7 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_lsButtonView      : 1 : 1.0 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_userPwView        : 1 : 1.2 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomLabel       : 1 : 1.4 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: FALSE];
    [self animateInOut:_bottomButtonView  : 1 : 1.6 : 1.0 :(NSUInteger)UIViewAnimationOptionCurveEaseInOut: TRUE];

} //end seventhPage


//----LoginViewController---------------------------------
//  Get email / password fields, validates both, then does signup
-(void) checkEmailAndPasswordforSignup
{
    NSString *topString = _topTextField.text;
    NSString *botString = _bottomTextField.text;
    if (botString.length < 8)
    {
        [self pixAlertDEBUG:self :@"Password too short" : @"Your password must be at least 8 characters" :false];
    }
    else{ //PW OK? keep checking
        if ([self validateEmailWithString:topString]) //Legit?
        {
                _emailString = topString;
                _password    = botString; //Load up final fields
                [self gotoPageForState:self->state+1];   //7/3 just continue...
        }
        else{
            [self pixAlertDEBUG:self :@"Bad Email Address" : @"It looks like you have bad characters in your email address" :false];
        }
    }
} //end checkEmailAndPasswordforSignup

//----LoginViewController---------------------------------
//  Get email field,
-(void) checkEmailforPasswordReset
{
    NSString *topString = _topTextField.text;
    if ([self validateEmailWithString:topString]) //Legit?
    {
        _emailString = topString; //Load up final fields
        [self performPasswordReset]; //This accesses DB... continues after success
    }
    else{
        [self pixAlertDEBUG:self :@"Bad Email Address" : @"It looks like you have bad characters in your email address" :false];
    }
} //end checkEmailforPasswordReset


//----LoginViewController---------------------------------
//  Get email / password fields, validates both, then does signup  6/18
-(void) getEmailAndPasswordAndLogin
{
    _emailString = _topTextField.text;
    _password    = _bottomTextField.text;
    if ([_entryMode containsString : PL_SIGNUP_MODE]) return;   //1/7/21 DO NOT LOGIN in signup mode!
    if (_emailString.length > 0 && _password.length > 0) //8/30 make sure both fields are there
        [self loginUser];
} //end getEmailAndPasswordAndLogin


//----LoginViewController---------------------------------
// This button has multiple uses, sometimes its Next,
//  sometimes its Login
- (IBAction)LSTopSelect:(id)sender
{
    //NSLog(@" LSTopSelect state %d",state);
    if (DBBeingAccessed) return; //DO not advance while DB in progress!
    //no mode? login / signup? user has chosen to login
    if ([_entryMode containsString : PL_NO_MODE])
    {
        if (state == 1) //at first state? switch to login mode and goto login page
        {
            _entryMode = PL_LOGIN_MODE;
            [self gotoPageForState:4]; // 1/8/21 Goto login page
        }
    }
    //signup sequence? handle next page...
    else if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        // 1/8/21 assume we never come from state 1, (or no_mode)
        if (state == 2) [self checkEmailAndPasswordforSignup];
        else if (state == 3) [self signupOrUpdateUserAvatar];
        else if (state == 4) [self getEmailAndPasswordAndLogin];
        else if (state == 5) [self checkEmailforPasswordReset]; //DHS 12/6 wups!
        else if (state == 6) [self dismissViewControllerAnimated : YES completion:nil];
        else [self gotoNthPage];
    }
    else if ([_entryMode containsString : PL_LOGIN_MODE]) //Login? only one place to go!
    {
        if (state == 5) [self checkEmailforPasswordReset]; // 1/6 new states
        else            [self getEmailAndPasswordAndLogin];
    }
//    else if ([_entryMode containsString : PL_HUENAME_MODE]) //Huename? reset it
//        [self checkHueName];
    else if ([_entryMode containsString : PL_AVATAR_MODE]) //Avatar? reset it
        [self signupOrUpdateUserAvatar];
}

//----LoginViewController---------------------------------
// This button is only used for signup...
- (IBAction)LSBottomSelect:(id)sender
{
    NSLog(@" LSBottomSelect");
    _entryMode = PL_SIGNUP_MODE;
    [self gotoPageForState:2];
}

//----LoginViewController---------------------------------
- (IBAction)anonymousSelect:(id)sender
{
    [self gotoPageForState:7]; //Goto anon page...
}


//----LoginViewController---------------------------------
// Goes to reset pw page...
- (IBAction)resetPasswordSelect:(id)sender
{
    page = state = 5; //1/12/21 NEW page #
    [self gotoNthPage];
} //end resetPasswordSelect

//----LoginViewController---------------------------------
//  called by checkEmailforPasswordReset
-(void)performPasswordReset
{
    [spv start : NSLocalizedString(@"Resetting...",nil)];

#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [PFUser requestPasswordResetForEmailInBackground:_emailString
         block:^(BOOL succeeded, NSError *error) {
            [spv stop];
            if (!error)
             {
                 [self pixAlertDEBUG:self :@"Reset Successful" : @"Check your email to complete the password reset process." :false];
                 self->state = 4; //1/12 setup to go back to login...
                 [self gotoPageForState:self->state];
             }
             else
             {
                 [self pixAlertDEBUG:self :@"Reset Failed" : error.localizedDescription :false];
             }
#ifdef IGNOREUSEREVENTS
             [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
             self->page = self->state = 4; //1/12/21 new page number
             [self gotoNthPage]; //Go to Login page now...
         }];
} //end performPasswordReset

//----LoginViewController---------------------------------
-(void) setupCannedAvatar : (int) which : (id)sender
{
    avatarNum = which;
    UIButton *button = (UIButton *)sender;
    avatarImage = button.currentBackgroundImage;
    avatarImage = [avatarImage imageByScalingAndCroppingForSize :
                   CGSizeMake(LOGIN_AVATAR_SIZE, LOGIN_AVATAR_SIZE)  ];
    _portraitImage.image = avatarImage; //[UIImage imageNamed : name];
    _LSTopButton.hidden  = FALSE; //User can now proceed...

} //end setupCannedAvatar

//----LoginViewController---------------------------------
- (IBAction)face1Select:(id)sender
{
    [self setupCannedAvatar : 1 : sender]; //OKeefe
}

//----LoginViewController---------------------------------
- (IBAction)face2Select:(id)sender
{
    [self setupCannedAvatar : 2 : sender];  // Faithringgold
}

//----LoginViewController---------------------------------
- (IBAction)face3Select:(id)sender 
{
    [self setupCannedAvatar : 3 : sender];  // nelson256
}

//----LoginViewController---------------------------------
- (IBAction)face4Select:(id)sender
{
    [self setupCannedAvatar : 4 : sender];  // "Albers"
}

//----LoginViewController---------------------------------
- (IBAction)face5Select:(id)sender
{
    [self setupCannedAvatar : 5 : sender];  // Frida
}

//----LoginViewController---------------------------------
- (IBAction)face6Select:(id)sender
{
    [self setupCannedAvatar : 6 : sender];  // monet
}


//----LoginViewController---------------------------------
// Upload button...
- (IBAction)uploadSelect:(id)sender
{
   [self displayPhotoPicker];
}

//----LoginViewController---------------------------------
- (IBAction)backSelect:(id)sender {
    BOOL bailit = FALSE;
    
    // 1/8/21 login/signup choosing mode?
    if ([_entryMode containsString : PL_NO_MODE])
    {
        if (state == 1)  
        {
            bailit = TRUE;
        }
    }
    //This mode has lots of states
    else if ([_entryMode containsString : PL_SIGNUP_MODE])
    {
        if (state == 1) //12/6 WHY ISNT this bailing!
        {
            bailit = TRUE;
        }
        else if (state == 7 || state == 5) // Bailout/Login page? Return home
        {
            [self gotoPageForState:1];
        }
        else //Just go back one state
        {
            [self gotoPageForState:state-1];
        }
    }
    else //Login /etc mode?
    {
        if (state == 1)  // First page? bail
            bailit = TRUE;
        else if (state == 6) // PW reset? back to login
        {
            [self gotoPageForState:5];
        }
    }
    if (bailit) [self dismissViewControllerAnimated : YES completion:nil];
}




//----LoginViewController---------------------------------
-(void) displayPhotoPicker
{
    //NSLog(@" photo picker...");
    UIImagePickerController *imgPicker;
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = YES;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imgPicker animated:NO completion:nil];
} //end displayPhotoPicker

//----LoginViewController---------------------------------
- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Makes poppy squirrel sound!
    // [_sfx makeTicSoundWithPitchandLevel:7 :70 : 40];
    [Picker dismissViewControllerAnimated:NO completion:^{
        self->avatarImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        self->avatarImage = [self->avatarImage imageByScalingAndCroppingForSize :
                       CGSizeMake(LOGIN_AVATAR_SIZE, LOGIN_AVATAR_SIZE)  ];
        self->_portraitImage.image = self->avatarImage;
        self->_LSTopButton.hidden  = FALSE; //User can now proceed...
    }];
} //end didFinishPickingMediaWithInfo

//======(PixUtils)==========================================
// For user choosing anonymous play...
-(void) anonymousInfoAlert : (UIViewController *) parent
{
    
    //1/1/20 localize...
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Anonymous Play has its limits...",nil)
                                 message:NSLocalizedString(@"If you don't create a Color Profile,\nyou cannot create puzzles...",nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"OK",nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //use fbcache, set avatar and name? Or is it huegogh by default?
                                    [self dismissViewControllerAnimated : YES completion:nil];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Go Back",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [parent presentViewController:alert animated:YES completion:nil];

} //end anonymousInfoAlert


//======(PixUtils)==========================================
-(void) emailVerifyAlert
{
    [self pixAlertDEBUG:self :@"Email Verification Required" :
        @"Check your email for a new message." :false];
}


//======(PixUtils)==========================================
// Pull on delivery, use pixAlert from pixUtils...
-(void) pixAlertDEBUG : (UIViewController *) parent : (NSString *) title : (NSString *) message : (BOOL) yesnoOption
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    if (yesnoOption)
    {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
        [alert addAction:yesButton];
        [alert addAction:noButton];
    }
    else //Just put up OK?
    {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                    }];
        
        [alert addAction:yesButton];
    }
    if (parent == nil) //Invoked from a non-UI object?
    {
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alert animated:YES completion:nil];
    }
    else
        [parent presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate

//======<UITextFieldDelegate>==========================================
- (IBAction)textFieldChanged:(id)sender {
    BOOL gotTop    =  (_topTextField.text.length > 0);
    BOOL gotBottom =  (_bottomTextField.text.length > 0);

    //Handle Next button enable/disable based on filled text fields
    if (state == 1 || state == 2)  //Huename page?
    {
        [_LSTopButton setEnabled:gotTop];
    }
    else if (state == 3) //email and password page?
    {
        [_LSTopButton setEnabled:(gotTop & gotBottom)];
    }
    else if (state == 5) //1/12/21 new page # password reset? bottom text entered?
    {
        [_LSTopButton setEnabled:gotTop];
    }

} //end textFieldChanged


//======(PixUtils)==========================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //This should close text typein!??
    [textField resignFirstResponder];
    //DHS login try login if both text fields are filled...
    [self  getEmailAndPasswordAndLogin];
    return YES;
}

//==========loginTestVC=========================================================================
//  6/18 logs in with email string now! only called from getEmailAndPasswordAndLogin
- (void)loginUser
{
#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [spv start:NSLocalizedString(@"Logging in...",nil)];
    [PFUser logInWithUsernameInBackground:_emailString password:_password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        BOOL bailit = false;
        if (user != nil)
        {
            //TEST...
            //[self queryForUser:@"fraktalmaui@gmail.com"];
            NSNumber *workn = user[@"emailVerified"];
            BOOL isVerified = [workn boolValue];
            if (!isVerified ) //Check for email verification first!
            {
                [PFUser logOut];
                [self emailVerifyAlert];
            }
            else
            {
                //NSLog(@"user logged in... id %@",PFUser.currentUser.objectId);
                bailit = true;
            }
        }
        else
        {
            [self pixAlertDEBUG:self :@"Error Logging In" : error.localizedDescription :false];
            self->failCount++;
            if (self->failCount > 2) //fail? Offer to reset password
            {
                NSLog(@" three failures!!");
            }
        }
        [self->spv stop];
#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
        if (bailit)            //all done?
            [self dismissViewControllerAnimated : YES completion:nil];
    }];
}  //end loginUser

//==========loginTestVC=========================================================================
- (void)signupUser
{
    PFUser *user  = [[PFUser alloc] init];
    signupError   = FALSE;
    user.username = _emailString; //DHS 6/18 username and email now the same
    user.password = _password;
    user.email    = _emailString;
    NSData *avatarData = UIImagePNGRepresentation(avatarImage);
    PFFile *avatarImageFile = [PFFile fileWithName : @"avatarImage.png" data:avatarData];
    user[_PuserPortraitKey] = avatarImageFile;
//    user[_PhueNameKey]      = _hueName;
    [spv start : NSLocalizedString(@"Creating profile",nil)];
    DBBeingAccessed = TRUE;
#ifdef IGNOREUSEREVENTS
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
#endif
    [user signUpInBackgroundWithBlock:^(BOOL success, NSError * _Nullable error) {
        [self->spv stop];
        self->DBBeingAccessed = FALSE;
        if (error != nil)
        {
            [self pixAlertDEBUG:self :@"Error Signing Up" : error.localizedDescription :false];
            self->signupError = TRUE;
        }
        else
        {
            [PFUser logOut]; //Log us out!
            [self gotoPageForState:self->state+1]; //Should go to login prompt...
        }

#ifdef IGNOREUSEREVENTS
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
#endif
    }];
}  // end signupUser

//==========loginTestVC=========================================================================
- (BOOL)validateEmailWithString:(NSString*)emailIn
{
    //NSLog(@"validate email %@.....",emailIn);
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailIn];
}

//==========loginTestVC=========================================================================
- (BOOL)validateUsernameWithString:(NSString*)uname
{
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    s = [s invertedSet];
    NSRange r = [uname rangeOfCharacterFromSet:s];
    if (r.location != NSNotFound) {
        return FALSE;
    }
    return TRUE;
}



//==========loginTestVC=========================================================================
// Boilerplate from stackoverflow
//  https://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
//  https://stackoverflow.com/questions/800123/what-are-best-practices-for-validating-email-addresses-on-ios-2-0
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}







@end
