//
//  MapPriceTag.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/27/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MapPriceTag.h"
#import "UIColor+Extended.h"
#import <QuartzCore/QuartzCore.h>

@implementation MapPriceTag

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    priceLabel.font = [UIFont systemFontOfSize:14];
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
    
    UIImage *bottomWedge = [UIImage imageNamed:@"bottom-wedge.png"];
    UIImageView *bottomWedgeView = [[UIImageView alloc]initWithImage:bottomWedge];
    
    rect = bottomWedgeView.frame;
    rect.origin.x = bg.frame.origin.x + bg.frame.size.width - rect.size.width;
    rect.origin.y = bg.frame.size.height;
    bottomWedgeView.frame = rect;
    [self addSubview:bottomWedgeView];
    
    CGRect fr = CGRectZero;
    fr.size.width = triangle.frame.size.width + bg.frame.size.width;
    fr.size.height = bottomWedgeView.frame.origin.y + bottomWedgeView.frame.size.height;
    self.backgroundColor = [UIColor clearColor];
    self.frame = fr;
    
    
}

-(UIImage *) toBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}


@end
