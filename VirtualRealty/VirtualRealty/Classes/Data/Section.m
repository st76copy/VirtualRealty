//
//  Section.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "Section.h"
#import "Row.h"

@implementation Section

@synthesize rows  = _rows;
@synthesize title = _title;
@synthesize state = _state;

-(id)initWithTitle:(NSString *)title
{
    self = [super init];
    if ( self != nil )
    {
        _state = kContracted;
        _rows  = [NSMutableArray array];
        _title = title;
        [self activeRows];
    }
    return self;
}

-(void)toggleRows
{
    _state = (_state == kContracted) ? kExpanded : kContracted;
}

-(NSArray *)activeRows
{
    NSMutableArray *active = [NSMutableArray array];
    NSArray    *animatable = [self.rows filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Row *row = ( Row *)evaluatedObject;
        return row.animatable;
    }]];
    
    for( Row *r in self.rows )
    {
        if( r.animatable == NO)
        {
            [active addObject:r];
        }
    }
    
    for( Row *r in animatable )
    {
        if( self.state == kExpanded )
        {
            r.visible = YES;
            [active addObject:r];
        }
        else
        {
            r.visible = NO;
        }
    }

    return active;
}

-(int)animatableRows
{
    Row *row;
    int count = 0;
    for ( row in self.rows )
    {
        if( row.animatable )
        {
            count++;
        }
    }
    return  count;
}

@end
