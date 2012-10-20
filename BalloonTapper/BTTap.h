//
//  BTTap.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTSession;

@interface BTTap : NSManagedObject

@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) BTSession *session;

+ (BTTap *)tapWithTime:(NSTimeInterval)time;

@end
