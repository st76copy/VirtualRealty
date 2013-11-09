//
//  FacebookManager.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FacebookManager.h"

@interface FacebookManager()

-(void)handleResultsLoaded:(NSDictionary *)results;
-(void)handleLoggedIn:(FBSession *)activeSession;
@end

@implementation FacebookManager

@synthesize fbid            = _fbid;
@synthesize currentSession  = _currentSession;
@synthesize email           = _email;
@synthesize connection      = _connection;
@synthesize token           = _token;
@synthesize tokenExpiration = _tokenExpiration;

+(FacebookManager *)sharedManager
{
    static FacebookManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        instance = [[FacebookManager alloc]init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    if( self != nil )
    {
        _connection = [[FBRequestConnection alloc] init];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _token = [defaults valueForKey:@"token"];
        _tokenExpiration = [defaults valueForKey:@"tokenExpiration"];
        _fbid = [defaults valueForKey:@"fbid"];

    }
    return self;
}

-(void)login:(FacebookLoginBlock)block
{
    self.loginBlock = block;
    
    __block FacebookManager *blockself = self;
    NSLog(@"%@ trying to load up open session" , self);
    

    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"] allowLoginUI:YES  completionHandler:^(FBSession *session,  FBSessionState status,NSError *error)
    {
        NSLog(@"%@ got session state change : %i ", self, status  );
        switch (status)
        {

            case FBSessionStateOpen:
                [blockself handleLoggedIn:session];
                break;
                
            default:
                break;
        }
    }];
}

-(void)handleLoggedIn:(FBSession *)activeSession
{
    __block FacebookManager *blockself = self;
    
    if( self.connection )
    {
        _connection = [[FBRequestConnection alloc] init];
    }
    
    _currentSession    = activeSession;
    _token             = [self.currentSession accessTokenData].accessToken;
    _tokenExpiration   = [self.currentSession accessTokenData].expirationDate;
    
    FBRequest  *requst = [[FBRequest alloc]initWithSession:self.currentSession graphPath:@"me"];
    
    [self.connection addRequest:requst completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        [blockself handleResultsLoaded:result];
        
        if( blockself.loginBlock )
        {
            blockself.loginBlock(YES);
        }
        
    }];
    
    [self.connection start];
}

-(void)handleResultsLoaded:(NSDictionary *)results
{
    _email = [results valueForKey:@"email"];
    _fbid  = [results valueForKey:@"id"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_token forKey:@"token"];
    [defaults setValue:_tokenExpiration forKey:@"tokenExpiration"];
    [defaults setValue:_fbid forKey:@"fbid"];
    [defaults synchronize];
}

-(void)logout
{
    self.loginBlock = nil;
    [self.currentSession close];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"token"];
    [defaults removeObjectForKey:@"tokenExpiration"];
    [defaults removeObjectForKey:@"fbid"];
    [defaults synchronize];

    _email = nil;
}

@end
