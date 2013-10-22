//
//  Filter.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "Filter.h"

@implementation Filter

@synthesize field, value;
-(NSDictionary *)toDictionary
{
    return @{ @"name" : self.field, @"value" : self.value };
}
@end
