//
//  SSIWebRequest.h
//  Contributor
//
//  Created by Chris on 8/27/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class JSONService;
typedef  void (^WebRequestCompleteBlock ) (JSONService *blockrequest, BOOL success);

@interface JSONService : NSObject

-(id)initWithRequest:(NSMutableURLRequest *)request client:(AFHTTPClient *)client andSuccessBlock:( WebRequestCompleteBlock )block;
-(void)start;
-(void)cancel;
-(void)destroy;
@property(nonatomic, strong, readonly)AFHTTPClient           *client;
@property(nonatomic, strong, readonly)AFHTTPRequestOperation *operation;
@property(nonatomic, strong, readonly)NSMutableURLRequest    *request;
@property(nonatomic, strong, readonly)id                      json;
@property(nonatomic, strong, readonly)NSError                *error;
@property(nonatomic, assign)int                               uid;
@property(nonatomic, copy)WebRequestCompleteBlock             completeBlock;
@end
