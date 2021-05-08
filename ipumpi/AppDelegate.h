//
//  AppDelegate.h
//  ipumpi
//
//  Created by Dave Scruton on 11/18/20.
//  Copyright © 2020 ipumpi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "soundFX.h"
#import "pumpSimulator.h"
#import "SceneDelegate.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
}

@property (nonatomic , assign) BOOL isSimulatingPump;
@property (nonatomic , assign) BOOL hasTopNotch;
@property (nonatomic , assign) BOOL gotIPad;

@property (nonatomic, strong) soundFX *sfx;


@end

