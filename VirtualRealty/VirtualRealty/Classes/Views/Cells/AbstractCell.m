//
//  AbstractCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractCell.h"

@implementation AbstractCell


@synthesize cellinfo  = _cellinfo;
@synthesize indexPath = _indexPath;
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
}

@end
