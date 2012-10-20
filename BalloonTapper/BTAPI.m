//
//  BTAPI.m
//  BalloonTapper
//
//  Created by Gabriele Petronella on 10/20/12.
//  Copyright (c) 2012 HCI. All rights reserved.
//

#import "BTAPI.h"
#import "AFNetworking.h"
#import "BTSession.h"

#define BTAPI_BASE_URL @"http://localhost:4567"
#define BT_POST_SESSION @"/session"

@interface BTAPI ()
@property(nonatomic, strong) AFHTTPClient * httpClient;
@end

@implementation BTAPI

+(BTAPI *)sharedInstance {
    static dispatch_once_t pred;
    static BTAPI * shared = nil;
    dispatch_once(&pred, ^{
        shared = [[BTAPI alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BTAPI_BASE_URL]];
    }
    return self;
}

- (void)postSession:(BTSession *)session
         completion:(void(^)())completion
            failure:(void(^)(NSError * error))failure {
    NSString * path = [NSString stringWithFormat:BT_POST_SESSION];
    NSDictionary * params = [session json];
    NSMutableURLRequest * urlRequest = [self.httpClient requestWithMethod:@"POST"
                                                                     path:path
                                                               parameters:params];

    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        completion();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    NSOperationQueue * queue = [NSOperationQueue new];
    [queue addOperation:operation];
}

@end
