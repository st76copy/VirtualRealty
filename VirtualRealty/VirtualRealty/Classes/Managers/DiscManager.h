//
//  SSICacheManager.h
//  shutterstock-ios
//
//  Created by Chris on 4/8/13.
//
//

#import <Foundation/Foundation.h>

typedef void (^CacheManagerDiscActionBlock) (BOOL success, NSError *errorOrNil, NSData *fileDataOrNil );

@interface DiscManager : NSObject

+(DiscManager *)sharedManager;

-(void)saveFileWithName:(NSString *)filename withData:(NSData *)data saveCompleteBlock:(CacheManagerDiscActionBlock )block;
-(BOOL )fileExistsOnDisc:(NSString *)filename;
-(void)loadFileWithName:(NSString *)filename completeBlock:( CacheManagerDiscActionBlock )block;

-(void)flushCacheWithBlock:(CacheManagerDiscActionBlock )block;
-(float)getAvailbleDiscSpace;

-(void)deleteFileWithName:(NSString *)name completeBlock:( void (^) (void) )block;
-(void)getTotalNumberOfFiles:( void (^) (int totalFiles) )block;
-(void)getTotalSpaceUsed:( void (^) (float spaceUsed) )block;
-(void)archiveCacheList;
-(BOOL)isCacheFull;
-(void)save;


@property(nonatomic, strong, readonly)dispatch_queue_t writeQueue;
@property(nonatomic, strong, readonly)dispatch_queue_t readQueue;
@property(nonatomic, strong, readonly)dispatch_queue_t deleteQueue;

@property(nonatomic, assign)float cacheSize;
@property(nonatomic, copy)CacheManagerDiscActionBlock discActionBlock;
@property(nonatomic, strong, readonly)NSMutableArray *cache;


@end
