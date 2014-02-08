
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
        NSArray *staticMonths = @[@{@"index" : @0   ,@"name" : @"January" },
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
        int timeRangeYears = 3;
        NSMutableArray *years  = [NSMutableArray array];
        NSMutableArray *months = [NSMutableArray array];
        NSMutableArray *day    = [NSMutableArray array];
        
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
            NSDate *temp   = [cal dateFromComponents:loopComp];
            
            NSRange days   = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:temp];
        }
        
        
        [ref addObject:years];
        [ref addObject:months];
        [ref addObject:day];
        _source = [NSArray arrayWithArray:ref];
        
    }
    return self;
}

-(NSArray *)getDaysFormMonth:(int)inYear:(int)y
{
    
    unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit |  NSYearCalendarUnit;
    
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *startComp = [cal components:unitFlags fromDate:date];
    
    return nil;
}

@end
