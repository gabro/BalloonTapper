//
//  BTTap.m
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import "BTTap.h"
#import "BTSession.h"


@implementation BTTap

@dynamic time;
@dynamic session;

- (id)initWithTime:(NSTimeInterval)interval {
    if (self = [super init]) {
        self.time = @(interval);
    }
    return self;
}

+ (BTTap *)tapWithTime:(NSTimeInterval)time {
    return [[BTTap alloc] init];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Tap %f", self.time.floatValue];
}

@end
