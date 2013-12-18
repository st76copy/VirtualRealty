//
//  NumberInputCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/18/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "NumberInputCell.h"
#import "KeyboardManager.h"
#import "UIColor+Extended.h"

@implementation NumberInputCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.inputField.keyboardType  = UIKeyboardTypeDecimalPad;
        self.inputField.returnKeyType = UIReturnKeyDone;
        self.inputField.delegate = self;
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.inputField.textColor = [UIColor colorFromHex:@"00aeef"];
}

-(void)inputTextChanged:(id)sender
{
    self.formValue = [NSNumber numberWithFloat:[self.inputField.text floatValue]];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
}


-(void)textFieldFinished:(id)sender
{
    [[KeyboardManager sharedManager]close];
    if( [self.formDelegate respondsToSelector:@selector(cell:didPressDone:)] )
    {
        self.formValue = [NSNumber numberWithFloat:[self.inputField.text floatValue]];
        [self.formDelegate cell:self didPressDone:[[self.cellinfo valueForKey:@"field"]intValue] ];
    }
}

-(void)render
{
    self.imageView.image = [UIImage imageNamed:self.cellinfo[@"icon"]];
    self.textLabel.text         = [self.cellinfo valueForKey:@"label"];
    self.inputField.placeholder = [self.cellinfo valueForKey:@"placeholder"];
    
    
    NSString *format = [self.cellinfo valueForKey:@"format"];
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        int value =  [[self.cellinfo valueForKey:@"current-value"] intValue];
        NSString *text = ( value == 0 ) ? @"" : [NSString stringWithFormat:format, value];
        self.inputField.text = text;
    }
    else
    {
        self.inputField.text = @"";
    }
    
    if( [[self.cellinfo valueForKey:@"read-only"]boolValue] )
    {
        self.inputField.userInteractionEnabled = NO;
        self.inputField.textColor = [UIColor colorFromHex:@"00aeef"];
    }
    
}

@end
