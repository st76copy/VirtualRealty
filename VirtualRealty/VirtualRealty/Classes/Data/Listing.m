//
//  Listing.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "Listing.h"

@implementation Listing
@synthesize errors = _errors;

-(id)initWithDefaults
{
    self = [super init];
    if( self != nil)
    {
        _errors = [NSMutableArray array];
    }
    return  self;
}

-(NSMutableArray *)isValid
{
    [self.errors removeAllObjects];
    
    if( self.addresss == nil || [self.addresss isEqualToString:@""])
    {
        [self.errors addObject:[NSNumber numberWithInt:kAddress]];
    }
    
    if( self.neighborhood == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kNeightborhood]];
    }
    
    if( self.monthlyCost == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kMonthlyRent]];
    }
    
    if( self.moveInCost == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kMoveInCost]];
    }
    
    if( self.bedrooms == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kBedrooms]];
    }
    
    if( self.bathrooms == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kBathrooms]];
    }
    
    if( self.thumb == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kThumbnail]];
    }
    
    if( self.video == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kVideo]];
    }
    
    if( self.contact == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kContact]];
    }
    
    if( self.moveInDate == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kMoveInDate]];
    }
    
    return self.errors;
}

-(void)clearErrorForField:(FormField)field
{
    NSNumber *remove;
    for( NSNumber *num in self.errors)
    {
        if( [num intValue] == field )
        {
            remove = num;
        }
    }
    [self.errors removeObject:remove];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"address : %@ \n"
                                    "neightborhood : %@ \n"
                                    "montly cost : %0.2f \n"
                                    "move in cost : %0.2f \n"
                                    "broker : %d \n"
                                    "move in date : %@ \n"
                                    "bedrooms  : %i \n"
                                    "bathroom  : %i \n"
                                    "contact : %@  \n"
                                    "share : %d \n"
                                    "dogs : %d \n"
                                    "cats : %d \n"
                                    "outdoor : %d \n"
                                    "washer dryer : %d \n"
                                    "gym : %d \n"
                                    "doorman : %d \n"
                                    "pool : %d \n"
                                    "thumb : %@ \n"
                                    "video : %@",
            _addresss,
            _neighborhood,
            [_monthlyCost floatValue],
            [_moveInCost floatValue],
            [_brokerfee boolValue],
            _moveInDate,
            [_bedrooms intValue ],
            [_bathrooms intValue],
            _contact,
            [_share boolValue],
            [_dogs boolValue],
            [_cats boolValue   ],
            [_outdoorSpace boolValue],
            [ _washerDryer boolValue],
            [_gym boolValue],
            [_doorman boolValue],
            [_pool boolValue ],
            _thumb,
            _video
            ];
    
}

@end
