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

@interface ViewController : UIViewController
{
    bleHelper *ble;
    NSString *bstatus;
    NSString *pstatus;
    NSString * loginVCMode;

}
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
- (IBAction)loginSelect:(id)sender;
- (IBAction)avatarSelect:(id)sender;

@end

