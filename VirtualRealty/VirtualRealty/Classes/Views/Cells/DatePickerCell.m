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
#import "DatePickerSource.h"
@interface DatePickerCell()<UIPickerViewDelegate, UIPickerViewDataSource>

@end;


@implementation DatePickerCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 162)];
        self.picker.dataSource = self;
        self.picker.delegate   = self;
        self.dataSource = [[DatePickerSource alloc]init];
        [self.contentView addSubview:self.picker];
        self.pickerFontSize = [NSNumber numberWithInt:14];
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
    
    rect = self.picker.frame;
    rect.origin.y = 38.0f;
    self.picker.frame = rect;
    
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
    
    if( self.cellinfo[@"current-value"] && [self.cellinfo[@"current-value"] isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]] == NO)
    {
        self.detailTextLabel.text      = [[self.cellinfo valueForKey:@"current-value"] toShortString];
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    }
    else
    {
        self.detailTextLabel.text = self.cellinfo[@"placeholder"];
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"aaaaaa"];
    }
    [self.picker reloadAllComponents];
}

#pragma mark - delegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CustomField *field;
    
    NSLog(@"%@", view);
    if( view )
    {
        field = (CustomField *)view;
        field.text = nil;
    }
    else
    {
        field = [[CustomField alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    switch (component)
    {
        case 0:
        {
            NSDictionary *year  = self.dataSource.source[0][row];
            field.backgroundColor = [UIColor clearColor];
            [field setTextColor:[UIColor colorFromHex:@"434343"]];
            [field setFont: [UIFont fontWithName:@"MuseoSans-500" size:[self.pickerFontSize intValue]]];
            field.text = year[@"label"];
        }
        break;
        case 1:
        {
            NSDictionary *month = self.dataSource.source[1][row];
            field.backgroundColor = [UIColor clearColor];
            [field setTextColor:[UIColor colorFromHex:@"434343"]];
            [field setFont: [UIFont fontWithName:@"MuseoSans-500" size:[self.pickerFontSize intValue]]];
            field.text = month[@"label"];
        }
        break;
        case 2:
        {
            NSDictionary *day   = self.dataSource.source[2][row];
            field.backgroundColor = [UIColor clearColor];
            [field setTextColor:[UIColor colorFromHex:@"434343"]];
            [field setFont: [UIFont fontWithName:@"MuseoSans-500" size:[self.pickerFontSize intValue]]];
            field.text = day[@"label"];
        }
        break;
    }

    [field sizeToFit];
    return field;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *label;
    switch (component)
    {
        case 0:
        {
            int selectedYear  = [self.picker selectedRowInComponent:0];
            NSDictionary *year  = self.dataSource.source[0][selectedYear];
            label = year[@"label"];
        }
            break;
        case 1:
        {
            int selectedMonth = [self.picker selectedRowInComponent:1];
            NSDictionary *month = self.dataSource.source[1][selectedMonth];
            label = month[@"label"];
        }
            break;
        case 2:
        {
            int selectedDay   = [self.picker selectedRowInComponent:2];
            NSDictionary *day   = self.dataSource.source[2][selectedDay];
            label = day[@"label"];
        }
        break;
    }
    return label;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.dataSource.source.count;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *comp = [self.dataSource.source objectAtIndex:component];
    return comp.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [super clearError];
    int y = 0;
    int m = 0;
    int d = 0;[self.dataSource.source[2][[self.picker selectedRowInComponent:2]][@"value"] intValue];
    
    
    switch (component)
    {
        case 0:
        {
            int selectedYear  = [self.dataSource.source[0][row][@"value"] intValue];
            NSDictionary *year  = self.dataSource.source[0][row];
            int month = [self.dataSource.source[1][[self.picker selectedRowInComponent:1]][@"value"] intValue];
            [self.dataSource.source replaceObjectAtIndex:2 withObject:[self.dataSource getDaysFormMonth:month inYear:selectedYear]];
            [self.picker reloadComponent:2];
            y = [self.dataSource.source[0][row][@"value"] intValue];
            m = [self.dataSource.source[1][[self.picker selectedRowInComponent:1]][@"value"] intValue] + 1;
            d = [self.dataSource.source[2][[self.picker selectedRowInComponent:2]][@"value"] intValue];
        }
        break;
        case 1:
        {
            int selectedMonth = [self.dataSource.source[1][row][@"value"] intValue];
            NSDictionary *month = self.dataSource.source[1][row];
            int year = [self.dataSource.source[0][[self.picker selectedRowInComponent:0]][@"value"] intValue];
            [self.dataSource.source replaceObjectAtIndex:2 withObject:[self.dataSource getDaysFormMonth:selectedMonth inYear:year]];
            [self.picker reloadComponent:2];
            y = [self.dataSource.source[0][[self.picker selectedRowInComponent:0]][@"value"] intValue];
            m = [self.dataSource.source[1][row][@"value"] intValue] + 1;
            d = [self.dataSource.source[2][[self.picker selectedRowInComponent:2]][@"value"] intValue];
        }
        break;
        case 2:
        {
            y = [self.dataSource.source[0][[self.picker selectedRowInComponent:0]][@"value"] intValue];
            m = [self.dataSource.source[1][[self.picker selectedRowInComponent:1]][@"value"] intValue] + 1;
            d = [self.dataSource.source[2][row][@"value"] intValue];
        }
        break;
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%i/%i/%i", m, d, y];
    NSDate   *date       = [NSDate fromShortString:dateString];
    self.formValue = date;
    
    self.detailTextLabel.text      = dateString;
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    [self.detailTextLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:16]];
    [self layoutSubviews];
    [super clearError];
    [self.formDelegate cell:self didChangeForField:[self.cellinfo[@"field"] intValue]];
}

-(id)valueForComponent:(int)compIndex
{
    int rowIndex  = [self.picker selectedRowInComponent:compIndex];
    NSDictionary *info = self.pickerData[compIndex][rowIndex];
    return info[@"value"];
}

-(void)setFocus
{
    unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit |  NSYearCalendarUnit;
    
    NSDate *date                = [NSDate date];
    NSCalendar *cal             = [NSCalendar currentCalendar];
    NSDateComponents *startComp = [cal components:unitFlags fromDate:date];
    
    int yearIndex = 0;
    int monthIndex = startComp.month -1;
    int dayIndex   = startComp.day -1;
    
    
    if(  [self.cellinfo[@"current-value"] isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]] == YES || self.cellinfo[@"current-value"] == nil )
    {
        self.formValue = nil;
        [self.picker selectRow:yearIndex  inComponent:0 animated:YES];
        [self.picker selectRow:monthIndex inComponent:1 animated:YES];
        [self.picker selectRow:dayIndex   inComponent:2 animated:YES];
    }
}



@end
