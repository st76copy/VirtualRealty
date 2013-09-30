//
//  SSIWebRequest.m
//  Contributor
//
//  Created by Chris on 8/27/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//


#import "JSONService.h"
#import "Utils.h"

@interface JSONService()
-(void)handleRequestComplete;
@end


@implementation JSONService

@synthesize json      = _json;
@synthesize request   = _request;
@synthesize operation = _operation;
@synthesize client    = _client;
@synthesize error     = _error;
@synthesize completeBlock;

-(id)initWithRequest:(NSMutableURLRequest *)request client:(AFHTTPClient *)client andSuccessBlock:(WebRequestCompleteBlock)block
{
    self = [super init];
    if( self )
    {
        _client  = client;
        _request = request;
        self.completeBlock = block;
    }
    return self;
}

-(void)start
{
    __block JSONService *blockService = self;
    
    _operation = [self.client HTTPRequestOperationWithRequest:self.request success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if( [[[operation.response allHeaderFields]valueForKey:@"Content-Type"] isEqualToString:@"application/json"] )
        {
            _json = responseObject;
        }
        else
        {
            _json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        }

        [blockService handleRequestComplete];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        _error = error;
        blockService.completeBlock( blockService, NO );
    }];
    
    [_operation start];
}

-(void)cancel
{
    [_operation setCompletionBlockWithSuccess:nil failure:nil];
    [_operation cancel];
}

-(void)handleRequestComplete
{
    self.completeBlock([Utils blockSafeInstanceOf:self], YES);
}

-(void)destroy
{
    [self cancel];
    _operation = nil;
    _request   = nil;
    _client    = nil;
    _json      = nil;
    _operation = nil;
}

@end
