//
//  DatePickerSource.h
//  VirtualRealty
//
//  Created by christopher shanley on 2/8/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatePickerSource : NSObject
-(NSArray *)getDaysFormMonth:(int)m inYear:(int)y;
@property(nonatomic, strong, readonly)NSMutableArray *source;
@end
