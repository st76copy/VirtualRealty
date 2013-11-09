//
//  NumberInputCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/18/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "NumberInputCell.h"
#import "KeyboardManager.h"
@implementation NumberInputCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.inputField.keyboardType  = UIKeyboardTypeDecimalPad;
        self.inputField.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)inputTextChanged:(id)sender
{
    
    [super clearError];
    self.formValue = [NSNumber numberWithFloat:[self.inputField.text floatValue]];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
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
    self.textLabel.text         = [self.cellinfo valueForKey:@"label"];
    self.inputField.placeholder = [self.cellinfo valueForKey:@"placeholder"];
    
    
    NSString *format = [self.cellinfo valueForKey:@"format"];
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        float value =  [[self.cellinfo valueForKey:@"current-value"] floatValue];
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
    }
    
}

@end
