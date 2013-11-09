//
//  NSDate+Extended.m
//  Contributor
//
//  Created by Chris on 8/14/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "NSDate+Extended.h"

#define kSQLStringFromat      @"yyyy-MM-dd HH:mm:ss"
#define kStandardStringFormat @"dd-MM-yyyy hh:mm:ss a z"
#define kShortFormat          @"MM/dd/yyyy"

@implementation NSDate (Extended)


+(NSDate*)fromSQLString:(NSString *)sqlDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:kSQLStringFromat];
    return [formatter dateFromString:sqlDateString];
}

+(NSDate*)fromShortString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:kShortFormat];
    return [formatter dateFromString:dateString];
}


+(NSDate *)dateWithYear:(int)year month:(int)month day:(int)day
{
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    comps.year   = year;
    comps.month  = month;
    comps.day    = day;
    comps.hour   = 0;
    comps.minute = 0;
    comps.second = 0;
    NSCalendar *cal = [NSCalendar currentCalendar];
    return  [cal dateFromComponents:comps];
}

-(NSString *)toString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:kStandardStringFormat];
    return  [formatter stringFromDate:self];
}

-(NSString *)toShortString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:kShortFormat];
    return  [formatter stringFromDate:self];
}

-(NSString *)toSQLString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:kSQLStringFromat];
    return  [formatter stringFromDate:self];
}

-(BOOL)isLaterThenDate:(NSDate*)date
{
    return ( [self compare:date] == NSOrderedDescending ) ? YES : NO;
}

-(BOOL)isEarlierThenDate:(NSDate*)date
{
    return ( [self compare:date] == NSOrderedAscending ) ? YES : NO;
}

-(BOOL)isInRangeWithStartDate:(NSDate *)earliestTime andEndDate:(NSDate *)latestDate
{
    if( [self compare:earliestTime] == NSOrderedDescending && [self compare:latestDate] == NSOrderedAscending  )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSDate *)zeroDate
{
    unsigned unitFlags = NSMinuteCalendarUnit | NSHourCalendarUnit |  NSSecondCalendarUnit;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    comps = [cal components:unitFlags fromDate:self];
    
    comps.hour   = comps.hour   *-1;
    comps.minute = comps.minute *-1;
    comps.second = comps.second *-1;
    
    return  [cal dateByAddingComponents:comps toDate:self options:0];
}

-(NSDate *)dateForStartOfWeekInMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *edgeCase = [[NSDateComponents alloc] init];
    [edgeCase setMonth:2];
    [edgeCase setDay:1];
    [edgeCase setYear:2013];
    NSDate *edgeCaseDate = [calendar dateFromComponents:edgeCase];
    
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:edgeCaseDate];
    [components setWeekday:1]; // 1 == Sunday, 7 == Saturday
    [components setWeek:[components week]];
    
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:self];
    [components setWeekday:1]; // 1 == Sunday, 7 == Saturday
    [components setWeek:[components week]];
    
    return [calendar dateFromComponents:components];
}
@end
