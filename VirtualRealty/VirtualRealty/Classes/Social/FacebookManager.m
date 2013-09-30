//
//  FacebookManager.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FacebookManager.h"

@interface FacebookManager()

-(void)handleEmailLoaded:(NSString *)email;
-(void)handleLoggedIn:(FBSession *)activeSession;
@end

@implementation FacebookManager

@synthesize currentSession = _currentSession;
@synthesize email          = _email;
@synthesize connection     = _connection;

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

    _currentSession = activeSession;
    
    FBRequest  *requst     = [[FBRequest alloc]initWithSession:self.currentSession graphPath:@"me"];
    [self.connection addRequest:requst completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSString *email = [result valueForKey:@"email"];
        if( email == nil )
        {
            if( blockself.loginBlock ){ blockself.loginBlock(NO); }
        }
        else
        {
            [blockself handleEmailLoaded:email];
            if( blockself.loginBlock ){ blockself.loginBlock(YES); }
            
        }
    }];
    
    [self.connection start];
}

-(void)handleEmailLoaded:(NSString *)email
{
    _email = email;
}

-(void)logout
{
    self.loginBlock = nil;
    [self.currentSession close];
    _email = nil;
}

@end
