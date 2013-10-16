//
//  QueryFactory.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Listing.h"
#import "User.h"
@interface QueryFactory : NSObject

+(NSString *)getSaveListingQuery:( Listing * )listing;
+(NSString *)getDeleteListingQuery:( Listing * )listing;
+(NSString *)getUpdateListingQuery:( Listing *)listing;
+(NSString *)getFavoritesForUser:( User * )listing;
+(NSString *)getListing:(Listing *)listing andUser:( User *)user;

@end
