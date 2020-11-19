//
//  AppDelegate.m
//  ipumpi
//
//  Created by Dave Scruton on 11/18/20.
//  Copyright © 2020 ipumpi. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"tVmzO94zgfGDzoDahWHBoNm9Vk5NgnzNLUgERRSO";
        configuration.clientKey     = @"NzXMo1yNoNQsyVdkYo9pTWHSzkkNVGSn5QO9ERUR";
        configuration.server        = @"https://pg-app-tinri4199t6zwqeww9u6jx9c6a0cr5.scalabl.cloud/1/";
    }]];

    
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
