//
//  SQLRequest.m
//  SQLiteTest
//
//  Created by Chris on 8/7/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "SQLRequest.h"
#import "SQLiteManager.h"

@implementation SQLRequest

@synthesize requestName;
@synthesize completeBlock;

@synthesize errorMessage = _errorMessage;
@synthesize query        = _query;
@synthesize results      = _results;
@synthesize type         = _type;

-(id)initWithQuery:(NSString *)value andType:(SQLRequestType)type andName:(NSString *)queryName
{
    self = [super init];
    if( self != nil )
    {
        self.requestName = queryName;
        _type  = type;
        _query = value;
    }
    return self;
}

-(void)runSelectOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block
{
    _type = kSelect;
    self.completeBlock = block;
    dispatch_async(manager.databaseQueue, ^
    {
        
        _results = [manager performSelect:self];
                
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self queryThreadComplete];
        });
    });
}

-(void)runInsertOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block
{
    _type = kInsert;
    self.completeBlock = block;
    dispatch_async(manager.databaseQueue, ^
    {
        
        [manager performAction:self];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self queryThreadComplete];
        });
    });
}


-(void)runUpdateOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block
{
    _type = kUpdate;
    self.completeBlock = block;
    dispatch_async(manager.databaseQueue, ^
    {
        [manager performAction:self];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self queryThreadComplete];
        });
    });
}

-(void)runDeleteOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock)block
{
    _type = kDelete;
    self.completeBlock = block;
    dispatch_async(manager.databaseQueue, ^
    {
       
        [manager performAction:self];
       
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self queryThreadComplete];
        });
    });
}

-(void)queryThreadComplete
{
    self.completeBlock(YES);
}

-(void)setErrorMessage:(NSString *)errorMessage
{
    _errorMessage = errorMessage;
}

@end
