//
//  SwitchCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SwitchCell.h"
#import "UIColor+Extended.h"

@implementation SwitchCell

@synthesize switchButton = _switchButton;
@synthesize stateLabel   = _stateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _stateLabel   = [[UILabel alloc]initWithFrame:CGRectZero];
        _switchButton = [[UISwitch alloc]initWithFrame:CGRectZero];
        [self.switchButton addTarget:self action:@selector(handleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = _switchButton;
    
        [self.contentView addSubview:_stateLabel];
        self.stateLabel.textAlignment = NSTextAlignmentRight;
        self.stateLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    float width = 300 - ( self.textLabel.frame.origin.x + self.textLabel.frame.size.width);
    [self.stateLabel sizeToFit];
    CGRect rect = self.stateLabel.frame;
    rect.size.width = width;
    rect.origin.x   = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
    rect.origin.y   = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.stateLabel.frame = rect;
    
    [self.contentView bringSubviewToFront:self.stateLabel];
}

-(void)handleSwitchChanged:(id)sender
{
    if( [self.formDelegate respondsToSelector:@selector(cell:didStartInteract:)] )
    {
        [self.formDelegate cell:self didStartInteract:[[self.cellinfo valueForKey:@"field"]intValue]];
    }
    BOOL on = self.switchButton.on;
    self.formValue = [NSNumber numberWithBool:on];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
}

-(void)render
{
    BOOL on = [[self.cellinfo valueForKey:@"current-value"] boolValue];
    self.switchButton.on = on;
    [super render];
    
    self.textLabel.text = self.cellinfo[@"label"];
    
    if( [[self.cellinfo valueForKey:@"read-only"] boolValue ] )
    {
        self.switchButton.hidden = YES;
        self.switchButton.userInteractionEnabled = NO;
        self.stateLabel.text = ( on ) ? @"Yes" : @"No";
    }
}


@end
