//
//  SSIReachabilityManager.h
//  shutterstock-ios
//
//  Created by Chris on 4/12/13.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define hostname @"www.shutterstock.com"

@protocol ReachabilityProtocal <NSObject>
@required
-(void)reachablityDidChange;
-(BOOL)removeFromQueueAfterChangeEvent;
@end

typedef void (^ReachabilityInitializedBlock) (void);

@interface ReachabilityManager : NSObject
{
    NSMutableArray *changeQueue;
}

+(ReachabilityManager *)sharedManager;

// Takes an initialization block, this is for the first call and
// @property currentStatus defaults to 3 or unknown, block is internally set to nill
// after fired once 
-(void)startChecking:(ReachabilityInitializedBlock )block;

// removed notification , and clears changeQueue, set @property isInitailized to NO
-(void)stopChecking;

// should move this error over to error factory, bad UI code mixed into logic code
-(void)showAlert;

// Adds an object conforming to ReachabilityProtocal interface to a queue, object are required the two methods
// When reachabilty is changed, the methods in the changeQueue array have the two methods called
-(void)registerChangeBlockForObject:(id<ReachabilityProtocal>)object;

// used to check to see if the SSIReachabilityManager has gotten its first status change event
@property(nonatomic, assign, readonly)BOOL isInitialized;

// used for any manually created NSError objects pertaining to a "No Internet Connection" error
@property(nonatomic, strong, readonly)NSString         *errorDomain;

// Callled only on first change , unless 
@property(nonatomic, copy)ReachabilityInitializedBlock initBlock;

// Default is set to 3 , internally, gets set for the first time after the first "change event" gets called
@property(nonatomic, assign, readonly)NetworkStatus currentStatus;

@property(nonatomic, strong, readonly)Reachability  *reachability;

@end
