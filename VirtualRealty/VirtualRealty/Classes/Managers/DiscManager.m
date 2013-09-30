//
//  SSICacheManager.m
//  shutterstock-ios
//
//  Created by Chris on 4/8/13.
//
//

#import "DiscManager.h"
#import "Utils.h"

#define  archiveName @"cache.archive"

@interface DiscManager()

-(void)loadArchiveCacheList;
-(BOOL)fileFitsInAvailableSpace:(NSData *)data;
@end

@implementation DiscManager

@synthesize discActionBlock;
@synthesize cache = _cache;
@synthesize cacheSize;
@synthesize readQueue = _readQueue;
@synthesize writeQueue = _writeQueue;
@synthesize deleteQueue = _deleteQueue;

+(DiscManager *)sharedManager
{
    static DiscManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[DiscManager alloc]init];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    if( self )
    {
        self.cacheSize = 4 * 1024 *1024; // 4mb
        
        _writeQueue   = dispatch_queue_create("disc.writequeue",  0);
        _readQueue    = dispatch_queue_create("disc.readqueue",   0);
        _deleteQueue  = dispatch_queue_create("disc.deletequeue", 0);
        [self loadArchiveCacheList];
    }
    return self;
}

-(void)saveFileWithName:(NSString *)filename withData:(NSData *)data saveCompleteBlock:(CacheManagerDiscActionBlock )block
{
         
    if( [self fileExistsOnDisc:filename] == NO )
    {
        dispatch_async(self.writeQueue, ^
        {
            NSString *filePath  = [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], filename];
            NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:[data length]] forKey:NSFileSize];
        
            BOOL success = [[NSFileManager defaultManager]createFileAtPath:filePath contents:data attributes:attrs];
        
            if( success )
            {
                dispatch_sync(dispatch_get_main_queue(), ^
                {
                    [_cache addObject:filename];
                    if(block){ block(YES, nil, nil); }
                });
            }
            else
            {
                // leave commented out so its easy to debug this error : 4-12-2013 in the year of our lord
                // NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
                dispatch_sync(dispatch_get_main_queue(), ^
                {
                    if( block ) { block(NO, nil, nil); }
                });
            }
        });
        
    }
    else
    {
        if( block ){block( NO, nil, nil);}
    }
}

-(BOOL )fileExistsOnDisc:(NSString *)filename
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], filename];
    return [[NSFileManager defaultManager]fileExistsAtPath:filePath];
}


// runs on a queue system, do not save blocks as properties as which object it will fire back to will not
// be consistant
-(void)loadFileWithName:(NSString *)filename completeBlock:( CacheManagerDiscActionBlock )block
{
    
    dispatch_async(self.readQueue, ^
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], filename];
        NSData   *data     = [[NSFileManager defaultManager]contentsAtPath:filePath];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            block(YES, nil, data);
        });
    });
}

-(void)deleteFileWithName:(NSString *)name completeBlock:( void (^) (void) )block
{

    NSString *filePath =  [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], name];
   
    dispatch_async(self.deleteQueue, ^
    {
        NSError *error;
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];
        int index = 0;
      
        for( NSString *cacheName in _cache )
        {
            if( [cacheName isEqualToString:name] )
            {
                break;
                [_cache removeObjectAtIndex:index];
                index ++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if( block )
            {
                block();
            }
        });
    });
}

-(void)flushCacheWithBlock:(CacheManagerDiscActionBlock )block
{
    dispatch_async( self.writeQueue , ^{
       
        NSString *filePath = nil;
        NSString *fileName = nil;
        
        for( fileName in _cache  )
        {
            NSError *error;
            filePath =  [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], fileName];
            if( [self fileExistsOnDisc:fileName])
            {
                [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];
            }
        }
        
        [_cache removeAllObjects];
        
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            if( block )
            {
                block(YES, nil , nil);
            }
            
        });
    });
}

-(void)save
{
    [self archiveCacheList];
    self.discActionBlock = nil;
}

-(BOOL)isCacheFull
{
    return NO;
}

-(float)getAvailbleDiscSpace
{
    return 1.0f;
}

-(void)archiveCacheList
{
    if( _cache != nil || [_cache count] > 0 )
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], archiveName];
        [NSKeyedArchiver archiveRootObject:self.cache toFile:filePath ];
    }
}

-(void)loadArchiveCacheList
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], archiveName];
    _cache  = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if( _cache == nil  || [_cache count] == 0  )
    {
        _cache = [NSMutableArray array]; 
    }
}

-(void)getTotalNumberOfFiles:( void (^) (int totalFiles) )block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Utils getDocsDirectory] error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            block( [directoryContent count] );
        });
    });
}

-(void)getTotalSpaceUsed:( void (^) (float spaceUsed) )block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Utils getDocsDirectory] error:NULL];
        float filesize = 0.0f;
        
        for( NSString *file in directoryContent  )
        {
            NSString      *path = [NSString stringWithFormat:@"%@/%@", [Utils getDocsDirectory], file];
            NSDictionary  *att  = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil];
            NSNumber      *num  = [att valueForKey:NSFileSize];
            filesize += [num floatValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            block( (float)filesize );
        });
    });
}

//TODO : Finish method
-(BOOL)fileFitsInAvailableSpace:(NSData *)data
{
    return YES;
}

@end
