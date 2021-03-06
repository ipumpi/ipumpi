//                   _    __     ______
//   _ __ ___   __ _(_)_ _\ \   / / ___|
//  | '_ ` _ \ / _` | | '_ \ \ / / |
//  | | | | | | (_| | | | | \ V /| |___
//  |_| |_| |_|\__,_|_|_| |_|\_/  \____|
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
#import "ipumpiTable.h"
#import "pumpSimVC.h"
#import "pumpControlVC.h"
#import "soundFX.h"
#import "stubSNs.h"

#define NNAV_MENU_BUTTON    0
#define NNAV_BUTTON_1       1
#define NNAV_BUTTON_2       2
#define NNAV_LOGIN_BUTTON   3


@interface ViewController : UIViewController <NavButtonsDelegate,ipumpiTableDelegate>
{
    UILabel *simLabel;
    
    NavButtons *nav;
    bleHelper *ble;
    pumpSimVC *psvc;
    pumpControlVC *pcvc;

    int viewWid,viewHit,viewW2,viewH2;
    
    ipumpiTable *pt;
    stubSNs *sns;

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

