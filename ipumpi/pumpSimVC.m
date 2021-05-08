//  pumpSimVC.m
//  oogieCam
//
//  Created by Dave Scruton on 5/5/21
//  Copyright © 1990 - 2021 fractallonomy, inc. All Rights Reserved.
//

#import "pumpSimVC.h"
#import "AppDelegate.h" //KEEP this OUT of viewController.h!!

@implementation pumpSimVC
AppDelegate *sappDelegate;

#define GREEN_COLOR [UIColor colorWithRed:0.0 green:0.9 blue:0.3 alpha:1]
#define BLUE_COLOR  [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1]
int pollCount = 0;

//======(pumpSimVC)==========================================
- (instancetype)init
{
    self = [super init];
    sappDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    pumpDict     = [[NSMutableDictionary alloc] init];
    workPump     = [[pumpSimulator alloc] init];
    // we handle returning messages from the pump simulator
    workPump.delegate = self;

    oldPumpStates = [[NSMutableDictionary alloc] init];;
    startCommands = @[PC_START1MIN,PC_START5MIN,PC_START10MIN];

    dformatter   =  [[NSDateFormatter alloc] init]; //9/11
    [dformatter setDateFormat:@"EEEE, MM/d/YYYY h:mm:ssa"];

    //fileNamesNoNumberSigns = [[NSMutableArray alloc] init];
    _sfx = [soundFX sharedInstance];
    sns  = [stubSNs sharedInstance];
    _isUp = FALSE; //8/21
    return self;



}

//======(pumpSimVC)==========================================
// 7/13 new
-(void) loadView
{
    [super loadView];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    viewWid = screenSize.width;
    viewHit = screenSize.height;
    buttonWid = viewWid * 0.17; //10/4 REDO button height,scale w/width
    if (sappDelegate.gotIPad) buttonWid = viewWid * 0.08; //3/27 smaller buttons on ipad
    buttonHit = buttonWid;
    
    self.view.backgroundColor = BLUE_COLOR;
    
    int xs,ys,xi,yi;
    yi = 0;
//    if (sappDelegate.hasTopNotch)
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
    [titleLabel setText:@"Sample Manager"];
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
    
    // 7/20 import button hidden for now, no cloud entitlements!
//    xs = viewWid*0.35;
//    ys = buttonHit * 0.9 - 2*ymargin;
//    xi = xmargin;
//    yi = ymargin;
//    importButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [importButton setTitle:@"Import..." forState:UIControlStateNormal]; //7/13
//    [importButton setFrame:CGRectMake(xi, yi, xs, ys)];
//    [importButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    importButton.backgroundColor    = [UIColor blackColor];
//    importButton.layer.cornerRadius = xmargin;
//    importButton.clipsToBounds      = TRUE;
//    importButton.layer.borderWidth  = borderWid;
//    importButton.layer.borderColor  = borderColor.CGColor;
//    [importButton addTarget:self action:@selector(importSelect:) forControlEvents:UIControlEventTouchUpInside];
//    [footer addSubview:importButton];
//    importButton.hidden = TRUE;
    
#ifdef NEEDBOTTOMLABEL
    // 4/26 add helpful info
    xi = xmargin;
    xs = viewWid*0.75 - xmargin;
    yi = ymargin;
    ys = 40;
    bottomInfoLabel = [[UILabel alloc] initWithFrame:  CGRectMake(xi, yi, xs , ys)];
    [bottomInfoLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:(int)12]];
    [bottomInfoLabel setTextColor:[UIColor blackColor]]; //colorWithRed: 0.5 green: .9 blue:.9 alpha: 1.0f]];
    [bottomInfoLabel setBackgroundColor:[UIColor clearColor]];
    [bottomInfoLabel setText:@"Samples can be found in the Files App\n  under oogieCam/samples"];
    [bottomInfoLabel setNumberOfLines : 0];
    bottomInfoLabel.textAlignment = NSTextAlignmentLeft;
    [footer addSubview:bottomInfoLabel];
#endif
    ys =  buttonHit * 0.9 - 2*ymargin;
    yi = ymargin;
    xs = viewWid*0.20;
    xi = xmargin;
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton setFrame:CGRectMake(xi, yi, xs, ys)];
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearButton.backgroundColor    = BLUE_COLOR;
    clearButton.layer.cornerRadius = xmargin;
    clearButton.clipsToBounds      = TRUE;
    clearButton.layer.borderWidth  = borderWid;
    clearButton.layer.borderColor  = borderColor.CGColor;
    [clearButton addTarget:self action:@selector(clearSelect:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:clearButton];

    xi += xs + xmargin;
    ys =  buttonHit * 0.9 - 2*ymargin;
    yi = ymargin;
    xs = viewWid*0.20;
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton setFrame:CGRectMake(xi, yi, xs, ys)];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addButton.backgroundColor    = BLUE_COLOR;
    addButton.layer.cornerRadius = xmargin;
    addButton.clipsToBounds      = TRUE;
    addButton.layer.borderWidth  = borderWid;
    addButton.layer.borderColor  = borderColor.CGColor;
    [addButton addTarget:self action:@selector(addSelect:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:addButton];

    
    // 2/6/21 change to Done label, match size in storeVC
    xi = viewWid - xs - xmargin;
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

//======(pumpSimVC)==========================================
// Boilerplate code from stackoverflow
- (void)viewDidLoad {
    [super viewDidLoad];
    // pull to refresh needed?
//    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
//    if (@available(iOS 10.0,*))
//    {
//        table.refreshControl = refreshControl;
//    }
//    else{
//        [table addSubview:refreshControl];
//    }
} //end viewDidLoad

//======(pumpSimVC)==========================================
// 4/28 for pull to refresh
-(void) refreshTable
{
//    [refreshControl endRefreshing];
//    [self getSampleFolder];
    [table reloadData];
}

//======(pumpSimVC)==========================================
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (pollTimer != nil) [pollTimer invalidate]; //clobber old timer
    [self startUITimer];

    //7/31 hide until we know about sample files
//    cancelButton.hidden = TRUE;
//
//    [self getSampleFolder];
//    [table reloadData];
//    changed = FALSE; //7/13
//    samplesPlaying = 0;
    [self resetTitle];
}

//======(controlsVC)==========================================
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isUp = TRUE; //8/21
}


//======(pumpSimVC)==========================================
// 9/24
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//======(pumpSimVC)==========================================
-(void) resetTitle
{
    [titleLabel setText:@"Pump Simulator"];
    [titleLabel setTextColor : [UIColor whiteColor]];
}


//======(pumpSimVC)==========================================
- (IBAction)importSelect:(id)sender
{
    NSArray *utisOLD  = @[@"mp3",@"caf",@"wav"];
    
    //NSArray *utis = @[@"public.image", @"public.audio", @"public.movie", @"public.text", @"public.item", @"public.content", @"public.source-code"];
     
    UIDocumentMenuViewController *documentProviderMenu =
    [[UIDocumentMenuViewController alloc] initWithDocumentTypes:utisOLD
                                                         inMode:UIDocumentPickerModeImport];

    //optionsVC.modalPresentationStyle = modalPresentationStyle
    
    //documentProviderMenu.modalPresentationStyle =
    //documentProviderMenu.delegate = self;
//    [self presentViewController:documentProviderMenu animated:YES
      [self presentViewController:documentProviderMenu animated:YES completion:nil];
}   //end importSelect

//======(pumpSimVC)==========================================
- (IBAction)clearSelect:(id)sender
{
    NSLog(@" clearit");
    [pumpDict removeAllObjects];
    [self refreshTable];
}   //end clearSelect

//======(pumpSimVC)==========================================
- (IBAction)addSelect:(id)sender
{
    NSLog(@" addit");
    int maxPumps = (int)sns.snStrings.count;
    if (pumpDict.count >= maxPumps)
    {
        [self errorMessage : @"Maximum Pump Limit" : @"You cannot add more pumps"];
        return;
    }
    //Get new pump
    pumpSimulator *wp = [[pumpSimulator alloc] init];
    int pumpnum = (int)pumpDict.count;
    NSString *sn = sns.snStrings[pumpnum];

    wp.serialNumber = sn;
    wp.name = [NSString stringWithFormat:@"pump%2.2d",pumpnum];
    wp.pumpState = PUMPSTATE_STOPPED;
    NSDate *today = [NSDate date];
    wp.commandDate = today;
    wp.lastCommandDate = today;
    wp.lastOnTime = today;
    wp.lastOffTime = today;
    [wp startPolling]; //OK start timer on pump
    [pumpDict setObject:wp forKey:sn];
    [self refreshTable];

//    @property (nonatomic , strong) NSString* sensorState;
//    @property (nonatomic , strong) NSString* command;
//    @property (nonatomic , strong) NSString* lastCommand;
 
}   //end addSelect


//======(pumpSimVC)==========================================
// start a timer, using COMMAND_INTERVAL, loop over all pump simulators
//   and query for new commands...
-(void) startUITimer
{
    pollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pollTick:)                                                 userInfo:nil repeats:YES];

    
}

//======(pumpSimVC)==========================================
// Look at pumps, update UI
- (void)pollTick:(NSTimer *)ltimer
{
    [self refreshTable]; //update our table
    pollCount++;
    
} //end animtimerTick



//======(pumpSimVC)==========================================
// THIS is just for test, never will be used
- (IBAction)playSelect:(id)sender
{

    selectedRow = [self getCellRow:sender];
    pumpCell *cell = (pumpCell *)[[sender superview] superview];
//    [clickedCell setPlayButtonHidden:TRUE]; //Hide cells play button!
//    NSString *sname = fileNamesNoNumberSigns[selectedRow];

    
//    //asdf
//    pumpCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.spi start:@"pumping"];
    [cell.playButton setImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];


}   //end dismiss


//======(pumpSimVC)==========================================
- (IBAction)dismissSelect:(id)sender
{
    [self dismissVC];
}   //end dismiss

//======(pumpSimVC)==========================================
// this is called from more than one place!
-(void) dismissVC
{
    //this starts up audio again and lets mainVC know if something was changed
    _isUp = FALSE; //8/21
    //[self.delegate didDismisspumpSimVC:changed];
    [self dismissViewControllerAnimated : YES completion:nil];
}

//======(pumpSimVC)==========================================
-(void) displayEmptyFolderAlert
{
    NSString *titleStr = @"No Samples...";
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:
                                            titleStr];
    [tatString addAttribute : NSForegroundColorAttributeName value:[UIColor blackColor]
                       range:NSMakeRange(0, tatString.length)];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30]
                      range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(titleStr,nil)
                                message:@"The User Samples folder is empty...\nTo add new Samples you can either\nrecord live oogieCam samples\n or import WAV files from Documents\nusing the Files App.\nNext, these samples here form the UserSamples SoundPack"
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert setValue:tatString forKey:@"attributedTitle"];
    alert.view.tintColor = [UIColor blackColor]; //lightText, works in darkmode

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                    [self dismissVC]; //7/17
                                              }]];
    
    if (sappDelegate.gotIPad) // 3/27 need popover for ipad!
    {
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        //Put it in Center... (NO ARROW)
        popPresenter.sourceRect = CGRectMake( self.view.bounds.size.width/2,self.view.bounds.size.height/2 ,   0,   0);
        popPresenter.permittedArrowDirections = 0;
    }

    [self presentViewController:alert animated:YES completion:nil];

} //end displayEmptyFolderAlert


//======(pumpSimVC)==========================================
-(void) displayActionMenu : (int) row
{
//    selectedRow = row;
//
//    NSString *titleStr = fileNamesNoNumberSigns[row];
//    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:
//                                            titleStr];
//    [tatString addAttribute : NSForegroundColorAttributeName value:[UIColor blackColor]
//                       range:NSMakeRange(0, tatString.length)];
//    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30]
//                      range:NSMakeRange(0, tatString.length)];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
//                                NSLocalizedString(titleStr,nil)
//                                message:@"You can rename, delete or share samples here..."
//                                preferredStyle:UIAlertControllerStyleActionSheet];
//    [alert setValue:tatString forKey:@"attributedTitle"];
//
//
//    alert.view.tintColor = [UIColor blackColor]; //lightText, works in darkmode

    

//    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
//                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        [self->_sfx  releaseAllNotes]; //7/10
//                                                  [self clearSelection];
//                                              }]];
//    if (sappDelegate.gotIPad) // 3/27 need popover for ipad!
//    {
//        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
//        popPresenter.sourceView = self.view;
//        //Put it in Center... (NO ARROW)
//        popPresenter.sourceRect = CGRectMake( self.view.bounds.size.width/2,self.view.bounds.size.height/2 ,   0,   0);
//        popPresenter.permittedArrowDirections = 0;
//    }
//    [self presentViewController:alert animated:YES completion:nil];

}




//======(pumpSimVC)==========================================
-(int) getCellRow : (id) sender
{
    return (int)[self getCellIndexPath:sender].row;
}

//======(pumpSimVC)==========================================
// Helps calculate which row a cell is on...
-(NSIndexPath *) getCellIndexPath : (id) sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [table indexPathForCell:clickedCell];
    return clickedButtonPath;
}


//=========<UITableViewDelegate>===========================================
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = (int)indexPath.row;
    pumpCell *cell = (pumpCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[pumpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *keys = pumpDict.allKeys;
    NSString *sn = keys[row];
    pumpSimulator *ps = pumpDict[sn]; //get by serial number
    // 7/14 redo font/color
    cell.backgroundColor = [UIColor clearColor];
    cell.title.text      = ps.name;
    cell.title.textColor = [UIColor whiteColor];
    cell.snLabel.text    = ps.serialNumber;
// NO BUTTON FOR NOW    [cell.playButton     addTarget:self action:@selector(playSelect:)      forControlEvents:UIControlEventTouchUpInside];

    // unpack file info , indexed by fname
    //NSDictionary *fileinfo = [self getFileInfo:fileNamesNoNumberSigns[row]];
    NSDate *ddd = ps.lastCommandDate;
    NSString *dstr = [dformatter stringFromDate:ddd];
    cell.dateLabel1.text = dstr;
    ddd = ps.stopTime;
    dstr = [dformatter stringFromDate:ddd];
    cell.dateLabel2.text = dstr;
    
    int timeLeft = ps.timeLeft;
    int timeMinutes = timeLeft / 60;
    int timeSeconds = timeLeft % 60;
    BOOL gotATime = (timeLeft > 0);
    cell.countdownLabel.hidden = !gotATime;
    cell.dateLabel1.hidden     = !gotATime;
    cell.dateLabel2.hidden     = !gotATime;
    if (gotATime)
        cell.countdownLabel.text = [NSString stringWithFormat:@"%d:%2.2d",timeMinutes,timeSeconds]; // [self getSizeText:nn];

    // look at last state for our pump
    NSString *newState = ps.pumpState;
    NSString *oldState = oldPumpStates[ps.serialNumber];
    if (![oldState isEqualToString:newState])  //Change?
    {
        if  ([newState isEqualToString:PUMPSTATE_RUNNING]) //just started?
        {
            [cell.spi start:@"pumping"];
            cell.spi.hidden = FALSE;
            cell.indicatorIcon.hidden = TRUE;
        }
        else  if ([newState isEqualToString:PUMPSTATE_STOPPED])
        {
            [cell.spi stop];
            cell.spi.hidden = TRUE;
            cell.indicatorIcon.hidden = FALSE;
        }
        oldPumpStates[ps.serialNumber] = newState;
    }
    
//    cell.headerLabel.text = @"header"; // [self getSizeText:nn];


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
    //return fileNamesNoNumberSigns.count;
    return pumpDict.count;
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
 

//====(OOGIECAM MainVC)============================================
-(void) errorMessage : (NSString *)title : (NSString *)message
{
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:
                                            title];
    [tatString addAttribute : NSForegroundColorAttributeName value:[UIColor blackColor]
                       range:NSMakeRange(0, tatString.length)];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30]
                      range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(title,nil)
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert setValue:tatString forKey:@"attributedTitle"];
    alert.view.tintColor = [UIColor blackColor]; //lightText, works in darkmode

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];

} //end errorMessage



@end
