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

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@\n%@\n%02f\n%02f\n%i\n%i\n%d", self.addresss, self.neighborhood, [self.monthlyCost floatValue], [self.moveInCost floatValue],
            [self.bedrooms intValue],
            [self.bathrooms intValue],
            [self.brokerfee boolValue]
            ];
}

@end
