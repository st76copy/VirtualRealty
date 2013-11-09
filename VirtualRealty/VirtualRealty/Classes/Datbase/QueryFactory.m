//
//  QueryFactory.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "QueryFactory.h"
#import "User.h"
#import "NSDate+Extended.h"
@implementation QueryFactory
+(NSString *)getDeleteListingQuery:(Listing *)listing
{
    NSString *template = @"DELETE FROM UserListings WEHRE uid='%@';";
    return [NSString stringWithFormat:template, listing.objectId];
}

+(NSString *)getSaveListingQuery:(Listing *)listing
{
    NSString *template = @"INSERT INTO UserListings"
        "( uid, user_id,address,unit, neighborhood, movin_cost,montly_cost,movein_date, bedrooms, bathrooms, broker_fee, outdoor_space, cats, dogs, gym, listing_state, washer_dryer, keywords )"
        "VALUES ('%@', '%@', '%@', '%@', '%@', %f, %f, '%@', %i, %i, %f, %d, %d, %d, %d, %i, %d, '%@' );";
    NSString *sql = [NSString stringWithFormat:template,
                     listing.objectId,
                     [User sharedUser].uid,
                     listing.address,
                     listing.unit,
                     listing.neighborhood,
                     [listing.moveInCost floatValue],
                     [listing.monthlyCost floatValue],
                     [listing.moveInDate toSQLString],
                     [listing.bedrooms intValue],
                     [listing.bathrooms intValue],
                     [listing.brokerfee floatValue],
                     [listing.outdoorSpace boolValue],
                     [listing.cats boolValue],
                     [listing.dogs boolValue],
                     [listing.gym boolValue],
                     [listing.listingState intValue],
                     [listing.washerDryer boolValue],
                     [listing.keywords componentsJoinedByString:@","]];
                     
    
    return sql;
}

+(NSString *)getUpdateListingQuery:( Listing *)listing
{
    return nil;
}

+(NSString *)getFavoritesForUser:(User *)listing
{
    NSString *template = @"SELECT uid as objectId,address,unit, neighborhood, movin_cost as moveInCost,montly_cost as monthlyCost,movein_date as moveInDate, bedrooms, bathrooms, broker_fee as brokerfee, outdoor_space as outdoorSpace, cats, dogs, gym, listing_state as listingState, washer_dryer as washerDryer FROM UserListings WHERE user_id = '%@'";
    
    return [NSString stringWithFormat:template, [User sharedUser].uid];
}

+(NSString *)getListing:(Listing *)listing andUser:( User *)user
{
    NSString *template = @"SELECT uid as objectId,address,unit, neighborhood, movin_cost as moveInCost,montly_cost as moveInCost,movein_date as moveInDate, bedrooms, bathrooms, broker_fee as brokerfee, outdoor_space as outdoorSpace, cats, dogs, gym, listing_state as listingState, washer_dryer as washerDryer FROM UserListings WHERE uid = '%@' AND user_id = '%@'";
    return  [NSString stringWithFormat:template, listing.objectId, user.uid];
}
@end
