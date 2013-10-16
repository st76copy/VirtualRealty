//
//  SwitchCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

@synthesize switchButton = _switchButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _switchButton = [[UISwitch alloc]initWithFrame:CGRectZero];
        [self.switchButton addTarget:self action:@selector(handleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = _switchButton;
    }
    return self;
}

-(void)handleSwitchChanged:(id)sender
{
    [self.formDelegate cell:self didStartInteract:[[self.cellinfo valueForKey:@"field"]intValue]];
    BOOL on = self.switchButton.on;
    self.formValue = [NSNumber numberWithBool:on];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
}

-(void)render
{
    BOOL on = [[self.cellinfo valueForKey:@"current-value"] boolValue];
    self.switchButton.on = on;
    [super render];
    
    if( [[self.cellinfo valueForKey:@"read-only"] boolValue ] )
    {
        self.switchButton.userInteractionEnabled = NO;
    }
}


@end
