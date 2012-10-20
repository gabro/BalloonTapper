//
//  BTSession.m
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import "BTSession.h"
#import "BTTap.h"


@implementation BTSession

+ (BTSession *)session {
    return [[BTSession alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _taps = [NSArray array];
    }
    return self;
}

- (NSDictionary *)json {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSMutableArray * taps = [NSMutableArray arrayWithCapacity:self.taps.count];
    for (BTTap * tap in self.taps) {
            [taps addObject:tap.json];
    }
    dict[@"taps"] = taps;
    return dict;
}

- (void)addTap:(BTTap *)tap {
    self.taps = [self.taps arrayByAddingObject:tap];
}

@end
