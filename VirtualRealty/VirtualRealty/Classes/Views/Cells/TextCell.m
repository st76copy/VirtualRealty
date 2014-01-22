//
//  TextCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "TextCell.h"
#import "UIColor+Extended.h"
@implementation TextCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return  [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.textColor = [UIColor colorFromHex:@"434343"];
    CGRect rect = self.textLabel.frame;
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.textLabel.textColor = [UIColor colorFromHex:@"434343"];
    self.textLabel.frame = rect;
    
    [self.detailTextLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:16]];
    [self.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
    [self.detailTextLabel sizeToFit];

    rect = self.detailTextLabel.frame;
    rect.origin.x = self.contentView.frame.size.width - (self.detailTextLabel.frame.size.width + 10);
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.detailTextLabel.frame = rect;
    
}


-(void)render
{
    self.textLabel.text  = [self.cellinfo valueForKey:@"label"];
    if( self.cellinfo[@"icon"])
    {
        self.imageView.image = [UIImage imageNamed:self.cellinfo[@"icon"]];
    }
    
    if( self.cellinfo[@"current-value"] && [self.cellinfo[@"current-value"] isEqualToString:@""] == NO )
    {
        
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
        NSString *text = ( self.cellinfo[@"current-value"] ) ? self.cellinfo[@"current-value"] : self.cellinfo[@"default"];
        self.detailTextLabel.text = text;
    }
    else
    {
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"aaaaaa"];
        self.detailTextLabel.text = [self.cellinfo valueForKey:@"placeholder"];
    }
    
    if( [self.cellinfo[@"read-only"]boolValue] )
    {
        if( self.cellinfo[@"current-value"] == nil )
        {
            self.detailTextLabel.text = self.cellinfo[@"default"];
        }
    }
        
    [self.detailTextLabel sizeToFit];
}



@end
