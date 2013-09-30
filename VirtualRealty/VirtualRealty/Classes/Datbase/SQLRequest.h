//
//  SQLRequest.h
//  SQLiteTest
//
//  Created by Chris on 8/7/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLiteManager;

typedef enum SQLRequestType
{
    kInsert,
    kSelect,
    kDelete,
    kUpdate
}SQLRequestType;

typedef void (^SQLRequestCompleteBlock) (BOOL success);

@interface SQLRequest : NSObject

-(id)initWithQuery:(NSString *)value andType:(SQLRequestType)type andName:(NSString *)queryName;

-(void)runSelectOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block;
-(void)runInsertOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block;
-(void)runUpdateOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block;
-(void)runDeleteOnDatabaseManager:(SQLiteManager *)manager WithBlock:(SQLRequestCompleteBlock )block;

-(void)queryThreadComplete;
-(void)setErrorMessage:(NSString *)errorMessage;

@property(nonatomic, strong, readonly)NSString *query;
@property(nonatomic, strong, readonly)NSArray  *results;
@property(nonatomic, strong, readonly)NSString *errorMessage;
@property(nonatomic, assign, readonly)SQLRequestType type;
@property(nonatomic, copy)SQLRequestCompleteBlock completeBlock;
@property(nonatomic, strong)NSString *requestName;

@end
