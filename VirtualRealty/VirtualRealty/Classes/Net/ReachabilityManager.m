//
//  SSIReachabilityManager.m
//  shutterstock-ios
//
//  Created by Chris on 4/12/13.
//
//

#import "ReachabilityManager.h"

@interface ReachabilityManager()
{
    BOOL isInitialized;
}

-(void)reachabilityChanged:(NSNotification *)note;

@end

@implementation ReachabilityManager

@synthesize isInitialized = _isInitialized;
@synthesize errorDomain   = _errorDomain;
@synthesize currentStatus = _currentStatus;
@synthesize reachability  = _reachability;

+(ReachabilityManager *)sharedManager
{
    static ReachabilityManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[ReachabilityManager alloc]init];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        // default to unknown
        
        changeQueue   = [NSMutableArray array];
        _isInitialized = NO;
        _errorDomain   = @"not reachable";
        _currentStatus = 3;
        _reachability  = [Reachability reachabilityWithHostname:hostname];
       
    }
    return self;
}

-(void)startChecking:(ReachabilityInitializedBlock)block
{
    if(self.currentStatus == 3)
    {
        self.initBlock = block;
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification  object:nil];
        [_reachability startNotifier];
    }
}

-(void)reachabilityChanged:(NSNotification *)note
{
    _currentStatus = [_reachability currentReachabilityStatus];
    
    if( _isInitialized == NO )
    {
        _isInitialized = YES;
        self.initBlock();
        self.initBlock = nil;
    }
    
    for( id<ReachabilityProtocal> object in changeQueue )
    {
        [object reachablityDidChange];
        if( [object removeFromQueueAfterChangeEvent])
        {
            [changeQueue removeObject:object];
        }
    }
}

-(void)stopChecking
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
    [_reachability stopNotifier];
    [changeQueue removeAllObjects];
    _isInitialized = NO;
}

-(void)showAlert
{
    NSString *title = NSLocalizedString(@"Sorry", @"Genereic : sorry");
    NSString *msg   = NSLocalizedString(@"An internet connection is required for this action.", @"Genereic : no internet error");
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK" , @"OK") otherButtonTitles:nil];
    [av show];
}

-(void)registerChangeBlockForObject:(id<ReachabilityProtocal>)object
{
    // make sure we have only one referance to an object in the queue
    if( [changeQueue containsObject:object] == NO )
    {
        [changeQueue addObject:object];
    }
}
@end
