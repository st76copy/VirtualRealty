//
//  ListingStateView.m
//  VirtualRealty
//
//  Created by christopher shanley on 1/5/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "ListingStateView.h"
#import "UIColor+Extended.h"

@implementation ListingStateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
      
        label = [[UILabel alloc]initWithFrame:CGRectZero];
        bg    = [[UIView alloc]initWithFrame:CGRectZero];
        imageView = [[UIImageView alloc]init];
        [self addSubview:bg];
        [self addSubview:label];
        [self addSubview:imageView];
    
    }
    return self;
}

-(void)setState:(ListingState)state
{
    
    [label setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    [label setTextColor:[UIColor whiteColor]];
    
    bg.frame = CGRectZero;
    imageView.frame = CGRectZero;
    label.frame = CGRectZero;
    
    switch (state)
    {
        case kPending:
            stateName = @"Pending";
            color     = [UIColor colorFromHex:@"d46e14"];
            wedge     = [UIImage imageNamed:@"pending-wedge.png"];
            break;
        case kVacant:
            stateName = @"Vacent";
            color     = [UIColor colorFromHex:@"e6e6e6"];
            label.textColor = [UIColor colorFromHex:@"303030"];
            wedge     = [UIImage imageNamed:@"vacent-wedge.png"];
            break;
        case kRented:
            stateName = @"Rented";
            color     = [UIColor colorFromHex:@"00aeef"];
            wedge     = [UIImage imageNamed:@"rigth-wedge.png"];
            break;
            
    }
    
    imageView.image = wedge;
    [imageView sizeToFit];
    
    label.text = stateName;
    [label sizeToFit];
    
    CGRect rect = label.frame;
    rect.size.width += 10;
    rect.size.height += 10;
    bg.frame = rect;
    
    rect = label.frame;
    rect.origin.x = 5;
    rect.origin.y = 5;
    label.frame = rect;
    
    rect = imageView.frame;
    rect.origin.x = bg.frame.size.width;
    rect.size.height = bg.frame.size.height;
    imageView.frame = rect;
    
    self.frame = CGRectMake(0, 0, imageView.frame.size.width + imageView.frame.origin.x, bg.frame.size.height);
    
    bg.backgroundColor = color;
}
@end
