//
//  NSDate+Extended.h
//  Contributor
//
//  Created by Chris on 8/14/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extended)

+(NSDate*)fromSQLString:(NSString *)sqlString;
+(NSDate*)fromShortString:(NSString *)dateString;

-(NSString *)toString;
-(NSString *)toSQLString;
-(NSString *)toShortString;

-(BOOL)isLaterThenDate:(NSDate*)date;
-(BOOL)isEarlierThenDate:(NSDate*)date;
-(BOOL)isInRangeWithStartDate:(NSDate *)earliestTime andEndDate:(NSDate *)latestDate;
-(NSDate *)zeroDate;
-(NSDate *)dateForStartOfWeekInMonth;

+(NSDate *)dateWithYear:(int)year month:(int)month day:(int)day;
@end
