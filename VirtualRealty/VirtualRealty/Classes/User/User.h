//
//  User.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Listing.h"

typedef void (^LoginInCompleteBlock) (BOOL success);

@interface User : NSObject

@property(nonatomic, strong, readonly)NSString   *username;
@property(nonatomic, strong, readonly)NSString   *uid;
@property(nonatomic, copy)LoginInCompleteBlock    loginBlock;
@property(nonatomic, assign, readonly)UserState  state;
@property(nonatomic, strong, readonly)NSArray    *listings;
@property(nonatomic, strong, readonly)NSArray    *recentListings;

@property(nonatomic, strong)Listing *currentListing;

-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password andBlock:(LoginInCompleteBlock)block;
-(void)signupWithUsername:(NSString *)username andPassword:(NSString *)password andBlock:(LoginInCompleteBlock)block;
-(void)loginWithFacebook:(LoginInCompleteBlock)block;
-(void)logout;


+(User* )sharedUser;
@end
