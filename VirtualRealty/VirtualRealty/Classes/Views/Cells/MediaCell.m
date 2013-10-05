//
//  MediaCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/5/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MediaCell.h"

@implementation MediaCell

-(void)render
{
    self.textLabel.text = [self.cellinfo valueForKey:@"label"];
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        self.accessoryType = ( [self.cellinfo valueForKey:@"current-value"]  ) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

@end
