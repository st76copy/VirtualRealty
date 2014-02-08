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
#import "CustomField.h"
#import <QuartzCore/QuartzCore.h>
@interface PickerInputCell()<UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation PickerInputCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 162)];
        self.picker.dataSource = self;
        self.picker.delegate   = self;
        self.pickerFontSize = [NSNumber numberWithInt:16];
        self.picker.clipsToBounds = YES;
        [self.contentView addSubview:self.picker];
   
        self.topStroke = [[UIView alloc]initWithFrame:CGRectMake(0, 38, 320, 1)];
        self.topStroke.backgroundColor = [UIColor colorFromHex:@"f3f3f3"];
        [self.contentView addSubview:self.topStroke];
        
        
        self.stroke = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
        self.stroke.backgroundColor = [UIColor colorFromHex:@"f3f3f3"];
        [self.contentView addSubview:self.stroke];
        self.clipsToBounds = YES;
        
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
 
    rect = self.stroke.frame;
    rect.origin.y = self.picker.frame.origin.y + self.picker.frame.size.height -1;
    self.stroke.frame = rect;
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
    self.pickerData = self.cellinfo[@"picker-data"];
    [self.picker reloadAllComponents];
}

#pragma mark - delegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CustomField *field = [[CustomField alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    field.backgroundColor = [UIColor clearColor];
    [field setTextColor:[UIColor colorFromHex:@"434343"]];
    [field setFont: [UIFont fontWithName:@"MuseoSans-500" size:[self.pickerFontSize intValue]]];
    NSArray *comp = [self.pickerData objectAtIndex:component];
    field.text = comp[row][@"label"];
    [field sizeToFit];
    return field;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *comp = [self.pickerData objectAtIndex:component];
    return comp[row][@"label"];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *comp = [self.pickerData objectAtIndex:component];
    return comp.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [super clearError];
    self.formValue = self.pickerData[component][row][@"value"];
    self.detailTextLabel.text      = self.formValue;
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    [self.detailTextLabel sizeToFit];
    [self layoutSubviews];
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
}

-(id)valueForComponent:(int)compIndex
{
    int rowIndex  = [self.picker selectedRowInComponent:compIndex];
    NSDictionary *info = self.pickerData[compIndex][rowIndex];
    return info[@"value"];
}

-(void)setFocus
{
    [super clearError];
    self.formValue = self.pickerData[0][[self.picker selectedRowInComponent:0]][@"value"];
    self.detailTextLabel.text      = self.formValue;
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    [self.detailTextLabel sizeToFit];
}


@end
