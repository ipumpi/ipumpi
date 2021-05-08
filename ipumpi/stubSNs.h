//
//  stubSNs.h
//  ipumpi
//
//  Created by Dave Scruton on 5/7/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface stubSNs : NSObject

@property (nonatomic , strong) NSArray* snStrings;

+ (id)sharedInstance;

@end

NS_ASSUME_NONNULL_END
