//
//  pumpControlVC.m
//  ipumpi
//
//  Created by Dave Scruton on 5/8/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import "pumpControlVC.h"
#import "AppDelegate.h" //KEEP this OUT of viewController.h!!

@implementation pumpControlVC
AppDelegate *cappDelegate;

#define GREEN_COLOR [UIColor colorWithRed:0.0 green:0.9 blue:0.3 alpha:1]
#define BLUE_COLOR  [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]

int cpollCount = 0;

//======(pumpControlVC)==========================================
- (instancetype)init
{
    self = [super init];
    cappDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    dformatter   =  [[NSDateFormatter alloc] init]; //9/11
    [dformatter setDateFormat:@"EEEE, MM/d/YYYY h:mm:ssa"];

    sortedKeysToSNs = [[NSMutableDictionary alloc] init];
    sortedLookups   = [[NSMutableArray alloc] init];
    statusDict      = [[NSMutableDictionary alloc] init];
    sensorDict      = [[NSMutableDictionary alloc] init];
    cellsBySN       = [[NSMutableDictionary alloc] init];
    
    //DB hookups
    ista = [[ipumpiStatus  alloc] init];
    ista.delegate = self;
    icmd = [[ipumpiCommand alloc] init];
    icmd.delegate = self;

    // Pump master table...
    ipt = [ipumpiTable sharedInstance];
    ipt.delegate = self;
    
    _sfx = [soundFX sharedInstance];
    sns  = [stubSNs sharedInstance];
    _isUp = FALSE; //8/21
    return self;

}

//======(pumpControlVC)==========================================
// 7/13 new
-(void) loadView
{
    [super loadView];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    viewWid = screenSize.width;
    viewHit = screenSize.height;
    buttonWid = viewWid * 0.17; //10/4 REDO button height,scale w/width
    if (cappDelegate.gotIPad) buttonWid = viewWid * 0.08; //3/27 smaller buttons on ipad
    buttonHit = buttonWid;
    
    self.view.backgroundColor = BLUE_COLOR;
    
    int xs,ys,xi,yi;
    yi = 0;
//    if (cappDelegate.hasTopNotch)
//  5/6 assume notch for now
        yi += 32; //watch out for top notch
    xs = viewWid;
    ys = 40;
    xi = viewWid * 0.5 - xs*0.5;;
    titleLabel = [[UILabel alloc] initWithFrame:
                  CGRectMake(xi, yi, xs , ys)];
    //7/14 redo look
    [titleLabel setFont: [UIFont systemFontOfSize:28 weight:UIFontWeightBold]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:BLUE_COLOR];
    [titleLabel setText:@"Pump Control"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [[self view] addSubview:titleLabel];

    int footerHit = buttonHit;

    yi += ys; //skip down below title
    xs = viewWid;
    ys = viewHit - yi - footerHit; //4/26 better fit
    //  5/6 assume notch for now
//    if ([sappDelegate hasTopNotch])
        ys-=32; //4/26

    table = [[UITableView alloc] initWithFrame:CGRectMake(xi, yi, xs, ys)];
    table.backgroundColor = BLUE_COLOR; //colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    [[self view] addSubview:table];
    table.delegate = self;
    table.dataSource = self;
   // selectedIndexPath = [NSIndexPath indexPathWithIndex:0];
    
    xs = viewWid;
    xi = 0;
    ys = footerHit;
    yi = viewHit-ys;
    //  5/6 assume notch for now
//    if ([sappDelegate hasTopNotch])
        yi-=32;
    footer = [[UIView alloc] init];
    [footer setFrame : CGRectMake(xi,yi,xs,ys)];
    footer.clipsToBounds = FALSE;
    footer.layer.shadowColor = BLUE_COLOR.CGColor;
    footer.layer.shadowOffset = CGSizeMake(0,-12);
    footer.layer.shadowOpacity = 0.3;
    footer.backgroundColor = GREEN_COLOR;
    [self.view addSubview:footer];
    
    

    //Add OK button
    float borderWid = 5.0f;
    UIColor *borderColor = [UIColor whiteColor];
    int xmargin = 20;
    int ymargin = 8;
   
    // 4/26 add helpful info
    xi = xmargin;
    xs = viewWid*0.7 - xmargin;
    yi = ymargin;
    ys = 80;
    bottomInfoLabel = [[UILabel alloc] initWithFrame:  CGRectMake(xi, yi, xs , ys)];
    [bottomInfoLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)16]];
    [bottomInfoLabel setTextColor:[UIColor blackColor]]; //colorWithRed: 0.5 green: .9 blue:.9 alpha: 1.0f]];
    [bottomInfoLabel setBackgroundColor:[UIColor clearColor]];
    [bottomInfoLabel setText:@"NOTE: need to restore start buttons on auto-stop!"];
    [bottomInfoLabel setNumberOfLines : 0];
    bottomInfoLabel.textAlignment = NSTextAlignmentLeft;
    [footer addSubview:bottomInfoLabel];

    // 2/6/21 change to Done label, match size in storeVC
    xs = viewWid*0.20;
    xi = viewWid - xs - xmargin;
    ys =  buttonHit * 0.9 - 2*ymargin;
    yi = ymargin;

    okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setTitle:@"Done" forState:UIControlStateNormal];
    [okButton setFrame:CGRectMake(xi, yi, xs, ys)];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor    = BLUE_COLOR;
    okButton.layer.cornerRadius = xmargin;
    okButton.clipsToBounds      = TRUE;
    okButton.layer.borderWidth  = borderWid;
    okButton.layer.borderColor  = borderColor.CGColor;
    [okButton addTarget:self action:@selector(dismissSelect:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:okButton];
 } //end loadView

//======(pumpControlVC)==========================================
// Boilerplate code from stackoverflow
- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshTable];
} //end viewDidLoad


//======(controlsVC)==========================================
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self readPumpsFromParse];
    [self startPollingTimer];
    [cellsBySN removeAllObjects];
}

//======(controlsVC)==========================================
// start a timer, using COMMAND_INTERVAL, loop over all pump simulators
//   and query for new commands...
-(void) startPollingTimer
{
    if (pollTimer != nil) [pollTimer invalidate];
    pollTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pollTick:)                                                 userInfo:nil repeats:YES];

    
}

//======(controlsVC)==========================================
// Look at pumps, update UI
- (void)pollTick:(NSTimer *)ltimer
{
    NSLog(@" PumpControlget status...");
    
    if (ipt == nil) return;
    for (NSString* key in ipt.pumpDict)
    {
        PFObject *pfo   = ipt.pumpDict[key];
        NSString *sn    = pfo[Pipumpi_serialNumber_key];
        //ista.serialNumber = sn; //set up serial number, go read it!
        [ista readFromParse:sn];
    }

  
    
    
//    [self refreshTable]; //update our table
    cpollCount++;
    
} //end animtimerTick


//======(controlsVC)==========================================
// 4/28 for pull to refresh
-(void) refreshTable
{
//    [refreshControl endRefreshing];
//    [self getSampleFolder];
    [table reloadData];
}


//======(pumpControlVC)==========================================
-(void) readPumpsFromParse
{
    // args are pump group and name, both nil means read everything
    [ipt readFromParse:nil :nil]; //get all pumps
} //end readPumpsFromParse


//======(pumpControlVC)==========================================
-(int) getCellRow : (id) sender
{
    return (int)[self getCellIndexPath:sender].row;
}

//======(pumpControlVC)==========================================
// Helps calculate which row a cell is on...
-(NSIndexPath *) getCellIndexPath : (id) sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [table indexPathForCell:clickedCell];
    return clickedButtonPath;
}

//======(pumpControlVC)==========================================
-(void) updateCellButtonsForStartStop : (id)sender : (BOOL) started
{
    selectedRow = [self getCellRow:sender];
    pumpConCell *cell = (pumpConCell *)[[sender superview] superview];
    //UI action! hide buttons...
    cell.tButton1.hidden = started;
    cell.tButton2.hidden = started;
    cell.tButton3.hidden = started;
}

//======(pumpControlVC)==========================================
-(NSString*) getCellSNFromButton : (id)sender
{
    selectedRow = [self getCellRow:sender];
    pumpConCell *cell = (pumpConCell *)[[sender superview] superview];
    return cell.sn;
}

//======(pumpControlVC)==========================================
-(void) sendStartCommand : (NSString*)sn : (int) minutes
{
    NSString * cmdToSend = [NSString stringWithFormat:@"START%dMIN",minutes];
    [icmd sendCommandToParse:sn : cmdToSend];
} //end sendStartCommand

//======(pumpControlVC)==========================================
-(void) sendStopCommand : (NSString*)sn
{
    [icmd sendCommandToParse:sn : PC_STOP];
} //end sendStartCommand


//======(pumpControlVC)==========================================
- (IBAction)b1Select:(id)sender
{
    NSLog(@" button 1: ");
    [self sendStartCommand: [self getCellSNFromButton : sender] :1];
    [self updateCellButtonsForStartStop:sender :TRUE];
}   //end b1Select

//======(pumpControlVC)==========================================
- (IBAction)b2Select:(id)sender
{
    NSLog(@" button 2: ");
    [self sendStartCommand: [self getCellSNFromButton : sender] :5];
    [self updateCellButtonsForStartStop:sender :TRUE];
}   //end b2Select

//======(pumpControlVC)==========================================
- (IBAction)b3Select:(id)sender
{
    NSLog(@" button 3: ");
    [self sendStartCommand: [self getCellSNFromButton : sender] :10];
    [self updateCellButtonsForStartStop:sender :TRUE];
}   //end b3Select

//======(pumpControlVC)==========================================
- (IBAction)b4Select:(id)sender
{
    NSLog(@" button 4: ");
    
    [self sendStopCommand: [self getCellSNFromButton : sender]];
    [self updateCellButtonsForStartStop:sender :FALSE];

}   //end b4Select

//======(pumpControlVC)==========================================
- (IBAction)dismissSelect:(id)sender
{
    [self dismissVC];
}   //end dismiss

//======(pumpControlVC)==========================================
// this is called from more than one place!
-(void) dismissVC
{
    //this starts up audio again and lets mainVC know if something was changed
    _isUp = FALSE; //8/21
    //[self.delegate didDismisspumpSimVC:changed];
    [self dismissViewControllerAnimated : YES completion:nil];
}


//======(pumpControlVC)==========================================
-(void) getSortedDictionary
{
    [sortedKeysToSNs removeAllObjects];
    //First get all keys from pump data
    NSArray *keys   = ipt.pumpDict.allKeys;
    //Lets get names now...
    NSMutableArray *presort = [[NSMutableArray alloc] init];
    for (NSString* key in ipt.pumpDict)
    {
        PFObject *pfo   = ipt.pumpDict[key];
        NSString *name  = pfo[Pipumpi_name_key];
        [presort addObject:name];
        [sortedKeysToSNs setObject:key forKey:name];
    }
    sortedLookups = [presort sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //NSLog(@" sorted %@ skeys %@",sortedLookups,sortedKeysToSNs);
} //end getSortedDictionary

#pragma mark - UITableViewDelegate
//=========<UITableViewDelegate>===========================================
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = (int)indexPath.row;
    pumpConCell *cell = (pumpConCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[pumpConCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];

    if (ipt != nil && ipt.pumpDict.count > 0)
    {
        NSString *lookup = sortedLookups[row];
        NSString *sn     = sortedKeysToSNs[lookup];
        PFObject *pfo    = ipt.pumpDict[sn];
        cell.title.text  = pfo[Pipumpi_name_key];
        cell.sn              = sn; //makes it easy to look up sn
        cell.snLabel.text    = pfo[Pipumpi_serialNumber_key];
        
        [cellsBySN setObject:cell forKey:sn]; //used to find cells at status time

        NSString *status = statusDict[sn]; //latest pump status if any
        NSString *sensor = sensorDict[sn]; //latest pump status if any
        int timeLeft = [sensor intValue];
        if (status != nil)
        {
            if (![status isEqualToString:cell.oldStatus]) //New status?
            {
                //if ([status isEqualToString:@"psStopped"]) //SLOPPY. move status states to global
                if  ([status isEqualToString:@"psRunning"]) //just started?
                {
                    [cell.spi start:@"pumping"];
                    cell.spi.hidden = FALSE;
                    cell.indicatorIcon.hidden = TRUE;
                }
                else  if ([status isEqualToString:@"psStopped"])
                {
                    [cell.spi stop];
                    cell.spi.hidden = TRUE;
                    cell.indicatorIcon.hidden = FALSE;
//                    cell.tButton1.hidden = FALSE; //put back start buttons
//                    cell.tButton2.hidden = FALSE;
//                    cell.tButton3.hidden = FALSE;
                }
            }
            if (status != nil && sensor != nil)
            {
                NSString *duh = [NSString stringWithFormat:@"%@:%d",status,sensor.intValue];
                NSLog(@" update countdown cell %d countdown %d",row,sensor.intValue);
                cell.countdownLabel.text = duh;
            }
//            cell.countdownLabel.text = status;

        }
        else
            cell.countdownLabel.text = @"n/a";
        cell.oldStatus = status;
    }
    else //krap
    {
        //    NSArray *keys = pumpDict.allKeys;
        //    NSString *sn = keys[row];
        //    pumpSimulator *ps = pumpDict[sn]; //get by serial number
            // 7/14 redo font/color
            cell.title.text      = @"test1"; //ps.name;
            cell.title.textColor = [UIColor whiteColor];
            cell.snLabel.text    = @"test2"; //ps.serialNumber;

            cell.countdownLabel.text = @"99.99"; //[NSString stringWithFormat:@"%d:%2.2d",timeMinutes,timeSeconds]; // [self getSizeText:nn];
    }
    [cell.tButton1 addTarget:self action:@selector(b1Select:) forControlEvents:UIControlEventTouchUpInside];
    [cell.tButton2 addTarget:self action:@selector(b2Select:) forControlEvents:UIControlEventTouchUpInside];
    [cell.tButton3 addTarget:self action:@selector(b3Select:) forControlEvents:UIControlEventTouchUpInside];
    [cell.tButton4 addTarget:self action:@selector(b4Select:) forControlEvents:UIControlEventTouchUpInside];


    return cell;
 } //end cellForRowAtIndexPath

//=========<UITableViewDelegate>===========================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

//=========<UITableViewDelegate>===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//=========<UITableViewDelegate>===========================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (ipt == nil || ipt.pumpDict.count == 0) return 5; //FOR STUB TESTING, make 0 at delivery
    return (int)ipt.pumpDict.count;
}

//=========<UITableViewDelegate>===========================================
// Handles any click on bottom table... just goes to actVC
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)indexPath.row;
    
//    NSDictionary *fileinfo = [self getFileInfo:fileNamesNoNumberSigns[row]];
//    NSNumber *srate = fileinfo[@"samplerate"];
//    int srateInt = srate.intValue;
//    if (srateInt != 44100 && srateInt != 11025 && srateInt != 16000)
//    {
//        [self errorMessage:@"Unsupported file" :@"oogieCam can't load this file.\nMake sure your audio files are all 44 or 11 khz and have 16-bit audio"];
//    }
//    else{
//        [self displayActionMenu : row];
//        selectedIndexPath = indexPath;
//    }
    
}
 

#pragma mark - ipumpiTableDelegate
//====<ipumpiTable delegate>=====================================================
- (void)didSavePumpToParse : (NSString *)serialNum
{
    NSLog(@" pt save OK %@",serialNum);
}

//====<ipumpiTable delegate>=====================================================
- (void)errorSavingPumpToParse : (NSString *)err
{
    NSLog(@" pt save error %@",err);
}

//====<ipumpiTable delegate>=====================================================
- (void)didReadPumpsFromParse
{
    NSLog(@" pt read OK");
    NSLog(@" dict %@",ipt.pumpDict);
    [self getSortedDictionary];
    [self refreshTable];
}

//====<ipumpiTable delegate>=====================================================
- (void)errorReadingPumpsFromParse : (NSString *)err
{
    NSLog(@" pt read error %@",err);
}

#pragma mark - ipumpiStatusDelegate
//====<ipumpiStatusDelegate>=====================================================
- (void)didReadPumpStatusFromParse : (NSString *)sn : (NSString *)status : (NSString *)sensorState
{
    NSLog(@" read status serial#%@/%@",sn,status);
    //HERE uuid is incoming serial number, may change!
    [statusDict setObject:status forKey:sn];
    [sensorDict setObject:sensorState forKey:sn];
    NSLog(@" store sensor %@ at key %@",sensorState,sn);
    pumpConCell *pcell = cellsBySN[sn];

    if ([status isEqualToString:@"psStopped"]) //got stop message? show start buttons again
    {
        pcell.tButton1.hidden = FALSE;
        pcell.tButton2.hidden = FALSE;
        pcell.tButton3.hidden = FALSE;
    }
    
    [self refreshTable];
}

//====<ipumpiStatusDelegate>=====================================================
- (void)errorReadingPumpStatusFromParse : (NSString *)uuid : (NSString *)err
{
    
}

//====<ipumpiStatusDelegate>=====================================================
- (void)didReadEmptyPumpStatusFromParse
{
    
}


@end
