//
//  CheckCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "CheckCell.h"

@implementation CheckCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    return self;
}

-(void)render
{
    self.textLabel.text = [self.cellinfo valueForKey:@"label"];
  
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        self.accessoryType = ( [[self.cellinfo valueForKey:@"current-value"]isEqualToString:self.textLabel.text] ) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

@end
