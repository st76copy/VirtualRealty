//
//  DetailsCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "DetailsCell.h"

@implementation DetailsCell


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
    self.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
}
@end
