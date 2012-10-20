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

- (id)initWithTime:(NSTimeInterval)time {
    if (self = [super init]) {
        _time = time;
    }
    return self;
}

+ (BTTap *)tapWithTime:(NSTimeInterval)time {
    return [[BTTap alloc] initWithTime:time];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Tap %f", self.time];
}

- (NSDictionary *)json {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[@"time"] = @(self.time);
    return dict;
}

@end
