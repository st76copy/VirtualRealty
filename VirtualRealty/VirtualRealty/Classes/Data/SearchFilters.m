//
//  SearchFilter.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SearchFilters.h"
#import "Filter.h"
@implementation SearchFilters


-(id)initWithDefaults
{
    self = [super init];
    if( self != nil )
    {
        _filters = [NSMutableArray array];
        _isDefault = YES;
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBoroughFilter],       @"value" : @"", @"name" : @"borough" } mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kNeightborhoodFilter], @"value" : @"", @"name" : @"neighborhood" } mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kStateFilter],         @"value" : @"", @"name" : @"state" } mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kCityFilter],          @"value" : @"", @"name" : @"city" } mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBedroomsFilter],      @"value" : @"", @"name" : @"bedrooms" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBathroomsFilter],     @"value" : @"", @"name" : @"bathrooms" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBrokerFeeFilter],     @"value" : [NSNumber numberWithBool:NO],  @"name" : @"brokerfee" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kMinCostFilter],       @"value" : @0,  @"name" : @"minCost" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kMaxCostFilter],       @"value" : @0,  @"name" : @"maxCost" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kShareFilter],         @"value" : [NSNumber numberWithBool:NO], @"name" : @"share" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kDogsFilter],          @"value" : [NSNumber numberWithBool:NO], @"name" : @"dogs" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kCatsFilter] ,         @"value" : [NSNumber numberWithBool:NO], @"name" : @"cats" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kOutdoorSpaceFilter],  @"value" : [NSNumber numberWithBool:NO], @"name" : @"outdoorSpace" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kWasherDryerFilter],   @"value" : [NSNumber numberWithBool:NO], @"name" : @"washerDryer" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kDoormanFilter],       @"value" : [NSNumber numberWithBool:NO], @"name" : @"doorman" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kPoolFilter],          @"value" : [NSNumber numberWithBool:NO], @"name" : @"pool" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kGymFilter],           @"value" : [NSNumber numberWithBool:NO], @"name" : @"gym" }mutableCopy]];
        [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kMoveInFilter],        @"value" : [NSDate dateWithTimeIntervalSince1970:0], @"name" : @"moveIndate" }mutableCopy]];
    }
    return self;
}

-(void)setFilter:(FormField)field withValue:(id)value
{
    switch (field)
    {
        case kBoroughFilter:
            if( value )
            {
                [self.filters[0] setValue:value[@"borough"] forKey:@"value"];
                [self.filters[1] setValue:value[@"neighborhood"] forKey:@"value"];
            }
            else
            {
                [self.filters[0] setValue:@"" forKey:@"value"];
                [self.filters[1] setValue:@"" forKey:@"value"];
            }
            break;
            
        default:
            for( NSMutableDictionary *info in self.filters)
            {
                if( [[info valueForKey:@"field"] intValue] == field )
                {
                    [info setValue:value forKey:@"value"];
                }
            }

            break;
    }
    _isDefault = NO;
}

-(id)getValueForField:(FormField)field
{
    id value;
    switch (field) {
        case kBoroughFilter:
        
            if( [self.filters[0][@"value"] isEqualToString:@""] == NO &&  [self.filters[1][@"value"] isEqualToString:@""] == NO )
            {
                value = @{ @"borough" : self.filters[0][@"value"] , @"neighborhood" : self.filters[1][@"value"] };
                return  value;
            }
            
            if([self.filters[0][@"value"] isEqualToString:@""] == NO )
            {
                value = @{ @"borough" : self.filters[0][@"value"]  };
                return value;
            }
            
            if([self.filters[1][@"value"] isEqualToString:@""] == NO )
            {
                value = @{  @"neighborhood" : self.filters[1][@"value"] };
                return value;
            }
            
            break;
            
        default:
        {
            for( NSMutableDictionary *info in self.filters)
            {
                if( [[info valueForKey:@"field"] intValue] == field )
                {
                    value = [info valueForKey:@"value"];
                }
            }
        }
        break;
    }
    return value;
}

-(NSDictionary *)getActiveFilters
{
    
    Filter         *filter;
    NSMutableDictionary *active = [NSMutableDictionary dictionary];
    id value;
    
    for( NSMutableDictionary *info in self.filters)
    {
        value = [info valueForKey:@"value"];
        if( [value isKindOfClass:[NSNumber class]] )
        {
            if( [value integerValue] != 0 || [value boolValue] == YES )
            {
                filter = [[Filter alloc]init];
                filter.field = [info valueForKey:@"name"];
                filter.value = [info valueForKey:@"value"];
                [active setValue:[filter toDictionary] forKey:[info valueForKey:@"name"]];
            }
        }
     
        if( [value isKindOfClass:[NSDate class]] )
        {
            if( [value isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]] == NO)
            {
                filter = [[Filter alloc]init];
                filter.field = [info valueForKey:@"name"];
                filter.value = [info valueForKey:@"value"];
                [active setValue:[filter toDictionary] forKey:[info valueForKey:@"name"]];
            }
        }
     
        if( [value isKindOfClass:[NSString class]] )
        {
            if( [value isEqualToString:@""] == NO )
            {
                filter = [[Filter alloc]init];
                filter.field = [info valueForKey:@"name"];
                filter.value = [info valueForKey:@"value"];
                [active setValue:[filter toDictionary] forKey:[info valueForKey:@"name"]];
            }
        }
    }
    
    return ( active.count > 0 ) ? active : nil;
}

-(void)clear
{
    
    [self.filters removeAllObjects];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBoroughFilter],       @"value" : @"", @"name" : @"borough" } mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kNeightborhoodFilter], @"value" : @"", @"name" : @"neighborhood" } mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kStateFilter],         @"value" : @"", @"name" : @"state " } mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kCityFilter],          @"value" : @"", @"name" : @"city" } mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBedroomsFilter],      @"value" : @"", @"name" : @"bedrooms" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBathroomsFilter],     @"value" : @"", @"name" : @"bathrooms" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kBrokerFeeFilter],     @"value" : [NSNumber numberWithBool:NO],  @"name" : @"brokerfee" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kMinCostFilter],       @"value" : @0,  @"name" : @"minCost" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kMaxCostFilter],       @"value" : @0,  @"name" : @"maxCost" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kShareFilter],         @"value" : [NSNumber numberWithBool:NO], @"name" : @"share" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kDogsFilter],          @"value" : [NSNumber numberWithBool:NO], @"name" : @"dogs" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kCatsFilter] ,         @"value" : [NSNumber numberWithBool:NO], @"name" : @"cats" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kOutdoorSpaceFilter],  @"value" : [NSNumber numberWithBool:NO], @"name" : @"outdoorSpace" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kWasherDryerFilter],   @"value" : [NSNumber numberWithBool:NO], @"name" : @"washerDryer" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kDoormanFilter],       @"value" : [NSNumber numberWithBool:NO], @"name" : @"doorman" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kPoolFilter],          @"value" : [NSNumber numberWithBool:NO], @"name" : @"pool" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kGymFilter],           @"value" : [NSNumber numberWithBool:NO], @"name" : @"gym" }mutableCopy]];
    [self.filters addObject:[@{ @"field" : [NSNumber numberWithInt:kMoveInFilter],        @"value" : [NSDate dateWithTimeIntervalSince1970:0], @"name" : @"moveIndate" }mutableCopy]];

}

@end
