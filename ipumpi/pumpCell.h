//  Created by Dave Scruton on 5/6/21
//  Copyright © 1990 - 2021 fractallonomy, inc. All Rights Reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "spinnerView.h"

#define GCIMAGESIZE 96

@interface pumpCell : UITableViewCell
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
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) spinnerView *spi;
@property (nonatomic, strong) UIImageView *sep;



@end
