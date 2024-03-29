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

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSArray * taps;
@property (nonatomic, assign) GameMode gameMode;

+ (BTSession *)session;
+ (BTSession *)sessionWithJSON:(NSDictionary *)json;

- (NSDictionary *)json;

- (void)addTap:(BTTap *)tap;

- (int)tapCount;

@end