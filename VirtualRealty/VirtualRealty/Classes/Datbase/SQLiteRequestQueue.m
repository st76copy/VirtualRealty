//
//  SQLiteRequestQueue.m
//  SQLiteTest
//
//  Created by Chris on 8/8/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "SQLiteRequestQueue.h"
#import "SQLiteManager.h"
@interface SQLiteRequestQueue()
{
    NSMutableDictionary *tempResults;
}
-(void)allRequestsFinished;
@end

@implementation SQLiteRequestQueue

@synthesize results = _results;
@synthesize requestQueue = _requestQueue;

-(id)initWithRequests:(NSArray *)requests
{
    self = [super init];
    if( self != nil )
    {
        requestDidEror = NO;
        requestIndex   = 0;
        _requestQueue  = requests;
        tempResults    = [NSMutableDictionary dictionary];
        
        for( SQLRequest *req in self.requestQueue )
        {
            NSAssert(req.requestName != nil, @"SQLiteRequestQueue : queue requires all request object to be named 'requst.requestName' is used for key value of results object");
        }
    }
    return self;
}

-(void)runQueue:(SQLiteQueueCompleteBlock)block
{
    self.completeBlock = block;
    
    if( requestIndex == self.requestQueue.count )
    {
        [self allRequestsFinished];
        return;
    }
    
    __block SQLiteRequestQueue *blockself = self;
    __block SQLRequest *req = self.requestQueue[requestIndex];
        
    [req runSelectOnDatabaseManager:[SQLiteManager sharedDatabase] WithBlock:^(BOOL success)
    {
        if( req.errorMessage == nil)
        {
            if( req.type == kSelect )
            {
                [tempResults setValue:req.results forKey:req.requestName];
            }
            
            requestIndex++;
            [blockself runQueue:blockself.completeBlock];
        }
        else
        {
            requestDidEror = YES;
            [blockself allRequestsFinished];
        }
    }];
}

-(void)allRequestsFinished
{
    _results = [tempResults copy];
    [tempResults removeAllObjects];
    self.completeBlock(!requestDidEror);
}

@end
