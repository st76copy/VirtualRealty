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
    NSString *template = @"DELETE  FROM UserListings WHERE uid='%@';";
    return [NSString stringWithFormat:template, listing.objectId];
}

+(NSString *)getSaveListingQuery:(Listing *)listing
{
    NSString *template = @"INSERT INTO UserListings "
        "( uid, user_id,unit, neighborhood, movin_cost,montly_cost,movein_date, bedrooms, bathrooms, broker_fee, outdoor_space, cats, dogs, gym, listing_state, washer_dryer,  phone, email, city, state, street, borough, zip, long, lat) "
            "VALUES ('%@', '%@', '%@', '%@', %i, %i, '%@', '%@', '%@', %i, %d, %d, %d, %d, %i, %d, '%@', '%@', '%@', '%@','%@', '%@', %i, %f, %f );";
    NSString *sql = [NSString stringWithFormat:template,
                     listing.objectId,
                     [User sharedUser].uid,
                     listing.unit,
                     listing.neighborhood,
                     [listing.moveInCost intValue],
                     [listing.monthlyCost intValue],
                     [listing.moveInDate toSQLString],
                     listing.bedrooms ,
                     listing.bathrooms ,
                     [listing.brokerfee intValue],
                     [listing.outdoorSpace boolValue],
                     [listing.cats boolValue],
                     [listing.dogs boolValue],
                     [listing.gym boolValue],
                     [listing.listingState intValue],
                     [listing.washerDryer boolValue],
                     listing.phone,
                     listing.email,
                     listing.city,
                     listing.state,
                     listing.street,
                     listing.borough,
                     [listing.zip intValue],
                     listing.geo.coordinate.longitude,
                     listing.geo.coordinate.latitude];
    
    
    return sql;
}

+(NSString *)getUpdateListingQuery:( Listing *)listing
{
    return nil;
}

+(NSString *)getFavoritesForUser:(User *)listing
{
    NSString *template = @"SELECT uid as objectId,unit, movin_cost as moveInCost,montly_cost as monthlyCost,movein_date as moveInDate, bedrooms, bathrooms, "
        "broker_fee as brokerfee, outdoor_space as outdoorSpace, "
        "cats, dogs, gym, listing_state as listingState, washer_dryer as washerDryer, phone, email, city, state, neighborhood, street, borough,  zip, long, lat "
        "FROM UserListings WHERE user_id = '%@'";
    
    return [NSString stringWithFormat:template, [User sharedUser].uid];
}

+(NSString *)getListing:(Listing *)listing andUser:( User *)user
{
    NSString *template = @"SELECT uid as objectId, unit, movin_cost as moveInCost,montly_cost as moveInCost,movein_date as moveInDate, bedrooms, bathrooms, broker_fee as brokerfee, outdoor_space as outdoorSpace, cats, dogs, gym, listing_state as listingState, washer_dryer as washerDryer, phone, email, email,city, state, neighborhood, street, borough, zip, long, lat FROM UserListings WHERE uid = '%@' AND user_id = '%@'";
    return  [NSString stringWithFormat:template, listing.objectId, user.uid];
}
@end
