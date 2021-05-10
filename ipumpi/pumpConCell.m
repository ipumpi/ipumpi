//  Created by Dave Scruton on 5/6/21
//  Copyright © 1990 - 2021 fractallonomy, inc. All Rights Reserved.
//
// 9/11 add creation dates to sampleCell
// 4/26 add small margin right of play button/indicator
// 4/30 debug, remove redundant start call at init
#import "pumpConCell.h"
@implementation pumpConCell

#define SEPARATOR_SIZE 2

#define GREEN_COLOR [UIColor colorWithRed:0.0 green:0.9 blue:0.3 alpha:1]
#define BLUE_COLOR  [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]
#define RED_COLOR   [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1]

//=====(sampleCell)=============================================
// Yup we create everything by hand...
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIScreen *sc = [UIScreen mainScreen];
        CGRect rt    = sc.bounds;
        CGSize csz   = rt.size;
        viewWid      = (int)csz.width;
        viewHit      = (int)csz.height;
        int xymargin = 5;
        int column2  = 120;
        int column3  = viewWid - 80;
        int xs,ys,xi,yi;

        xi = xymargin;
        yi = xymargin;
        xs = ys = 100;
        _spi = [[spinnerView alloc] initWithFrame:CGRectMake(xi,yi, xs,ys)];
        [self.contentView addSubview:_spi];
        _spi.hidden = TRUE;

        int inset = 10;
        xi+=inset;
        yi+=inset;
        xs-=2*inset;
        ys-=2*inset;
        _indicatorIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pauseBtn"]];
        [_indicatorIcon setFrame:CGRectMake(xi,yi, xs, ys)];
        [self addSubview : _indicatorIcon];
        _indicatorIcon.hidden = FALSE;


        xi = 5; //4/27 no icon here! scootch to LH side
        xs = 100;        ys = 20;
        yi = 120 - ys; //120 assumed to be height
        _title = [[UILabel alloc] initWithFrame:CGRectMake(xi,yi,xs,ys)];
        [_title setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)18]];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_title];

        xi = column2; //4/27 no icon here! scootch to LH side
        yi =xymargin;
        xs = viewWid - xi - xymargin;
        _dateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(xi,yi,xs,ys)];
        [_dateLabel1 setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)14]];
        _dateLabel1.textColor = [UIColor blackColor]; //colorWithRed:0.4 green:0.5 blue:1.0 alpha:1];
        _dateLabel1.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:_dateLabel1];
        yi+=ys;
        _dateLabel1.hidden = TRUE;
        
        _dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(xi,yi,xs,ys)];
        [_dateLabel2 setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)14]];
        _dateLabel2.textColor = [UIColor whiteColor]; //colorWithRed:0.4 green:0.5 blue:1.0 alpha:1];
        _dateLabel2.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_dateLabel2];
        _dateLabel2.hidden = TRUE;

        int buttonwh = 80;
        yi+=ys;
        ys = buttonwh;
        xs = viewWid - xi - buttonwh - 2*xymargin; //account for RH button
        _countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(xi,yi,xs,ys)];
        [_countdownLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)20]];
        _countdownLabel.textColor = [UIColor whiteColor];
        _countdownLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_countdownLabel];
        
        ys = 15;
        yi = 120-ys-xymargin;
        xs = viewWid - xi;
        _snLabel = [[UILabel alloc] initWithFrame:CGRectMake(xi,yi,xs,ys)];
        [_snLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)ys]];
        _snLabel.textColor = [UIColor blackColor];
        _snLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_snLabel];

        int cornerRad = 5;
        int borderWid = 2;
        UIColor *borderColor = [UIColor whiteColor];
        UIColor *textColor   = [UIColor blackColor];
        xi = column3;
        yi = xymargin;
        xs = 80;
        ys = 28;
        _tButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tButton1 setTitle:@"Start1" forState:UIControlStateNormal];
        [_tButton1 setFrame:CGRectMake(xi, yi, xs, ys)];
        [_tButton1 setTitleColor:textColor forState:UIControlStateNormal];
        _tButton1.backgroundColor    = GREEN_COLOR;
        _tButton1.layer.cornerRadius = cornerRad;
        _tButton1.clipsToBounds      = TRUE;
        _tButton1.layer.borderWidth  = borderWid;
        _tButton1.layer.borderColor  = borderColor.CGColor;
        [self.contentView addSubview:_tButton1];

        yi+=ys;
        _tButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tButton2 setTitle:@"Start5" forState:UIControlStateNormal];
        [_tButton2 setFrame:CGRectMake(xi, yi, xs, ys)];
        [_tButton2 setTitleColor:textColor forState:UIControlStateNormal];
        _tButton2.backgroundColor    = GREEN_COLOR;
        _tButton2.layer.cornerRadius = cornerRad;
        _tButton2.clipsToBounds      = TRUE;
        _tButton2.layer.borderWidth  = borderWid;
        _tButton2.layer.borderColor  = borderColor.CGColor;
        [self.contentView addSubview:_tButton2];

        yi+=ys;
        _tButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tButton3 setTitle:@"Start10" forState:UIControlStateNormal];
        [_tButton3 setFrame:CGRectMake(xi, yi, xs, ys)];
        [_tButton3 setTitleColor:textColor forState:UIControlStateNormal];
        _tButton3.backgroundColor    = GREEN_COLOR;
        _tButton3.layer.cornerRadius = cornerRad;
        _tButton3.clipsToBounds      = TRUE;
        _tButton3.layer.borderWidth  = borderWid;
        _tButton3.layer.borderColor  = borderColor.CGColor;
        [self.contentView addSubview:_tButton3];

        yi+=ys;
        _tButton4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tButton4 setTitle:@"Stop" forState:UIControlStateNormal];
        [_tButton4 setFrame:CGRectMake(xi, yi, xs, ys)];
        [_tButton4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _tButton4.backgroundColor    = RED_COLOR;
        _tButton4.layer.cornerRadius = cornerRad;
        _tButton4.clipsToBounds      = TRUE;
        _tButton4.layer.borderWidth  = borderWid;
        _tButton4.layer.borderColor  = borderColor.CGColor;
        [self.contentView addSubview:_tButton4];

//        xs = ys = buttonwh; //match size of countdown label
//        xi = viewWid - xs - xymargin;
//        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playButton setImage:[UIImage imageNamed:@"continueBtn"] forState:UIControlStateNormal];
//        [_playButton setFrame:CGRectMake(xi,yi, xs,ys)];
//        [self.contentView addSubview:_playButton];
        //2/6 add separator
        xi = 0;
        xs = viewWid;
        ys = SEPARATOR_SIZE;
        yi = 120-ys;
        _sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white128x128"]];
        [_sep setFrame:CGRectMake(xi,yi, xs,ys)];
        [self.contentView addSubview:_sep];

    }
    
    return self;
} //end init...


@end
