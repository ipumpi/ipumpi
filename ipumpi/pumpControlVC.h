//
//  pumpControlVC.h
//  ipumpi
//
//  Created by Dave Scruton on 5/8/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ipumpiCommand.h"
#import "ipumpiStatus.h"
#import "ipumpiTable.h"
#import "pumpConCell.h"
#import "soundFX.h"
#import "stubSNs.h"


@interface pumpControlVC : UIViewController <UITableViewDelegate,
                            ipumpiTableDelegate,ipumpiCommandDelegate,ipumpiStatusDelegate,
                            UITableViewDataSource,UITextFieldDelegate>
{
    int viewWid,viewHit,buttonWid,buttonHit;
    UILabel *titleLabel;
    UITableView *table;
    UILabel *bottomInfoLabel;
    UIButton *clearButton;
    UIButton *addButton;
    UIButton *okButton;
    UIButton *cancelButton;
    UIView *header,*footer;
    NSMutableDictionary *sortedKeysToSNs;
    NSMutableArray *sortedLookups;
    NSMutableDictionary *statusDict;
    NSMutableDictionary *sensorDict;
    NSMutableDictionary *cellsBySN;
    ipumpiTable  *ipt;
    ipumpiCommand *icmd;
    ipumpiStatus *ista;
    int selectedRow;
    NSTimer *pollTimer;

    NSDateFormatter * dformatter;

    stubSNs *sns;
    
}

@property (nonatomic, strong) soundFX *sfx;
@property(nonatomic,assign)   BOOL isUp; //8/21


@end
 
