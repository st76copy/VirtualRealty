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

@property(nonatomic, copy)LoginInCompleteBlock    loginBlock;
@property(nonatomic, strong)NSString             *username;
@property(nonatomic, strong)NSNumber             *facebookUser;
@property(nonatomic, strong, readonly)NSString   *password;
@property(nonatomic, strong, readonly)NSString   *uid;
@property(nonatomic, assign, readonly)UserState  state;
@property(nonatomic, strong, readonly)NSArray    *listings;
@property(nonatomic, strong, readonly)NSArray    *recentListings;

@property(nonatomic, strong)Listing *currentListing;

@property(nonatomic, strong)NSNumber *activelySearching;
@property(nonatomic, strong)NSNumber *maxRent;
@property(nonatomic, strong)NSNumber *searchRadius;
@property(nonatomic, strong)NSString *minBedrooms;
@property(nonatomic, strong)NSDate   *moveInAfter;


-(void)loginWithUsername:(NSString *)username andPassword:(NSString *)password andBlock:(LoginInCompleteBlock)block;
-(void)signupWithUsername:(NSString *)username andPassword:(NSString *)password andBlock:(LoginInCompleteBlock)block;
-(void)loginWithFacebook:(LoginInCompleteBlock)block;
-(void)logout;
-(BOOL)valid;
-(void)update;
+(User* )sharedUser;
@end
