//
//  pumpSimVC.h
//  oogieCam
//
//  Created by Dave Scruton on 6/22/20.
//  Copyright © 1990 - 2021 fractallonomy, inc. All Rights Reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "pumpSimCell.h"
#import "pumpSimulator.h"
#import "soundFX.h"
#import "stubSNs.h"


#define COMMAND_INTERVAL 10.0

@interface pumpSimVC : UIViewController <UITableViewDelegate,
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

    stubSNs *sns;
    
    NSMutableDictionary *oldPumpStates;
    NSArray *startCommands;
    pumpSimulator *workPump;
    NSMutableDictionary *pumpDict; //Dictionary of pump simulators
    NSDateFormatter * dformatter;
    int selectedRow;
    NSTimer *pollTimer;
    
}
@property (nonatomic, strong) soundFX *sfx;

//10/17 use allPatches @property (nonatomic, weak) NSMutableDictionary *bufLookups;
//10/17 use allPatches @property (nonatomic, weak) NSMutableDictionary *patLookups;
//@property (nonatomic, unsafe_unretained) id <samplesVCDelegate> delegate; // receiver of completion messages
@property(nonatomic,assign)   BOOL isUp; //8/21

@end



