//
//  FacebookManager.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

typedef void (^FacebookLoginBlock) (BOOL success);

@interface FacebookManager : NSObject

@property(nonatomic,strong, readonly)NSString             *email;
@property(nonatomic,copy)FacebookLoginBlock                loginBlock;
@property(nonatomic, strong, readonly)FBSession           *currentSession;
@property(nonatomic, strong, readonly)FBRequestConnection *connection;
@property(nonatomic, strong, readonly)NSString            *token;
@property(nonatomic, strong, readonly)NSDate              *tokenExpiration;
@property(nonatomic, strong, readonly)NSString            *fbid;
+(FacebookManager *)sharedManager;
-(void)login:(FacebookLoginBlock)block;
-(void)logout;

@end
