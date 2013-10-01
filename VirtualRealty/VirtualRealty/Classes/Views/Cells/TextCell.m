//
//  TextCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "TextCell.h"

@implementation TextCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return  [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    CGRect rect = self.textLabel.frame;
    rect.origin.x = 20;
}

-(void)render
{
    self.textLabel.text = [self.cellinfo valueForKey:@"label"];
    self.detailTextLabel.text = [self.cellinfo valueForKey:@"current-value"];
    [self.detailTextLabel sizeToFit];
}



@end
