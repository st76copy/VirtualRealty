//
//  MediaCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/5/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MediaCell.h"

@implementation MediaCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.accessoryType = UITableViewCellAccessoryNone;

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.contentView.frame;
    self.imageView.frame = rect;
    
}

-(void)render
{
    self.textLabel.text = [self.cellinfo valueForKey:@"label"];
    self.imageView.image = [UIImage imageNamed:self.cellinfo[@"temp-image"]];
    self.imageView.userInteractionEnabled = NO;
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        self.imageView.image = [self.cellinfo valueForKey:@"current-value"];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
    }
}

@end
