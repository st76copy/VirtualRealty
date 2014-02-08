//
//  DatePickerCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 2/8/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "DatePickerCell.h"
#import "UIColor+Extended.h"
#import "CustomField.h"
#import "NSDate+Extended.h"

@interface DatePickerCell()<UIPickerViewDelegate>

@end;


@implementation DatePickerCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 320, 162)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;

        [self.datePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.datePicker];
        self.datePicker.date = [NSDate date];
    }
    return  self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect;
    rect  = self.textLabel.frame;
    rect.origin.y  = 38.0 * 0.5 - rect.size.height * 0.5;
    self.textLabel.frame = rect;
    
    float width = 300 - ( self.textLabel.frame.origin.x + self.textLabel.frame.size.width);
    rect = self.detailTextLabel.frame;
    
    rect.size.width = width;
    rect.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
    rect.origin.y = 38.0 * 0.5 - rect.size.height * 0.5;
    self.detailTextLabel.frame = rect;
    
    [self.detailTextLabel setTextAlignment:NSTextAlignmentRight];
    
    rect = self.datePicker.frame;
    rect.origin.y = 38.0f;
    self.datePicker.frame = rect;
    
    rect = self.imageView.frame;
    rect.origin.y = 38.0f * 0.5 - rect.size.height * 0.5;
    self.imageView.frame = rect;
}

-(void)changeDateInLabel:(id)sender
{
    self.formValue = self.datePicker.date;
    self.detailTextLabel.text      = [self.datePicker.date toShortString];
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    [self.detailTextLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:16]];
    [self.detailTextLabel sizeToFit];
    [super clearError];
    [self.formDelegate cell:self didChangeForField:[self.cellinfo[@"field"] intValue]];
}

-(void)layoutIfNeeded
{
    [super layoutIfNeeded];
}

-(void)render
{
    [super render];
    
    self.backgroundView       = nil;
    self.textLabel.text       = [self.cellinfo valueForKey:@"label"];
    
    if( [self.cellinfo[@"current-value"] isKindOfClass:[NSString class]])
    {
        if( self.cellinfo[@"current-value"] )
        {
            self.detailTextLabel.text      = [self.cellinfo valueForKey:@"current-value"];
            self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
        }
        else
        {
            self.detailTextLabel.text = self.cellinfo[@"placeholder"];
            self.detailTextLabel.textColor = [UIColor colorFromHex:@"aaaaaa"];
        }
    }
    else
    {
        self.detailTextLabel.text = self.cellinfo[@"placeholder"];
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"aaaaaa"];
    }
    
    [self.detailTextLabel sizeToFit];
}

#pragma mark - delegate



@end
