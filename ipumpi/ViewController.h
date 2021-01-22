//
//  ViewController.h
//  pumpie
//
//  Created by Dave Scruton on 11/17/20.
//  Copyright © 2020 lpumpi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bleHelper.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "NavButtons.h"
#import "soundFX.h"

#define NNAV_MENU_BUTTON    0
#define NNAV_BUTTON_1       1
#define NNAV_BUTTON_2       2
#define NNAV_LOGIN_BUTTON   3


@interface ViewController : UIViewController <NavButtonsDelegate>
{
    NavButtons *nav;
    bleHelper *ble;

    int viewWid,viewHit,viewW2,viewH2;

    NSString *bstatus;
    NSString *pstatus;
    NSString * loginVCMode;

}
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) soundFX *sfx;

- (IBAction)loginSelect:(id)sender;
- (IBAction)avatarSelect:(id)sender;
- (IBAction)logoutSelect:(id)sender;

@end

