//
//  PriceView.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/26/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "PriceView.h"
#import "UIColor+Extended.h"
@implementation PriceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
    }
    return self;
}


-(void)setPrice:(float)value
{
    
    UIImage *wedge = [UIImage imageNamed:@"left-wedge.png"];
    
    UIImageView *triangle = [[UIImageView alloc]initWithImage:wedge];
    [self addSubview:triangle];
    
    UIView *bg = [[UIView alloc]initWithFrame:CGRectZero];
    [bg setBackgroundColor:[UIColor colorFromHex:@"01aef0"]];
    
    [self addSubview:bg];
    
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    priceLabel.textColor = [UIColor whiteColor];
    priceLabel.text = [NSString stringWithFormat:@"$%i", (int)value];
    [priceLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    [priceLabel sizeToFit];
    [self addSubview:priceLabel];
    
    CGRect rect = priceLabel.frame;
    rect.size.width += 10;
    rect.size.height = triangle.frame.size.height;
    rect.origin.x = triangle.frame.size.width;
    bg.frame = rect;
    
    rect = priceLabel.frame;
    rect.origin.y = 5;
    rect.origin.x = bg.frame.origin.x + 5;
    priceLabel.frame = rect;
    
    CGRect fr = CGRectZero;
    fr.size.width = triangle.frame.size.width + bg.frame.size.width;
    fr.size.height = triangle.frame.size.height;
    self.frame = fr;
}



@end
