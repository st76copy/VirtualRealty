//
//  SQLiteRequestQueue.h
//  SQLiteTest
//
//  Created by Chris on 8/8/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLRequest.h"

typedef void (^SQLiteQueueCompleteBlock) (BOOL success);

@interface SQLiteRequestQueue : NSObject
{
    BOOL requestDidEror;
    int  requestIndex;
}

-(id)initWithRequests:(NSArray *)requests;
-(void)runQueue:(SQLiteQueueCompleteBlock)block;

@property(nonatomic, strong, readonly)NSArray      *requestQueue;
@property(nonatomic, strong, readonly)NSDictionary *results;
@property(nonatomic, copy)SQLiteQueueCompleteBlock  completeBlock;
@end
