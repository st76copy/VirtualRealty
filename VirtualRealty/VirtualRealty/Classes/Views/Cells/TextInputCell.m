//
//  TextInputCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//
#import "UIColor+Extended.h"
#import "TextInputCell.h"
#import "KeyboardManager.h"
@implementation TextInputCell

@synthesize inputField = _inputField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _inputField = [[CustomField alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        self.inputField.backgroundColor = [UIColor clearColor];
        self.inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.inputField.textAlignment  = NSTextAlignmentRight;
        self.inputField.returnKeyType  = UIReturnKeyDone;
        self.inputField.delegate       = self;
        [self.inputField addTarget:self  action:@selector(inputFieldBegan:) forControlEvents:UIControlEventEditingDidBegin];
        [self.inputField addTarget:self  action:@selector(inputTextChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.inputField addTarget:self  action:@selector(textFieldFinished:)  forControlEvents:UIControlEventEditingDidEndOnExit];
        [self.inputField setFont: [UIFont fontWithName:@"MuseoSans-500" size:16]];
        selectableText = YES;
        [self.contentView addSubview:self.inputField];
        self.maxCharacters = -1;
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.backgroundView setBackgroundColor:[UIColor whiteColor]];

    [self.textLabel sizeToFit];
    CGRect rect = self.textLabel.frame;
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.textLabel.textColor = [UIColor colorFromHex:@"434343"];
    self.textLabel.frame = rect;
    
    float width = 300 - ( self.textLabel.frame.origin.x + self.textLabel.frame.size.width);

    self.inputField.frame = rect;
    self.inputField.textColor = [UIColor colorFromHex:@"00aeef"];
    self.inputField.delegate = self;

    
    rect = self.inputField.frame;
    rect.size.width = width;
    rect.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.inputField.frame = rect;
    [self.contentView bringSubviewToFront:self.inputField];
}

-(void)render
{
    [super render];
     self.inputField.userInteractionEnabled = NO;
    
    [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
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
    
    if( [[self.cellinfo valueForKey:@"read-only"] boolValue ] )
    {
        self.inputField.textColor = [UIColor colorFromHex:@"00aeef"];
        self.inputField.userInteractionEnabled = NO;
    }
    
    if( [[self.cellinfo valueForKey:@"is-secure"] boolValue])
    {
        self.inputField.secureTextEntry = YES;
    }
    
    if( self.cellinfo[@"keyboard-type"] )
    {
        self.inputField.keyboardType = [self.cellinfo[@"keyboard-type"] intValue];
    }
    
    if( self.cellinfo[@"max-characters"] )
    {
        self.maxCharacters = [self.cellinfo[@"max-characters"] intValue];
    }
}

-(void)inputTextChanged:(id)sender
{
    [super clearError];
    self.formValue = self.inputField.text;
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
}

-(void)textFieldFinished:(id)sender
{
    [[KeyboardManager sharedManager]close];
    if( [self.formDelegate respondsToSelector:@selector(cell:didPressDone:)] )
    {
        self.formValue = self.inputField.text;
        [self.formDelegate cell:self didPressDone:[[self.cellinfo valueForKey:@"field"]intValue] ];
    }
}

-(void)inputFieldBegan:(id)sender
{
    if( self.selected || [KeyboardManager sharedManager].textfieldInFocus == self.inputField )
    {
        return;
    }
    
    if([self.formDelegate respondsToSelector:@selector(cell:didStartInteract:)] )
    {
       // [[KeyboardManager sharedManager] setTextfieldInFocus:(UITextField *)self.inputField];
        [self.formDelegate cell:self didStartInteract:[[self.cellinfo valueForKey:@"field"]intValue]];
    }
}

-(void)killFocus
{
    self.inputField.userInteractionEnabled = NO;
    [[KeyboardManager sharedManager]close];
}

-(void)setFocus
{
    self.inputField.userInteractionEnabled = YES;
    [[KeyboardManager sharedManager]showWithFocusField:(UITextField *)self.inputField];
}
@end
