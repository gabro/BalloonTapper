//
//  BTAPI.h
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTSession;
@class BTTap;

@interface BTAPI : NSObject

+ (BTAPI *)sharedInstance;

- (void)startSessionForGameMode:(GameMode)gameMode
                     completion:(void (^)(BTSession * newSession))completion
                       failure:(void (^)(NSError *))failure;

- (void)postTap:(BTTap *)tap
      toSession:(BTSession *)session
     completion:(void (^)())completion
        failure:(void (^)(NSError *))failure;

- (void)postSession:(BTSession *)session
         completion:(void(^)())completion
            failure:(void(^)(NSError * error))failure;

@end
