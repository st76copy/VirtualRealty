//
//  MoneyInputCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MoneyInputCell.h"
#import "KeyboardManager.h"
#import "UIColor+Extended.h"
@implementation MoneyInputCell




-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super clearError];
    
    if( [textField.text isEqualToString:@"$"] && [string isEqualToString:@""])
    {
        return NO;
    }
    
    self.formValue = [NSNumber numberWithInt:[self.inputField.text intValue]];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
    
    NSString *format = [self.cellinfo valueForKey:@"format"];
    
    if( range.location == 0 )
    {
        textField.text = [NSString stringWithFormat:format, [string intValue]];
    }

    NSRange noDollarSign;
    noDollarSign.location = 1;
    noDollarSign.length   = ([string isEqualToString:@""] ) ? textField.text.length -1 : textField.text.length;
    
    NSString *amount = [NSString stringWithFormat:@"%@%@", textField.text, string];
    NSString *number = [amount substringWithRange:noDollarSign];
    
    NSLog(@"%@ -- bumbers only %i ", [self class], [number intValue] );
    
    self.formValue = [NSNumber numberWithInt:[number intValue]];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    
    return (range.location == 0 ) ? NO : YES ;
}

-(void)inputTextChanged:(id)sender
{
    
}

-(void)textFieldFinished:(id)sender
{
    [[KeyboardManager sharedManager]close];
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if( [self.inputField.text isEqualToString:@"$"] )
    {
        self.inputField.text = @"";
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
        NSString *text = ( value == 0 ) ? nil : [NSString stringWithFormat:format, value];
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
