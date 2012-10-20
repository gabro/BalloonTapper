//
//  BTAPI.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTSession;

@interface BTAPI : NSObject

+ (BTAPI *)sharedInstance;

- (void)postSession:(BTSession *)session
         completion:(void(^)())completion
            failure:(void(^)(NSError * error))failure;

@end
