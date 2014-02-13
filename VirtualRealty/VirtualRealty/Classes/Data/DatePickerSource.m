
//
//  DatePickerSource.m
//  VirtualRealty
//
//  Created by christopher shanley on 2/8/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "DatePickerSource.h"

@implementation DatePickerSource

-(id)init
{
    self = [super init];
    if( self )
    {
        NSArray *staticMonths = @[@{@"index" :  @0   ,@"name" : @"January" },
                                   @{@"index" : @1  ,@"name" : @"February" },
                                   @{@"index" : @2  ,@"name" : @"March" },
                                   @{@"index" : @3  ,@"name" : @"April" },
                                   @{@"index" : @4  ,@"name" : @"May" },
                                   @{@"index" : @5  ,@"name" : @"June" },
                                   @{@"index" : @6  ,@"name" : @"July" },
                                   @{@"index" : @7  ,@"name" : @"August" },
                                   @{@"index" : @8  ,@"name" : @"September" },
                                   @{@"index" : @9  ,@"name" : @"October" },
                                   @{@"index" : @10 ,@"name" : @"November" },
                                   @{@"index" : @11 ,@"name" : @"December" }];
        NSMutableArray *years  = [NSMutableArray array];
        NSMutableArray *months = [NSMutableArray array];
        
        unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit |  NSYearCalendarUnit;
        
        NSDate *date = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *startComp = [cal components:unitFlags fromDate:date];
        NSDateComponents *loopComp  = [cal components:unitFlags fromDate:date];
        
        NSMutableArray *ref = [NSMutableArray array];
        
        for( int i =0; i < 3; i ++)
        {
            loopComp.year = startComp.year + i;
            [years addObject:@{@"value" : [NSString stringWithFormat:@"%i", loopComp.year], @"label" : [NSString stringWithFormat:@"%i", loopComp.year]}];
        }
     
        for( NSDictionary *info in staticMonths )
        {
            loopComp.month = [info[@"index"] intValue];
            [months addObject:@{@"label": info[@"name"] , @"value" : info[@"index"]}];
        }
        
        [ref addObject:years];
        [ref addObject:months];
        [ref addObject:[self getDaysFormMonth:0 inYear:startComp.year]];
        _source = [[NSArray arrayWithArray:ref] mutableCopy];
    }
    return self;
}

-(NSArray *)getDaysFormMonth:(int)m inYear:(int)y
{
    NSCalendar *cal         = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    comps.year  = y;
    comps.month = m + 1;
    NSDate *date = [cal dateFromComponents:comps];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *label;
    NSString *value;
   
    for( int i = 1; i < range.length +1; i++ )
    {
        label = [NSString stringWithFormat:@"%i", i];
        value = [NSString stringWithFormat:@"%i", i];
        [array addObject:@{@"label": label , @"value" : value}];
    }
    return array;
}

@end
