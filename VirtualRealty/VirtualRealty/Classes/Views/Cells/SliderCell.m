//
//  SliderCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "UIColor+Extended.h"
#import "SliderCell.h"

@interface SliderCell()

-(void)handleSliderChanged:(id)sender;
@property(nonatomic, strong)UISlider *slider;
@end

@implementation SliderCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        self.slider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 300, 20)];
        [self.slider addTarget:self action:@selector(handleSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider setBackgroundColor:[UIColor clearColor ]];
        [self.slider setTintColor:[UIColor colorFromHex:@"00aeef"]];
        [self.slider setThumbTintColor:[UIColor colorFromHex:@"00aeef"]];
        
        [self.contentView addSubview:self.slider];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
 
    
    CGRect rect = self.slider.frame;
    rect.origin.x = self.contentView.frame.size.width * 0.5 - rect.size.width * 0.5;
    rect.origin.y = self.contentView.frame.size.height - (rect.size.height + 10);
    self.slider.frame = rect;
    
    rect = self.textLabel.frame;
    rect.origin.y = 20;
    self.textLabel.frame = rect;
    
    rect = self.detailTextLabel.frame;
    rect.origin.y = self.textLabel.frame.size.height + self.textLabel.frame.size.height;
    rect.origin.x = self.textLabel.frame.origin.x;
    self.detailTextLabel.frame = rect;
    
    [self.detailTextLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:12]];
    [self.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"00aeef"];
}

-(void)handleSliderChanged:(id)sender
{
    NSString *format  = self.cellinfo[@"format"];
    
    self.detailTextLabel.text = [NSString stringWithFormat:format, self.slider.value];
    self.formValue = [NSNumber numberWithFloat:self.slider.value];
    if( [self.formDelegate respondsToSelector:@selector(cell:didChangeForField:)] )
    {
        [self.formDelegate cell:self didChangeForField:[self.cellinfo[@"field"] intValue]];
    }
}

-(void)render
{
    self.slider.maximumValue = [self.cellinfo[@"max"] floatValue];
    self.slider.minimumValue = [self.cellinfo[@"min"] floatValue];
    self.textLabel.text = self.cellinfo[@"label"];
    
    NSString *format  = self.cellinfo[@"format"];
    
    if( self.cellinfo[@"current-value"])
    {
        self.detailTextLabel.text = [NSString stringWithFormat:format, [self.cellinfo[@"current-value"] floatValue]];
        self.slider.value =  [self.cellinfo[@"current-value"] floatValue];
    }
}

@end
