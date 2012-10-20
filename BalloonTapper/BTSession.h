//
//  BTSession.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTTap;

@interface BTSession : NSObject

@property (nonatomic, retain) NSArray * taps;

+ (BTSession *)session;

- (NSDictionary *)json;

- (void)addTap:(BTTap *)tap;

@end