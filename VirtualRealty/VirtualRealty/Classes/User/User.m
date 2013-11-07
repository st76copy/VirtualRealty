//
//  User.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "User.h"
#import "ErrorFactory.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookManager.h"

@interface User()
-(void)handleUserLoggedIn:(PFUser *)temp;
-(void)loadFromDefaults;
-(void)saveToDefaults:(PFUser *)user;
-(void)authFacebookUser;
-(void)handleFacebookAuth:(PFUser *)user;

@end

@implementation User

@synthesize uid      = _uid;
@synthesize username = _username;
@synthesize loginBlock;
@synthesize state    = _state;

+(User *)sharedUser
{
    static User *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        instance = [[User alloc]init];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    if( self != nil )
    {
        _state = kNoUser;
        self.minBedrooms = @0;
        self.maxRent     = @0;
        self.moveInAfter = [NSDate date];
        [self loadFromDefaults];
    }
    return self;
}

-(void)loadFromDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _username = [defaults valueForKey:@"username"];
    _uid      = [defaults valueForKey:@"uid"];
    if( self.username != nil  || self.uid != nil )
    {
        _state = kUserValid;
    }
}

-(void)saveToDefaults:(PFUser *)temp
{
    _username = temp.username;
    _uid      = temp.objectId;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_username forKey:@"username"];
    [defaults setValue:_uid      forKey:@"uid"];
    
    [defaults setValue:self.moveInAfter forKey:@"moveInAfter"];
    [defaults setValue:self.maxRent     forKey:@"maxRent"];
    [defaults setValue:self.minBedrooms forKey:@"minBedrooms"];
    
    [defaults synchronize];
    _state = kUserValid;
}


#pragma mark - email flow
-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password andBlock:(LoginInCompleteBlock)block
{
    if( block )
    {
        self.loginBlock = block;
    }
    
    __block User *blockself = self;
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if( error )
        {
            [[ErrorFactory getAlertCustomMessage:[[error userInfo] valueForKey:@"error"] andDelegateOrNil:nil andOtherButtons:nil]show];
        }
        else
        {
            [blockself saveToDefaults:user];
            [blockself handleUserLoggedIn:nil];
        }
    }];
}

-(void)signupWithUsername:(NSString *)username andPassword:(NSString *)password andBlock:(LoginInCompleteBlock)block
{
    self.loginBlock = block;
    __block PFUser *temp  = [PFUser user];
    temp.username = username;
    temp.password = password;
    temp.email    = username;
    
    [temp setValue:self.activelySearching forKey:@"activelySearching"];
    [temp setValue:self.moveInAfter forKey:@"moveInAfter"];
    [temp setValue:self.minBedrooms forKey:@"minBedrooms"];
    [temp setValue:self.maxRent     forKey:@"maxRent"];
   
    [temp addObject:[NSNumber numberWithBool:NO] forKey:@"facebook_user"];
    
    if( password == nil )
    {
        [temp addObject:[NSNumber numberWithBool:YES] forKey:@"facebook_user"];
    }
    
    __block User *user = self;
    
    [temp signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if( succeeded )
        {
           [user handleUserLoggedIn:temp];
        }
        else
        {
            [[ErrorFactory getAlertCustomMessage:[[error userInfo] valueForKey:@"error"] andDelegateOrNil:nil andOtherButtons:nil]show];
        }
    }];
}

-(void)handleUserLoggedIn:(PFUser *)temp
{
    __block User *blockself = self;
    if( temp )
    {
        [PFUser logInWithUsernameInBackground:temp.username password:temp.password block:^(PFUser *user, NSError *error)
        {
            if( error )
            {
                [[ErrorFactory getAlertCustomMessage:[[error userInfo] valueForKey:@"error"] andDelegateOrNil:nil andOtherButtons:nil]show];
            }
            else
            {
                [blockself saveToDefaults:user];
                self.loginBlock(YES);
                [[NSNotificationCenter defaultCenter]postNotificationName:kLOGIN_NOTIFICATION_NAME object:nil];
            }

        }];
    }
    else
    {
        self.loginBlock(YES);
        [[NSNotificationCenter defaultCenter]postNotificationName:kLOGIN_NOTIFICATION_NAME object:nil];
    }
}


#pragma mark - facebook flow
-(void)loginWithFacebook:(LoginInCompleteBlock)block
{
    self.loginBlock = block;
    
    __block User *blockself = self;
    __block FacebookManager *fb = [FacebookManager sharedManager];
    
    [fb login:^(BOOL success)
    {
        if( success )
        {
            [blockself authFacebookUser];
        }
        else
        {
            [fb logout];
            [[ErrorFactory getAlertForType:kUserLoginFailError andDelegateOrNil:nil andOtherButtons:nil]show];
        }
    }];
    
}

-(void)authFacebookUser
{
    __block User *blockself = self;
    FacebookManager *fb = [FacebookManager sharedManager];
    [PFFacebookUtils initializeFacebook];   
    [PFFacebookUtils logInWithFacebookId:fb.fbid accessToken:fb.token expirationDate:fb.tokenExpiration block:^(PFUser *user, NSError *error)
    {
        if( user )
        {
            [blockself handleFacebookAuth:user];
            blockself.loginBlock(YES);
            [[NSNotificationCenter defaultCenter]postNotificationName:kLOGIN_NOTIFICATION_NAME object:nil];
        }
        else
        {
            blockself.loginBlock(NO);
        }
    }];
    
}

-(void)handleFacebookAuth:(PFUser *)user
{
    __block User *blockself = self;
    [user addObject:self.moveInAfter forKey:@"moveInAfter"];
    [user addObject:self.minBedrooms forKey:@"minBedrooms"];
    [user addObject:self.maxRent     forKey:@"maxRent"];

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [blockself saveToDefaults:user];      
    }];
}

-(void)logout
{
    _username = nil;
    _uid      = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"uid"];
    [defaults synchronize];
    _state = kNoUser;
    
    [[FacebookManager sharedManager]logout];
    [[NSNotificationCenter defaultCenter]postNotificationName:kLOGOUT_NOTIFICATION_NAME object:nil];
}

-(BOOL)valid
{
    return ( self.uid == nil  ) ? NO : YES;
}

@end
    