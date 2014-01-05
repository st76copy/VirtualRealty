//
//  PhoneInputCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "PhoneInputCell.h"
#import "UIColor+Extended.h"
#import "KeyboardManager.h"

@implementation PhoneInputCell

-(void)render
{
    self.imageView.image = [UIImage imageNamed:self.cellinfo[@"icon"]];
    self.textLabel.text         = [self.cellinfo valueForKey:@"label"];
    self.inputField.placeholder = [self.cellinfo valueForKey:@"placeholder"];
    

    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        self.inputField.text = [self.cellinfo valueForKey:@"current-value"];
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [super clearError];
 
    if( [string isEqualToString:@""] )
    {
        return YES;
    }
    
    switch (range.location) {
        case 3:
            self.inputField.text = [NSString stringWithFormat:@"%@-%@",self.inputField.text, string ];
            self.formValue = self.inputField.text;
            [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
            return NO;
            break;
        case 7:
            self.inputField.text = [NSString stringWithFormat:@"%@-%@",self.inputField.text, string ];
            self.formValue = self.inputField.text;
            [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
            return NO;
            break;
        case 12:
            self.formValue = self.inputField.text;
            [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
            return NO;
            break;
        default:
            self.formValue = [NSString stringWithFormat:@"%@%@",self.inputField.text, string ];
            [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
            return YES;
            break;
    }
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


@end
