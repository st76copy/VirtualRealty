//
//  DateCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/28/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "DateCell.h"
#import "NSDate+Extended.h"
#import "UIColor+Extended.h"

@implementation DateCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        
    }
    return  self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    float width = 300 - ( self.textLabel.frame.origin.x + self.textLabel.frame.size.width);
    CGRect rect = self.detailTextLabel.frame;

    rect.size.width = width;
    rect.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.detailTextLabel.frame = rect;
    
}

-(void)render
{
    self.backgroundView       = nil;
    self.textLabel.text       = [self.cellinfo valueForKey:@"label"];
    self.detailTextLabel.text = [[self.cellinfo valueForKey:@"current-value"]toShortString];
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    [self.detailTextLabel sizeToFit];
}
@end
