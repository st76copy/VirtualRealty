//
//  SearchFilter.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchFilters : NSObject
@property(nonatomic, strong, readonly)NSMutableArray *filters;

-(id)initWithDefaults;
-(id)getValueForField:(FormField)field;
-(void)setFilter:(FormField)field withValue:(id)value;
-(NSDictionary *)getActiveFilters;
-(void)clear;
@end
