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

@dynamic taps;

+ (BTSession *)session {
    return [[BTSession alloc] init];
}

@end
