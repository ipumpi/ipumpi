//
//  AppDelegate.m
//  ipumpi
//
//  Created by Dave Scruton on 11/18/20.
//  Copyright © 2020 ipumpi. All rights reserved.
//

#import "AppDelegate.h"
#define USE_SFX
@interface AppDelegate ()

@end

@implementation AppDelegate

#define NUM_SFX_SAMPLES 9
NSString *hdkSoundFiles[NUM_SFX_SAMPLES] =
{
    @"clave0044k",          //00:click sound
    @"karate44k",           //01:Opening sound
    @"snap44k",             //02:tile sound
    @"bigweiner",           //03:win sound
    @"lilglock",            //04:glockinspiel trimmed
    @"congamid44k",         //05
    @"timer44k",            //06 secret sound
    @"bub1",                //07 Squirrel Sound
    @"clave0044k"           //08:click sound
};

//=========ipumpi appDelegate=================================================
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"tVmzO94zgfGDzoDahWHBoNm9Vk5NgnzNLUgERRSO";
        configuration.clientKey     = @"NzXMo1yNoNQsyVdkYo9pTWHSzkkNVGSn5QO9ERUR";
        configuration.server        = @"https://pg-app-tinri4199t6zwqeww9u6jx9c6a0cr5.scalabl.cloud/1/";
    }]];

    //Start up sfx...
    _sfx = [soundFX sharedInstance];

    #ifdef USE_SFX
        //Load Audio Sample files...
        _sfx = [soundFX sharedInstance];
        for (int i=0;i<NUM_SFX_SAMPLES;i++)
        {
            [_sfx setSoundFileName:i :hdkSoundFiles[i]];
        }
        //For now, load ALL audio in background: mixed foreground/background audio loading was
        //  causing data corruption in the sound buffers. We will have to accept no "bong" sound
        //STill getting audio weirdness: Load in bkgd 99 seems to load up every sample but 1,
        //  while loadAudio (foreground) produces all null audio or static!
        [_sfx loadAudioBKGD:-1]; ///6]; //Load all samples except 6 in bkgd, 6 loads immediately...
    #endif

//    https://pg-app-tinri4199t6zwqeww9u6jx9c6a0cr5.scalabl.cloud/
    
    
    return YES;
}




#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
