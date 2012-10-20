//
//  BTTap.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTSession;

@interface BTTap : NSObject

@property (nonatomic, assign) NSTimeInterval time;

+ (BTTap *)tapWithTime:(NSTimeInterval)time;

- (NSDictionary *)json;

@end
