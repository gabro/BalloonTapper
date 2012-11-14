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

+ (BTSession *)sessionWithJSON:(NSDictionary *)json {
    BTSession * session = [BTSession session];
    session.sessionId = json[@"_id"];
    for (NSDictionary * tapDict in json[@"taps"]) {
        // TODO initialize the taps
    }
    return session;
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
    dict[@"_id"] = self.sessionId;
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

- (int)tapCount {
    return [self.taps count];
}

@end
