//
//  PickerInputCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/8/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "PickerInputCell.h"
#import "UIColor+Extended.h"
#import "NSDate+Extended.h"

@implementation PickerInputCell
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
    [super render];
    self.backgroundView       = nil;
    self.textLabel.text       = [self.cellinfo valueForKey:@"label"];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[self.cellinfo valueForKey:@"current-value"] intValue]];
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    [self.detailTextLabel sizeToFit];
}

@end
