//  Created by Dave Scruton on 5/8/21
//  Copyright © 1990 - 2021 fractallonomy, inc. All Rights Reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "spinnerView.h"

#define GCIMAGESIZE 96

@interface pumpConCell : UITableViewCell
{
    int viewWid,viewHit;
    int cellHit;
    
}


//-(void) setPlayButtonHidden : (BOOL) hidden;
@property (nonatomic, strong) UIImageView *indicatorIcon;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *dateLabel1;
@property (nonatomic, strong) UILabel *dateLabel2;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic, strong) UILabel *snLabel;
@property (nonatomic, strong) UIButton *tButton1;
@property (nonatomic, strong) UIButton *tButton2;
@property (nonatomic, strong) UIButton *tButton3;
@property (nonatomic, strong) UIButton *tButton4;
@property (nonatomic, strong) UIButton *tButton5;
@property (nonatomic, strong) spinnerView *spi;
@property (nonatomic, strong) UIImageView *sep;
@property (nonatomic, strong) NSString *sn; //serial number for this cell
@property (nonatomic, strong) NSString *oldStatus;  



@end
