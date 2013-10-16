//
//  AppDelegate.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AppDelegate.h"
#import "ReachabilityManager.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import <Parse/Parse.h>
#import "LocationManager.h"
#import "FacebookManager.h"
#import "LoadingView.h"
#import "SQLiteManager.h"

@interface AppDelegate()
-(void)handleReachabilityKnow;
-(void)initViewControllers;
-(void)initThirdPartySDKs;
-(void)handleNavigationRequest:(NSDictionary *)info;
-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)sender;
-(void)handleSwipeRight:(UISwipeGestureRecognizer *)sender;
@end

@implementation AppDelegate

@synthesize nav         = _nav;
@synthesize section     = _section;
@synthesize loadingView = _loadingView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = [[LoadingViewController alloc]initWithNibName:nil bundle:nil];
    self.window.backgroundColor    = [UIColor whiteColor];
    
    [[SQLiteManager sharedDatabase]setUp:^(DatabaseState state) {
        switch (state) {
            case kDatabaseError :
                break;
                
            case kDatabaseUpdated :
                break;
                
            case kDatabaseValid :
                break;
            
            case kDatabaseInvalid :
                break;
        }
    }];
    
    _loadingView = [[LoadingView alloc]initWithFrame:self.window.frame];
    __block AppDelegate *blockself = self;
    
    [[ReachabilityManager sharedManager]startChecking:^
    {
        [blockself handleReachabilityKnow];
    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

-(void)handleReachabilityKnow
{
    [User sharedUser];
    [[LocationManager shareManager]startGettingLocations];
    [self initThirdPartySDKs];
    [self initViewControllers];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeft:)];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeRight:)];
    
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.window addGestureRecognizer:leftSwipe];
    [self.window addGestureRecognizer:rightSwipe];

}

-(void) initViewControllers
{
    switch ([Utils getDevice])
    {
        case kiPad:
        {
            
        }
        break;
            
        default:
        {
            self.window.rootViewController = nil;
            
            __block AppDelegate *blockself = self;
            _nav = [[NavViewController alloc]initWithNibName:nil bundle:nil];
            
            UIViewController *rootViewController = [[FeaturedViewController alloc]initWithNibName:nil bundle:nil];
            
            CGRect rect;
            _section = [[UINavigationController alloc]initWithRootViewController:rootViewController];
            
            rect = self.section.view.frame;
            rect.origin = CGPointMake(0, 0);
            [self.section.view setFrame:rect];
            
            [_nav addChildViewController:self.section];
            [_nav.view addSubview:self.section.view];
            [_nav loadNavigation];
            [_nav setSelectBlock:^(NSDictionary *info)
            {
                [blockself handleNavigationRequest:info];
            }];
            
            self.window.rootViewController = self.nav;

        }
        break;
    }
}

-(void)handleNavigationRequest:(NSDictionary *)info
{
    if( [[info valueForKey:@"requires-user"]boolValue] == YES )
    {
        if( [User sharedUser].state == kNoUser )
        {
            [self showlogin];
        }
        else
        {
            AbstractViewController *vc = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithNibName:nil bundle:nil];
            self.section.viewControllers = @[vc];
            [vc toggleMenu];
        }
    }
    else
    {
        AbstractViewController *vc = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithNibName:nil bundle:nil];
        self.section.viewControllers = @[vc];
        [vc toggleMenu];
    }
}

-(void)showlogin
{
    LoginViewController *login = [[LoginViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:login];
    [self.window.rootViewController presentViewController:nc animated:YES completion:nil];
}

-(void)initThirdPartySDKs
{
    [Parse setApplicationId:@"yIp5Z8ERGHY8ELMVvfo4kGJuACTMUPNh5zxGhGuB" clientKey:@"A5Fo3tdmadYS6CWcq7LdpIuisHjCv63C5QSau7ii"];
}

- (void)applicationWillResignActive:(UIApplication *)application{}
- (void)applicationWillEnterForeground:(UIApplication *)application{}
- (void)applicationWillTerminate:(UIApplication *)application{}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[FacebookManager sharedManager].currentSession ];
}

-(void)showLoader
{
    [self.window.rootViewController.view addSubview:self.loadingView];
    [self.loadingView show];
}

-(void)hideLoader
{
    [self.loadingView hide];
}

#pragma mark - window getstures
-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.section.view.frame;
        rect.origin.x = 0;
        self.section.view.frame = rect;
        AbstractViewController *avc =(AbstractViewController *)[self.section.viewControllers objectAtIndex:0];
        [avc setActive:YES];
    }];

}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.3 animations:^
    {
        CGRect rect = self.section.view.frame;
        rect.origin.x = 260;
        self.section.view.frame = rect;
        AbstractViewController *avc = (AbstractViewController *)[self.section.viewControllers objectAtIndex:0];
        [avc setActive:NO];
    }];
}

@end
