//
//  SQLiteManager.m
//  SQLiteTest
//
//  Created by Chris on 8/7/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "SQLiteManager.h"

@interface SQLiteManager()
{
    sqlite3_stmt     *_databaseStatement;
}

-(BOOL)isDatabaseVersionCorrect;
-(BOOL)loadFile;
-(BOOL)removeDatabaseFile;

@end

@implementation SQLiteManager

@synthesize databaseFilePath  = _databaseFilePath;
@synthesize database          = _database;
@synthesize databaseQueue     = _databaseQueue;


+(SQLiteManager *)sharedDatabase
{
    static dispatch_once_t onceToken;
    static SQLiteManager *instance;
    
    dispatch_once(&onceToken, ^
    {
        instance = [[SQLiteManager alloc]init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if( self != nil )
    {
        _databaseQueue = dispatch_queue_create(kDATABASE_QUEUE, NULL);
    }
    return self;
}

-(void)setUp:( void (^) (DatabaseState state) )successBlock;
{
    _database = NULL;
    DatabaseState state = kDatabaseValid;
    
    if( [self loadFile]  )
    {
        if( [self isDatabaseVersionCorrect] == NO )
        {
            [self removeDatabaseFile];
            [self loadFile];
            state = kDatabaseUpdated;
        }
        
        int success = sqlite3_open([_databaseFilePath UTF8String], &_database);
        
        if( success == SQLITE_OK )
        {
            _databaseStatement = nil;
        }
        else
        {
            state = kDatabaseError;
        }
    }
    else
    {
        state = kDatabaseError;
    }
    successBlock(state);
}


-(BOOL)loadFile
{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSError       *error;
    NSArray       *paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString      *docs         = [paths objectAtIndex:0];
    NSString      *writePath    = [docs stringByAppendingFormat:@"/%@", kDATABASE_FILE_NAME];
    NSString      *resourcePath = nil;
    
    BOOL exists = [fileManager fileExistsAtPath:writePath];
    BOOL writeSuccess = NO;
    
    if( exists )
    {
        _databaseFilePath = writePath;
        writeSuccess = YES;
    }
    else
    {
        resourcePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingFormat:@"/%@", kDATABASE_FILE_NAME];
        writeSuccess = [fileManager copyItemAtPath:resourcePath toPath:writePath error:&error];
        
        if( writeSuccess )
        {
            NSString *dbversion = [NSString stringWithFormat:@"%f", kDATABASE_VERSION];
            [[NSUserDefaults standardUserDefaults]setValue:dbversion forKey:kDATABASE_VERSION_KEY];
            [[NSUserDefaults standardUserDefaults]synchronize];
            _databaseFilePath = writePath;
        }
    }
    return writeSuccess;
}

-(BOOL)removeDatabaseFile
{
    NSError       *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray       *paths       = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString      *docs        = [paths objectAtIndex:0];
    NSString      *path        = [docs stringByAppendingFormat:@"/%@", kDATABASE_FILE_NAME];
    
    [fileManager removeItemAtPath:path error:&error];
    
    return (error == nil)? YES : NO;

}

-(BOOL)isDatabaseVersionCorrect
{
    float defautlsVersion = [[[NSUserDefaults standardUserDefaults]valueForKey:kDATABASE_VERSION_KEY]floatValue];
    return (kDATABASE_VERSION == defautlsVersion) ? YES : NO;
}

-(NSArray *)performSelect:(SQLRequest *)request
{
    sqlite3_reset(_databaseStatement);
    
    const char *sql    = [request.query UTF8String];
    int statementReady = sqlite3_prepare_v2(self.database, sql, -1, &_databaseStatement, NULL);
    int count          = 0;
    
    NSMutableArray      *queryResults = [NSMutableArray array];
    NSMutableDictionary *resultRow    = nil;
    
    if(statementReady == SQLITE_OK)
    {
        while( sqlite3_step(_databaseStatement) == SQLITE_ROW )
        {
            resultRow = [NSMutableDictionary dictionary];
            count     = sqlite3_column_count(_databaseStatement);
            for(int i = 0; i < count; i++ )
            {
                
                char *nameChar  = (char *)sqlite3_column_name(_databaseStatement, i);
                char *valueChar = (char *)sqlite3_column_text(_databaseStatement, i);
                
                if( nameChar != NULL && valueChar != NULL )
                {
                    NSString *name  = [NSString stringWithUTF8String:nameChar ];
                    NSString *value = [NSString stringWithUTF8String:valueChar];
                    [resultRow setValue:value forKey:name];
                }
            }
            [queryResults addObject:resultRow];
        }
    }
    else
    {
        queryResults = nil;
        [request setErrorMessage:[NSString stringWithUTF8String:sqlite3_errmsg(self.database)]];
    }
    return queryResults;
}

-(BOOL)performAction:(SQLRequest *)request
{
    
    sqlite3_reset(_databaseStatement);
    
    BOOL success       = NO;
    const char *sql    = [request.query UTF8String];
    int statementReady = sqlite3_prepare_v2(self.database, sql, -1, &_databaseStatement, NULL);
    
    if( statementReady == SQLITE_OK )
    {
        if(sqlite3_step(_databaseStatement) == SQLITE_DONE )
        {
            success = YES;
        }
        else
        {
            [request setErrorMessage:[NSString stringWithUTF8String:sqlite3_errmsg(self.database)]];
            success = NO;
        }
    }
    else
    {
        [request setErrorMessage:[NSString stringWithUTF8String:sqlite3_errmsg(self.database)]];
        success = NO;
    }
    sqlite3_reset(_databaseStatement);
    return  success;
}


@end
