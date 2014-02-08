//
//  NeighborhoodCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 2/7/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//



#import "NeighborhoodCell.h"
#import "UIColor+Extended.h"

@interface NeighborhoodCell()

@property(nonatomic, strong)UILabel *subLabel;
@property(nonatomic, strong)UILabel *subDetailsLabel;

@end;

@implementation NeighborhoodCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self !=  nil )
    {
        self.subLabel        = [[UILabel alloc]initWithFrame:CGRectZero];
        self.subDetailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        
        self.subLabel.font        = [UIFont fontWithName:@"MuseoSans-500" size:16];
        self.subLabel.textColor   = [UIColor colorFromHex:@"434343"];
      
        self.subDetailsLabel.font = [UIFont fontWithName:@"MuseoSans-500" size:16];
        
        self.pickerFontSize = [NSNumber numberWithInt:12];
        [self.detailTextLabel setTextAlignment:NSTextAlignmentRight];
        
        [self.contentView addSubview:self.subLabel];
        [self.contentView addSubview:self.subDetailsLabel];
    }
    return self;
}

-(void)render
{
    [super render];
    self.picker.delegate = self;
    self.subLabel.text   = self.cellinfo[@"sub-label"];
    [self.subLabel sizeToFit];
    
    if( self.cellinfo[@"current-value"][@"borough"] )
    {
        self.detailTextLabel.text = self.cellinfo[@"current-value"][@"borough"];
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    }
    else
    {
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"aaaaaa"];
        self.detailTextLabel.text = self.cellinfo[@"placeholder"];
    }
    
    [self.textLabel sizeToFit];
    
    
    if( self.cellinfo[@"current-value"][@"neighborhood"] )
    {
        self.subDetailsLabel.text = self.cellinfo[@"current-value"][@"neighborhood"];
        self.subDetailsLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    }
    else
    {
        self.subDetailsLabel.text = self.cellinfo[@"sub-placeholder"];
        self.subDetailsLabel.textColor = [UIColor colorFromHex:@"aaaaaa"];
    }
    [self.subDetailsLabel sizeToFit];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGRect rect;
    rect  = self.textLabel.frame;
    rect.origin.y  = 38.0 * 0.5 - rect.size.height * 0.5;
    self.textLabel.frame = rect;
    
    rect = self.subLabel.frame;
    rect.origin.x = self.textLabel.frame.origin.x;
    rect.origin.y = 38.0f + ( 38.0 * 0.5 - rect.size.height * 0.5 );
    self.subLabel.frame = rect;
    
    float width = 300 - ( self.textLabel.frame.origin.x + self.textLabel.frame.size.width);
    rect = self.detailTextLabel.frame;
    
    rect.size.width = width;
    rect.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
    rect.origin.y = 38.0 * 0.5 - rect.size.height * 0.5;
    self.detailTextLabel.frame = rect;
    
    width = 300 - ( self.subLabel.frame.origin.x + self.subLabel.frame.size.width);
    rect.size.width = width;
    rect.origin.x = self.subLabel.frame.origin.x + self.subLabel.frame.size.width + 10;
    rect.origin.y = 38.0f + ( 38.0  * 0.5 - rect.size.height * 0.5 );
    self.subDetailsLabel.textAlignment = NSTextAlignmentRight; 
    self.subDetailsLabel.frame = rect;
    
    rect = self.picker.frame;
    rect.origin.y = 38.0 * 2;
    self.picker.frame = rect;
    
    rect = self.stroke.frame;
    rect.origin.y = self.picker.frame.size.height + self.picker.frame.origin.y - 1;
    self.stroke.frame = rect;
    self.topStroke.frame = CGRectMake(0, 38*2, 320, 1);
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int target;
    
    NSString *neighborhood;
    NSString *borough;
    
    switch (component) {
        case 0:
            target = [self.cellinfo[@"picker-targets"][row] intValue];
            [self.picker selectRow:target inComponent:1 animated:YES];
            break;
        case 1:
            [super clearError];
            [self.picker selectRow:[self.pickerData[component][row][@"comp-index"] intValue] inComponent:0 animated:YES];
            break;
        default:
            break;
    }

    neighborhood = self.pickerData[1][[self.picker selectedRowInComponent:1]][@"value"];
    borough      = self.pickerData[0][[self.picker selectedRowInComponent:0]][@"value"];
    
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    self.subDetailsLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    self.detailTextLabel.text = borough;
    self.subDetailsLabel.text = neighborhood;

    self.formValue = @{@"neighborhood" : neighborhood, @"borough" : borough };
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
    
    [super clearError];
}

-(void)setFocus
{
    NSString *neighborhood;
    NSString *borough;
    
    neighborhood = self.pickerData[1][0][@"value"];
    borough      = self.pickerData[0][0][@"value"];
    
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    self.subDetailsLabel.textColor = [UIColor colorFromHex:@"00aeef"];
    self.detailTextLabel.text = borough;
    self.subDetailsLabel.text = neighborhood;
    
    self.formValue = @{@"neighborhood" : neighborhood, @"borough" : borough };
    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
    
    [super clearError];
}

@end
