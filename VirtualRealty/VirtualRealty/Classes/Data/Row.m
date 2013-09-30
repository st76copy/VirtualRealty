//
//  Row.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "Row.h"

@implementation Row

@synthesize animatable = _animatable;
@synthesize info       = _info;
@synthesize state;

-(id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if ( self != nil )
    {
        _info        = info;
        self.state   = [[self.info valueForKey:@"state"]intValue];
        self.visible = ( self.state == kContracted ) ? NO : YES;
       _animatable   = [[self.info valueForKey:@"animatable"]boolValue];
    }
    return self;
}

@end
