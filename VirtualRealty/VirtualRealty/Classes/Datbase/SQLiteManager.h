//
//  SQLiteManager.h
//  SQLiteTest
//
//  Created by Chris on 8/7/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SQLRequest.h"

#define kDATABASE_VERSION_KEY   @"database-version-key"
#define kDATABASE_FILE_NAME     @"virtualrealty.sqlite"
#define kDATABASE_QUEUE         "com.vr.virtualrealty.dbqueue"
#define kDATABASE_VERSION       1.1f

typedef enum DatabaseState
{
    kDatabaseValid,
    kDatabaseInvalid,
    kDatabaseUpdated,
    kDatabaseError
}DatabaseState;


@interface SQLiteManager : NSObject
{

}


@property(nonatomic, assign, readonly)sqlite3          *database;
@property(nonatomic, strong, readonly)dispatch_queue_t  databaseQueue;
@property(nonatomic, strong, readonly)NSString         *databaseFilePath;

+(SQLiteManager *)sharedDatabase;
-(void)setUp:( void (^) (DatabaseState state) )successBlock;


-(NSArray *)performSelect:(SQLRequest *)request;
-(BOOL)performAction:(SQLRequest *)query;

@end
