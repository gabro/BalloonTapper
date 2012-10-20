//
//  BTSession.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTTap;

@interface BTSession : NSManagedObject

@property (nonatomic, retain) NSSet *taps;

+ (BTSession *)session;

@end

@interface BTSession (CoreDataGeneratedAccessors)

- (void)addTapsObject:(BTTap *)value;
- (void)removeTapsObject:(BTTap *)value;
- (void)addTaps:(NSSet *)values;
- (void)removeTaps:(NSSet *)values;

@end
