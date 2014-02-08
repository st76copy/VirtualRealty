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
{
    PFUser *userRef;
}
-(void)softLogin:(void (^) (BOOL success) )block;
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
@synthesize password = _password;
@synthesize facebookUser = _facebookUser;
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
        _facebookUser    = [NSNumber numberWithBool:NO];
        self.minBedrooms   = nil;
        self.maxRent       = @0;
        self.searchRadius  = @1.0;
        self.activelySearching = [NSNumber numberWithBool:YES];
        self.moveInAfter = [NSDate date];
        self.brokerFirm = @"";
        self.isBroker   = [NSNumber numberWithBool:NO];
        [self loadFromDefaults];
    }
    return self;
}

-(void)loadFromDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _username     = [defaults valueForKey:@"username"];
    _uid          = [defaults valueForKey:@"uid"];
    _password     = [defaults valueForKey:@"password"];
    _facebookUser = [defaults valueForKey:@"facebookUser"];
    
    _isBroker     = [defaults valueForKey:@"isBroker"];
    _brokerFirm   = [defaults valueForKey:@"brokerFirm"];
    
    self.minBedrooms = ([defaults valueForKey:@"minBedrooms"] ) ? [defaults valueForKey:@"minBedrooms"] : nil;
    self.maxRent     = ([defaults valueForKey:@"maxRent"])?[defaults valueForKey:@"maxRent"] : @0;
    self.moveInAfter = ([defaults valueForKey:@"moveInAfter"]) ? [defaults valueForKey:@"moveInAfter"] : [NSDate date];
    self.activelySearching = ([defaults valueForKey:@"activelySearching"])?[defaults valueForKey:@"activelySearching"] : [NSNumber numberWithBool:NO];
    
    userRef   = [defaults valueForKey:@"userRef"];
    
    if( self.username != nil  || self.uid != nil )
    {
        _state = kUserValid;
    }
}

-(void)saveToDefaults:(PFUser *)temp
{
    userRef   = temp;
    _username = temp.email;
    _uid      = temp.objectId;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_username forKey:@"username"];
    [defaults setValue:_uid      forKey:@"uid"];
    [defaults setValue:_password forKey:@"password"];
    [defaults setValue:_facebookUser forKey:@"facebookUser" ];
    [defaults setValue:_brokerFirm   forKey:@"brokerFirm"];
    [defaults setValue:_isBroker     forKey:@"isBroker"];
    
    
    
    if( [self.activelySearching boolValue] )
    {
        [defaults setValue:self.activelySearching forKey:@"activelySearching"];
        [defaults setValue:self.moveInAfter forKey:@"moveInAfter"];
        [defaults setValue:self.maxRent     forKey:@"maxRent"];
        [defaults setValue:self.minBedrooms forKey:@"minBedrooms"];
    }
    
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
    _password = password;
    
    __block User *blockself = self;
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
    {
        if( error )
        {
            blockself.loginBlock(NO);
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
    NSLog(@"%@ -- sign up with %@ , %@ ", self, username, password);
    self.loginBlock = block;
    __block PFUser *temp  = [PFUser user];
    temp.username = username;
    temp.password = password;
    temp.email    = username;
    
    _password = password;
    
    if( [self.activelySearching boolValue] )
    {
        [temp setValue:self.activelySearching forKey:@"activelySearching"];
        
        if( self.moveInAfter )
        {
            [temp setValue:self.moveInAfter       forKey:@"moveInAfter"];
        }
        
        if( self.minBedrooms )
        {
            [temp setValue:self.minBedrooms       forKey:@"minBedrooms"];
            
        }
    
        if( self.maxRent )
        {
            [temp setValue:self.maxRent           forKey:@"maxRent"];
            
        }
    }
   
    if( self.isBroker )
    {
        [temp setValue:self.isBroker forKey:@"isBroker"];
    }
    
    if( self.brokerFirm )
    {
        [temp setValue:self.brokerFirm forKey:@"borkerFirm"];
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
    NSLog(@"%@ authFacebookUser " , self );
    __block User *blockself = self;
    FacebookManager *fb = [FacebookManager sharedManager];
    [PFFacebookUtils initializeFacebook];   
    [PFFacebookUtils logInWithFacebookId:fb.fbid accessToken:fb.token expirationDate:fb.tokenExpiration block:^(PFUser *user, NSError *error)
    {
        if( user )
        {
            [blockself handleFacebookAuth:user];
            
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

    _facebookUser = [NSNumber numberWithBool:YES];
    
    [user setValue:self.moveInAfter  forKey:@"moveInAfter"];
    
    if( self.minBedrooms )
    {
        [user setValue:self.minBedrooms  forKey:@"minBedrooms"];
    }
    
    [user setValue:self.maxRent      forKey:@"maxRent"];
    [user setValue:self.activelySearching  forKey:@"activelySearching"];
    [user setValue:self.facebookUser forKey:@"facebookUser"];
 
    if( user.email == nil )
    {
        user.email = self.username;
    }
    
    _facebookUser = [NSNumber numberWithBool:YES];

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [blockself saveToDefaults:user];
        if( blockself.loginBlock )
        {
            blockself.loginBlock(YES);
            [[NSNotificationCenter defaultCenter]postNotificationName:kLOGIN_NOTIFICATION_NAME object:nil];
        }
    }];
}

-(void)update
{
    __block User *blockself = self;
    if( userRef )
    {
        
        if(self.moveInAfter )
        {
            [userRef setValue:self.moveInAfter        forKey:@"moveInAfter"];
        }
        if( self.minBedrooms )
        {
            [userRef setValue:self.minBedrooms        forKey:@"minBedrooms"];
        }
        
        if( self.maxRent )
        {
            [userRef setValue:self.maxRent            forKey:@"maxRent"];
        }
        
        if( self.activelySearching )
        {
            [userRef setValue:self.activelySearching  forKey:@"activelySearching"];
        }
        
        [userRef saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if( succeeded )
            {
                UIAlertView * av = [ErrorFactory getAlertCustomMessage:@"Your profiles has been updated" andDelegateOrNil:Nil andOtherButtons:nil];
                av.title = @"Success";
                [av show];
            }
            else
            {
                [[ErrorFactory getAlertCustomMessage:@"Sorry update currently not available" andDelegateOrNil:Nil andOtherButtons:nil]show];
            }
        }];
    }
    else
    {
        [self softLogin:^(BOOL success) {
            if( success  )
            {
                [blockself update];
            }
            else
            {
                [[ErrorFactory getAlertCustomMessage:@"Sorry soft login failed" andDelegateOrNil:Nil andOtherButtons:nil]show];
            }
        }];
    }
}

-(void)softLogin:(void (^) (BOOL success) )block
{
    if( [self.facebookUser boolValue] )
    {
        self.loginBlock = ^(BOOL success)
        {
            if( success )
            {
                block(YES);
            }
            else
            {
                block(NO);
            }
        };
        [self authFacebookUser];
    }
    else
    {
        [self loginWithUsername:self.username andPassword:self.password andBlock:^(BOOL success) {
            if( success )
            {
                block(YES);
            }
            else
            {
                block(NO);
            }
        }];
    }
}

-(void)logout
{
    _username = nil;
    _uid      = nil;
    
    _activelySearching = [NSNumber numberWithBool:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"uid"];
    [defaults removeObjectForKey:@"activelySearching"];
    [defaults removeObjectForKey:@"moveInAfter"];
    [defaults removeObjectForKey:@"maxRent"];
    [defaults removeObjectForKey:@"minBedrooms"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"facebookUser"];
    [defaults removeObjectForKey:@"isBroker"];
    [defaults removeObjectForKey:@"brokerFirm"];
    
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
    